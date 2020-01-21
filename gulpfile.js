
const gulp = require('gulp');
const elm = require('gulp-elm');
const rename = require('gulp-rename');
const { promisify } = require('util');
const exec = promisify(require('child_process').exec);

const retrieveWorks = require('./source/js/retrieve-works');
const generateWorksJson = require('./source/js/generate-works-json');
const generateVisualsCache = require('./source/js/generate-visuals-cache');

const cfg = require('./source/js/config.js');


// Elm compilation

const doElm = (options) =>
	gulp.src(`${ cfg.elmDir }Main.elm`)
	.pipe(elm(options))
	.pipe(rename('script.js'))
	.pipe(gulp.dest(`${ cfg.outputDir }js/`));

const buildElm = () =>
	doElm({ optimize: true, debug: false });

const debugElm = () =>
	doElm({ optimize: false, debug: true });

const formatElm = () =>
	exec(`npx elm-format ${ cfg.elmDir } --yes`);

const watchElm = () =>
	gulp.watch(`${ cfg.elmDir }**/*.elm`, gulp.series(formatElm, debugElm));


// Static files copy

const copyGeneralData = () =>
	gulp.src(`${ cfg.copyDir }**`)
	.pipe(gulp.dest(`${ cfg.outputDir }`));
const copyCache = () =>
	gulp.src([
		`${ cfg.cacheDir }**/*.*`,
		`!${ cfg.cacheDir }**/*.meta.json`,
	])
	.pipe(gulp.dest(`${ cfg.outputDir }works/`));

const copy = gulp.parallel(copyGeneralData, copyCache);

const watchCopy = () =>
	gulp.watch(`${ cfg.copyDir }**`, copy);


// Data generation

const generateCache = async () => {
	const data = await retrieveWorks();
	return await generateVisualsCache(data);
};

const generateJson = async () => {
	const data = await retrieveWorks();
	return await generateWorksJson(data);
};

const watchJson = () =>
	gulp.watch(`${ cfg.dataDir }**`, generateJson);



// Combined tasks

const build = gulp.parallel(copy, generateJson, buildElm);

const debug = gulp.parallel(copy, generateJson, debugElm);

const watch = gulp.parallel(watchCopy, watchJson, watchElm);


module.exports = {
	default: build,
	build,
	debug,
	watch,
	format: formatElm,
	cache: generateCache,
};

