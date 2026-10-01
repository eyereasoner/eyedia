import { Env, COMPOUND, VAR, compound, atom, variable, copyResolved } from './kernel/term.js';
import { writeCanonical } from './kernel/write.js';

export const key = (term) => `${term.name}/${term.arity}`;
export const is = (term, name, arity) => term?.name === name && term.arity === arity;
export function text(term, env = new Env()) {
  // Sanitizing X#1 into X_1 would conflate it with a user's actual X_1.
  // Reserve a prefix and encode it too, so this mapping is injective.
  const names = new Map([...variables(copyResolved(term, env))].map(([name]) => [name,
    /^[A-Z_][A-Za-z0-9_]*$/.test(name) && !name.startsWith('EYE_') && name !== '_'
      ? name : 'EYE_' + Array.from(name, (ch) => ch.codePointAt(0).toString(16)).join('_'),
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
