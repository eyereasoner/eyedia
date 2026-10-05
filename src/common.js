import { Env, ATOM, COMPOUND, VAR, compound, atom, variable, copyResolved, freshTerm } from './kernel/term.js';
import { writeCanonical } from './kernel/write.js';

export const key = (term) => `${term.name}/${term.arity}`;
export const is = (term, name, arity) => term?.name === name && term.arity === arity;
export const callable = (term) => term?.type === ATOM || term?.type === COMPOUND;
// Append to the list a map holds under a key, starting the list if need be.
export function addTo(map, id, value) {
  const list = map.get(id);
  if (list === undefined) map.set(id, [value]);
  else list.push(value);
}
// Rename a clause apart: its head and body share one set of fresh variables,
// which names maps from the source variable names.
export function freshClause(clause, suffix) {
  const names = new Map();
  const head = freshTerm(clause.head, suffix, names);
  const body = clause.body.map((item) => freshTerm(item, suffix, names));
  return { head, body, names };
}
// A variable name that is not a valid source name, such as the X#12 a clause
// renamed apart gets, is written under a reserved prefix: letters and digits
// stay, an underscore doubles and any other character becomes _hex_, so X#12
// is EYE_X_23_12. Sanitizing X#12 into X_12 would conflate it with a user's
// actual X_12; names that already start with the prefix are encoded too, so
// the mapping stays injective.
const encodeName = (name) => 'EYE_' + Array.from(name, (ch) => (/[A-Za-z0-9]/.test(ch) ? ch
  : ch === '_' ? '__' : `_${ch.codePointAt(0).toString(16)}_`)).join('');
export function text(term, env = new Env()) {
  const names = new Map([...variables(copyResolved(term, env))].map(([name]) => [name,
    /^[A-Z_][A-Za-z0-9_]*$/.test(name) && !name.startsWith('EYE_') && name !== '_' ? name : encodeName(name),
  ]));
  return writeCanonical(term, env, names);
}
export function variables(term, result = new Map()) {
  if (term.type === VAR) result.set(term.name, term);
  else for (const arg of term.args) variables(arg, result);
  return result;
}
export function conjunction(items) {
  return items.reduceRight((tail, item) => tail ? compound(',', [item, tail]) : item, null) ?? atom('true');
}
// A variant key preserves sharing while forgetting freshly allocated names.
export function variant(term) {
  const names = new Map();
  const visit = (t) => {
    if (t.type === VAR) {
      if (!names.has(t.name)) names.set(t.name, names.size);
      return variable(`V${names.get(t.name)}`);
    }
    return t.type === COMPOUND ? compound(t.name, t.args.map(visit)) : t;
  };
  return text(visit(term));
}
