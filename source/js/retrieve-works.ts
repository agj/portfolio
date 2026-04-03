import * as R from "ramda";
import { fromEntries, last, mapValues, mergeDeep, values } from "remeda";
import fs from "node:fs";
import path from "path";
import { glob } from "glob";
import matter from "gray-matter";
import * as z from "zod";
import "dot-into";
import cfg, { defaultLanguageId, type LanguageId } from "./config.ts";
import { isUrl } from "./utils.ts";

// Types

type NormalizedLanguageId = Exclude<
  LanguageId | "default",
  typeof defaultLanguageId
>;

type Work = z.output<typeof workSchema>;

type NormalizedWork = {
  [key in NormalizedLanguageId]: key extends "default"
    ? NormalizedDefaultLanguage
    : NormalizedLanguage;
};

type DefaultLanguage = z.output<typeof defaultLanguageSchema>;

type NormalizedDefaultLanguage = DefaultLanguage & {
  mainVisualUrl: string;
  mainVisualMetaUrl: string;
  visuals: NormalizedVisual[];
  date: string;
};

type Language = z.output<typeof languageSchema>;

type NormalizedLanguage = Language & {
  mainVisualUrl: string;
  mainVisualMetaUrl: string;
  visuals: NormalizedVisual[];
  links: Link[];
  date: string;
};

type Visual = z.output<typeof visualSchema>;

type NormalizedVisual = Visual &
  (
    | {
        url: string;
        thumbnailUrl: string;
        retrieveUrl: string;
        metaUrl: string;
      }
    | {
        thumbnailUrl: string;
        metaUrl: string;
      }
  );

type Link = z.output<typeof linkSchema>;

// Utils

const getFileName = (p: string): string =>
  getLastDir(p)?.split(".").into(R.init).join("") ?? "";

const getLastDir = (p: string): string | undefined =>
  p
    .split(path.sep)
    .filter((s) => s !== "")
    .into(last());

const fileStandardToLanguageId = (id: string) =>
  id === "default" ? cfg.languages[0] : id;

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
    type: z.literal(cfg.visualType.image),
    url: pathSchema,
  }),
  z.object({
    type: z.literal(cfg.visualType.video),
    host: z.enum(values(cfg.hostType)),
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
  tags: z.array(z.string()).min(1),
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
  return R.mergeRight(parsed.data, { description: parsed.content });
};

const normalizeWork = async (
  workRaw: unknown,
  workName: string,
): Promise<NormalizedWork> => {
  const workParseResult = workSchema.safeParse(workRaw);

  if (!workParseResult.success) {
    throw `Error in work '${workName}'`;
  }

  const work: Work = workParseResult.data;

  const def = {
    ...work.default,
    mainVisualUrl: `${workName}/${await getMainVisualFilename(workName)}`,
    mainVisualMetaUrl: `${workName}/${await getMainVisualFilename(workName)}.meta.json`,
    visuals: [],
    links: [],
  };

  const processedReadMore = mapValues(
    work,
    (language, id): Language & { readMore: string } => ({
      ...language,
      readMore: normalizeReadMore(id, def.readMore, language.readMore),
    }),
  );

  return mapValues(processedReadMore, mergeDeep(def)).into(
    mapValues((o) => ({
      ...o,
      visuals: o.visuals.map(normalizeVisual(workName)),
      date: o.date.toString(),
    })),
  );
};

const getMainVisualFilename = async (workName: string) => {
  const mainFiles = await glob(`${cfg.worksDir}${workName}/main.*`);
  if (!mainFiles[0]) {
    throw `No main visual file (main.jpg/.png) for work ${workName}!`;
  }
  return path.parse(mainFiles[0]).base;
};

const normalizeVisual =
  (workName: string) =>
  (visual: Visual): NormalizedVisual => {
    if (visual.type === cfg.visualType.image) {
      const localPath = toLocalPath(workName, visual.url);
      return R.mergeRight(visual, {
        url:
          "url" in visual && isUrl(visual.url)
            ? visual.url
            : toLocalPath(workName, visual.url),
        thumbnailUrl: toThumbnailPath(workName, visual.url),
        retrieveUrl: visual.url,
        metaUrl: `${localPath}.meta.json`,
      });
    } else if (visual.type === cfg.visualType.video) {
      return R.mergeRight(visual, {
        thumbnailUrl: `${workName}/${visual.host}-${visual.id}-thumb.jpg`,
        metaUrl: `${workName}/${visual.host}-${visual.id}.meta.json`,
      });
    }

    throw `Visual for work '${workName}' has wrong type`;
  };

const normalizeReadMore = R.curry((langId, defUrl, url) => {
  return url
    ? { url: url, language: fileStandardToLanguageId(langId) }
    : defUrl
      ? { url: defUrl, language: cfg.languages[0] }
      : undefined;
});

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
): Promise<[string, NormalizedWork]> => [
  workName,
  await retrieveWork(workName),
];

const retrieveWork = async (workName: string): Promise<NormalizedWork> => {
  const folder = `${cfg.worksDir}${workName}/`;
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

export const retrieveWorks = async (): Promise<
  Record<string, NormalizedWork>
> => {
  const workNames = (await glob(`${cfg.worksDir}*/`))
    .map(getLastDir)
    .filter((s): s is string => !!s);

  const workPairs = await Promise.all(workNames.map(retrieveWorkAsPair));

  return fromEntries(workPairs);
};
