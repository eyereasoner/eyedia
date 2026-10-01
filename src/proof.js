import {
  Env, VAR, ATOM, COMPOUND, NUMBER, atom, compound, numberTerm, unify,
  freshTerm, copyResolved, properListItems, listFromItems, flattenConjunction,
} from './kernel/term.js';
import { parseProgramText } from './kernel/parser.js';
import { Program } from './program.js';
import { primitive, primitiveKeys } from './builtins.js';
import { is, key, text, conjunction } from './common.js';

function template(term) {
  if (term.type === VAR) return compound('var', [atom(term.name)]);
  return term.type === COMPOUND ? compound(term.name, term.args.map(template)) : term;
}
export function renderProof(program, claims, roots) {
  const steps = new Map();
  const clauses = new Set();
  const visit = (node) => {
    const id = text(node.goal);
    if (steps.has(id)) return;
    steps.set(id, node);
    if (node.by.arity) clauses.add(Number(node.by.args[0].name));
    for (const child of node.children) visit(child);
  };
  roots.forEach(visit);
  const lines = claims.map((claim) => `${text(claim)}.`);
  lines.push('');
  for (const id of [...clauses].sort((a, b) => a - b)) {
    const clause = program.clauses[id - 1];
    lines.push(`${text(compound('clause', [numberTerm(id), template(clause.head), template(conjunction(clause.body))]))}.`);
  }
  lines.push('');
  for (const node of steps.values()) {
    const bindings = listFromItems(node.bindings.map(([name, value]) => compound('=', [atom(name), value])));
    const uses = listFromItems(node.children.map((child) => child.goal));
    lines.push(`${text(compound('step', [node.goal, node.by, bindings, uses]))}.`);
  }
  return lines.join('\n') + '\n';
}

// Verification follows recorded uses; it never asks the solver to find a
// missing derivation. Only pure primitives are independently recomputed.
export function checkProof(source, document, options = {}) {
  const program = source instanceof Program ? source : Program.parse(source);
  const failures = [];
  const trusted = [];
  const claims = [];
  const steps = new Map();
  let verified = 0;
  let redecided = 0;
  let composed = 0;
  const withTerm = (record, term) => {
    // Keep the printable report easy to serialize while retaining the actual
    // conclusion term for a report another Prolog program can reason over.
    if (term) Object.defineProperty(record, 'term', { value: term });
    return record;
  };
  const fail = (condition, detail, term = null) => failures.push(withTerm({
    condition, detail, ...(term ? { conclusion: text(term) } : {}),
  }, term));
  try {
    for (const entry of parseProgramText(String(document))) {
      if (!entry.head || entry.body.length || entry.kind || is(entry.head, ':-', 1)) {
        fail('C3', 'proof documents may contain facts only', entry.head); continue;
      }
      const term = entry.head;
      if (is(term, 'clause', 3)) {
        // These display records are not authority: the source program is.
        const clause = program.clauses[Number(term.args[0].name) - 1];
        if (!clause || text(term.args[1]) !== text(template(clause.head)) ||
            text(term.args[2]) !== text(template(conjunction(clause.body)))) fail('C1', 'clause display differs from source', term);
        continue;
      }
      if (!is(term, 'step', 4)) { claims.push(term); continue; }
      const [goal, by, bindingList, useList] = term.args;
      const bindings = properListItems(bindingList, new Env());
      const uses = properListItems(useList, new Env());
      if (!bindings || !uses) { fail('C3', 'step bindings and uses must be proper lists', goal); continue; }
      const id = text(goal);
      if (steps.has(id)) { fail('C3', `duplicate justification for ${id}`, goal); continue; }
      steps.set(id, { goal, by, bindings, uses });
    }
  } catch (error) { fail('C3', error.message); }
  if (!steps.size || !claims.length) fail('C4', 'a proof needs claims and steps');

  function covered(goal) {
    if (is(goal, ',', 2)) return flattenConjunction(goal).every(covered);
    if (steps.has(text(goal))) return true;
    // Source facts are available as leaves, including universal fact clauses.
    return (program.groups.get(key(goal)) ?? []).some((clause) => {
      if (clause.body.length) return false;
      const head = freshTerm(clause.head, 'given');
      const env = new Env();
      return unify(head, goal, env) && text(copyResolved(head, env)) === text(goal);
    });
  }
  for (const claim of claims) if (!flattenConjunction(claim).every((part) => steps.has(text(part)))) {
    fail('C4', `unjustified claim ${text(claim)}`, claim);
  }
  for (const step of steps.values()) {
    const { goal, by, bindings, uses } = step;
    for (const use of uses) if (!covered(use)) fail('C4', `unjustified use ${text(use)}`, goal);
    if (is(by, 'rule', 1) || is(by, 'fact', 1)) {
      const cited = by.args[0];
      const id = Number(cited.name);
      const clause = cited.type === NUMBER && /^\d+$/.test(cited.name) && program.clauses[id - 1];
      if (!clause) { fail('C1', `unknown clause ${text(by)}`, goal); continue; }
      if (by.name === 'fact' && (clause.forward || clause.body.length)) { fail('C1', 'fact justification cites a rule', goal); continue; }
      const names = new Map();
      const head = freshTerm(clause.head, `check${id}`, names);
      const body = clause.body.map((item) => freshTerm(item, `check${id}`, names));
      const env = new Env();
      const seen = new Set();
      let valid = true;
      for (const binding of bindings) {
        if (!is(binding, '=', 2) || binding.args[0].type !== ATOM ||
            !names.has(binding.args[0].name) || seen.has(binding.args[0].name)) { valid = false; break; }
        seen.add(binding.args[0].name);
        if (!unify(names.get(binding.args[0].name), binding.args[1], env)) valid = false;
      }
      const heads = clause.forward ? flattenConjunction(head) : [head];
      let resolution = false;
      for (const candidate of heads) {
        const next = env.clone();
        if (!unify(candidate, goal, next) || body.length !== uses.length) continue;
        let matches = true;
        for (let i = 0; i < body.length; i++) {
          if (!unify(body[i], uses[i], next)) { matches = false; break; }
        }
        if (matches && text(copyResolved(candidate, next)) === text(goal) &&
            body.every((item, i) => text(copyResolved(item, next)) === text(uses[i]))) resolution = true;
      }
      if (!valid || !resolution) fail('C1', `not an instance of source clause ${id}: ${text(goal)}`, goal);
      else verified++;
    } else if (is(by, 'builtin', 0)) {
      if (bindings.length || uses.length || !primitiveKeys.has(key(goal))) { fail('C3', 'invalid builtin justification', goal); continue; }
      let agrees = false;
      try {
        for (const env of primitive(goal, new Env())) {
          if (text(copyResolved(goal, env)) === text(goal)) { agrees = true; break; }
        }
      } catch { /* A primitive that cannot be recomputed does not pass C5. */ }
      if (!agrees) fail('C5', `primitive disagrees: ${text(goal)}`, goal);
      else redecided++;
    } else if (is(by, 'control', 0)) {
      let candidates = [];
      if (is(goal, 'call', 1) || is(goal, 'once', 1)) candidates = [goal.args[0]];
      else if (is(goal, ';', 2)) candidates = goal.args;
      const valid = !bindings.length && candidates.some((candidate) => {
        const parts = flattenConjunction(candidate);
        return parts.length === uses.length && parts.every((part, i) => text(part) === text(uses[i]));
      });
      if (!valid) fail('C5', `control step does not follow from its uses: ${text(goal)}`, goal);
      else composed++;
    } else if ((is(by, 'absent', 0) && is(goal, '\\+', 1)) ||
               (is(by, 'collected', 0) && is(goal, 'findall', 3))) {
      if (bindings.length || uses.length) fail('C3', 'trusted boundaries cannot have bindings or uses', goal);
      trusted.push(withTerm({ kind: by.name, conclusion: text(goal) }, goal));
      if (options.allowTrusted === false) fail('C5', `trusted boundary forbidden: ${by.name}`, goal);
    } else fail('C3', `unknown justification ${text(by)}`, goal);
  }
  const visiting = new Set();
  const visited = new Set();
  const visit = (id) => {
    if (visiting.has(id)) { fail('C2', `cyclic derivation at ${id}`, steps.get(id).goal); return; }
    if (visited.has(id)) return;
    visiting.add(id);
    for (const use of steps.get(id)?.uses ?? []) {
      for (const part of flattenConjunction(use)) if (steps.has(text(part))) visit(text(part));
    }
    visiting.delete(id); visited.add(id);
  };
  for (const id of steps.keys()) visit(id);
  const uses = [...steps.values()].reduce((count, step) => count + step.uses.length, 0);
  const failed = (condition) => failures.filter((failure) => failure.condition === condition).length;
  const conditions = [
    { id: 'C1', name: 'resolution', covered: verified, failed: failed('C1') },
    { id: 'C2', name: 'well_founded', covered: steps.size, failed: failed('C2') },
    { id: 'C3', name: 'justification', covered: steps.size, failed: failed('C3') },
    { id: 'C4', name: 'coverage', covered: claims.length + uses, failed: failed('C4') },
    { id: 'C5', name: 're_decision', covered: redecided + composed, failed: failed('C5') },
  ];
  return { valid: failures.length === 0, steps: steps.size, claims: claims.length,
    verified, redecided, composed, uses, trusted, failures, conditions };
}

function verdictTerm(report) {
  if (!report.valid) return compound('failed', [numberTerm(report.failures.length)]);
  return atom(report.trusted.length ? 'checked_with_obligations' : 'checked');
}

// One formatter backs CLI output, saved example checks and embedding callers.
// Every report includes all five conditions, even when a condition covered 0.
export function checkReportTerms(report) {
  const facts = [];
  for (const condition of report.conditions) {
    facts.push(compound('condition', [atom(condition.id), atom(condition.name),
      condition.failed ? compound('failed', [numberTerm(condition.failed)]) : atom('ok'),
      numberTerm(condition.covered)]));
  }
  for (const failure of report.failures) {
    facts.push(compound('failure', [atom(failure.condition),
      failure.term ?? atom(failure.conclusion ?? 'proof_document'), atom(failure.detail)]));
  }
  for (const item of report.trusted) {
    facts.push(compound('obligation', [atom(item.kind), atom(item.reason ?? 'theory_scoped'),
      item.term ?? atom(item.conclusion)]));
  }
  for (const [name, count] of [
    ['steps', report.steps], ['verified', report.verified], ['recomputed', report.redecided],
    ['composed', report.composed], ['trusted', report.trusted.length], ['claims', report.claims],
  ]) facts.push(compound(name, [numberTerm(count)]));
  facts.push(compound('verdict', [verdictTerm(report)]));
  return facts.map((fact) => `${text(fact)}.\n`).join('');
}

export function verdictTermText(report) {
  return `${text(compound('verdict', [verdictTerm(report)]))}.\n`;
}
