
const R = require('ramda');
const fs = require('fs-extra');
const path = require('path');
const xre = require('xregexp');
const glob = require('glob-promise');
const matter = require('gray-matter');
const ow = require('ow');
const sharp = require('sharp');
const axios = require('axios');
require('dot-into').install();


// Constants

const worksDir = 'source/data/works/';
const cacheDir = 'cache/works/';
const thumbnailSize = 200;

const visualType = {
	image: 'Image',
	video: 'Video',
};
const hostType = {
	youtube: 'Youtube',
	vimeo: 'Vimeo',
};


// Utils

const getFile = async (filename) =>
	fs.readFile(filename, 'utf-8');
const awaitAll = Promise.all.bind(Promise);

const parseMD = (text) => {
	const parsed = matter(text);
	return R.mergeRight(
		parsed.data,
		{ description: parsed.content },
	);
};
const normalizeWork = (work) => {
	const def = work.default;
	return work.into(R.map(R.pipe(
		R.mergeDeepRight(def),
		R.tap(validateLanguage),
	)));
};
const getFileName = (p) =>
	p
	.split(path.sep)
	.filter(R.complement(R.isEmpty))
	.into(R.last)
	.split('.')
	.into(R.init)
	.join('');
const validateLanguage = ow.create(
	ow.object.exactShape({
		description: ow.string,
		name: ow.string,
		tags: ow.array.ofType(ow.string).minLength(1),
		date: ow.string,
		readMore: ow.optional.string,
		visuals: ow.optional.array.ofType(ow.any(
			ow.object.exactShape({
				type: ow.string.equals(visualType.image),
				url: ow.any(
					ow.string.url,
					ow.string.not.includes(path.sep),
				),
			}),
			ow.object.exactShape({
				type: ow.string.equals(visualType.video),
				host: ow.string.oneOf(R.values(hostType)),
				host: ow.string,
				id: ow.string,
			})
		)),
		links: ow.optional.array.ofType(ow.object.exactShape({
			label: ow.string,
			url: ow.string,
		})),
	})
);

const generateWorkCache = (work, workName) => {
	console.log(workName)

	// Visuals
	if (work.default.visuals) {
		work.default.visuals.into(R.forEachObjIndexed(async (visual) => {
			console.log(visual)
			if (visual.type === visualType.image) {
				const isUrl = ow.isValid(visual.url, ow.string.url);
				const outputDir = `${ cacheDir }${ workName }/`;
				fs.ensureDirSync(outputDir);
				const parsedFilename =
					isUrl ? path.parse(visual.url.split('/').into(R.last))
					: path.parse(`${ outputDir }${ visual.url }`);
				const outputFilename = `${ outputDir }${ parsedFilename.name }-thumb${ parsedFilename.ext }`;
				const output = fs.createWriteStream(outputFilename);

				if (isUrl) {
					(await axios.get(visual.url, { responseType: 'stream' }))
						.data
						.pipe(makeThumbnail())
						.pipe(output);

				} else {
					fs.createReadStream(`${ worksDir }${ workName }/${ visual.url }`)
						.pipe(makeThumbnail())
						.pipe(output);
				}
			}
		}))
	}
};

const makeThumbnail = () =>
	sharp()
		.resize(thumbnailSize, thumbnailSize, { fit: 'cover' })
		.jpeg({
			quality: 80,
			force: false,
			chromaSubsampling: '4:4:4',
		});


// Functions

const retrieveWorks = async () => {
	// const workNames =
	// 	(await glob(`${ worksDir }*/`))
	// 	.map(getFileName)
	const workNames = [
		'kotokan',
		'runnerby',
		'tearoom',
		'mitos',
	];

	const works =
		(await (workNames
			.map(async (workName) => [
				workName,
				(await ((await glob(`${ worksDir }${ workName }/*.md`))
						.map(getFileName)
						.map(async (mdName) => [
							mdName,
							(await getFile(`${ worksDir }${ workName }/${ mdName }.md`))
						]))
					.into(awaitAll))
					.into(R.fromPairs)
					.into(R.map(parseMD))
			]))
		.into(awaitAll))
		.into(R.fromPairs)
		.into(R.map(normalizeWork));

	return works;
};

const generateCache = async (works) => {
	works.into(R.forEachObjIndexed(generateWorkCache));
};



// Temp

fs.removeSync(cacheDir);

(async () => {
	generateCache(await retrieveWorks());
})();


module.exports = {
	// retrieve,
};
