// Tokenizer and recursive-descent parser for the eyel source language.
// It reads ISO term syntax over a fixed operator table and produces Term
// objects for the solver. The operator table is fixed because eyel has no
// directives: `op/3`, `set_prolog_flag/2` and `char_conversion/2` would be the
// only ways to change parsing, and a program that uses one is rejected by the
// language profile rather than parsed differently.
import {
  ATOM, COMPOUND, atom, compound, cons, emptyList, numberTerm, numberTextFromDouble, variable,
} from './term.js';
import { isTerminatingFullStop } from './syntax-scan.js';

class NumberRepresentationError extends Error {
  constructor(formal) {
    super(`error(${formal})`);
    this.name = 'NumberRepresentationError';
    this.formal = formal;
  }
}

function finiteFloatTokenText(text) {
  const value = Number(text);
  if (!Number.isFinite(value)) {
    throw new NumberRepresentationError(String(text).startsWith('-')
      ? 'representation_error(min_float)'
      : 'representation_error(max_float)');
  }
  return numberTextFromDouble(value);
}

const TOK = {
  EOF: 'eof', ATOM: 'atom', VAR: 'var', STRING: 'string', NUMBER: 'number',
  LPAREN: '(', RPAREN: ')', LBRACKET: '[', RBRACKET: ']', LBRACE: '{', RBRACE: '}',
  COMMA: ',', BAR: '|', DOT: '.', IF: ':-'
};

function isWhitespaceCode(code) {
  return (code >= 0 && code <= 32) || code === 127;
}

function isWhitespaceCharacter(character) {
  if (!character) return false;
  const code = character.charCodeAt(0);
  // Deciding ASCII by code keeps the Unicode property escapes off the scan's
  // hot path, where nearly every character is ASCII.
  if (code <= 0x7f) return isWhitespaceCode(code);
  return /\p{White_Space}/u.test(character);
}

function isUnicodeUpperCharacter(character) {
  return Boolean(character) && /[\p{Lu}\p{Lt}]/u.test(character);
}

function isUnicodeLetterCharacter(character) {
  return Boolean(character) && /\p{L}/u.test(character);
}

function isUnicodeNameContinueCharacter(character) {
  return Boolean(character) && /[\p{L}\p{M}\p{Nd}]/u.test(character);
}

function isDigitCode(code) {
  return code >= 48 && code <= 57;
}

function isNameContinueCharacter(character) {
  if (!character) return false;
  const code = character.charCodeAt(0);
  if (code === 95 || (code >= 48 && code <= 57) ||
      (code >= 65 && code <= 90) || (code >= 97 && code <= 122)) return true;
  return code > 0x7f && isUnicodeNameContinueCharacter(character);
}

function isVariableStartCharacter(character) {
  if (!character) return false;
  const code = character.charCodeAt(0);
  if (code === 95 || (code >= 65 && code <= 90)) return true;
  return code > 0x7f && isUnicodeUpperCharacter(character);
}

function isPlainAtomStartCharacter(character) {
  if (!character) return false;
  const code = character.charCodeAt(0);
  if (code >= 97 && code <= 122) return true;
  return code > 0x7f && isUnicodeLetterCharacter(character) && !isUnicodeUpperCharacter(character);
}

const graphicAtomChars = '#$&*+-./<=>?@^~\\:';

// ISO operator syntax is lowered to the same ordinary compound terms used by
// canonical notation. Commas remain separators except inside parentheses.
// Precedence here is operator strength, 1201 minus the ISO priority, so a
// tighter-binding operator has the larger number.
const strength = (priority) => 1201 - priority;
const infixOperator = (priority, specifier) => ({
  precedence: strength(priority),
  associativity: specifier === 'xfy' ? 'right' : specifier === 'yfx' ? 'left' : 'none',
});
const INFIX_OPERATORS = new Map([
  [':-', infixOperator(1200, 'xfx')],
  ['-->', infixOperator(1200, 'xfx')],
  // The eyel forward-rule extension. A top-level Conclusion :+ Premise is
  // evaluated to a fixpoint by the forward solver.
  [':+', infixOperator(1200, 'xfx')],
  // Part 1 reserves `|` as list punctuation but permits a program to read it
  // as an infix operator at priority 1001 or greater (Corrigendum 2).
  ['|', infixOperator(1105, 'xfy')],
  [';', infixOperator(1100, 'xfy')],
  ['->', infixOperator(1050, 'xfy')],
  [',', infixOperator(1000, 'xfy')],
  ...['=', '=..', '\\=', '==', '\\==', '@<', '@=<', '@>', '@>=', 'is',
    '=:=', '=\\=', '<', '=<', '>', '>='].map((name) => [name, infixOperator(700, 'xfx')]),
  // Part 2 writes module qualification this way. eyel has no modules, but
  // `:` remains ordinary term syntax in a data position.
  [':', infixOperator(600, 'xfy')],
  ...['+', '-', '/\\', '\\/'].map((name) => [name, infixOperator(500, 'yfx')]),
  ...['*', '/', '//', 'div', 'mod', 'rem', '<<', '>>'].map((name) => [name, infixOperator(400, 'yfx')]),
  ['**', infixOperator(200, 'xfx')],
  ['^', infixOperator(200, 'xfy')],
]);
const PREFIX_OPERATORS = new Map([
  // ISO Table 7 declares `:-` both as xfx 1200 and as fx 1200, exactly like
  // `?-` below it. The prefix reading only becomes reachable where priority
  // 1200 is, which at term level means inside parentheses or braces: program
  // directives never reach here, because parseProgram consumes their `:-`
  // itself before parsing the term.
  [':-', { precedence: strength(1200), strict: true }],
  ['?-', { precedence: strength(1200), strict: true }],
  ['\\+', { precedence: strength(900), strict: false }],
  ['+', { precedence: strength(200), strict: false }],
  ['-', { precedence: strength(200), strict: false }],
  ['\\', { precedence: strength(200), strict: false }],
]);

// ISO 6.3.3 arguments have maximum priority 999. Parenthesized terms and
// curly-bracket contents may contain a full priority-1200 term instead.
const ARG_MIN_PRECEDENCE = strength(999);
// Priority-1200 operators are the ones a clause may be built around.
const NECK_PRECEDENCE = strength(1200) + 2;

function isGraphicAtomCharacter(character) {
  if (!character) return false;
  const code = character.charCodeAt(0);
  if (graphicAtomChars.includes(character)) return true;
  if (code <= 0x7f || isWhitespaceCharacter(character) ||
      isUnicodeNameContinueCharacter(character)) return false;
  // Non-ASCII symbols/punctuation are eyel extended graphic characters.
  // Surrogate code units are kept together by the maximal-token scan, so a
  // supplementary scalar remains one atom spelling even though source offsets
  // are UTF-16 based.
  return true;
}

const RE_OCTAL_DIGIT = /^[0-7]$/;
const RE_HEX_DIGIT = /^[0-9A-Fa-f]$/;
const RE_DECIMAL_DIGIT = /^[0-9]$/;
const RE_BINARY_DIGIT = /^[01]$/;
const RE_DECIMAL_INTEGER = /^-?\d+$/;

function digitPatternForRadix(radix) {
  return radix === 2 ? RE_BINARY_DIGIT : radix === 8 ? RE_OCTAL_DIGIT : RE_HEX_DIGIT;
}

// Symbolic control-character escapes shared by quoted-token reading and
// character-code constants (ISO 6.4.2.1).
const ESCAPE_CONTROL_CHARACTERS = { a: '\x07', b: '\b', r: '\r', f: '\f', t: '\t', n: '\n', v: '\v' };

// ISO 6.4.2.1 numeric escapes name a character, so a value outside Unicode --
// or inside the UTF-16 surrogate range, which names no character on its own --
// is a syntax error rather than a representable code point.
function isCodePointOutOfRange(code) {
  return code > 0x10ffff || (code >= 0xd800 && code <= 0xdfff);
}

// Negate an already-scanned number token. The token text is canonical, so the
// result canonicalizes the same way every other numeric literal does; in
// particular -0 and -0.0 collapse to 0 and 0.0 rather than keeping a spelling
// that compares as zero but does not print as one.
function negatedNumberTerm(value) {
  return RE_DECIMAL_INTEGER.test(value)
    ? numberTerm(BigInt(`-${value}`).toString())
    : numberTerm(numberTextFromDouble(-Number(value)));
}

class Parser {
  constructor(source) {
    this.source = String(source ?? '');
    this.pos = 0;
    this.line = 1;
    this.anonymous = 0;
    this.variables = new Map();
    this.previousToken = null;
    this.token = this.nextToken();
  }
  peek(offset = 0) {
    return this.source[this.pos + offset] ?? '';
  }
  take() {
    const ch = this.peek();
    if (ch) {
      this.pos++;
      if (ch === '\n') this.line++;
    }
    return ch;
  }
  terminatingFullStop(index = this.pos) {
    return isTerminatingFullStop(this.source, index);
  }
  operatorTokenName(token = this.token) {
    if (token.type === TOK.ATOM) return token.text;
    // `:-` has its own token because it also introduces clauses and
    // directives, but ISO 6.3.3.1 still permits an operator atom as an
    // argument. Treat the token as the ordinary operator name while parsing
    // terms; the surrounding grammar decides whether it is operator notation
    // or atom data.
    if (token.type === TOK.IF) return ':-';
    return null;
  }
  skipWhitespaceAndComments() {
    while (true) {
      while (this.peek() && isWhitespaceCharacter(this.peek())) this.take();
      if (this.peek() === '%') {
        while (this.peek() && this.peek() !== '\n') this.take();
        continue;
      }
      if (this.peek() === '/' && this.peek(1) === '*') {
        const line = this.line;
        this.take();
        this.take();
        while (this.peek() && !(this.peek() === '*' && this.peek(1) === '/')) this.take();
        if (!this.peek()) throw new Error(`parse line ${line}: unterminated block comment`);
        this.take();
        this.take();
        continue;
      }
      break;
    }
  }
  integerDigits(digitPattern, line) {
    let digits = '';
    let separated = false;
    while (digitPattern.test(this.peek())) {
      digits += this.take();
      if (this.peek() !== '_') continue;
      separated = true;
      this.take();
      this.skipWhitespaceAndComments();
      if (!digitPattern.test(this.peek())) {
        throw new Error(`parse line ${line}: bad digit separator`);
      }
    }
    return { digits, separated };
  }
  readEscape(line, allowContinuation = true) {
    const escaped = this.take();
    if (!escaped) throw new Error(`parse line ${line}: unterminated escape sequence`);

    // ISO 6.4.2 permits a continuation escape only inside quoted tokens: a
    // backslash immediately followed by a newline. Character-code constants
    // use a single quoted character and therefore cannot use continuation.
    if (escaped === '\n') {
      if (allowContinuation) return '';
      throw new Error(`parse line ${line}: bad escape sequence`);
    }
    if (escaped === '\r' && this.peek() === '\n') {
      if (!allowContinuation) throw new Error(`parse line ${line}: bad escape sequence`);
      this.take();
      return '';
    }

    if (ESCAPE_CONTROL_CHARACTERS[escaped] != null) return ESCAPE_CONTROL_CHARACTERS[escaped];

    if (escaped === 'x' || RE_OCTAL_DIGIT.test(escaped)) {
      const hexadecimal = escaped === 'x';
      const pattern = hexadecimal ? RE_HEX_DIGIT : RE_OCTAL_DIGIT;
      let digits = hexadecimal ? '' : escaped;
      while (pattern.test(this.peek())) digits += this.take();
      const kind = hexadecimal ? 'hexadecimal' : 'octal';
      if (!digits || this.take() !== '\\') throw new Error(`parse line ${line}: bad ${kind} escape`);
      const code = Number.parseInt(digits, hexadecimal ? 16 : 8);
      if (isCodePointOutOfRange(code)) throw new Error(`parse line ${line}: character escape out of range`);
      return String.fromCodePoint(code);
    }
    // A backslash followed by a decimal digit is numeric-escape syntax, but
    // ISO octal digits are limited to 0..7.  Do not reinterpret \8 or \9 as
    // implementation-specific one-character escapes.
    if (RE_DECIMAL_DIGIT.test(escaped)) throw new Error(`parse line ${line}: bad octal escape`);

    // The only remaining ISO meta escapes are the four meta characters from
    // 6.5.5.  Forms such as \c, \d, \e, \u or \. are not quoted
    // characters in ISO syntax and must not be silently accepted.
    if (escaped === '\\' || escaped === "'" || escaped === '"' || escaped === '`') return escaped;
    throw new Error(`parse line ${line}: bad escape sequence`);
  }
  characterCodeConstant(line, negative) {
    this.take();
    this.take();
    let value = this.take();
    if (value) {
      const firstCode = value.charCodeAt(0);
      if (firstCode >= 0xd800 && firstCode <= 0xdbff) {
        const secondCode = this.peek().charCodeAt(0);
        if (secondCode < 0xdc00 || secondCode > 0xdfff) {
          throw new Error(`parse line ${line}: bad character code constant`);
        }
        value += this.take();
      } else if (firstCode >= 0xdc00 && firstCode <= 0xdfff) {
        throw new Error(`parse line ${line}: bad character code constant`);
      }
    }
    if (!value || (value !== ' ' && isWhitespaceCode(value.charCodeAt(0)))) {
      throw new Error(`parse line ${line}: bad character code constant`);
    }
    if (value === "'") {
      // In the single-quoted-character notation used after 0', an apostrophe
      // is doubled just as it is inside a quoted atom. Thus 0''' is one
      // numeric token denoting character code 39, while the undoubled 0'' is
      // not a complete single quoted character.
      if (this.peek() !== "'") throw new Error(`parse line ${line}: bad character code constant`);
      this.take();
    } else if (value === '\\') {
      value = this.readEscape(line, false);
    }
    const code = value.codePointAt(0);
    return { type: TOK.NUMBER, text: String(negative ? -code : code), line };
  }
  quotedToken(line) {
    const quote = this.take();
    let text = '';
    while (true) {
      if (!this.peek()) throw new Error(`parse line ${line}: unterminated quoted term`);
      let value = this.take();
      if (value === quote) {
        if (this.peek() !== quote) break;
        this.take();
        value = quote;
      } else if (value === '\\' && this.peek()) {
        value = this.readEscape(line);
      } else if (value !== ' ' && isWhitespaceCode(value.charCodeAt(0))) {
        // ISO 6.4.2.1 allows an ordinary space in a quoted character, but not
        // literal layout characters such as tab or newline. Newlines are
        // permitted only through the continuation escape handled above.
        throw new Error(`parse line ${line}: layout character in quoted term`);
      }
      text += value;
    }
    return { type: quote === '"' ? TOK.STRING : TOK.ATOM, text, line, quoted: true };
  }
  numberToken(line) {
    const start = this.pos;
    const negative = this.peek() === '-';
    if (negative) this.take();
    const startsQuotedCharacter = this.peek() === '0' && this.peek(1) === "'" &&
      // `0''` is the integer 0 followed by the empty atom, whereas `0'''`
      // is the character-code constant for an apostrophe. A continuation
      // after the integer likewise belongs to the following quoted atom.
      (this.peek(2) !== "'" || this.peek(3) === "'") &&
      !(this.peek(2) === '\\' && this.peek(3) === '\n');
    if (startsQuotedCharacter) return this.characterCodeConstant(line, negative);

    const radixKind = this.peek() === '0' ? this.peek(1) : '';
    const radixHasDigit = radixKind === 'b' ? RE_BINARY_DIGIT.test(this.peek(2))
      : radixKind === 'o' ? RE_OCTAL_DIGIT.test(this.peek(2))
      : radixKind === 'x' ? RE_HEX_DIGIT.test(this.peek(2))
      : false;
    if (radixHasDigit) {
      this.take();
      const kind = this.take();
      const radix = kind === 'b' ? 2 : kind === 'o' ? 8 : 16;
      const { digits } = this.integerDigits(digitPatternForRadix(radix), line);
      if (!digits) throw new Error(`parse line ${line}: bad radix integer`);
      let integer = 0n;
      for (const digit of digits) integer = integer * BigInt(radix) + BigInt(Number.parseInt(digit, radix));
      if (negative) integer = -integer;
      return { type: TOK.NUMBER, text: integer.toString(), line };
    }

    const { digits, separated } = this.integerDigits(RE_DECIMAL_DIGIT, line);
    let hasFraction = false;
    if (!separated && this.peek() === '.' && isDigitCode(this.peek(1).charCodeAt(0))) {
      hasFraction = true;
      this.take();
      while (isDigitCode(this.peek().charCodeAt(0))) this.take();
    }
    // ISO floating-point syntax requires a fractional part before an exponent.
    // Thus 1.0e9 is one number token, while 1E9 is the integer 1 followed by
    // the name E9 and is not a valid term without an operator.
    if (hasFraction && (this.peek() === 'e' || this.peek() === 'E')) {
      let index = this.pos + 1;
      if (['+', '-'].includes(this.source[index] ?? '')) index++;
      if (isDigitCode((this.source[index] ?? '').charCodeAt(0))) {
        this.take();
        if (this.peek() === '+' || this.peek() === '-') this.take();
        while (isDigitCode(this.peek().charCodeAt(0))) this.take();
      }
    }
    const text = hasFraction
      ? finiteFloatTokenText(this.source.slice(start, this.pos))
      : BigInt(`${negative ? '-' : ''}${digits}`).toString();
    return { type: TOK.NUMBER, text, line };
  }
  nextToken() {
    // The tokenizer keeps just enough state for useful parse-line errors and
    // treats quoted atoms and quoted strings differently, as Prolog syntax does.
    const beforeLayout = this.pos;
    this.skipWhitespaceAndComments();
    const precededByLayout = this.pos !== beforeLayout;
    const line = this.line;
    const ch = this.peek();
    if (!ch) return { type: TOK.EOF, text: '', line };
    if (ch === '?' && this.peek(1) === '-' &&
        !(graphicAtomChars.includes(this.peek(2)) && !this.terminatingFullStop(this.pos + 2))) {
      this.pos += 2;
      return { type: TOK.ATOM, text: '?-', line };
    }
    if (ch === '.' && !this.terminatingFullStop()) {
      const start = this.pos;
      this.take();
      while (isGraphicAtomCharacter(this.peek()) && !this.terminatingFullStop()) this.take();
      return { type: TOK.ATOM, text: this.source.slice(start, this.pos), line };
    }
    if (ch === '!' || ch === ';') {
      this.take();
      return { type: TOK.ATOM, text: ch, line };
    }
    const punct = {
      '(': TOK.LPAREN, ')': TOK.RPAREN, '[': TOK.LBRACKET, ']': TOK.RBRACKET,
      '{': TOK.LBRACE, '}': TOK.RBRACE, ',': TOK.COMMA, '|': TOK.BAR, '.': TOK.DOT,
    };
    if (punct[ch]) {
      this.take();
      return { type: punct[ch], text: ch, line, precededByLayout };
    }
    if (ch === ':' && this.peek(1) === '-' &&
        !(graphicAtomChars.includes(this.peek(2)) && !this.terminatingFullStop(this.pos + 2))) {
      this.pos += 2;
      return { type: TOK.IF, text: ':-', line };
    }
    if (ch === ':' &&
        !(graphicAtomChars.includes(this.peek(1)) && !this.terminatingFullStop(this.pos + 1))) {
      this.take();
      return { type: TOK.ATOM, text: ':', line };
    }
    if (ch === '"' || ch === "'") return this.quotedToken(line);

    // A signed numeric literal is only recognized where a term may start.
    // Otherwise the minus is the standard infix operator, so compact ISO
    // syntax such as `X-1` must not be read as `X` followed by `-1`.
    const previousEndsTerm = this.previousToken && (
      [TOK.VAR, TOK.NUMBER, TOK.STRING, TOK.RPAREN, TOK.RBRACKET, TOK.RBRACE].includes(this.previousToken.type) ||
      (this.previousToken.type === TOK.ATOM &&
       !INFIX_OPERATORS.has(this.previousToken.text) &&
       !PREFIX_OPERATORS.has(this.previousToken.text))
    );
    if (isDigitCode(ch.charCodeAt(0)) ||
        (ch === '-' && isDigitCode(this.peek(1).charCodeAt(0)) && !previousEndsTerm)) {
      return this.numberToken(line);
    }

    if (isVariableStartCharacter(ch) || isPlainAtomStartCharacter(ch)) {
      const variableName = isVariableStartCharacter(ch);
      const start = this.pos;
      this.take();
      while (isNameContinueCharacter(this.peek())) this.take();
      return { type: variableName ? TOK.VAR : TOK.ATOM, text: this.source.slice(start, this.pos), line };
    }

    if (isGraphicAtomCharacter(ch)) {
      const start = this.pos;
      this.take();
      while (isGraphicAtomCharacter(this.peek()) && !this.terminatingFullStop()) this.take();
      return { type: TOK.ATOM, text: this.source.slice(start, this.pos), line };
    }

    throw new Error(`parse line ${line}: bad character ${JSON.stringify(ch)}`);
  }
  advance() {
    this.previousToken = this.token;
    this.token = this.nextToken();
  }
  expect(type, desc = type) {
    if (this.token.type !== type) throw new Error(`parse line ${this.token.line}: expected ${desc}, got ${this.token.text}`);
  }
  expectAndAdvance(type, desc = type) {
    this.expect(type, desc);
    this.advance();
  }
  parseParenthesizedTerm() {
    this.expectAndAdvance(TOK.LPAREN, '(');
    // A current operator atom may be the complete parenthesized term, e.g.
    // (+), but it cannot silently become an operand in a larger expression.
    const term = this.parseTerm(0, true, true, true);
    this.expectAndAdvance(TOK.RPAREN, ')');
    return term;
  }
  parseList() {
    // Lists are lowered to './2' cons cells and [] so list predicates can work
    // on a single canonical representation.
    this.expectAndAdvance(TOK.LBRACKET, '[');
    if (this.token.type === TOK.RBRACKET) {
      this.advance();
      return emptyList();
    }
    const items = [];
    let tail = null;
    while (true) {
      items.push(this.parseTerm(ARG_MIN_PRECEDENCE, false, false, true));
      if (this.token.type === TOK.COMMA) {
        this.advance();
        continue;
      }
      if (this.token.type === TOK.BAR) {
        this.advance();
        tail = this.parseTerm(ARG_MIN_PRECEDENCE, false, false, true);
        this.expectAndAdvance(TOK.RBRACKET, ']');
        break;
      }
      this.expectAndAdvance(TOK.RBRACKET, ']');
      tail = emptyList();
      break;
    }
    for (let i = items.length - 1; i >= 0; i--) tail = cons(items[i], tail);
    return tail;
  }
  parseCurly() {
    this.expectAndAdvance(TOK.LBRACE, '{');
    if (this.token.type === TOK.RBRACE) {
      this.advance();
      return atom('{}');
    }
    // As with a parenthesized term, a current operator atom may be the entire
    // curly-bracket content: `{*}` denotes {}(*), not an incomplete infix use.
    const term = this.parseTerm(0, true, true, true);
    this.expectAndAdvance(TOK.RBRACE, '}');
    return compound('{}', [term]);
  }
  parseFunctionalNotation(name) {
    this.expectAndAdvance(TOK.LPAREN, '(');
    const args = [];
    if (this.token.type === TOK.RPAREN) {
      throw new Error(`parse line ${this.token.line}: zero-arity compound syntax is not supported; use atom ${JSON.stringify(name)} for arity zero data`);
    }
    while (true) {
      args.push(this.parseTerm(ARG_MIN_PRECEDENCE, false, false, true));
      if (this.token.type !== TOK.COMMA) break;
      this.advance();
    }
    this.expectAndAdvance(TOK.RPAREN, ')');
    return compound(name, args);
  }
  // The infix operator at the current token, with comma and bar reported only
  // where the surrounding grammar admits them as operators rather than
  // separators.
  infixAt(allowComma, allowBar) {
    if (this.token.type === TOK.COMMA) return allowComma ? ',' : null;
    if (this.token.type === TOK.BAR) return allowBar ? '|' : null;
    if (this.token.type === TOK.IF) return ':-';
    return this.operatorTokenName();
  }
  parseTerm(minPrecedence = 0, allowComma = false, allowBar = true, allowOperatorAtom = false) {
    const initialOperatorName = this.operatorTokenName();
    const initialWasCurrentOperator = initialOperatorName != null &&
      (INFIX_OPERATORS.has(initialOperatorName) || PREFIX_OPERATORS.has(initialOperatorName));
    let left = this.parsePrefixTerm(minPrecedence, allowBar, allowOperatorAtom);
    const leftIsBareOperatorAtom = initialWasCurrentOperator &&
      left.type === ATOM && left.name === initialOperatorName;
    while (true) {
      const op = this.infixAt(allowComma, allowBar);
      const info = op == null ? null : INFIX_OPERATORS.get(op);
      if (!info || info.precedence < minPrecedence) break;
      if (leftIsBareOperatorAtom) {
        throw new Error(`parse line ${this.token.line}: operator atom ${left.name} requires parentheses as an operand`);
      }
      this.advance();
      const right = this.parseTerm(
        info.associativity === 'right' ? info.precedence : info.precedence + 1,
        allowComma,
        allowBar,
        false,
      );
      left = compound(op, [left, right]);
      if (info.associativity === 'none' &&
          INFIX_OPERATORS.get(this.infixAt(allowComma, allowBar))?.precedence === info.precedence) {
        throw new Error(`parse line ${this.token.line}: non-associative operator ${op} requires parentheses`);
      }
    }
    if (leftIsBareOperatorAtom && left.type === ATOM && !allowOperatorAtom) {
      throw new Error(`parse line ${this.token.line}: operator atom ${left.name} requires parentheses as an operand`);
    }
    return left;
  }
  parsePrefixTerm(minPrecedence = 0, allowBar = true, allowOperatorAtom = false) {
    // `:-` is tokenized specially so the program grammar can recognize clause
    // and directive markers. In term argument position ISO 6.3.3.1 permits an
    // operator atom directly as an `arg`, and a leading `:-` cannot be prefix
    // operator notation at argument priority 999, so there it denotes the atom.
    //
    // Where priority 1200 is actually in reach, though, it can: ISO 6.3.4.1
    // gives a parenthesized term the full priority, so `x((:- a))` is the
    // compound `x(:-(a))` -- as SWI, Scryer and GNU Prolog all read it. Only
    // decide the atom here when the prefix reading is genuinely unavailable;
    // otherwise fall through to the ordinary prefix-operator path below, which
    // already applies exactly this precedence test and still yields the bare
    // atom when no operand follows, as in `(:-)`.
    if (this.token.type === TOK.IF && !(PREFIX_OPERATORS.get(':-').precedence >= minPrecedence)) {
      if (!allowOperatorAtom) {
        throw new Error(`parse line ${this.token.line}: operator atom :- requires argument context or parentheses`);
      }
      this.advance();
      return atom(':-');
    }
    const operatorName = this.operatorTokenName();
    // A negative number is a minus name token followed by a numeric token,
    // with layout permitted between them. It is lexical number syntax, not an
    // application of the prefix `-` operator, and applies to a quoted '-' too:
    // WG17 #57/#58 require integer('-'1) and integer('-' 1) to succeed exactly
    // like integer(-1). An unquoted minus immediately touching a digit is
    // merged into one NUMBER token by the scanner before parsing reaches here.
    if (operatorName === '-' && this.token.type === TOK.ATOM) {
      const state = {
        pos: this.pos, line: this.line, previousToken: this.previousToken, token: this.token,
      };
      this.advance();
      if (this.token.type === TOK.NUMBER && !this.token.text.startsWith('-')) {
        const value = this.token.text;
        this.advance();
        return negatedNumberTerm(value);
      }
      this.pos = state.pos;
      this.line = state.line;
      this.previousToken = state.previousToken;
      this.token = state.token;
    }
    const prefix = operatorName == null ? null : PREFIX_OPERATORS.get(operatorName);
    if (prefix && prefix.precedence >= minPrecedence) {
      const op = operatorName;
      this.advance();
      // Graphic operators can also be ordinary atom data in a term, as in
      // `op(+, Left, Right)`.  When the operator is immediately followed by
      // an argument delimiter there is no operand for prefix syntax, so keep
      // the operator as an atom instead of reporting a misleading bad-term
      // error.
      if ([TOK.COMMA, TOK.RPAREN, TOK.RBRACKET, TOK.RBRACE, TOK.BAR, TOK.DOT].includes(this.token.type)) {
        if (!allowOperatorAtom && this.token.type !== TOK.DOT) {
          throw new Error(`parse line ${this.token.line}: operator atom ${op} requires argument context or parentheses`);
        }
        return atom(op);
      }
      if (this.token.type === TOK.LPAREN && this.token.precededByLayout !== true) {
        return this.parseFunctionalNotation(op);
      }
      return compound(op, [this.parseTerm(prefix.precedence + (prefix.strict ? 1 : 0), false, allowBar, false)]);
    }
    if (this.token.type === TOK.LPAREN) return this.parseParenthesizedTerm();
    if (this.token.type === TOK.LBRACKET) {
      const list = this.parseList();
      if (list.type === ATOM && list.name === '[]' && this.token.type === TOK.LPAREN &&
          this.token.precededByLayout !== true) return this.parseFunctionalNotation('[]');
      return list;
    }
    if (this.token.type === TOK.LBRACE) {
      const curly = this.parseCurly();
      if (curly.type === ATOM && curly.name === '{}' && this.token.type === TOK.LPAREN &&
          this.token.precededByLayout !== true) return this.parseFunctionalNotation('{}');
      return curly;
    }
    if (this.token.type === TOK.VAR) {
      const name = this.token.text;
      this.advance();
      if (name === '_') return variable(`__anon${this.anonymous++}`);
      let term = this.variables.get(name);
      if (term == null) {
        term = variable(name);
        this.variables.set(name, term);
      }
      return term;
    }
    if (this.token.type === TOK.STRING) return this.parseCharacterList(allowBar);
    if (this.token.type === TOK.NUMBER) {
      const value = this.token.text;
      this.advance();
      return numberTerm(value);
    }
    if (this.token.type === TOK.ATOM) {
      const name = this.token.text;
      const quoted = this.token.quoted === true;
      this.advance();
      if (this.token.type === TOK.LPAREN && this.token.precededByLayout !== true) {
        return this.parseFunctionalNotation(name);
      }
      if (!quoted && !allowOperatorAtom &&
          (INFIX_OPERATORS.has(name) || PREFIX_OPERATORS.has(name))) {
        throw new Error(`parse line ${this.token.line}: operator atom ${name} requires argument context or parentheses`);
      }
      return atom(name);
    }
    throw new Error(`parse line ${this.token.line}: bad term`);
  }
  // Double-quoted text is a list of one-character atoms. It may be followed by
  // `||Tail` to splice a tail onto that list, so "ab"||T is [a,b|T]. Both the
  // whole production and the tail have priority 0: the tail is a primary term,
  // so an operator term there needs explicit parentheses, and an infix
  // operator after the tail is not absorbed into it.
  parseCharacterList(allowBar) {
    const value = this.token.text;
    this.advance();
    let tail = emptyList();
    if (this.token.type === TOK.BAR) {
      const state = {
        pos: this.pos, line: this.line, previousToken: this.previousToken, token: this.token,
      };
      this.advance();
      if (this.token.type === TOK.BAR) {
        this.advance();
        tail = this.parseTerm(strength(0), false, allowBar, false);
      } else {
        // A single bar remains ordinary bar syntax. We had to advance once to
        // distinguish it from `||`, so restore the tokenizer state.
        this.pos = state.pos;
        this.line = state.line;
        this.previousToken = state.previousToken;
        this.token = state.token;
      }
    }
    const items = Array.from(value);
    for (let i = items.length - 1; i >= 0; i--) tail = cons(atom(items[i]), tail);
    return tail;
  }
  parseStandaloneTerm() {
    // parseTermText consumes one ordinary Prolog term, not a program clause.
    // Commas and operators such as :- and ?- belong to the term itself and
    // must not be reinterpreted by parseProgram().
    const term = this.parseTerm(0, true, true, true);
    this.expectAndAdvance(TOK.DOT, '.');
    this.expect(TOK.EOF, 'end of input');
    return term;
  }
  parseProgram() {
    const clauses = [];
    while (this.token.type !== TOK.EOF) {
      const line = this.token.line;
      const source = { line };
      // `?- Goal.` delivers a goal to the reasoner. ISO 6.2.1 admits only
      // directive-terms and clause-terms in a Prolog text, and its own "query"
      // is interactive input, so reading `?-` from a file as a goal is
      // 7.7.3's implementation-defined "method by which a user delivers a
      // goal" -- the notation nearly every Prolog uses for one.
      if (this.operatorTokenName() === '?-') {
        this.advance();
        const goal = this.parseTerm(0, true);
        this.expectAndAdvance(TOK.DOT, '.');
        clauses.push({ kind: 'query', goal, source });
        continue;
      }
      // Directives are outside the language. Read the whole term so the
      // profile check reports the directive itself rather than a syntax error.
      if (this.token.type === TOK.IF) {
        this.advance();
        const directive = this.parseTerm(0, true);
        this.expectAndAdvance(TOK.DOT, '.');
        clauses.push({ head: compound(':-', [directive]), body: [], source });
        continue;
      }
      // The clause grammar keeps the priority-1200 neck outside the initial
      // head parse, so a head is read below that priority and the neck,
      // forward arrow or any other priority-1200 operator is folded in after.
      let head = this.parseTerm(NECK_PRECEDENCE, false, true, true);
      if (this.token.type === TOK.COMMA) {
        // Several forward conclusions may be written without parentheses.
        const items = [head];
        while (this.token.type === TOK.COMMA) {
          if (items.length >= 2) throw new Error(`parse line ${this.token.line}: expected ., got ,`);
          this.advance();
          items.push(this.parseTerm(NECK_PRECEDENCE));
        }
        head = items.reduceRight((tail, item) => compound(',', [item, tail]));
      }
      const neck = this.operatorTokenName();
      const neckInfo = neck == null || neck === ':-' ? null : INFIX_OPERATORS.get(neck);
      if (neckInfo && neckInfo.precedence < NECK_PRECEDENCE) {
        this.advance();
        const right = this.parseTerm(
          neckInfo.associativity === 'right' ? neckInfo.precedence : neckInfo.precedence + 1,
          true, true, false,
        );
        head = compound(neck, [head, right]);
        if (neckInfo.associativity === 'none' &&
            INFIX_OPERATORS.get(this.operatorTokenName())?.precedence === neckInfo.precedence) {
          throw new Error(`parse line ${this.token.line}: non-associative operator ${neck} requires parentheses`);
        }
      }
      const body = [];
      if (this.token.type === TOK.IF) {
        this.advance();
        while (true) {
          body.push(this.parseTerm());
          if (this.token.type !== TOK.COMMA) break;
          this.advance();
        }
      }
      this.expectAndAdvance(TOK.DOT, '.');
      clauses.push({ head, body, source });
    }
    return clauses;
  }
}

export function parseProgramText(source) {
  return new Parser(source).parseProgram();
}

export function parseTermText(text) {
  return new Parser(text).parseStandaloneTerm();
}

export function parseGoalText(text) {
  const clauses = parseProgramText(`zz_goal((${text})).`);
  const head = clauses[0]?.head;
  if (clauses.length !== 1 || head?.type !== COMPOUND ||
      head.name !== 'zz_goal' || head.arity !== 1 || clauses[0].body.length !== 0) {
    throw new Error('bad goal');
  }
  return head.args[0];
}
