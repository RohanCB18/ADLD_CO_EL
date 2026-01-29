import React from "react";
import PropTypes from "prop-types";
import StateMatrix from "./StateMatrix";
import { bytesToHex, stateToMatrix } from "../lib/aes128";

const OperationRow = ({ operation }) => (
  <div className="rounded-lg border border-slate-200 bg-slate-50 p-4">
    <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
      <div>
        <p className="text-sm font-semibold uppercase tracking-[0.25em] text-slate-500">
          {operation.name}
        </p>
        <p className="mt-1 text-sm text-slate-600">
          {operation.description}
        </p>
      </div>
      {operation.roundKey && (
        <div className="mt-3 text-xs font-mono uppercase md:mt-0">
          <span className="text-slate-500">Round key:</span>{" "}
          <span className="font-semibold text-emerald-600">
            {bytesToHex(operation.roundKey, " ")}
          </span>
        </div>
      )}
    </div>
    <div className="mt-4">
      <StateMatrix
        matrix={stateToMatrix(operation.state)}
        accent="bg-emerald-100"
      />
    </div>
  </div>
);

OperationRow.propTypes = {
  operation: PropTypes.shape({
    name: PropTypes.string.isRequired,
    description: PropTypes.string.isRequired,
    state: PropTypes.arrayOf(PropTypes.number.isRequired).isRequired,
    roundKey: PropTypes.arrayOf(PropTypes.number.isRequired),
  }).isRequired,
};

const RoundCard = ({ round }) => (
  <section className="h-full rounded-2xl border border-slate-200 bg-white p-6 shadow-sm shadow-slate-200/50 transition hover:shadow-md">
    <header className="flex flex-col gap-2 pb-4 md:flex-row md:items-center md:justify-between">
      <div>
        <h3 className="text-lg font-bold uppercase tracking-[0.3em] text-emerald-600">
          {round.round === 0 ? "Initial Round" : `Round ${round.round}`}
        </h3>
        <p className="text-sm text-slate-500">
          {round.round === 0
            ? "Key whitening before main rounds"
            : round.round === 10
              ? "Final round omits MixColumns"
              : "Core AES transformations"}
        </p>
      </div>
    </header>
    <div className="flex flex-col gap-4">
      {round.operations.map((operation) => (
        <OperationRow key={operation.name} operation={operation} />
      ))}
    </div>
  </section>
);

RoundCard.propTypes = {
  round: PropTypes.shape({
    round: PropTypes.number.isRequired,
    operations: PropTypes.arrayOf(
      PropTypes.shape({
        name: PropTypes.string.isRequired,
        description: PropTypes.string.isRequired,
        state: PropTypes.arrayOf(PropTypes.number.isRequired).isRequired,
        roundKey: PropTypes.arrayOf(PropTypes.number.isRequired),
      }).isRequired,
    ).isRequired,
  }).isRequired,
};

export default RoundCard;
