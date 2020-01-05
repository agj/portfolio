
const R = require('ramda');
const fs = require('fs-extra');
const path = require('path');
const xre = require('xregexp');
const glob = require('glob-promise');
const matter = require('gray-matter');
const ow = require('ow');
const sharp = require('sharp');
const axios = require('axios');
const stream = require('stream');
require('dot-into').install();


// Constants

const worksDir = 'source/data/works/';
const cacheDir = 'cache/works/';
const worksFolderName = 'works';
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
const getFileName = (p) =>
	p
	.split(path.sep)
	.filter(R.complement(R.isEmpty))
	.into(R.last)
	.split('.')
	.into(R.init)
	.join('');
const getVideoMetadata = async (host, id) => {
	if (host === hostType.youtube) {
		const response = (await axios.get(`https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${ id }&format=json`, { responseType: 'json' })).data;
		console.log(response)
		return {
			width: response.width,
			height: response.height,
			thumbnailUrl: response.thumbnail_url,
		};
	} else if (host === hostType.vimeo) {
		const response = (await axios.get(`http://vimeo.com/api/v2/video/${ id }.json`, { responseType: 'json' })).data[0];
		console.log(response)
		return {
			width: response.width,
			height: response.height,
			thumbnailUrl: response.thumbnail_large,
		};
	}
};
const jsonStream = (data) => {
	const Readable = stream.Readable;
	const input = new Readable();
	input._read = () => {};
	input.push(JSON.stringify(data, null, '\t'));
	input.push(null);
	return input;
};


// Massage data

const parseMD = (text) => {
	const parsed = matter(text);
	return R.mergeRight(
		parsed.data,
		{ description: parsed.content },
	);
};
const normalizeWork = (work, name) => {
	const def = work.default;
	const filled =
		work.into(R.map(R.pipe(
			R.mergeDeepRight(def),
			R.tap(validateLanguage),
		)));
	return filled
		.into(R.map(
			R.over(R.lensProp('visuals'), R.map(normalizeVisual(name)))
			// if (language.visuals)
			// 	language.visuals.map(normalize);
		))
};
const normalizeVisual = R.curry((workName, visual) => {
	if (visual.type === visualType.image) {
		const normalizedUrl = toLocalPath(workName, visual.url);
		return R.mergeRight(visual, {
			url: normalizedUrl,
			thumbnailUrl: toThumbnailPath(workName, visual.url),
			retrieveUrl: visual.url,
			metaUrl: `${ normalizedUrl }.meta.json`,
		});
	} else if (visual.type === visualType.video) {
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
	return `${ workName }/${ parsedPath.dir }${ parsedPath.dir ? '/' : '' }${ parsedPath.base }`
};
const toThumbnailPath = (workName, url) => {
	const isUrl = ow.isValid(url, ow.string.url);
	const parsedPath =
		isUrl ? path.parse(url.split('/').into(R.last))
		: path.parse(`${ url }`);
	return `${ workName }/${ parsedPath.dir }${ parsedPath.dir ? '/' : '' }${ parsedPath.name }-thumb${ parsedPath.ext }`
};
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
		work.default.visuals.into(R.forEach(async (visual) => {
			console.log(workName, visual.type);
			console.log(visual);

			// Filenames.
			const outputDir = `${ cacheDir }`;
			const outputFilename = `${ outputDir }${ visual.thumbnailUrl }`;
			const metaOutputFilename = `${ outputDir }${ visual.metaUrl }`;

			// Create folders.
			const outputFilenameParsed = path.parse(outputFilename);
			const metaOutputFilenameParsed = path.parse(metaOutputFilename);
			fs.ensureDirSync(outputFilenameParsed.dir);
			fs.ensureDirSync(metaOutputFilenameParsed.dir);

			// Streams.
			const output = fs.createWriteStream(outputFilename);
			const metaOutput = fs.createWriteStream(metaOutputFilename);

			if (visual.type === visualType.image) {
				// Streams.
				const isUrl = ow.isValid(visual.retrieveUrl, ow.string.url);
				const input =
					isUrl ? (await axios.get(visual.retrieveUrl, { responseType: 'stream' })).data
					: fs.createReadStream(`${ worksDir }${ workName }/${ visual.retrieveUrl }`);

				makeThumbnail(input, output, metaOutput);

			} else if (visual.type === visualType.video) {
				const meta = await getVideoMetadata(visual.host, visual.id);

				// Streams.
				const input = (await axios.get(meta.thumbnailUrl, { responseType: 'stream' })).data;

				const process =
					sharp()
					.resize(thumbnailSize, thumbnailSize, { fit: 'cover' })
					.jpeg({
						force: true,
						quality: 80,
						chromaSubsampling: '4:4:4',
					});
				input.pipe(process).pipe(output);

				const metaInput = jsonStream({
					width: meta.width,
					height: meta.height,
				});
				metaInput.pipe(metaOutput);
			}
		}))
	}
};

const makeThumbnail = (input, output, metaOutput) => {
	const process =
		sharp()
		.metadata((err, data) => {
			const metaInput = jsonStream({
				width: data.width,
				height: data.height,
			});
			metaInput.pipe(metaOutput);
		})
		.resize(thumbnailSize, thumbnailSize, { fit: 'cover' })
		.jpeg({
			force: false,
			quality: 80,
			chromaSubsampling: '4:4:4',
		});
	input.pipe(process).pipe(output);
};


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
						.map(async (language) => [
							language,
							(await getFile(`${ worksDir }${ workName }/${ language }.md`))
						]))
					.into(awaitAll))
					.into(R.fromPairs)
					.into(R.map(parseMD))
			]))
		.into(awaitAll))
		.into(R.fromPairs)
		.into(R.mapObjIndexed(normalizeWork));

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
