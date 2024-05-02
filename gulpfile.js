import gulp from "gulp";
import elm from "gulp-elm";
import rename from "gulp-rename";
import { promisify } from "util";
import { exec as exec_ } from "child_process";
import path from "path";

import retrieveWorks from "./source/js/retrieve-works.js";
import generateWorksJson from "./source/js/generate-works-json.js";
import generateVisualsCache from "./source/js/generate-visuals-cache.js";

import cfg from "./source/js/config.js";
import { run } from "./source/js/utils.js";

// Elm compilation

const elmMainFile = path.join(cfg.elmDir, "Main.elm");
const elmOutputFileName = "script.js";

const doElm = (options) =>
  gulp
    .src(elmMainFile)
    .pipe(elm(options))
    .pipe(rename(elmOutputFileName))
    .pipe(gulp.dest(path.join(cfg.outputDir, "js")));

const buildElm = () => doElm({ optimize: true, debug: false });

const debugElm = () => doElm({ optimize: false, debug: true });

const developElm = () =>
  run(
    `pnpm exec elm-go ${elmMainFile} `,
    {
      "path-to-elm": "./node_modules/.bin/elm",
      dir: "output/",
      open: false,
      hot: true,
    },
    {
      output: path.join(cfg.outputDir, "js", elmOutputFileName),
      debug: true,
    }
  );

// Static files copy

const copyGeneralData = () =>
  gulp.src(path.join(cfg.copyDir, "**")).pipe(gulp.dest(cfg.outputDir));
const copyCache = () =>
  gulp
    .src([
      path.join(cfg.cacheDir, "**/*.*"),
      path.join(`!${cfg.cacheDir}`, "**/*.meta.json"),
    ])
    .pipe(gulp.dest(path.join(cfg.outputDir, "works/")));

const copy = gulp.parallel(copyGeneralData, copyCache);

const watchCopy = () => gulp.watch(path.join(cfg.copyDir, "**"), copy);

// Data generation

const generateCache = async () => {
  const data = await retrieveWorks();
  return await generateVisualsCache(data);
};

const generateJson = async () => {
  const data = await retrieveWorks();
  return await generateWorksJson(data);
};

const watchJson = () => gulp.watch(path.join(cfg.copyDir, "**"), generateJson);

// Combined tasks

export const build = gulp.parallel(copy, generateJson, buildElm);

export const debug = gulp.parallel(copy, generateJson, debugElm);

export const develop = gulp.series(
  gulp.parallel(copy, generateJson),
  gulp.parallel(watchCopy, watchJson, developElm)
);

export { generateCache as cache };

export default build;
