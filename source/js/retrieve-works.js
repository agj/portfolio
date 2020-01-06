
const R = require('ramda');
const fs = require('fs-extra');
const path = require('path');
const glob = require('glob-promise');
const matter = require('gray-matter');
const ow = require('ow');
require('dot-into').install();

const cfg = require('./config');
const _ = require('./utils');


// Utils

const getFile = async (filename) =>
	fs.readFile(filename, 'utf-8');
const awaitAll = Promise.all.bind(Promise);
const getFileName = (p) =>
	p
	.split(path.sep)
	.filter(R.complement(R.isEmpty))
	.into(R.last)
	.split('.')
	.into(R.init)
	.join('');


// Process

const parseMarkdown = (text) => {
	const parsed = matter(text);
	return R.mergeRight(
		parsed.data,
		{ description: parsed.content },
	);
};
const normalizeWork = R.curry(async (work, workName) => {
	const def =
		work.default
		.into(R.assoc('mainVisualUrl', `${ workName }/${ await getMainVisualFilename(workName) }`));
	const filled =
		work.into(R.map(R.pipe(
			R.mergeDeepRight(def),
		)));
	validateWork(filled);
	return filled
		.into(R.map(
			R.over(R.lensProp('visuals'), R.map(normalizeVisual(workName)))
		))
});
const getMainVisualFilename = async (workName) => {
	const mainFiles = await glob(`${ cfg.worksDir }${ workName }/main.*`);
	if (mainFiles.length === 0)
		throw `No main visual file (main.jpg/.png) for work ${ workName }!`;
	return path.parse(mainFiles[0]).base;
};
const normalizeVisual = R.curry((workName, visual) => {
	if (visual.type === cfg.visualType.image) {
		const normalizedUrl = toLocalPath(workName, visual.url);
		return R.mergeRight(visual, {
			url: normalizedUrl,
			thumbnailUrl: toThumbnailPath(workName, visual.url),
			retrieveUrl: visual.url,
			metaUrl: `${ normalizedUrl }.meta.json`,
		});
	} else if (visual.type === cfg.visualType.video) {
		return R.mergeRight(visual, {
			thumbnailUrl: `${ workName }/${ visual.host }-${ visual.id }-thumb.jpg`,
			metaUrl: `${ workName }/${ visual.host }-${ visual.id }.meta.json`,
		});
	}
	return visual;
});
const toLocalPath = (workName, url) => {
	const isUrl = ow.isValid(url, ow.string.url);
	const parsedPath =
		isUrl ? path.parse(url.split('/').into(R.last))
		: path.parse(`${ url }`);
	return `${ workName }/${ parsedPath.dir }${ parsedPath.dir ? '/' : '' }${ parsedPath.base }`;
};
const toThumbnailPath = (workName, url) => {
	const isUrl = ow.isValid(url, ow.string.url);
	const parsedPath =
		isUrl ? path.parse(url.split('/').into(R.last))
		: path.parse(`${ url }`);
	return `${ workName }/${ parsedPath.dir }${ parsedPath.dir ? '/' : '' }${ parsedPath.name }-thumb${ parsedPath.ext }`;
};
const retrieveWorkAsPair = async (workName) => [workName, await retrieveWork(workName)];
const retrieveWork = async (workName) => {
	const folder = `${ cfg.worksDir }${ workName }/`;
	const languageFiles = await glob(`${ folder }*.md`);
	const languagePairs = await
		languageFiles
		.map(getFileName)
		.map(async (language) => [
			language,
			fs.readFileSync(`${ folder }${ language }.md`, 'utf-8'),
		])
		.into(awaitAll);
	const work =
		languagePairs
		.into(R.fromPairs)
		.into(R.map(parseMarkdown));
	return normalizeWork(work, workName);
};


// Validation

const linkValidation = ow.object.exactShape({
	label: ow.string,
	url: ow.string,
});
const visualValidation = ow.any(
	ow.object.exactShape({
		type: ow.string.equals(cfg.visualType.image),
		url: ow.any(
			ow.string.url,
			ow.string.not.includes(path.sep),
		),
	}),
	ow.object.exactShape({
		type: ow.string.equals(cfg.visualType.video),
		host: ow.string.oneOf(R.values(cfg.hostType)),
		host: ow.string,
		id: ow.string,
	})
);
const languageValidation = ow.object.exactShape({
	description: ow.string,
	name: ow.string,
	tags: ow.array.ofType(ow.string).minLength(1),
	date: ow.string,
	mainVisualUrl: ow.string,
	readMore: ow.optional.string,
	visuals: ow.optional.array.ofType(visualValidation),
	links: ow.optional.array.ofType(linkValidation),
});
const workValidation = (() => {
	const languages = cfg.languages.into(R.update(0, 'default'));
	const validations =
		languages
		.into(R.indexBy(R.identity))
		.into(R.map(R.always(languageValidation)));
	return ow.object.exactShape(validations);
})();

const validateWork = ow.create(workValidation);
const validateLanguage = ow.create(languageValidation);


// API

const retrieveWorks = async () => {
	// const workNames =
	// 	(await glob(`${ cfg.worksDir }*/`))
	// 	.map(getFileName)
	const workNames = [
		'kotokan',
		'runnerby',
		'tearoom',
		'mitos',
	];

	const workPairs = await
		workNames
		.map(retrieveWorkAsPair)
		.into(awaitAll);
	const works =
		workPairs
		.into(R.fromPairs);

	return works;
};


module.exports = retrieveWorks;
