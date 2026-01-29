import React, { useMemo, useState } from "react";
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

  const cipherHex = result ? bytesToHex(result.cipherState, " ") : "";

  return (
    <div className="min-h-screen bg-slate-50 pb-16 text-slate-900">
      <div className="mx-auto flex w-full max-w-[90rem] flex-col gap-10 px-4 pt-12 sm:px-8">
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
                  {cipherHex}
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
                <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                  <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
                    <div className="md:w-1/2">
                      <h2 className="text-base font-bold uppercase tracking-[0.35em] text-emerald-600">
                        Initial State
                      </h2>
                      <p className="mt-2 text-sm text-slate-500">
                        The plaintext is mapped column-wise into the state matrix
                        before round transformations start.
                      </p>
                    </div>
                    <div className="md:w-1/2 flex justify-center md:justify-end">
                      <StateMatrix
                        matrix={stateToMatrix(hexToBytes(sanitizedPlaintext))}
                        accent="bg-emerald-100"
                      />
                    </div>
                  </div>
                </section>

                <section className="grid gap-6 grid-cols-1 md:grid-cols-2 xl:grid-cols-3 items-stretch">
                  {result.rounds.map((round) => (
                    <RoundCard key={round.round} round={round} />
                  ))}
                  <section className="h-full rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                    <h2 className="text-base font-bold uppercase tracking-[0.35em] text-emerald-600">
                      Round Keys
                    </h2>
                    <p className="mt-2 text-sm text-slate-500 mb-4">
                      11 round keys derived via Rijndael key schedule.
                    </p>
                    <div className="grid gap-3 h-[30rem] overflow-y-auto pr-2 custom-scrollbar">
                      {result.roundKeys.map((roundKey, index) => (
                        <div
                          key={`round-key-${index}`}
                          className="rounded-lg border border-slate-200 bg-slate-50 p-3 font-mono text-xs uppercase tracking-widest text-slate-600"
                        >
                          <p className="mb-1 text-[0.65rem] font-bold tracking-[0.4em] text-emerald-600">
                            Round {index}
                          </p>
                          <pre className="whitespace-pre-wrap break-words">
                            {bytesToHex(roundKey, " ")}
                          </pre>
                        </div>
                      ))}
                    </div>
                  </section>
                </section>
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
