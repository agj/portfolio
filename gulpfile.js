import gulp from "gulp";
import path from "path";

import retrieveWorks from "./source/js/retrieve-works.js";
import generateWorksJson from "./source/js/generate-works-json.js";
import generateVisualsCache from "./source/js/generate-visuals-cache.js";

import cfg from "./source/js/config.js";
import { run } from "./source/js/utils.js";

// Static files copy

const copyCache = () =>
  gulp
    .src(
      [
        path.join(cfg.cacheDir, "**/*.*"),
        path.join(`!${cfg.cacheDir}`, "**/*.meta.json"),
      ],
      { encoding: false }
    )
    .pipe(gulp.dest(path.join(cfg.outputDir, "works/")));

const watchCopyCache = () => gulp.watch(path.join(cfg.cacheDir, "**"), copyCache);

// Data generation

const generateCache = async () => {
  const data = await retrieveWorks();
  return await generateVisualsCache(data);
};

const generateJson = async () => {
  const data = await retrieveWorks();
  return await generateWorksJson(data);
};

const watchGenerateJson = () => gulp.watch(path.join(cfg.worksDir, "**"), generateJson);

// Vite

const elmDevelop = () => run(`pnpm exec vite --clearScreen false --host`)

// Tasks

export const develop = gulp.series(
  gulp.parallel(copyCache, generateJson),
  gulp.parallel(elmDevelop, watchCopyCache, watchGenerateJson)
);

export { generateCache as cache };
