// @ts-check

import gulp from "gulp";
import path from "path";
import { parseArgs } from "util";
import { retrieveWorks } from "./source/js/retrieve-works.ts";
import { generateWorksJson } from "./source/js/generate-works-json.ts";
import { generateVisualsCache } from "./source/js/generate-visuals-cache.ts";
import { cacheDir, outputDir, worksDir } from "./source/js/constants.ts";
import { run } from "./source/js/utils.ts";

// Static files copy

const copyCache = () =>
  gulp
    .src(
      [
        path.join(cacheDir, "**/*.*"),
        path.join(`!${cacheDir}`, "**/*.meta.json"),
      ],
      { encoding: false },
    )
    .pipe(gulp.dest(path.join(outputDir, "works/")));

const watchCopyCache = () => gulp.watch(path.join(cacheDir, "**"), copyCache);

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
  gulp.watch(path.join(worksDir, "**"), generateJson);

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
