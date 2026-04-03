import { tap } from "remeda";
import * as z from "zod";
import { spawn } from "child_process";
import "dot-into";

export const log = tap(console.log);

export const toJson = (data: unknown) => JSON.stringify(data, null, "\t");

export const isUrl = (url: string): boolean => z.url().safeParse(url).success;

export const run = (command: string) => {
  const [cmd, ...args] = command.split(" ");
  if (!cmd) {
    throw new Error("No command specified");
  }
  return spawn(cmd, args, { stdio: "inherit" });
};
