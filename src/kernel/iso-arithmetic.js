// ISO arithmetic evaluation and comparison semantics.
// Integers are unbounded; floats are IEEE-754 doubles. Integer results never
// pass through a double, so exactness survives the whole evaluation.
import {
  ATOM, COMPOUND, NUMBER, VAR, atom, compound, deref, isDecimalInteger,
  numberTerm, numberTextFromDouble,
} from './term.js';
import { PrologError } from './errors.js';

function integerResource(operation) {
  try {
    return operation();
  } catch (error) {
    // Integer operations have no language-level numeric representation bound.
    // A finite host can nevertheless exhaust storage (V8 reports oversized
    // BigInt powers/shifts as RangeError). Keep that implementation resource
    // boundary inside the ISO error model.
    if (error?.name === 'RangeError') throw new PrologError('resource_error(memory)');
    throw error;
  }
}

const integerValue = (value) => ({ integer: true, value });
const floatValue = (value) => ({ integer: false, value });

const UNARY_FUNCTIONS = new Set([
  'abs', 'sign', 'float', 'truncate', 'round', 'ceiling', 'floor',
  'float_integer_part', 'float_fractional_part',
  'sin', 'cos', 'atan', 'asin', 'acos', 'tan', 'exp', 'log', 'sqrt',
]);
const INTEGER_ONLY = new Set(['//', 'div', 'mod', 'rem', '/\\', '\\/', 'xor', '<<', '>>']);
// Rounding an integer is the identity. Going through a double would silently
// lose the exactness the unbounded integer type exists to provide.
const INTEGER_ROUNDINGS = new Set(['truncate', 'round', 'ceiling', 'floor']);

export function evaluateArithmetic(term, env) {
  term = deref(term, env);
  if (term.type === VAR) throw new PrologError('instantiation_error');
  if (term.type === NUMBER) {
    if (isDecimalInteger(term.name)) return integerValue(BigInt(term.name));
    const value = Number(term.name);
    if (!Number.isFinite(value)) throw new PrologError('evaluation_error(float_overflow)');
    return floatValue(value);
  }
  if (term.type === ATOM) {
    if (term.name === 'pi') return floatValue(Math.PI);
    if (term.name === 'e') return floatValue(Math.E);
    throw new PrologError('type_error(evaluable)', compound('/', [atom(term.name), numberTerm(0)]));
  }
  if (term.type !== COMPOUND) throw new PrologError('type_error(evaluable)', term);
  return evaluateOperation(term, term.args.map((arg) => evaluateArithmetic(arg, env)));
}

function evaluateOperation(term, args) {
  const name = term.name;
  const arity = term.arity;
  if (arity === 1 && (name === '+' || name === '-')) {
    return name === '+' ? args[0] : { integer: args[0].integer, value: -args[0].value };
  }
  if (arity === 1 && name === '\\') {
    if (!args[0].integer) throw new PrologError('type_error(integer)', arithmeticValueTerm(args[0]));
    return integerValue(~args[0].value);
  }
  if (arity === 1 && UNARY_FUNCTIONS.has(name)) {
    if (args[0].integer) {
      if (name === 'abs') return integerValue(args[0].value < 0n ? -args[0].value : args[0].value);
      if (name === 'sign') return integerValue(args[0].value < 0n ? -1n : args[0].value > 0n ? 1n : 0n);
      if (INTEGER_ROUNDINGS.has(name)) return args[0];
      if (name === 'float_integer_part' || name === 'float_fractional_part') {
        throw new PrologError('type_error(float)', arithmeticValueTerm(args[0]));
      }
    }
    const a = Number(args[0].value);
    if (INTEGER_ROUNDINGS.has(name)) {
      // round/1 breaks ties away from zero, like every other Prolog; JavaScript
      // Math.round breaks them towards positive infinity.
      const rounded = name === 'truncate' ? Math.trunc(a)
        : name === 'ceiling' ? Math.ceil(a)
          : name === 'floor' ? Math.floor(a)
            : a < 0 ? -Math.round(-a) : Math.round(a);
      return integerValue(BigInt(rounded));
    }
    if (name === 'float_integer_part') return floatValue(Math.trunc(a));
    if (name === 'float_fractional_part') return floatValue(a - Math.trunc(a));
    const fn = name === 'float' ? (x) => x : name === 'abs' ? Math.abs : name === 'sign' ? Math.sign : Math[name];
    const value = fn(a);
    if (Number.isNaN(value) || (name === 'log' && a === 0)) throw new PrologError('evaluation_error(undefined)');
    if (!Number.isFinite(value)) throw new PrologError('evaluation_error(float_overflow)');
    return floatValue(value);
  }
  if (arity !== 2) throw new PrologError('type_error(evaluable)', compound('/', [atom(name), numberTerm(arity)]));
  const bothInteger = args[0].integer && args[1].integer;
  const a = args[0].value, b = args[1].value;
  if ((name === 'gcd' || INTEGER_ONLY.has(name)) && !bothInteger) {
    throw new PrologError('type_error(integer)', arithmeticValueTerm(args[0].integer ? args[1] : args[0]));
  }
  if (bothInteger) {
    if (name === 'gcd') {
      return integerValue(integerResource(() => {
        let x = a < 0n ? -a : a;
        let y = b < 0n ? -b : b;
        while (y !== 0n) [x, y] = [y, x % y];
        return x;
      }));
    }
    if (name === '^') {
      if (b >= 0n) return integerValue(integerResource(() => a ** b));
      if (a === 0n) throw new PrologError('evaluation_error(undefined)');
      if (a === 1n) return integerValue(1n);
      if (a === -1n) return integerValue((-b) % 2n === 0n ? 1n : -1n);
      // Corrigendum 3: the defined real result needs a floating-point base.
      throw new PrologError('type_error(float)', arithmeticValueTerm(args[0]));
    }
    if (b === 0n && ['/', '//', 'div', 'mod', 'rem'].includes(name)) {
      throw new PrologError('evaluation_error(zero_divisor)');
    }
    // ISO 9.1.7 gives '/'(I, I) an integer result when the division is exact;
    // an inexact one falls through to the float template below.
    if (name === '/' && a % b === 0n) return integerValue(integerResource(() => a / b));
    if (name === '+') return integerValue(integerResource(() => a + b));
    if (name === '-') return integerValue(integerResource(() => a - b));
    if (name === '*') return integerValue(integerResource(() => a * b));
    if (name === '//') return integerValue(integerResource(() => a / b));
    if (name === 'div') {
      return integerValue(integerResource(() => {
        const quotient = a / b;
        return a % b !== 0n && ((a < 0n) !== (b < 0n)) ? quotient - 1n : quotient;
      }));
    }
    if (name === 'rem') return integerValue(integerResource(() => a % b));
    if (name === 'mod') return integerValue(integerResource(() => ((a % b) + b) % b));
    if (name === '/\\') return integerValue(integerResource(() => a & b));
    if (name === '\\/') return integerValue(integerResource(() => a | b));
    if (name === 'xor') return integerValue(integerResource(() => a ^ b));
    if (name === '<<') return integerValue(integerResource(() => a << b));
    if (name === '>>') return integerValue(integerResource(() => a >> b));
  }
  // Power has prescribed exceptional conditions that depend on the evaluated
  // operand values and therefore precede any I->F conversion needed by the
  // selected floating template.
  if ((name === '**' || name === '^') &&
      (args[0].integer ? a === 0n : a === 0) && (args[1].integer ? b < 0n : b < 0)) {
    throw new PrologError('evaluation_error(undefined)');
  }
  if (name === 'max' || name === 'min') {
    const cmp = compareArithmeticValues(args[0], args[1]);
    return (name === 'max' ? cmp >= 0 : cmp <= 0) ? args[0] : args[1];
  }
  const x = Number(a), y = Number(b);
  if (!Number.isFinite(x) || !Number.isFinite(y)) throw new PrologError('evaluation_error(float_overflow)');
  if (name === '/' && y === 0) throw new PrologError('evaluation_error(zero_divisor)');
  let value;
  if (name === 'atan2') {
    if (x === 0 && y === 0) throw new PrologError('evaluation_error(undefined)');
    value = Math.atan2(x, y);
  } else if (name === '+') value = x + y;
  else if (name === '-') value = x - y;
  else if (name === '*') value = x * y;
  else if (name === '/') value = x / y;
  else if (name === '**' || name === '^') value = Math.pow(x, y);
  else throw new PrologError('type_error(evaluable)', compound('/', [atom(name), numberTerm(arity)]));
  if (Number.isNaN(value)) throw new PrologError('evaluation_error(undefined)');
  if (!Number.isFinite(value)) throw new PrologError('evaluation_error(float_overflow)');
  return floatValue(value);
}

export function arithmeticValueTerm(value) {
  return value.integer ? numberTerm(value.value.toString()) : numberTerm(numberTextFromDouble(value.value));
}

function compareIntegerToFloat(integer, float) {
  if (!Number.isFinite(float)) throw new PrologError('evaluation_error(float_overflow)');
  // Do not round an unbounded integer through a JavaScript Number before a
  // mixed comparison. Every integral IEEE-754 double converts back to the exact
  // integer it represents, and fractional doubles necessarily have magnitude
  // below 2^53, so truncating them is exact too. This preserves mathematical
  // ordering across the I/F boundary, e.g. 9007199254740993 > 9007199254740992.0.
  if (Number.isInteger(float)) {
    const exact = BigInt(float);
    return integer < exact ? -1 : integer > exact ? 1 : 0;
  }
  const truncated = BigInt(Math.trunc(float));
  if (integer < truncated) return -1;
  if (integer > truncated) return 1;
  return float > 0 ? -1 : 1;
}

export function compareArithmeticValues(left, right) {
  const a = left.value;
  const b = right.value;
  if (left.integer && right.integer) return a < b ? -1 : a > b ? 1 : 0;
  if (left.integer) return compareIntegerToFloat(a, b);
  if (right.integer) return -compareIntegerToFloat(b, a);
  return a < b ? -1 : a > b ? 1 : 0;
}
