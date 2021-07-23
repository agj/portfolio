import R from "ramda";
import ow from "ow";
import { spawn } from "child_process";
import dotInto from "dot-into";

dotInto.install();

export const log = R.tap(console.log);

export const prepend = R.curry((prep, text) => prep + text);

export const multiGroupBy = R.curry((getGroups, list) =>
  list
    .reduce(
      (r, item) =>
        getGroups(item).reduce(
          (r, group) =>
            R.set(
              R.lensProp(group),
              R.append(item, R.has(group, r) ? r[group] : []),
              r
            ),
          r
        ),
      {}
    )
    .into(R.map(R.uniq))
);

export const toJson = (data) => JSON.stringify(data, null, "\t");

export const isUrl = (url) => ow.isValid(url, ow.string.url);

export const run = (program, options, furtherOptions) => {
  const [cmd, ...cmds] = program.split(" ");
  const opts = cmds.concat(optionsToArray(options));
  const allOpts = furtherOptions
    ? append("--", opts).concat(optionsToArray(furtherOptions))
    : opts;

  const proc = spawn(cmd || "echo", allOpts, {
    shell: true,
    stdio: "inherit",
  });

  return proc;
};
