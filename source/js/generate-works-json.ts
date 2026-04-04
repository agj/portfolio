import fs from "node:fs";
import * as z from "zod";
import "dot-into";
import { ensureDirForFile, isUrl, toJson } from "./utils.ts";
import {
  cacheDir,
  outputDir,
  worksFolder,
  type LanguageId,
  type VisualType,
} from "./constants.ts";
import type {
  Language,
  Link,
  ReadMore,
  Visual,
  Work,
} from "./retrieve-works.ts";
import { values } from "remeda";

// Types

type NormalizedWork = Record<LanguageId, NormalizedLanguage>;

type NormalizedLanguage = {
  name: string;
  description: string;
  date: string;
  tags: [string, ...string[]];
  mainVisualUrl: string;
  mainVisualColor: VisualMetadataColor;
  visuals: NormalizedVisual[];
  links: Link[];
  readMore: ReadMore | undefined;
};

type NormalizedVisual =
  | {
      type: "Image" & VisualType;
      url: string;
      thumbnailUrl: string;
      aspectRatio: number;
      color: VisualMetadataColor;
    }
  | {
      type: "Video" & VisualType;
      host: string;
      id: string;
      thumbnailUrl: string;
      aspectRatio: number;
      color: VisualMetadataColor;
      parameters: Record<string, string>;
    };

type VisualMetadata = z.output<typeof visualMetaSchema>;

type VisualMetadataColor = VisualMetadata["color"];

// Schemas

const visualMetaSchema = z.object({
  width: z.int(),
  height: z.int(),
  color: z.object({
    red: z.number(),
    green: z.number(),
    blue: z.number(),
  }),
});

// Process

const normalizeWork = (work: Work): NormalizedWork => ({
  en: normalizeLanguage(work.default),
  es: normalizeLanguage(work.es),
  ja: normalizeLanguage(work.ja),
});

const normalizeLanguage = (language: Language): NormalizedLanguage => {
  const mvMeta = getVisualMetadata(language.mainVisualMetaUrl);

  return {
    name: language.name,
    description: language.description,
    date: language.date,
    tags: language.tags,
    mainVisualUrl: `${worksFolder}/${language.mainVisualUrl}`,
    mainVisualColor: mvMeta.color,
    visuals: language.visuals ? language.visuals.map(normalizeVisual) : [],
    links: language.links ? language.links : [],
    readMore: language.readMore,
  };
};

const normalizeVisual = (visual: Visual): NormalizedVisual => {
  const meta = getVisualMetadata(visual.metaUrl);

  if (visual.type === "Image") {
    return {
      type: visual.type,
      url: isUrl(visual.url) ? visual.url : `${worksFolder}/${visual.url}`,
      thumbnailUrl: `${worksFolder}/${visual.thumbnailUrl}`,
      aspectRatio: meta.width / meta.height,
      color: meta.color,
    };
  } else if (visual.type === "Video") {
    return {
      type: visual.type,
      host: visual.host,
      id: visual.id,
      thumbnailUrl: `${worksFolder}/${visual.thumbnailUrl}`,
      aspectRatio: meta.width / meta.height,
      color: meta.color,
      parameters: visual.parameters ? visual.parameters : {},
    };
  }

  throw new Error("A visual has wrong type");
};

const getVisualMetadata = (url: String): VisualMetadata => {
  const raw = fs.readFileSync(`${cacheDir}${url}`, "utf-8").into(JSON.parse);
  const parsed = visualMetaSchema.safeParse(raw);

  if (!parsed.success) {
    throw new Error(`Visual meta "${url}" has the wrong format`);
  }

  return parsed.data;
};

// API

export const generateWorksJson = async (
  works: Record<string, Work>,
): Promise<void> => {
  fs.mkdirSync(outputDir, { recursive: true });

  const worksArray = values(works).map(normalizeWork);

  const filename = `${outputDir}${worksFolder}/data.json`;
  ensureDirForFile(filename);
  fs.writeFileSync(filename, toJson(worksArray), "utf-8");
};
