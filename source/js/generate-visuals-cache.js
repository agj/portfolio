
const R = require('ramda');
const fs = require('fs-extra');
const path = require('path');
const ow = require('ow');
const sharp = require('sharp');
const vibrant = require('node-vibrant');
const axios = require('axios');
const stream = require('stream');
const streamToPromise = require('stream-to-promise');
require('dot-into').install();

const cfg = require('./config');
const _ = require('./utils');


// Utils

const getFile = async (filename) =>
	fs.readFile(filename, 'utf-8');
const awaitAll = Promise.all.bind(Promise);
const getVideoMetadata = async (host, id) => {
	if (host === cfg.hostType.youtube) {
		const response = (await axios.get(`https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${ id }&format=json`, { responseType: 'json' })).data;
		return {
			width: response.width,
			height: response.height,
			thumbnailUrl: response.thumbnail_url,
		};
	} else if (host === cfg.hostType.vimeo) {
		const response = (await axios.get(`http://vimeo.com/api/v2/video/${ id }.json`, { responseType: 'json' })).data[0];
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


// Process

const logSkipped = (name) => {
	_.log(`Skipped existing: ${ name }`);
}
const generateVisualsCache = async (work, workName) => {
	// Main visual.

	const mvMetaOutputFilename = `${ cfg.cacheDir }${ work.default.mainVisualMetaUrl }`;

	if (fs.pathExistsSync(mvMetaOutputFilename)) {
		logSkipped(mvMetaOutputFilename);

	} else {
		// Create folders.
		const mvMetaOutputFilenameParsed = path.parse(mvMetaOutputFilename);
		fs.ensureDirSync(mvMetaOutputFilenameParsed.dir);

		const input = fs.createReadStream(`${ cfg.worksDir }${ work.default.mainVisualUrl }`);
		const image = await streamToPromise(input);

		await writeImageMetadata(image, mvMetaOutputFilename);
	}

	// Visuals.

	if (work.default.visuals) {
		const promises = work.default.visuals.into(R.map(async (visual) => {
			// Filenames.
			const outputFilename = `${ cfg.cacheDir }${ visual.thumbnailUrl }`;
			const metaOutputFilename = `${ cfg.cacheDir }${ visual.metaUrl }`;

			if (fs.pathExistsSync(outputFilename) && fs.pathExistsSync(metaOutputFilename)) {
				logSkipped(outputFilename);
				logSkipped(metaOutputFilename);

			} else {
				// Create folders.
				const outputFilenameParsed = path.parse(outputFilename);
				const metaOutputFilenameParsed = path.parse(metaOutputFilename);
				fs.ensureDirSync(outputFilenameParsed.dir);
				fs.ensureDirSync(metaOutputFilenameParsed.dir);

				// Images.
				if (visual.type === cfg.visualType.image) {
					const input =
						_.isUrl(visual.retrieveUrl) ? (await axios.get(visual.retrieveUrl, { responseType: 'stream' })).data
						: fs.createReadStream(`${ cfg.worksDir }${ workName }/${ visual.retrieveUrl }`);
					const image = await streamToPromise(input);

					await makeThumbnail(image, outputFilename);
					await writeImageMetadata(image, metaOutputFilename);

				// Videos.
				} else if (visual.type === cfg.visualType.video) {
					const metaVideo = await getVideoMetadata(visual.host, visual.id);

					const input = (await axios.get(metaVideo.thumbnailUrl, { responseType: 'stream' })).data;
					const image = await streamToPromise(input);

					await makeThumbnail(image, outputFilename);

					const metaImage = await getImageMetadata(image, metaOutputFilename);

					fs.writeFileSync(
						metaOutputFilename,
						_.toJson({
							width: metaVideo.width,
							height: metaVideo.height,
							color: metaImage.color,
						}),
						'utf-8',
					);
				}
			}
		}));

		await awaitAll(promises);
	}
};

const onFinished = (str) => new Promise((resolve) => {
	const done = (err, done) => {
		resolve(true);
	};
	str.on('finish', done);
	str.on('end', done);
});

const getImageMetadata = async (image) => {
	const metadata = await sharp(image)
		.metadata();
	const colors = await vibrant.from(image)
		.getPalette();
	const color = colors.DarkVibrant.rgb;
	return {
		width: metadata.width,
		height: metadata.height,
		color: {
			red: color[0] / 0xff,
			green: color[1] / 0xff,
			blue: color[2] / 0xff,
		},
	};
};
const writeImageMetadata = async (image, outputPath) => {
	fs.writeFileSync(outputPath, _.toJson(await getImageMetadata(image)), 'utf-8');
};
const makeThumbnail = async (image, outputPath) => {
	const thumbnail = await sharp(image)
		.resize(cfg.thumbnailSize, cfg.thumbnailSize, { fit: 'cover' })
		.jpeg({
			force: false,
			quality: 80,
			chromaSubsampling: '4:4:4',
		})
		.toBuffer();
	return fs.writeFile(outputPath, thumbnail);
};


// API

const generateCache = async (works) => {
	const promises =
		works.into(R.mapObjIndexed(generateVisualsCache))
		.into(R.values);
	await awaitAll(promises);
};


module.exports = generateCache;
