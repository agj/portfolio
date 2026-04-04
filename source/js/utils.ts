import path from "node:path";
import fs from "node:fs";
import { tap } from "remeda";
import * as z from "zod";
import { spawn } from "child_process";
import "dot-into";
import axios from "axios";

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

export const fetchJsonUrl = async <T,>(
  url: string,
  schema: z.ZodType<T>,
): Promise<T> => {
  const response = await axios.get(url, { responseType: "json" });

  if (!response.data) {
    throw new Error(`Fetch failed for: ${url}`);
  }

  const parsed = schema.safeParse(response.data);

  if (!parsed.success) {
    throw new Error(
      `Failed to parse response from: ${url}\n${JSON.stringify(response.data)}\n${JSON.stringify(z.formatError(parsed.error))}`,
    );
  }

  return parsed.data;
};

export const fetchBufferUrl = async (url: string) => {
  const response = await axios.get(url, { responseType: "arraybuffer" });

  if (!(response.data instanceof Buffer)) {
    throw new Error(`Fetch failed for: ${url}`);
  }

  return response.data;
};
