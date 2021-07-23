import gulp from "gulp";
import elm from "gulp-elm";
import rename from "gulp-rename";
import { promisify } from "util";
import { exec as exec_ } from "child_process";

import retrieveWorks from "./source/js/retrieve-works.js";
import generateWorksJson from "./source/js/generate-works-json.js";
import generateVisualsCache from "./source/js/generate-visuals-cache.js";

import cfg from "./source/js/config.js";
import { run } from "./source/js/utils.js";

// Elm compilation

const doElm = (options) =>
  gulp
    .src(`${cfg.elmDir}Main.elm`)
    .pipe(elm(options))
    .pipe(rename("script.js"))
    .pipe(gulp.dest(`${cfg.outputDir}js/`));

const buildElm = () => doElm({ optimize: true, debug: false });

const debugElm = () => doElm({ optimize: false, debug: true });

const developElm = () =>
  run(
    `npx elm-go ${cfg.elmDir}Main.elm `,
    {
      "path-to-elm": "./node_modules/.bin/elm",
      dir: "output/",
      open: false,
      hot: true,
    },
    {
      output: `${cfg.outputDir}js/script.js`,
      debug: true,
    }
  );

// Static files copy

const copyGeneralData = () =>
  gulp.src(`${cfg.copyDir}**`).pipe(gulp.dest(`${cfg.outputDir}`));
const copyCache = () =>
  gulp
    .src([`${cfg.cacheDir}**/*.*`, `!${cfg.cacheDir}**/*.meta.json`])
    .pipe(gulp.dest(`${cfg.outputDir}works/`));

const copy = gulp.parallel(copyGeneralData, copyCache);

const watchCopy = () => gulp.watch(`${cfg.copyDir}**`, copy);

// Data generation

const generateCache = async () => {
  const data = await retrieveWorks();
  return await generateVisualsCache(data);
};

const generateJson = async () => {
  const data = await retrieveWorks();
  return await generateWorksJson(data);
};

const watchJson = () => gulp.watch(`${cfg.dataDir}**`, generateJson);

// Combined tasks

export const build = gulp.parallel(copy, generateJson, buildElm);

export const debug = gulp.parallel(copy, generateJson, debugElm);

export const develop = gulp.parallel(watchCopy, developElm);

export { generateCache as cache };

export default build;
