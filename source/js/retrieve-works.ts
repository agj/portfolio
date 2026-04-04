import { dropLast, fromEntries, last, mapValues, merge } from "remeda";
import fs from "node:fs";
import path from "path";
import { glob } from "tinyglobby";
import matter from "gray-matter";
import * as z from "zod";
import "dot-into";
import {
  defaultLanguageId,
  hostTypes,
  worksDir,
  type HostType,
  type LanguageId,
  type VisualType,
} from "./constants.ts";
import { isUrl } from "./utils.ts";

// Types

type NormalizedLanguageId = Exclude<
  LanguageId | "default",
  typeof defaultLanguageId
>;

type RawWork = z.output<typeof workSchema>;

export type Work = {
  [key in NormalizedLanguageId]: Language;
};

export type Language = {
  description: string;
  name: string;
  readMore: ReadMore | undefined;
  mainVisualUrl: string;
  mainVisualMetaUrl: string;
  tags: [string, ...string[]];
  visuals: Visual[];
  links: Link[];
  date: string;
};

type RawVisual = z.output<typeof visualSchema>;

export type Visual =
  | {
      type: "Image" & VisualType;
      url: string;
      thumbnailUrl: string;
      retrieveUrl: string;
      metaUrl: string;
    }
  | {
      type: "Video" & VisualType;
      host: HostType;
      id: string;
      parameters?: Record<string, string> | undefined;
      thumbnailUrl: string;
      metaUrl: string;
    };

export type Link = z.output<typeof linkSchema>;

export type ReadMore = {
  url: string;
  language: LanguageId;
};

// Utils

const getFileName = (p: string): string =>
  getLastDir(p)?.split(".").into(dropLast(1)).join("") ?? "";

const getLastDir = (p: string): string | undefined =>
  p
    .split(path.sep)
    .filter((s) => s !== "")
    .into(last());

const fileStandardToLanguageId = (id: NormalizedLanguageId): LanguageId =>
  id === "default" ? defaultLanguageId : id;

// Schemas

const pathSchema = z.union([
  z.url(),
  z.string().refine((s) => !s.includes(path.sep)),
]);

const linkSchema = z.object({
  label: z.string(),
  url: z.url(),
});

const visualSchema = z.discriminatedUnion("type", [
  z.object({
    type: z.literal("Image" satisfies VisualType),
    url: pathSchema,
  }),
  z.object({
    type: z.literal("Video" satisfies VisualType),
    host: z.enum(hostTypes),
    id: z.string(),
    parameters: z.record(z.string(), z.string()).optional(),
  }),
]);

const languageSchema = z.object({
  description: z.string(),
  name: z.string().optional(),
  readMore: z.string().optional(),
  visuals: z.array(visualSchema).optional(),
  links: z.array(linkSchema).optional(),
});

const defaultLanguageSchema = z.object({
  description: z.string(),
  name: z.string(),
  tags: z
    .array(z.string())
    .refine((tags): tags is [string, ...string[]] => tags.length >= 1),
  date: z.union([z.string(), z.int()]),
  readMore: z.string().optional(),
  visuals: z.array(visualSchema).optional(),
  links: z.array(linkSchema).optional(),
});

const workSchema = z.object({
  default: defaultLanguageSchema,
  es: languageSchema,
  ja: languageSchema,
} satisfies Record<NormalizedLanguageId, any>);

// Process

const parseMarkdown = (text: string) => {
  const parsed = matter(text);
  return merge(parsed.data, { description: parsed.content });
};

const normalizeWork = async (
  workRaw: unknown,
  workName: string,
): Promise<Work> => {
  const workParseResult = workSchema.safeParse(workRaw);

  if (!workParseResult.success) {
    throw `Error in work '${workName}'`;
  }

  const work: RawWork = workParseResult.data;

  const mainVisualUrl = `${workName}/${await getMainVisualFilename(workName)}`;
  const mainVisualMetaUrl = `${workName}/${await getMainVisualFilename(workName)}.meta.json`;

  return mapValues(
    work,
    (language, langId): Language => ({
      ...work.default,
      ...language,
      name: language.name ?? work.default.name,
      mainVisualUrl,
      mainVisualMetaUrl,
      readMore: normalizeReadMore(
        langId,
        work.default.readMore,
        language.readMore,
      ),
      visuals:
        (language.visuals ?? work.default.visuals)?.map(
          normalizeVisual(workName),
        ) ?? [],
      links: language.links ?? [],
      date: work.default.date.toString(),
    }),
  );
};

const getMainVisualFilename = async (workName: string) => {
  const mainFiles = await glob(`${worksDir}${workName}/main.*`);
  if (!mainFiles[0]) {
    throw `No main visual file (main.jpg/.png) for work ${workName}!`;
  }
  return path.parse(mainFiles[0]).base;
};

const normalizeVisual =
  (workName: string) =>
  (visual: RawVisual): Visual => {
    if (visual.type === "Image") {
      const localPath = toLocalPath(workName, visual.url);
      return merge(visual, {
        url:
          "url" in visual && isUrl(visual.url)
            ? visual.url
            : toLocalPath(workName, visual.url),
        thumbnailUrl: toThumbnailPath(workName, visual.url),
        retrieveUrl: visual.url,
        metaUrl: `${localPath}.meta.json`,
      });
    } else if (visual.type === "Video") {
      return merge(visual, {
        thumbnailUrl: `${workName}/${visual.host}-${visual.id}-thumb.jpg`,
        metaUrl: `${workName}/${visual.host}-${visual.id}.meta.json`,
      });
    }

    throw `Visual for work '${workName}' has wrong type`;
  };

const normalizeReadMore = (
  langId: NormalizedLanguageId,
  defaultUrl: string | undefined,
  url: string | undefined,
): ReadMore | undefined => {
  return url
    ? { url: url, language: fileStandardToLanguageId(langId) }
    : defaultUrl
      ? { url: defaultUrl, language: defaultLanguageId }
      : undefined;
};

const toLocalPath = (workName: string, url: string) => {
  const parsedPath = isUrl(url)
    ? path.parse(url.split("/")?.into(last()) ?? "")
    : path.parse(`${url}`);
  return `${workName}/${parsedPath.dir}${parsedPath.dir ? "/" : ""}${
    parsedPath.base
  }`;
};

const toThumbnailPath = (workName: string, url: string) => {
  const parsedPath = isUrl(url)
    ? path.parse(url.split("/").into(last()) ?? "")
    : path.parse(`${url}`);
  return `${workName}/${parsedPath.dir}${parsedPath.dir ? "/" : ""}${
    parsedPath.name
  }-thumb${parsedPath.ext}`;
};

const retrieveWorkAsPair = async (
  workName: string,
): Promise<[string, Work]> => [workName, await retrieveWork(workName)];

const retrieveWork = async (workName: string): Promise<Work> => {
  const folder = `${worksDir}${workName}/`;
  const languageFiles = await glob(`${folder}*.md`);
  const languagePairs = languageFiles
    .map(getFileName)
    .map((language): [string, string] => [
      language,
      fs.readFileSync(`${folder}${language}.md`, "utf-8"),
    ]);
  const work = fromEntries(languagePairs).into(mapValues(parseMarkdown));
  return normalizeWork(work, workName);
};

// API

export const retrieveWorks = async (): Promise<Record<string, Work>> => {
  const workNames = (await glob(`${worksDir}*/`))
    .map(getLastDir)
    .filter((s): s is string => !!s);

  const workPairs = await Promise.all(workNames.map(retrieveWorkAsPair));

  return fromEntries(workPairs);
};
