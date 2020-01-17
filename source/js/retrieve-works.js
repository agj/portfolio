
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
	getLastDir(p)
	.split('.')
	.into(R.init)
	.join('');
const getLastDir = (p) =>
	p.split(path.sep)
	.filter(R.complement(R.isEmpty))
	.into(R.last);

const languageIdToFileStandard = (id) => id === cfg.languages[0] ? 'default' : id;
const fileStandardToLanguageId = (id) => id === 'default' ? cfg.languages[0] : id;


// Process

const parseMarkdown = (text) => {
	const parsed = matter(text);
	return R.mergeRight(
		parsed.data,
		{ description: parsed.content },
	);
};
const normalizeWork = R.curry(async (work, workName) => {
	try {
		validateWork(work);
	} catch (e) {
		throw `Error in work '${ workName }'\n` + e.message;
	}

	const def =
		work.default
		.into(R.assoc('mainVisualUrl', `${ workName }/${ await getMainVisualFilename(workName) }`))
		.into(R.assoc('mainVisualMetaUrl', `${ workName }/${ await getMainVisualFilename(workName) }.meta.json`))
		.into(R.mergeRight({ visuals: [], links: [] }));

	const processedReadMore =
		work.into(R.mapObjIndexed((language, id) =>
			language.into(R.assoc('readMore', normalizeReadMore(id, def.readMore, language.readMore)))
		));
	const filled =
		processedReadMore.into(R.map(
			R.mergeDeepRight(def),
		))
		.into(R.map(R.evolve({
			visuals: R.map(normalizeVisual(workName)),
			date: (date) => typeof date == 'string' ? date : R.toString(date),
		})));
	return filled;
});
const getMainVisualFilename = async (workName) => {
	const mainFiles = await glob(`${ cfg.worksDir }${ workName }/main.*`);
	if (mainFiles.length === 0)
		throw `No main visual file (main.jpg/.png) for work ${ workName }!`;
	return path.parse(mainFiles[0]).base;
};
const normalizeVisual = R.curry((workName, visual) => {
	if (visual.type === cfg.visualType.image) {
		const localPath = toLocalPath(workName, visual.url);
		return R.mergeRight(visual, {
			url: _.isUrl(visual.url) ? visual.url : localPath,
			thumbnailUrl: toThumbnailPath(workName, visual.url),
			retrieveUrl: visual.url,
			metaUrl: `${ localPath }.meta.json`,
		});
	} else if (visual.type === cfg.visualType.video) {
		return R.mergeRight(visual, {
			thumbnailUrl: `${ workName }/${ visual.host }-${ visual.id }-thumb.jpg`,
			metaUrl: `${ workName }/${ visual.host }-${ visual.id }.meta.json`,
		});
	}
	throw `Visual for work '${ workName }' has wrong type: ${ visual.type }`;
});
const normalizeReadMore = R.curry((langId, defUrl, url) =>{
	return url ?      { url: url,    language: fileStandardToLanguageId(langId) }
	: defUrl ? { url: defUrl, language: cfg.languages[0] }
	: undefined
});
const toLocalPath = (workName, url) => {
	const parsedPath =
		_.isUrl(url) ? path.parse(url.split('/').into(R.last))
		: path.parse(`${ url }`);
	return `${ workName }/${ parsedPath.dir }${ parsedPath.dir ? '/' : '' }${ parsedPath.base }`;
};
const toThumbnailPath = (workName, url) => {
	const parsedPath =
		_.isUrl(url) ? path.parse(url.split('/').into(R.last))
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

const pathValidation = ow.any(
	ow.string.url,
	ow.string.not.includes(path.sep),
);
const linkValidation = ow.object.exactShape({
	label: ow.string,
	url: ow.string.url,
});
const visualValidation = ow.any(
	ow.object.exactShape({
		type: ow.string.equals(cfg.visualType.image),
		url: pathValidation,
	}),
	ow.object.exactShape({
		type: ow.string.equals(cfg.visualType.video),
		host: ow.string.oneOf(R.values(cfg.hostType)),
		id: ow.string.not.url,
		parameters: ow.optional.object.valuesOfType(ow.string),
	})
);
const languageValidation = ow.object.exactShape({
	description: ow.string,
	name: ow.optional.string,
	readMore: ow.optional.string,
	links: ow.optional.array.ofType(linkValidation),
});
const defaultLanguageValidation = ow.object.exactShape({
	description: ow.string,
	name: ow.string,
	tags: ow.array.ofType(ow.string).minLength(1),
	date: ow.any(ow.string, ow.number.integer),
	readMore: ow.optional.string,
	visuals: ow.optional.array.ofType(visualValidation),
	links: ow.optional.array.ofType(linkValidation),
});
const workValidation = (() => {
	const languages = cfg.languages.map(languageIdToFileStandard);
	const validations =
		languages
		.into(R.indexBy(R.identity))
		.into(R.map(R.always(languageValidation)))
		.into(R.assoc('default', defaultLanguageValidation));
	return ow.object.exactShape(validations);
})();

const validateWork = ow.create(workValidation);


// API

const retrieveWorks = async () => {
	const workNames =
		(await glob(`${ cfg.worksDir }*/`))
		.map(getLastDir);
	// const workNames = [
	// 	'kotokan',
	// ];

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
