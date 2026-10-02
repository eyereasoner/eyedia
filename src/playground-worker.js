// Runs one program for playground.html. Reasoning happens off the page's main
// thread, so a long search cannot freeze the editor, and stopping a run is a
// matter of terminating this worker.
import { run, checkProof, checkReportTerms } from '../index.js';

self.onmessage = ({ data }) => {
  const { source, goal, proof, check, strict, limits } = data;
  const started = performance.now();
  try {
    const options = { ...limits };
    if (goal) options.goal = goal;
    // Checking needs a certificate even when the proof itself is not shown.
    const result = run(source, { ...options, proof: Boolean(proof || check) });
    const answers = result.answers.map((answer) => `${answer}.\n`).join('');
    let report = null;
    if (check && result.answers.length) {
      // A generated proof is already checked once; a strict check is a
      // different question, so it gets its own run of the checker.
      const verdict = strict ? checkProof(source, result.proof, { allowTrusted: false }) : result.proofReport;
      report = { text: checkReportTerms(verdict), valid: verdict.valid, trusted: verdict.trusted.length };
    }
    self.postMessage({
      ok: true,
      output: proof ? result.proof : answers,
      answers: result.answers.length,
      report,
      stats: result.stats,
      haltCode: result.haltCode,
      milliseconds: performance.now() - started,
    });
  } catch (error) {
    self.postMessage({ ok: false, error: error?.message ?? String(error), milliseconds: performance.now() - started });
  }
};

self.postMessage({ type: 'ready' });
