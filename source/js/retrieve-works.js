// @ts-check

import * as R from "ramda";
import fs from "node:fs";
import path from "path";
import { glob } from "glob";
import matter from "gray-matter";
import * as z from "zod";
import "dot-into";

import cfg from "./config.ts";
import { isUrl } from "./utils.ts";
import { constant, identity, indexBy, mapValues, values } from "remeda";

// Utils

const awaitAll = Promise.all.bind(Promise);
const getFileName = (p) => getLastDir(p).split(".").into(R.init).join("");
const getLastDir = (p) =>
  p.split(path.sep).filter(R.complement(R.isEmpty)).into(R.last);

const languageIdToFileStandard = (id) =>
  id === cfg.languages[0] ? "default" : id;
const fileStandardToLanguageId = (id) =>
  id === "default" ? cfg.languages[0] : id;

// Process

const parseMarkdown = (text) => {
  const parsed = matter(text);
  return R.mergeRight(parsed.data, { description: parsed.content });
};
const normalizeWork = R.curry(async (workRaw, workName) => {
  const workParseResult = workSchema.safeParse(workRaw);

  if (!workParseResult.success) {
    throw `Error in work '${workName}'\n` + e.message;
  }

  const work = workParseResult.data;

  const def = work.default
    .into(
      R.assoc(
        "mainVisualUrl",
        `${workName}/${await getMainVisualFilename(workName)}`,
      ),
    )
    .into(
      R.assoc(
        "mainVisualMetaUrl",
        `${workName}/${await getMainVisualFilename(workName)}.meta.json`,
      ),
    )
    .into(R.mergeRight({ visuals: [], links: [] }));

  const processedReadMore = work.into(
    R.mapObjIndexed((language, id) =>
      language.into(
        R.assoc(
          "readMore",
          normalizeReadMore(id, def.readMore, language.readMore),
        ),
      ),
    ),
  );
  const filled = processedReadMore.into(R.map(R.mergeDeepRight(def))).into(
    R.map(
      R.evolve({
        visuals: R.map(normalizeVisual(workName)),
        date: (date) => (typeof date == "string" ? date : R.toString(date)),
      }),
    ),
  );
  return filled;
});
const getMainVisualFilename = async (workName) => {
  const mainFiles = await glob(`${cfg.worksDir}${workName}/main.*`);
  if (mainFiles.length === 0)
    throw `No main visual file (main.jpg/.png) for work ${workName}!`;
  return path.parse(mainFiles[0]).base;
};
const normalizeVisual = R.curry((workName, visual) => {
  if (visual.type === cfg.visualType.image) {
    const localPath = toLocalPath(workName, visual.url);
    return R.mergeRight(visual, {
      url: isUrl(visual.url) ? visual.url : localPath,
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
  throw `Visual for work '${workName}' has wrong type: ${visual.type}`;
});
const normalizeReadMore = R.curry((langId, defUrl, url) => {
  return url
    ? { url: url, language: fileStandardToLanguageId(langId) }
    : defUrl
      ? { url: defUrl, language: cfg.languages[0] }
      : undefined;
});
const toLocalPath = (workName, url) => {
  const parsedPath = isUrl(url)
    ? path.parse(url.split("/").into(R.last))
    : path.parse(`${url}`);
  return `${workName}/${parsedPath.dir}${parsedPath.dir ? "/" : ""}${
    parsedPath.base
  }`;
};
const toThumbnailPath = (workName, url) => {
  const parsedPath = isUrl(url)
    ? path.parse(url.split("/").into(R.last))
    : path.parse(`${url}`);
  return `${workName}/${parsedPath.dir}${parsedPath.dir ? "/" : ""}${
    parsedPath.name
  }-thumb${parsedPath.ext}`;
};
const retrieveWorkAsPair = async (workName) => [
  workName,
  await retrieveWork(workName),
];
const retrieveWork = async (workName) => {
  const folder = `${cfg.worksDir}${workName}/`;
  const languageFiles = await glob(`${folder}*.md`);
  const languagePairs = await languageFiles
    .map(getFileName)
    .map(async (language) => [
      language,
      fs.readFileSync(`${folder}${language}.md`, "utf-8"),
    ])
    .into(awaitAll);
  const work = languagePairs.into(R.fromPairs).into(R.map(parseMarkdown));
  return normalizeWork(work, workName);
};

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

const workSchema = (() => {
  const languages = cfg.languages.map(languageIdToFileStandard);
  return z.object({
    ...indexBy(languages, identity()).into(mapValues(constant(languageSchema))),
    default: defaultLanguageSchema,
  });
})();

// API

const retrieveWorks = async () => {
  const workNames = (await glob(`${cfg.worksDir}*/`)).map(getLastDir);

  const workPairs = await workNames.map(retrieveWorkAsPair).into(awaitAll);
  const works = workPairs.into(R.fromPairs);

  return works;
};

export default retrieveWorks;
