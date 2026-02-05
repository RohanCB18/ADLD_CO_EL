import React, { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import {
  bytesToHex,
  encryptBlockWithTrace,
  hexToBytes,
  stateToMatrix,
} from "./lib/aes128";
import RoundCard from "./components/RoundCard";
import StateMatrix from "./components/StateMatrix";

const DEFAULT_PLAINTEXT = "00112233445566778899aabbccddeeff";
const DEFAULT_KEY = "000102030405060708090a0b0c0d0e0f";

const sanitizeHex = (value) => value.replace(/[^0-9a-f]/gi, "").toLowerCase();

const toMatrixString = (matrix) =>
  matrix
    .map((row) => row.map((value) => value.toString(16).padStart(2, "0")).join(" "))
    .join("\n");

const getRoundDescription = (round) => {
  if (round === 0) {
    return "The initial round performs 'Key Whitening'. The 128-bit key is XORed directly with the plaintext to mask the input data before processing begins.";
  }
  if (round === 10) {
    return "The final round of encryption. It is similar to the standard rounds but omits the 'MixColumns' step. This structure is crucial for the reversibility of the cipher during decryption.";
  }
  return "A standard round of AES encryption. It applies four distinct transformations: non-linear substitution (SubBytes), row shifting (ShiftRows), column mixing (MixColumns), and key addition (AddRoundKey) to scramble the data.";
};

const App = () => {
  const [plaintextHex, setPlaintextHex] = useState(DEFAULT_PLAINTEXT);
  const [keyHex, setKeyHex] = useState(DEFAULT_KEY);
  const [error, setError] = useState("");

  const sanitizedPlaintext = useMemo(
    () => sanitizeHex(plaintextHex),
    [plaintextHex],
  );
  const sanitizedKey = useMemo(() => sanitizeHex(keyHex), [keyHex]);

  const result = useMemo(() => {
    try {
      const plaintext = hexToBytes(sanitizedPlaintext);
      const key = hexToBytes(sanitizedKey);
      setError("");
      return encryptBlockWithTrace(plaintext, key);
    } catch (err) {
      setError(err.message);
      return null;
    }
  }, [sanitizedPlaintext, sanitizedKey]);

  const [currentRound, setCurrentRound] = useState(0);

  // Reset round when inputs change to avoid out-of-bounds errors
  React.useEffect(() => {
    setCurrentRound(0);
  }, [sanitizedPlaintext, sanitizedKey]);

  return (
    <div className="min-h-screen bg-slate-50 pb-16 text-slate-900">
      <div className="mx-auto flex w-full max-w-[90rem] flex-col gap-10 px-4 pt-12 sm:px-8">
        {/* Navigation Tabs */}
        <nav className="flex gap-2">
          <Link
            to="/"
            className="rounded-full border border-emerald-200 bg-emerald-50 px-6 py-2.5 text-sm font-bold uppercase tracking-widest text-emerald-700"
          >
            🔐 Encryption
          </Link>
          <Link
            to="/decrypt"
            className="rounded-full border border-slate-200 bg-white px-6 py-2.5 text-sm font-bold uppercase tracking-widest text-slate-600 transition hover:border-rose-200 hover:text-rose-700"
          >
            🔓 Decryption
          </Link>
        </nav>

        <header className="rounded-2xl border border-slate-200 bg-white p-10 shadow-sm">
          <p className="mb-3 text-sm uppercase tracking-[0.65em] text-emerald-600 font-bold">
            Demonstration
          </p>
          <h1 className="text-3xl font-bold text-slate-900 sm:text-4xl lg:text-5xl">
            AES-128 Encryption Round-by-Round Visualizer
          </h1>
          <p className="mt-4 max-w-3xl text-base text-slate-600">
            Explore how Advanced Encryption Standard (AES) transforms a 128-bit
            plaintext block through its substitution, permutation, and mixing
            steps. Adjust the plaintext and key to see each round update in real
            time.
          </p>
        </header>

        <section className="grid gap-8 lg:grid-cols-[24rem_1fr]">
          <aside className="space-y-6">
            <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
              <h2 className="text-base font-bold uppercase tracking-[0.3em] text-emerald-600">
                Inputs
              </h2>
              <p className="mt-2 text-sm text-slate-500">
                Provide 16-byte (128-bit) values as hexadecimal strings. Uses standard FIPS-197 vectors.
              </p>
              <div className="mt-5 space-y-4">
                <label className="block text-sm font-bold uppercase tracking-[0.2em] text-slate-500">
                  Plaintext (hex)
                  <textarea
                    className="mt-2 w-full rounded-xl border border-slate-300 bg-slate-50 p-3 font-mono text-sm uppercase text-slate-800 shadow-inner focus:border-emerald-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                    rows={2}
                    value={plaintextHex}
                    onChange={(event) => setPlaintextHex(event.target.value)}
                  />
                </label>
                <label className="block text-sm font-bold uppercase tracking-[0.2em] text-slate-500">
                  Key (hex)
                  <textarea
                    className="mt-2 w-full rounded-xl border border-slate-300 bg-slate-50 p-3 font-mono text-sm uppercase text-slate-800 shadow-inner focus:border-emerald-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                    rows={2}
                    value={keyHex}
                    onChange={(event) => setKeyHex(event.target.value)}
                  />
                </label>
              </div>
              <div className="mt-5 flex flex-wrap gap-3">
                <button
                  type="button"
                  className="rounded-full border border-emerald-200 bg-emerald-50 px-4 py-2 text-xs font-bold uppercase tracking-[0.25em] text-emerald-700 transition hover:bg-emerald-100"
                  onClick={() => {
                    setPlaintextHex(DEFAULT_PLAINTEXT);
                    setKeyHex(DEFAULT_KEY);
                  }}
                >
                  Use FIPS-197 sample
                </button>
                <button
                  type="button"
                  className="rounded-full border border-slate-200 bg-white px-4 py-2 text-xs font-bold uppercase tracking-[0.25em] text-slate-600 transition hover:border-emerald-200 hover:text-emerald-700"
                  onClick={() => {
                    const randomBytes = crypto.getRandomValues(new Uint8Array(16));
                    const randomKey = crypto.getRandomValues(new Uint8Array(16));
                    setPlaintextHex(bytesToHex(Array.from(randomBytes)));
                    setKeyHex(bytesToHex(Array.from(randomKey)));
                  }}
                >
                  Randomize
                </button>
              </div>
              {error && (
                <div className="mt-4 rounded-xl border border-rose-200 bg-rose-50 p-3 text-sm text-rose-700">
                  {error}
                </div>
              )}
            </div>

            {result && (
              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                <h3 className="text-sm font-bold uppercase tracking-[0.3em] text-emerald-600">
                  Ciphertext
                </h3>
                <p className="mt-3 rounded-xl border border-emerald-200 bg-emerald-50/50 p-4 font-mono text-sm uppercase tracking-widest text-emerald-900 shadow-inner">
                  {bytesToHex(result.cipherState, " ")}
                </p>
                <p className="mt-4 text-xs text-slate-400">
                  Expected ciphertext for FIPS-197 example: 69 c4 e0 d8 6a 7b
                  04 30 d8 cd b7 80 70 b4 c5 5a
                </p>
              </div>
            )}
          </aside>

          <main className="space-y-8">
            {result ? (
              <>
                {/* Stepper Navigation */}
                <nav className="flex items-center justify-between rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                  <button
                    disabled={currentRound === 0}
                    onClick={() => setCurrentRound((p) => Math.max(0, p - 1))}
                    className="flex w-32 items-center justify-center rounded-lg border border-slate-200 bg-slate-50 px-4 py-2 text-xs font-bold uppercase tracking-widest text-slate-600 transition hover:bg-slate-100 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Previous
                  </button>

                  <div className="flex flex-col items-center">
                    <span className="text-xs font-bold uppercase tracking-[0.2em] text-emerald-600">
                      Round {currentRound} of 10
                    </span>
                    <div className="mt-2 flex gap-1">
                      {new Array(11).fill(0).map((_, i) => (
                        <div
                          key={i}
                          className={`h-1.5 w-6 rounded-full transition-all ${i === currentRound ? "bg-emerald-500 scale-110" : "bg-slate-200"
                            }`}
                        />
                      ))}
                    </div>
                  </div>

                  <button
                    disabled={currentRound === 10}
                    onClick={() => setCurrentRound((p) => Math.min(10, p + 1))}
                    className="flex w-32 items-center justify-center rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-2 text-xs font-bold uppercase tracking-widest text-emerald-700 transition hover:bg-emerald-100 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Next
                  </button>
                </nav>

                <div className="flex flex-col xl:flex-row gap-6">
                  {/* Left Column: Round Visualization (Focus) */}
                  <div className="flex-1 space-y-6">
                    <RoundCard key={result.rounds[currentRound].round} round={result.rounds[currentRound]} />
                  </div>

                  {/* Right Column: Context (Initial State & Keys) */}
                  <div className="xl:w-80 flex flex-col gap-6">
                    <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                      <h2 className="text-xs font-bold uppercase tracking-[0.2em] text-emerald-600 mb-4">
                        Round {currentRound} Overview
                      </h2>
                      <p className="text-sm text-slate-600 leading-relaxed mb-6">
                        {getRoundDescription(currentRound)}
                      </p>

                      <h3 className="text-xs font-bold uppercase tracking-[0.2em] text-slate-400 mb-3">
                        Operations in this step
                      </h3>
                      <div className="space-y-3">
                        {result.rounds[currentRound].operations.map((op, i) => (
                          <div key={i} className="rounded-lg border border-slate-100 bg-slate-50 p-3">
                            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-700">
                              {op.name}
                            </h4>
                            <p className="mt-1 text-sm text-slate-600 leading-relaxed">
                              {op.description}
                            </p>
                          </div>
                        ))}
                      </div>
                    </section>
                    <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                      <h2 className="text-xs font-bold uppercase tracking-[0.2em] text-emerald-600 mb-4">
                        Initial State
                      </h2>
                      <div className="flex justify-center">
                        <StateMatrix
                          matrix={stateToMatrix(hexToBytes(sanitizedPlaintext))}
                          accent="bg-emerald-100"
                        />
                      </div>
                    </section>

                    <section className="flex-1 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm flex flex-col min-h-[16rem]">
                      <h2 className="text-xs font-bold uppercase tracking-[0.2em] text-emerald-600 mb-2">
                        Round Key {currentRound}
                      </h2>
                      <div className="rounded-lg border border-slate-200 bg-slate-50 p-4 font-mono text-xs uppercase tracking-widest text-slate-600 break-all">
                        {bytesToHex(result.roundKeys[currentRound], " ")}
                      </div>

                      <div className="mt-auto pt-6">
                        <h3 className="text-xs font-semibold text-slate-400 mb-2 uppercase tracking-wider">Full Key Schedule</h3>
                        <div className="h-40 overflow-y-auto pr-2 custom-scrollbar text-[0.65rem] font-mono text-slate-400 space-y-1">
                          {result.roundKeys.map((k, i) => (
                            <div key={i} className={`flex gap-2 ${i === currentRound ? "text-emerald-600 font-bold" : ""}`}>
                              <span className="opacity-50 min-w-[3ch]">{i}:</span>
                              <span>{bytesToHex(k, "")}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    </section>
                  </div>
                </div>

              </>
            ) : (
              <section className="rounded-2xl border border-slate-200 bg-white p-10 text-center">
                <h2 className="text-xl font-bold uppercase tracking-[0.35em] text-emerald-600">
                  Awaiting valid inputs
                </h2>
                <p className="mt-3 text-sm text-slate-500">
                  Provide 16-byte plaintext and key values in hexadecimal to
                  visualize the complete AES-128 encryption process.
                </p>
              </section>
            )}
          </main>
        </section>

        <footer className="border-t border-slate-200 pt-8 text-xs text-slate-400">
          <p>
            AES-128 uses 10 rounds: the first (round 0) performs key whitening,
            rounds 1-9 apply SubBytes, ShiftRows, MixColumns, and AddRoundKey,
            and the final round (10) omits MixColumns. This simulator follows
            that specification exactly and shows state matrices after each step.
          </p>
        </footer>
      </div>
    </div>
  );
};

export default App;
