
const R = require('ramda');
const fs = require('fs-extra');
const path = require('path');
const ow = require('ow');
const sharp = require('sharp');
const axios = require('axios');
const stream = require('stream');
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

const generateVisualsCache = async (work, workName) => {
	if (work.default.visuals) {
		const promises = work.default.visuals.into(R.map(async (visual) => {
			// Filenames.
			const outputDir = `${ cfg.cacheDir }`;
			const outputFilename = `${ outputDir }${ visual.thumbnailUrl }`;
			const metaOutputFilename = `${ outputDir }${ visual.metaUrl }`;

			if (fs.pathExistsSync(outputFilename) && fs.pathExistsSync(metaOutputFilename)) {
				_.log(`Skipping files already existing in cache:`);
				_.log(`    ${ outputFilename }`);
				_.log(`    ${ metaOutputFilename }`);

			} else {
				// Create folders.
				const outputFilenameParsed = path.parse(outputFilename);
				const metaOutputFilenameParsed = path.parse(metaOutputFilename);
				fs.ensureDirSync(outputFilenameParsed.dir);
				fs.ensureDirSync(metaOutputFilenameParsed.dir);

				// Streams.
				const output = fs.createWriteStream(outputFilename);
				const metaOutput = fs.createWriteStream(metaOutputFilename);

				// Images.
				if (visual.type === cfg.visualType.image) {
					// Streams.
					const isUrl = ow.isValid(visual.retrieveUrl, ow.string.url);
					const input =
						isUrl ? (await axios.get(visual.retrieveUrl, { responseType: 'stream' })).data
						: fs.createReadStream(`${ cfg.worksDir }${ workName }/${ visual.retrieveUrl }`);

					await makeThumbnail(input, output, metaOutput);

				// Videos.
				} else if (visual.type === cfg.visualType.video) {
					const meta = await getVideoMetadata(visual.host, visual.id);

					// Streams.
					const input = (await axios.get(meta.thumbnailUrl, { responseType: 'stream' })).data;

					const process =
						sharp()
						.resize(cfg.thumbnailSize, cfg.thumbnailSize, { fit: 'cover' })
						.jpeg({
							force: true,
							quality: 80,
							chromaSubsampling: '4:4:4',
						});

					await input.pipe(process).pipe(output)
						.into(onFinished);

					const metaInput = jsonStream({
						width: meta.width,
						height: meta.height,
					});
					await metaInput.pipe(metaOutput)
						.into(onFinished);
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

const makeThumbnail = async (input, output, metaOutput) => {
	const process =
		sharp()
		.metadata((err, data) => {
			const metaInput = jsonStream({
				width: data.width,
				height: data.height,
			});
			metaInput.pipe(metaOutput);
		})
		.resize(cfg.thumbnailSize, cfg.thumbnailSize, { fit: 'cover' })
		.jpeg({
			force: false,
			quality: 80,
			chromaSubsampling: '4:4:4',
		});
	await input.pipe(process).pipe(output)
		.into(onFinished);
};


// API

const generateCache = async (works) => {
	const promises =
		works.into(R.mapObjIndexed(generateVisualsCache))
		.into(R.values);
	await awaitAll(promises);
};


module.exports = generateCache;
