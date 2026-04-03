import path from "node:path";
import fs from "node:fs";
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

export const ensureDirForFile = (filePath: string): void => {
  const { dir } = path.parse(filePath);
  fs.mkdirSync(dir, { recursive: true });
};
