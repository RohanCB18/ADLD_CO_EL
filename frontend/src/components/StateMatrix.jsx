import React from "react";
import PropTypes from "prop-types";
import { bytesToHex } from "../lib/aes128";

const MatrixCell = ({ value, highlight }) => (
  <div
    className={`flex h-12 w-12 items-center justify-center rounded-md border border-slate-200 text-sm font-mono uppercase tracking-widest transition-all duration-200 ${highlight}`}
  >
    {bytesToHex([value])}
  </div>
);

MatrixCell.propTypes = {
  value: PropTypes.number.isRequired,
  highlight: PropTypes.string,
};

MatrixCell.defaultProps = {
  highlight: "",
};

const StateMatrix = ({ matrix, accent }) => (
  <div className="overflow-hidden rounded-xl border border-slate-200 bg-white p-3 shadow-md shadow-slate-200/50">
    <div className="grid grid-cols-4 gap-3">
      {matrix.map((row, rowIndex) =>
        row.map((value, colIndex) => (
          <MatrixCell
            // eslint-disable-next-line react/no-array-index-key
            key={`${rowIndex}-${colIndex}`}
            value={value}
            highlight={
              rowIndex === colIndex
                ? `${accent} shadow-inner shadow-emerald-500/10 text-emerald-900 font-bold`
                : "bg-slate-50 text-slate-500"
            }
          />
        )),
      )}
    </div>
  </div>
);

StateMatrix.propTypes = {
  matrix: PropTypes.arrayOf(
    PropTypes.arrayOf(PropTypes.number.isRequired).isRequired,
  ).isRequired,
  accent: PropTypes.string,
};

StateMatrix.defaultProps = {
  accent: "bg-emerald-100",
};

export default StateMatrix;
