import path from "node:path";
import fs from "node:fs";
import { tap } from "remeda";
import * as z from "zod";
import { spawn } from "child_process";
import "dot-into";

export const log =
  (label?: string) =>
  <T,>(value: T): T => {
    console.log(`${label ? label + ": " : ""}${value}`);
    return value;
  };

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

export const fetchJsonUrl = async <T,>(
  url: string,
  schema: z.ZodType<T>,
): Promise<T> => {
  const response = await fetch(
    new Request(url, {
      method: "GET",
      headers: { "Response-Type": "application/json" },
    }),
  );
  const data = await response.json();

  if (!data) {
    throw new Error(`Fetch failed for: ${url}`);
  }

  const parsed = schema.safeParse(data);

  if (!parsed.success) {
    throw new Error(
      `Failed to parse response from: ${url}\n${JSON.stringify(data)}\n${JSON.stringify(z.formatError(parsed.error))}`,
    );
  }

  return parsed.data;
};

export const fetchBufferUrl = async (url: string): Promise<Buffer> => {
  const response = await fetch(new Request(url, { method: "GET" }));
  const data = await response.arrayBuffer();

  if (!data) {
    throw new Error(`Fetch failed for: ${url}`);
  }

  return Buffer.from(data);
};
