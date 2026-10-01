// Numeric value identity for term semantics: keep integer and float terms
// distinct while ignoring insignificant spelling differences within either ISO
// numeric type, so 007 and 7 unify but 7 and 7.0 do not.
const decimalInteger = (text) => /^-?\d+$/.test(text ?? '');

const finiteFloat = (text) => {
  if (!/^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$/.test(text ?? '')) return null;
  const value = Number(text);
  return Number.isFinite(value) ? value : null;
};

// Compare decimal integer spellings without constructing host BigInts. This is
// used on term-ordering and unification hot paths, including integers far beyond
// JavaScript's safe-number range. Leading zeros and -0 remain value-equivalent.
export function compareIntegerValueText(left, right) {
  let li = left[0] === '-' ? 1 : 0;
  let ri = right[0] === '-' ? 1 : 0;
  while (li < left.length && left.charCodeAt(li) === 48) li++;
  while (ri < right.length && right.charCodeAt(ri) === 48) ri++;

  const leftZero = li === left.length;
  const rightZero = ri === right.length;
  const leftNegative = !leftZero && left[0] === '-';
  const rightNegative = !rightZero && right[0] === '-';
  if (leftNegative !== rightNegative) return leftNegative ? -1 : 1;
  if (leftZero || rightZero) return leftZero ? (rightZero ? 0 : -1) : 1;

  const leftDigits = left.length - li;
  const rightDigits = right.length - ri;
  if (leftDigits !== rightDigits) {
    const cmp = leftDigits < rightDigits ? -1 : 1;
    return leftNegative ? -cmp : cmp;
  }
  for (let offset = 0; offset < leftDigits; offset++) {
    const a = left.charCodeAt(li + offset);
    const b = right.charCodeAt(ri + offset);
    if (a === b) continue;
    const cmp = a < b ? -1 : 1;
    return leftNegative ? -cmp : cmp;
  }
  return 0;
}

export function sameNumberValue(left, right) {
  const leftInteger = decimalInteger(left);
  const rightInteger = decimalInteger(right);
  if (leftInteger || rightInteger) {
    return leftInteger && rightInteger && compareIntegerValueText(left, right) === 0;
  }
  const leftValue = finiteFloat(left);
  const rightValue = finiteFloat(right);
  return leftValue != null && rightValue != null && leftValue === rightValue;
}
