// Canonical term output. eyedia prints one spelling per term: quoted,
// functional notation, with character lists written back in double-quoted
// form. Operator notation, numbervars and the layout variants a general
// writeq/1 offers are deliberately absent, so printed output reads back as the
// same term without any operator declarations.
import { ATOM, NUMBER, STRING, VAR, Env, deref, isCons, isEmptyList } from './term.js';

const graphicAtomCharacters = new Set('!#$&*+-./<=>?@^~\\'.split(''));
const RE_LOWER_WORD = /^[a-z][A-Za-z0-9_]*$/;
const RE_LEGACY_VAR = /^\?(?:[A-Za-z_][A-Za-z0-9_]*)?$/;
const RE_UPPER_IDENT = /^(?:_|[A-Z_][A-Za-z0-9_]*)$/;
const RE_SANITIZE = /[^A-Za-z0-9_]/g;
const RE_UPPER_START = /^[A-Z_]/;

function quotedControlEscape(ch) {
  if (ch === '\x00') return '\\0\\';
  if (ch === '\x07') return '\\a';
  if (ch === '\b') return '\\b';
  if (ch === '\r') return '\\r';
  if (ch === '\f') return '\\f';
  if (ch === '\t') return '\\t';
  if (ch === '\n') return '\\n';
  if (ch === '\v') return '\\v';
  const code = ch.codePointAt(0);
  // Other C0 controls and DEL have no ISO symbolic-control escape. Emit an
  // octal escape so quoted output remains valid read-back syntax instead of
  // leaking a raw control character into the output stream.
  if (code < 0x20 || code === 0x7f) return `\\${code.toString(8)}\\`;
  return null;
}

function atomNeedsQuotes(name) {
  if (!name) return true;
  if (name === '[]' || name === '{}') return false;
  // `;` is a solo-character name token in ISO 6.4.2/6.5.3, so unlike most
  // solo characters it is a valid atom without quotes. `|` is not: Corrigendum
  // 2 makes the bar token equivalent to atom '|' only while it is being used
  // as an operator, and it is not a graphic character either, so it falls
  // through to the quoted form below.
  if (name === ';') return false;
  // A lone full stop is the end token, not a graphic atom.  Longer
  // graphic tokens may contain dots and are valid unquoted writeq/1 output
  // (WG17 #371-373: ./*, .*, ...*).  Only a token beginning with /* would
  // be read as a bracketed comment and therefore still requires quoting.
  if (name === '.') return true;
  if (name.startsWith('/*')) return true;
  if (RE_LOWER_WORD.test(name)) return false;
  for (const ch of name) if (!graphicAtomCharacters.has(ch)) return true;
  return false;
}

function quoteAtom(name) {
  let out = "'";
  for (const ch of name) {
    if (ch === "'") out += "''";
    else if (ch === '\\') out += '\\\\';
    else out += quotedControlEscape(ch) ?? ch;
  }
  return out + "'";
}

function writeAtom(name) {
  return atomNeedsQuotes(name) ? quoteAtom(name) : name;
}

function legacyVariableToIso(name) {
  if (name === '?') return '_';
  const tail = name.slice(1);
  if (!tail) return '_';
  if (tail[0] === '_') return tail;
  return tail[0].toUpperCase() + tail.slice(1);
}

function writeVariable(name) {
  name = String(name ?? '');
  if (RE_LEGACY_VAR.test(name)) return legacyVariableToIso(name);
  if (RE_UPPER_IDENT.test(name)) return name;
  const sanitized = name.replace(RE_SANITIZE, '_');
  if (!sanitized) return '_';
  return RE_UPPER_START.test(sanitized) ? sanitized : `_${sanitized}`;
}

function writeString(value) {
  let out = '"';
  for (const ch of value) {
    if (ch === '"' || ch === '\\') out += `\\${ch}`;
    else out += quotedControlEscape(ch) ?? ch;
  }
  return out + '"';
}

function format(term, env, variableNames) {
  const resolved = deref(term, env);
  if (resolved.type === VAR) return variableNames.get(resolved.name) ?? writeVariable(resolved.name);
  if (resolved.type === STRING) return writeString(resolved.name);
  if (resolved.type === NUMBER) return resolved.name;
  if (resolved.type === ATOM) return writeAtom(resolved.name);
  // List notation is core ISO syntax, not an operator, so it reads back without
  // any declaration or flag - unlike double-quoted text, whose meaning depends
  // on double_quotes. Walking the spine iteratively also keeps a long list from
  // costing one level of recursion per element.
  if (isCons(resolved)) {
    const items = [];
    let cursor = resolved;
    while (isCons(cursor)) {
      items.push(format(cursor.args[0], env, variableNames));
      cursor = deref(cursor.args[1], env);
    }
    const tail = isEmptyList(cursor) ? '' : `|${format(cursor, env, variableNames)}`;
    return `[${items.join(', ')}${tail}]`;
  }
  const args = resolved.args.map((arg) => format(arg, env, variableNames));
  return `${writeAtom(resolved.name)}(${args.join(', ')})`;
}

export function writeCanonical(term, env = new Env(), variableNames = new Map()) {
  return format(term, env, variableNames);
}
