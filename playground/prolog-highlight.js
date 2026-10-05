// Prolog syntax coloring, shared by the playground and the documentation
// pages. A small tokenizer for coloring only: it never decides what a
// program means. colorize returns HTML with tok-* classes, styled by
// prolog-highlight.css.
const KEYWORDS = new Set([':+', ':-']);
const HEAD_WORDS = new Set(['true', 'false']);
// Names of the native predicates and controls, from src/builtins.js and src/program.js.
const BUILTINS = new Set([
  'fail', 'is', 'var', 'nonvar', 'ground', 'atom', 'number', 'integer', 'float', 'compound',
  'functor', 'arg', 'atom_chars', 'atom_codes', 'atom_length', 'atom_concat', 'compare',
  'call', 'once', 'findall', 'mod', 'rem', 'div', 'xor', 'abs', 'sign', 'min', 'max', 'sqrt',
  'sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'atan2', 'exp', 'log', 'truncate', 'round',
  'ceiling', 'floor', 'float_integer_part', 'float_fractional_part', 'gcd', 'pi', 'e',
]);
const GRAPHIC = '#$&*+-./<=>?@^~\\:';

export function colorize(text) {
  let out = '';
  let i = 0;
  while (i < text.length) {
    const ch = text[i];
    if (ch === '%') {
      const end = lineEnd(text, i);
      out += span('comment', text.slice(i, end)); i = end;
    } else if (ch === '/' && text[i + 1] === '*') {
      const close = text.indexOf('*/', i + 2);
      const end = close < 0 ? text.length : close + 2;
      out += span('comment', text.slice(i, end)); i = end;
    } else if (ch === "'" || ch === '"') {
      const end = quotedEnd(text, i);
      out += span(ch === '"' ? 'string' : 'predicate', text.slice(i, end)); i = end;
    } else if (/[0-9]/.test(ch)) {
      const match = /^(0'(\\.|.)|0x[0-9a-fA-F_]+|0o[0-7_]+|0b[01_]+|[0-9][0-9_]*(\.[0-9]+([eE][+-]?[0-9]+)?)?)/.exec(text.slice(i));
      out += span('number', match[0]); i += match[0].length;
    } else if (/[A-Z_]/.test(ch)) {
      const match = /^[A-Za-z0-9_]+/.exec(text.slice(i));
      out += span('variable', match[0]); i += match[0].length;
    } else if (/[a-z]/.test(ch)) {
      const word = /^[A-Za-z0-9_]+/.exec(text.slice(i))[0];
      const kind = HEAD_WORDS.has(word) ? 'keyword' : BUILTINS.has(word) ? 'operator'
        : text[i + word.length] === '(' ? 'predicate' : null;
      out += kind ? span(kind, word) : escapeHtml(word); i += word.length;
    } else if (GRAPHIC.includes(ch)) {
      let j = i;
      while (j < text.length && GRAPHIC.includes(text[j])) j++;
      // A full stop followed by layout ends a clause rather than continuing a graphic token.
      if (text[j - 1] === '.' && j - 1 > i && /\s|$/.test(text[j] ?? '')) j--;
      const word = text.slice(i, j);
      out += span(KEYWORDS.has(word) ? 'keyword' : word === '.' ? 'punctuation' : 'operator', word); i = j;
    } else if ('()[]{},|;!'.includes(ch)) {
      out += span('punctuation', ch); i++;
    } else {
      out += escapeHtml(ch); i++;
    }
  }
  return out;
}

function lineEnd(text, from) {
  const end = text.indexOf('\n', from);
  return end < 0 ? text.length : end;
}

function quotedEnd(text, from) {
  const quote = text[from];
  let i = from + 1;
  while (i < text.length) {
    if (text[i] === '\\') { i += 2; continue; }
    if (text[i] === quote) { if (text[i + 1] === quote) { i += 2; continue; } return i + 1; }
    if (text[i] === '\n') return i;
    i++;
  }
  return i;
}

function span(kind, text) { return `<span class="tok-${kind}">${escapeHtml(text)}</span>`; }
export function escapeHtml(text) { return text.replace(/[&<>]/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[ch])); }
