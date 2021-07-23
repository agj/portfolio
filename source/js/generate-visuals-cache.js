import R from "ramda";
import fs from "fs-extra";
import path from "path";
import sharp from "sharp";
import vibrant from "node-vibrant";
import axios from "axios";
import stream from "stream";
import streamToPromise from "stream-to-promise";
import dotInto from "dot-into";

import cfg from "./config.js";
import _ from "./utils.js";

dotInto.install();

// Utils

const getFile = async (filename) => fs.readFile(filename, "utf-8");
const awaitAll = Promise.all.bind(Promise);
const getVideoMetadata = async (host, id) => {
  if (host === cfg.hostType.youtube) {
    const response = (
      await axios.get(
        `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${id}&format=json`,
        { responseType: "json" }
      )
    ).data;
    return {
      width: response.width,
      height: response.height,
      thumbnailUrl: response.thumbnail_url,
    };
  } else if (host === cfg.hostType.vimeo) {
    const response = (
      await axios.get(`http://vimeo.com/api/v2/video/${id}.json`, {
        responseType: "json",
      })
    ).data[0];
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
  input.push(JSON.stringify(data, null, "\t"));
  input.push(null);
  return input;
};
const fileExists = fs.pathExistsSync;
const filesExist = R.all(fileExists);
const ensureFolder = (filename) => {
  const parsed = path.parse(filename);
  fs.ensureDirSync(parsed.dir);
};

// Process

const logSkipped = (name) => {
  _.log(`Skipped existing: ${name}`);
};
const generateVisualsCache = async (work, workName) => {
  // Main visual.

  const mvOutputFilename = `${cfg.cacheDir}${work.default.mainVisualUrl}`;
  const mvMetaOutputFilename = `${cfg.cacheDir}${work.default.mainVisualMetaUrl}`;

  if (
    fs.pathExistsSync(mvOutputFilename) &&
    fs.pathExistsSync(mvMetaOutputFilename)
  ) {
    console.log(`Skipped: ${workName} -> main visual`);
  } else {
    // Create folders.
    const mvMetaOutputFilenameParsed = path.parse(mvMetaOutputFilename);
    fs.ensureDirSync(mvMetaOutputFilenameParsed.dir);

    const input = fs.createReadStream(
      `${cfg.worksDir}${work.default.mainVisualUrl}`
    );
    const image = await streamToPromise(input);

    const resized = await resizeMainVisual(image);
    await fs.writeFile(mvOutputFilename, resized);
    await writeImageMetadata(resized, mvMetaOutputFilename);
  }

  // Visuals.

  if (work.default.visuals) {
    const allVisuals = work
      .into(R.map(R.prop("visuals")))
      .into(R.values)
      .into(R.unnest);
    const promises = allVisuals.into(
      R.map(async (visual) => {
        // Filenames.
        const thumbOutputFilename = `${cfg.cacheDir}${visual.thumbnailUrl}`;
        const metaOutputFilename = `${cfg.cacheDir}${visual.metaUrl}`;

        if (filesExist([thumbOutputFilename, metaOutputFilename])) {
          console.log(
            `Skipped: ${workName} -> ${
              visual.retrieveUrl ? visual.retrieveUrl : visual.id
            }`
          );
        } else {
          [thumbOutputFilename, metaOutputFilename].forEach(ensureFolder);

          // Images.
          if (visual.type === cfg.visualType.image) {
            const isLocal = !_.isUrl(visual.retrieveUrl);
            const input = isLocal
              ? fs.createReadStream(
                  `${cfg.worksDir}${workName}/${visual.retrieveUrl}`
                )
              : (
                  await axios.get(visual.retrieveUrl, {
                    responseType: "stream",
                  })
                ).data;
            const image = await streamToPromise(input);

            const thumbnail = await toThumbnail(image);
            await fs.writeFile(thumbOutputFilename, thumbnail);

            if (isLocal) {
              const outputFilename = `${cfg.cacheDir}${visual.url}`;
              ensureFolder(outputFilename);

              const resized = await resizeImage(image);
              await fs.writeFile(outputFilename, resized);
              await writeImageMetadata(resized, metaOutputFilename);
            } else {
              await writeImageMetadata(image, metaOutputFilename);
            }

            // Videos.
          } else if (visual.type === cfg.visualType.video) {
            const metaVideo = await getVideoMetadata(visual.host, visual.id);

            const input = (
              await axios.get(metaVideo.thumbnailUrl, {
                responseType: "stream",
              })
            ).data;
            const image = await streamToPromise(input);

            const thumbnail = await toThumbnail(image);
            await fs.writeFile(thumbOutputFilename, thumbnail);

            const color = await getImageColor(thumbnail);

            fs.writeFileSync(
              metaOutputFilename,
              _.toJson({
                width: metaVideo.width,
                height: metaVideo.height,
                color: color,
              }),
              "utf-8"
            );
          }
        }
      })
    );

    await awaitAll(promises);
  }
};

const onFinished = (str) =>
  new Promise((resolve) => {
    const done = (err, done) => {
      resolve(true);
    };
    str.on("finish", done);
    str.on("end", done);
  });

const getImageDimensions = async (image) => {
  const metadata = await sharp(image).metadata();
  return {
    width: metadata.width,
    height: metadata.height,
  };
};
const getImageColor = async (image) => {
  const colors = await vibrant.from(image).getPalette();
  const color = colors.DarkVibrant.rgb;
  return {
    red: color[0] / 0xff,
    green: color[1] / 0xff,
    blue: color[2] / 0xff,
  };
};
const getImageMetadata = async (image) => {
  const dimensions = await getImageDimensions(image);
  const color = await getImageColor(image);
  return {
    width: dimensions.width,
    height: dimensions.height,
    color,
  };
};
const writeImageMetadata = async (image, outputPath) => {
  fs.writeFileSync(
    outputPath,
    _.toJson(await getImageMetadata(image)),
    "utf-8"
  );
};

const toThumbnail = async (image) => {
  const thumbnail = await sharp(image)
    .resize(cfg.thumbnailSize, cfg.thumbnailSize, { fit: "cover" })
    .jpeg({
      force: false,
      quality: 80,
      chromaSubsampling: "4:4:4",
    })
    .toBuffer();
  return thumbnail;
};
const resizeMainVisual = async (image) => {
  const actual = await getImageMetadata(image);
  const targetSize = cfg.mainVisualSize;
  const actualAR = actual.width / actual.height;
  const targetAR = cfg.mainVisualAR;

  const ar =
    actualAR >= targetAR // Is image more landscapey?
      ? targetAR
      : actualAR > 1 // Is image landscape at all?
      ? actualAR
      : 1;

  const croppedSize =
    actualAR >= ar
      ? {
          // If image is more landscapey
          width: actual.height * ar,
          height: actual.height,
        }
      : {
          // If image is more portraity
          width: actual.width,
          height: actual.width / ar,
        };

  const scaledSize =
    croppedSize.height > targetSize
      ? {
          width: croppedSize.width * (targetSize / croppedSize.height),
          height: targetSize,
        }
      : croppedSize;

  return resizeTo(scaledSize, image);
};

const resizeImage = async (image) => {
  const actual = await getImageMetadata(image);
  const actualAR = actual.width / actual.height;

  if (actual.width > cfg.visualMaxSize || actual.height > cfg.visualMaxSize) {
    const targetSize =
      actual.width > actual.height
        ? {
            // Wider
            width: cfg.visualMaxSize,
            height: cfg.visualMaxSize / actualAR,
          }
        : {
            // Taller
            width: cfg.visualMaxSize * actualAR,
            height: cfg.visualMaxSize,
          };

    return resizeTo(targetSize, image);
  } else {
    return image;
  }
};

const resizeTo = (dimensions, image) =>
  sharp(image)
    .resize(Math.round(dimensions.width), Math.round(dimensions.height), {
      fit: "cover",
    })
    .jpeg({
      force: false,
      quality: 80,
      chromaSubsampling: "4:4:4",
    })
    .toBuffer();

// API

const generateCache = async (works) => {
  const promises = works
    .into(R.mapObjIndexed(generateVisualsCache))
    .into(R.values);
  await awaitAll(promises);
};

export default generateCache;
