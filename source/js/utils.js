import { append, tap, curry, uniq, map, set, lensProp, has } from "ramda";
import ow from "ow";
import { spawn } from "child_process";
import "dot-into";

export const log = tap(console.log);

export const prepend = curry((prep, text) => prep + text);

export const multiGroupBy = curry((getGroups, list) =>
  list
    .reduce(
      (r, item) =>
        getGroups(item).reduce(
          (r, group) =>
            set(
              lensProp(group),
              append(item, has(group, r) ? r[group] : []),
              r,
            ),
          r,
        ),
      {},
    )
    .into(map(uniq)),
);

export const toJson = (data) => JSON.stringify(data, null, "\t");

export const isUrl = (url) => ow.isValid(url, ow.string.url);

export const run = (command) => {
  const [cmd, ...args] = command.split(" ");
  return spawn(cmd, args, { stdio: "inherit" });
};
