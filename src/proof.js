import {
  Env, VAR, ATOM, COMPOUND, NUMBER, atom, compound, numberTerm, unify, deref,
  freshTerm, copyResolved, properListItems, listFromItems, flattenConjunction, termIsGround,
} from './kernel/term.js';
import { parseProgramText, parseGoalText } from './kernel/parser.js';
import { Program, controlKeys } from './program.js';
import { primitive, primitiveKeys } from './builtins.js';
import { is, key, text, callable, addTo, freshClause, conjunction } from './common.js';

function template(term) {
  if (term.type === VAR) return compound('var', [atom(term.name)]);
  return term.type === COMPOUND ? compound(term.name, term.args.map(template)) : term;
}
// Whether term, read through env, is exactly target, variables included. This is
// the comparison of their printed forms, made without copying or printing.
function resolvesTo(term, env, target) {
  const pending = [term, target];
  while (pending.length) {
    const expected = pending.pop();
    const actual = deref(pending.pop(), env);
    if (actual.type !== expected.type || actual.name !== expected.name || actual.args.length !== expected.args.length) return false;
    for (let i = actual.args.length - 1; i >= 0; i--) pending.push(actual.args[i], expected.args[i]);
  }
  return true;
}
export function renderProof(program, claims, roots) {
  const steps = new Map();
  const clauses = new Set();
  const pending = [...roots].reverse();
  while (pending.length) {
    const node = pending.pop();
    const id = text(node.goal);
    if (steps.has(id)) continue;
    steps.set(id, node);
    if (node.by.arity) clauses.add(Number(node.by.args[0].name));
    for (let index = node.children.length - 1; index >= 0; index--) pending.push(node.children[index]);
  }
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
// options.goals names the goals the proof answers when they were asked from
// outside the program, as with --goal.
export function checkProof(source, document, options = {}) {
  const program = source instanceof Program ? source : Program.parse(source);
  const failures = [];
  const fail = (condition, detail, term = null) => failures.push(withTerm({
    condition, detail, ...(term ? { conclusion: text(term) } : {}),
  }, term));
  const { claims, steps } = readDocument(program, document, fail);
  if (!steps.size || !claims.length) fail('C4', 'a proof needs claims and steps');
  for (const claim of claims) if (!flattenConjunction(claim).every((part) => steps.has(text(part)))) {
    fail('C4', `unjustified claim ${text(claim)}`, claim);
  }
  const { verified, redecided, composed, boundaries, trusted } = checkSteps(program, steps, options, fail);
  const confronted = checkBoundaries(program, steps, boundaries, fail);
  checkRelevance(program, claims, steps, options, fail);
  checkWellFounded(steps, fail);

  const uses = [...steps.values()].reduce((count, step) => count + step.uses.length, 0);
  const failed = (condition) => failures.filter((failure) => failure.condition === condition).length;
  const conditions = [
    { id: 'C1', name: 'resolution', covered: verified, failed: failed('C1') },
    { id: 'C2', name: 'well_founded', covered: steps.size, failed: failed('C2') },
    { id: 'C3', name: 'justification', covered: steps.size, failed: failed('C3') },
    { id: 'C4', name: 'coverage', covered: claims.length + uses, failed: failed('C4') },
    { id: 'C5', name: 're_decision', covered: redecided + composed, failed: failed('C5') },
    { id: 'C6', name: 'boundary_consistency', covered: confronted, failed: failed('C6') },
    { id: 'C7', name: 'relevance', covered: claims.length + steps.size, failed: failed('C7') },
  ];
  return { valid: failures.length === 0, steps: steps.size, claims: claims.length,
    verified, redecided, composed, uses, trusted, failures, conditions };
}

// Keep the printable report easy to serialize while retaining the actual
// conclusion term for a report another Prolog program can reason over.
function withTerm(record, term) {
  if (term) Object.defineProperty(record, 'term', { value: term });
  return record;
}

// C3: split a document into its claims and its steps, keyed by the text of the
// goal each step justifies. clause/3 records are compared with the source.
function readDocument(program, document, fail) {
  const claims = [];
  const steps = new Map();
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
  return { claims, steps };
}

// C4, C1, C3 and C5 for each step in turn: every use is justified, and the step
// is an instance of the clause it cites, a recomputed primitive, a control
// composed of its uses, or a trusted boundary the later checks confront.
function checkSteps(program, steps, options, fail) {
  const tally = { verified: 0, redecided: 0, composed: 0, boundaries: [], trusted: [] };
  const covered = (goal) => {
    if (is(goal, ',', 2)) return flattenConjunction(goal).every(covered);
    if (steps.has(text(goal))) return true;
    // Source facts are available as leaves, including universal fact clauses.
    return (program.groups.get(key(goal)) ?? []).some((clause) => {
      if (clause.body.length) return false;
      const head = freshTerm(clause.head, 'given');
      const env = new Env();
      return unify(head, goal, env) && resolvesTo(head, env, goal);
    });
  };
  for (const step of steps.values()) {
    const { goal, by, bindings, uses } = step;
    for (const use of uses) if (!covered(use)) fail('C4', `unjustified use ${text(use)}`, goal);
    if (is(by, 'rule', 1) || is(by, 'fact', 1)) {
      if (checkResolution(program, step, fail)) tally.verified++;
    } else if (is(by, 'builtin', 0)) {
      if (bindings.length || uses.length || !primitiveKeys.has(key(goal))) { fail('C3', 'invalid builtin justification', goal); continue; }
      let agrees = false;
      try {
        for (const env of primitive(goal, new Env())) {
          if (resolvesTo(goal, env, goal)) { agrees = true; break; }
        }
      } catch { /* A primitive that cannot be recomputed does not pass C5. */ }
      if (!agrees) fail('C5', `primitive disagrees: ${text(goal)}`, goal);
      else tally.redecided++;
    } else if (is(by, 'control', 0)) {
      let candidates = [];
      if (is(goal, 'call', 1) || is(goal, 'once', 1)) candidates = [goal.args[0]];
      else if (is(goal, ';', 2)) candidates = goal.args;
      const valid = !bindings.length && candidates.some((candidate) => {
        const parts = flattenConjunction(candidate);
        return parts.length === uses.length && parts.every((part, i) => text(part) === text(uses[i]));
      });
      if (!valid) fail('C5', `control step does not follow from its uses: ${text(goal)}`, goal);
      else tally.composed++;
    } else if ((is(by, 'absent', 0) && is(goal, '\\+', 1)) ||
               (is(by, 'collected', 0) && is(goal, 'findall', 3))) {
      if (bindings.length || uses.length) fail('C3', 'trusted boundaries cannot have bindings or uses', goal);
      tally.boundaries.push(goal);
      tally.trusted.push(withTerm({ kind: by.name, conclusion: text(goal) }, goal));
      if (options.allowTrusted === false) fail('C5', `trusted boundary forbidden: ${by.name}`, goal);
    } else fail('C3', `unknown justification ${text(by)}`, goal);
  }
  return tally;
}

// C1: a rule or fact step names a source clause, its bindings name distinct
// variables of that clause, and under them one of the clause's heads is the
// step's goal and its body is exactly the step's uses.
function checkResolution(program, { goal, by, bindings, uses }, fail) {
  const cited = by.args[0];
  const id = Number(cited.name);
  const clause = cited.type === NUMBER && /^\d+$/.test(cited.name) && program.clauses[id - 1];
  if (!clause) { fail('C1', `unknown clause ${text(by)}`, goal); return false; }
  if (by.name === 'fact' && (clause.forward || clause.body.length)) { fail('C1', 'fact justification cites a rule', goal); return false; }
  const { head, body, names } = freshClause(clause, `check${id}`);
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
    const mark = env.mark();
    let matches = unify(candidate, goal, env) && body.length === uses.length;
    for (let i = 0; matches && i < body.length; i++) {
      if (!unify(body[i], uses[i], env)) matches = false;
    }
    if (matches && resolvesTo(candidate, env, goal) &&
        body.every((item, i) => resolvesTo(item, env, uses[i]))) resolution = true;
    env.undo(mark);
  }
  if (!valid || !resolution) { fail('C1', `not an instance of source clause ${id}: ${text(goal)}`, goal); return false; }
  return true;
}

// C6: a trusted boundary cannot be proved, but it can be refuted by evidence
// already at hand. An absence fails when a source fact, a step of this
// certificate or a recomputed primitive is a solution; a collection fails
// when such a solution is missing from its list. Returns how many boundaries
// the evidence could speak for.
function checkBoundaries(program, steps, boundaries, fail) {
  const stepGoals = new Map();
  for (const { goal } of steps.values()) if (goal.type !== VAR) addTo(stepGoals, key(goal), goal);
  let serial = 0;
  let confronted = 0;
  // Each solution of a simple goal that the evidence shows, as a term to unify
  // with it; a goal the evidence cannot speak for yields null.
  const evidence = (goal) => {
    if (!callable(goal)) return null;
    if (primitiveKeys.has(key(goal))) {
      if (!termIsGround(goal, new Env())) return null;
      try { for (const _ of primitive(goal, new Env())) return [goal]; } catch { return null; }
      return [];
    }
    if (controlKeys.has(key(goal))) return null;
    const facts = (program.groups.get(key(goal)) ?? []).filter((clause) => !clause.body.length && !clause.forward)
      .map((clause) => freshTerm(clause.head, `evidence${++serial}`));
    return [...facts, ...(stepGoals.get(key(goal)) ?? []).map((item) => freshTerm(item, `evidence${++serial}`))];
  };
  for (const boundary of boundaries) {
    if (is(boundary, '\\+', 1)) {
      const parts = flattenConjunction(boundary.args[0]);
      // Without a join, only a single goal or a ground conjunction is decided.
      if (parts.length > 1 && !termIsGround(boundary.args[0], new Env())) continue;
      const shown = parts.map(evidence);
      if (shown.some((items) => items == null)) continue;
      confronted++;
      const solved = parts.every((part, i) => shown[i].some((item) => unify(freshTerm(part, `absent${++serial}`), item, new Env())));
      if (solved) fail('C6', `absence contradicted by evidence: ${text(boundary)}`, boundary);
    } else {
      const items = properListItems(boundary.args[2], new Env());
      if (!items) { fail('C6', `collected result is not a proper list: ${text(boundary)}`, boundary); continue; }
      const parts = flattenConjunction(boundary.args[1]);
      const shown = parts.length === 1 ? evidence(parts[0]) : null;
      if (shown == null) continue;
      confronted++;
      for (const item of shown) {
        const names = new Map();
        const pattern = freshTerm(boundary.args[0], `collect${++serial}`, names);
        const goal = freshTerm(parts[0], `collect${serial}`, names);
        const env = new Env();
        if (!unify(goal, item, env)) continue;
        const answer = copyResolved(pattern, env);
        const listed = items.some((element) => unify(answer, freshTerm(element, `listed${++serial}`), new Env()));
        if (!listed) { fail('C6', `collection misses ${text(answer)}: ${text(boundary)}`, boundary); break; }
      }
    }
  }
  return confronted;
}

// C7: the certificate answers the question that was asked and carries
// nothing beside it. A claim is an instance of a goal asked from outside,
// of a `true :+ Goal` goal or, for printed conclusions, of a forward head.
function checkRelevance(program, claims, steps, options, fail) {
  let serial = 0;
  const instanceOf = (claim, question) => {
    const env = new Env();
    const pattern = freshTerm(question, `asked${++serial}`);
    return unify(pattern, claim, env) && resolvesTo(pattern, env, claim);
  };
  const asked = (options.goals ?? []).map((goal) => (typeof goal === 'string' ? parseGoalText(goal) : goal));
  const halted = claims.some((claim) => is(claim, 'false', 0));
  const questions = [];
  if (asked.length && !halted) questions.push(...asked);
  else {
    for (const clause of program.forward) {
      const heads = flattenConjunction(clause.head);
      if (heads.some((head) => is(head, 'true', 0))) {
        if (!halted && clause.body.length) questions.push(conjunction(clause.body));
      }
      for (const head of heads) if (!is(head, 'true', 0)) questions.push(head);
    }
  }
  for (const claim of claims) {
    if (!questions.some((question) => instanceOf(claim, question))) fail('C7', `claim answers no goal: ${text(claim)}`, claim);
  }
  const reached = new Set();
  const reach = [];
  for (const claim of claims) for (const part of flattenConjunction(claim)) reach.push(text(part));
  while (reach.length) {
    const id = reach.pop();
    if (reached.has(id) || !steps.has(id)) continue;
    reached.add(id);
    for (const use of steps.get(id).uses) for (const part of flattenConjunction(use)) reach.push(text(part));
  }
  for (const [id, step] of steps) if (!reached.has(id)) fail('C7', `step serves no claim: ${id}`, step.goal);
}

// C2: no step depends on itself. Walk the derivation iteratively: a certificate
// is as deep as the search that produced it, which can be far deeper than the
// host stack allows.
function checkWellFounded(steps, fail) {
  const visiting = new Set();
  const visited = new Set();
  const supports = (id) => {
    const used = [];
    for (const use of steps.get(id)?.uses ?? []) {
      for (const part of flattenConjunction(use)) if (steps.has(text(part))) used.push(text(part));
    }
    return used;
  };
  for (const start of steps.keys()) {
    if (visited.has(start)) continue;
    visiting.add(start);
    const stack = [{ id: start, used: supports(start), index: 0 }];
    while (stack.length) {
      const top = stack[stack.length - 1];
      if (top.index >= top.used.length) {
        visiting.delete(top.id); visited.add(top.id); stack.pop(); continue;
      }
      const next = top.used[top.index++];
      if (visiting.has(next)) { fail('C2', `cyclic derivation at ${next}`, steps.get(next).goal); continue; }
      if (visited.has(next)) continue;
      visiting.add(next);
      stack.push({ id: next, used: supports(next), index: 0 });
    }
  }
}

function verdictTerm(report) {
  if (!report.valid) return compound('failed', [numberTerm(report.failures.length)]);
  return atom(report.trusted.length ? 'checked_with_obligations' : 'checked');
}

// One formatter backs CLI output, saved example checks and embedding callers.
// Every report includes all seven conditions, even when a condition covered 0.
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
