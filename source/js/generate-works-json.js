

const R = require('ramda');
const fs = require('fs-extra');
require('dot-into').install();

const _ = require('./utils');
const cfg = require('./config');


// Utils

const correctLanguageId = (language) =>
	language === 'default' ? cfg.languages[0] : language;


// Process

const normalizeWork = (work) =>
	R.toPairs(work)
	.map(([id, lang]) => [
		correctLanguageId(id),
		normalizeLanguage(lang),
	])
	.into(R.fromPairs);
const normalizeLanguage = (language) => {
	return {
		name: language.name,
		description: language.description,
		date: language.date,
		tags: language.tags,
		visuals:
			language.visuals ? language.visuals.map(normalizeVisual)
			: [],
		links:
			language.links ? language.links
			: [],
		readMore: language.readMore,
	};
};
const normalizeVisual = (visual) => {
	const meta = getVisualMetadata(visual);
	if (visual.type === cfg.visualType.image) {
		return {
			type: visual.type,
			url: visual.url,
			thumbnailUrl: visual.thumbnailUrl,
			aspectRatio: meta.width / meta.height,
		};
	} else if (visual.type === cfg.visualType.video) {
		return {
			type: visual.type,
			host: visual.host,
			id: visual.id,
			thumbnailUrl: visual.thumbnailUrl,
			aspectRatio: meta.width / meta.height,
		};
	}
};
const getVisualMetadata = (visual) =>
	fs.readFileSync(`${ cfg.cacheDir }${ visual.metaUrl }`, 'utf-8')
	.into(JSON.parse);


// API

const generateWorksJson = async (works) => {
	fs.ensureDirSync(cfg.cacheDir);

	const worksArray =
		R.values(works)
		.map(normalizeWork);

	fs.writeFileSync(`${ cfg.cacheDir }data.json`, _.toJson(worksArray), 'utf-8');
};


module.exports = generateWorksJson;
