import * as R from "ramda";
import fs from "fs-extra";
import dotInto from "dot-into";

import { isUrl, toJson } from "./utils.js";
import cfg from "./config.js";

dotInto.install();

// Utils

const correctLanguageId = (language) =>
  language === "default" ? cfg.languages[0] : language;

// Process

const normalizeWork = (work) =>
  R.toPairs(work)
    .map(([id, lang]) => [correctLanguageId(id), normalizeLanguage(lang)])
    .into(R.fromPairs);
const normalizeLanguage = (language) => {
  const mvMeta = fs
    .readFileSync(`${cfg.cacheDir}${language.mainVisualMetaUrl}`, "utf-8")
    .into(JSON.parse);

  return {
    name: language.name,
    description: language.description,
    date: language.date,
    tags: language.tags,
    mainVisualUrl: `${cfg.worksFolder}/${language.mainVisualUrl}`,
    mainVisualColor: mvMeta.color,
    visuals: language.visuals ? language.visuals.map(normalizeVisual) : [],
    links: language.links ? language.links : [],
    readMore: language.readMore,
  };
};
const normalizeVisual = (visual) => {
  const meta = getVisualMetadata(visual);
  if (visual.type === cfg.visualType.image) {
    return {
      type: visual.type,
      url: isUrl(visual.url) ? visual.url : `${cfg.worksFolder}/${visual.url}`,
      thumbnailUrl: `${cfg.worksFolder}/${visual.thumbnailUrl}`,
      aspectRatio: meta.width / meta.height,
      color: meta.color,
    };
  } else if (visual.type === cfg.visualType.video) {
    return {
      type: visual.type,
      host: visual.host,
      id: visual.id,
      thumbnailUrl: `${cfg.worksFolder}/${visual.thumbnailUrl}`,
      aspectRatio: meta.width / meta.height,
      color: meta.color,
      parameters: visual.parameters ? visual.parameters : {},
    };
  }
};
const getVisualMetadata = (visual) =>
  fs.readFileSync(`${cfg.cacheDir}${visual.metaUrl}`, "utf-8").into(JSON.parse);

// API

const generateWorksJson = async (works) => {
  fs.ensureDirSync(cfg.outputDir);

  const worksArray = R.values(works).map(normalizeWork);

  const filename = `${cfg.outputDir}${cfg.worksFolder}/data.json`;
  fs.ensureFileSync(filename);
  fs.writeFileSync(filename, toJson(worksArray), "utf-8");
};

export default generateWorksJson;
