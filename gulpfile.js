
const gulp = require('gulp');
const elm = require('gulp-elm');
const rename = require('gulp-rename');
const { promisify } = require('util');
const exec = promisify(require('child_process').exec);

const generateJSON = require('./source/js/generate-json');


// Elm compilation

const doElm = (options) =>
	gulp.src('source/elm/Main.elm')
	.pipe(elm(options))
	.pipe(rename('script.js'))
	.pipe(gulp.dest('output/js/'));

const buildElm = () =>
	doElm({ optimize: true, debug: false });

const debugElm = () =>
	doElm({ optimize: false, debug: false }); // Temporarily using `debug: false` due to Elm compiler bug.

const formatElm = () =>
	exec('npx elm-format source/elm/ --yes');

const watchElm = () =>
	gulp.watch('source/elm/**/*.elm', gulp.series(formatElm, debugElm));


// Static files copy

const copy = () =>
	gulp.src('source/copy/**')
	.pipe(gulp.dest('output/'));

const watchCopy = () =>
	gulp.watch('source/copy/**', copy);


// Data JSON generation

// const json = generateJSON;


// Combined tasks

const build = gulp.parallel(copy, buildElm);

const debug = gulp.parallel(copy, debugElm);

const watch = gulp.parallel(watchCopy, watchElm);


module.exports = {
	default: build,
	build,
	debug,
	watch,
	// json,
	formatElm,
};

