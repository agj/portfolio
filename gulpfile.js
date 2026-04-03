import gulp from "gulp";
import path from "path";
import { parseArgs } from "util";

import { retrieveWorks } from "./source/js/retrieve-works.ts";
import generateWorksJson from "./source/js/generate-works-json.js";
import generateVisualsCache from "./source/js/generate-visuals-cache.js";

import cfg from "./source/js/config.ts";
import { run } from "./source/js/utils.ts";

// Static files copy

const copyCache = () =>
  gulp
    .src(
      [
        path.join(cfg.cacheDir, "**/*.*"),
        path.join(`!${cfg.cacheDir}`, "**/*.meta.json"),
      ],
      { encoding: false },
    )
    .pipe(gulp.dest(path.join(cfg.outputDir, "works/")));

const watchCopyCache = () =>
  gulp.watch(path.join(cfg.cacheDir, "**"), copyCache);

// Data generation

const generateCache = async () => {
  const data = await retrieveWorks();
  return await generateVisualsCache(data);
};

const generateJson = async () => {
  const data = await retrieveWorks();
  return await generateWorksJson(data);
};

const watchGenerateJson = () =>
  gulp.watch(path.join(cfg.worksDir, "**"), generateJson);

// Elm through Vite

const elmDevelop = () => {
  const args = getElmDevelopArgs();
  run(`pnpm exec vite --clearScreen false --host --port ${args.port}`);
};

const elmBuild = () => run("pnpm exec vite build --base ./");

const getElmDevelopArgs = () =>
  parseArgs({
    options: {
      port: {
        type: "string",
        default: "1234",
      },
    },
    strict: false,
  }).values;

// Tasks

export const develop = gulp.series(
  gulp.parallel(copyCache, generateJson),
  gulp.parallel(elmDevelop, watchCopyCache, watchGenerateJson),
);

export const build = gulp.series(
  gulp.parallel(copyCache, generateJson),
  elmBuild,
);

export { generateCache as cache };
