// The ISO processor error type, kept independent of the rest of the kernel so
// the syntax, program and solver layers can report Prolog errors without
// importing one another.
import { termToString } from './term.js';

export class PrologError extends Error {
  constructor(formal, culprit = null) {
    const detail = culprit == null ? formal : `${formal}, ${termToString(culprit)}`;
    super(`error(${detail})`);
    this.name = 'PrologError';
    this.formal = formal;
    this.culprit = culprit;
  }
}
