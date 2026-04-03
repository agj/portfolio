import * as R from "ramda";
import fs from "node:fs";
import fsPromises from "node:fs/promises";
import * as z from "zod";
import sharp from "sharp";
import vibrant from "node-vibrant";
import axios from "axios";
import "dot-into";

import cfg, { type HostType } from "./config.ts";
import * as _ from "./utils.ts";
import type { Work } from "./retrieve-works.ts";
import { flat, mapValues, unique, values } from "remeda";

// Types

type VideoMeta = {
  width: number;
  height: number;
  thumbnailUrl: string;
};

// Utils

const awaitAll = Promise.all.bind(Promise);

const getVideoMetadata = async (
  host: HostType,
  id: string,
): Promise<VideoMeta> => {
  if (host === "Youtube") {
    const response = (
      await axios.get(
        `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${id}&format=json`,
        { responseType: "json" },
      )
    ).data;
    const parsed = youtubeVideoMetaResponseSchema.parse(response);

    return {
      width: parsed.width,
      height: parsed.height,
      thumbnailUrl: parsed.thumbnail_url,
    };
  } else if (host === "Vimeo") {
    const response = (
      await axios.get(`http://vimeo.com/api/v2/video/${id}.json`, {
        responseType: "json",
      })
    ).data[0];
    const parsed = vimeoVideoMetaResponseSchema.parse(response);

    return {
      width: parsed.width,
      height: parsed.height,
      thumbnailUrl: parsed.thumbnail_large,
    };
  }

  throw new Error(`Video ID "${id}" has wrong host: ${host}`);
};

const filesExist = R.all(fs.existsSync);

// Schemas

const youtubeVideoMetaResponseSchema = z.object({
  width: z.int(),
  height: z.int(),
  thumbnail_url: z.string(),
});

const vimeoVideoMetaResponseSchema = z.object({
  width: z.int(),
  height: z.int(),
  thumbnail_large: z.string(),
});

// Process

const generateVisualsCacheForWork = async (work: Work, workName: string) => {
  // Main visual.

  const mvLogReference = `${workName} -> main visual`;
  const mvOutputFilename = `${cfg.cacheDir}${work.default.mainVisualUrl}`;
  const mvMetaOutputFilename = `${cfg.cacheDir}${work.default.mainVisualMetaUrl}`;

  if (filesExist([mvOutputFilename, mvMetaOutputFilename])) {
    console.log(`Skipped: ${mvLogReference}`);
  } else {
    console.log(`Processing: ${mvLogReference}`);

    // Create folders.
    _.ensureDirForFile(mvMetaOutputFilename);

    const image = await fsPromises.readFile(
      `${cfg.worksDir}${work.default.mainVisualUrl}`,
    );

    const resized = await resizeMainVisual(image);
    await fsPromises.writeFile(mvOutputFilename, resized);
    console.log(`Output: ${mvOutputFilename}`);
    await writeImageMetadata(resized, mvMetaOutputFilename);
  }

  // Visuals.

  if (work.default.visuals) {
    const allVisuals = mapValues(work, (lang) => lang.visuals)
      .into(values())
      .into(flat(1))
      .into(unique());

    const promises = allVisuals.into(
      R.map(async (visual) => {
        const visualLogReference = `${workName} -> ${
          visual.type === "Image" ? visual.retrieveUrl : visual.id
        }`;

        // Filenames.
        const thumbOutputFilename = `${cfg.cacheDir}${visual.thumbnailUrl}`;
        const metaOutputFilename = `${cfg.cacheDir}${visual.metaUrl}`;

        if (filesExist([thumbOutputFilename, metaOutputFilename])) {
          console.log(`Skipped: ${visualLogReference}`);
        } else {
          console.log(`Processing: ${visualLogReference}`);

          [thumbOutputFilename, metaOutputFilename].forEach(_.ensureDirForFile);

          // Images.
          if (visual.type === cfg.visualType.image) {
            const isLocal = !_.isUrl(visual.retrieveUrl);
            const image: Buffer = isLocal
              ? await fsPromises.readFile(
                  `${cfg.worksDir}${workName}/${visual.retrieveUrl}`,
                )
              : (
                  await axios.get(visual.retrieveUrl, {
                    responseType: "arraybuffer",
                  })
                ).data;

            const thumbnail = await toThumbnail(image);
            await fsPromises.writeFile(thumbOutputFilename, thumbnail);
            console.log(`Output: ${thumbOutputFilename}`);

            if (isLocal) {
              const outputFilename = `${cfg.cacheDir}${visual.url}`;
              _.ensureDirForFile(outputFilename);

              const resized = await resizeImage(image);
              await fsPromises.writeFile(outputFilename, resized);
              console.log(`Output: ${outputFilename}`);
              await writeImageMetadata(resized, metaOutputFilename);
            } else {
              await writeImageMetadata(image, metaOutputFilename);
            }
            console.log(`Output: ${metaOutputFilename}`);

            // Videos.
          } else if (visual.type === cfg.visualType.video) {
            const metaVideo = await getVideoMetadata(visual.host, visual.id);

            const image: Buffer = (
              await axios.get(metaVideo.thumbnailUrl, {
                responseType: "arraybuffer",
              })
            ).data;

            const thumbnail = await toThumbnail(image);
            await fsPromises.writeFile(thumbOutputFilename, thumbnail);
            console.log(`Output: ${thumbOutputFilename}`);

            const color = await getImageColor(thumbnail);

            fs.writeFileSync(
              metaOutputFilename,
              _.toJson({
                width: metaVideo.width,
                height: metaVideo.height,
                color: color,
              }),
              "utf-8",
            );
            console.log(`Output: ${metaOutputFilename}`);
          }
        }
      }),
    );

    await awaitAll(promises);
  }
};

const getImageDimensions = async (image: Buffer) => {
  const metadata = await sharp(image).metadata();
  return {
    width: metadata.width,
    height: metadata.height,
  };
};
const getImageColor = async (image: Buffer) => {
  const colors = await vibrant.from(image).getPalette();
  const color = colors.Vibrant?.rgb;

  if (!color) {
    throw new Error("Could not get color for image");
  }

  return {
    red: color[0] / 0xff,
    green: color[1] / 0xff,
    blue: color[2] / 0xff,
  };
};
const getImageMetadata = async (image: Buffer) => {
  const dimensions = await getImageDimensions(image);
  const color = await getImageColor(image);
  return {
    width: dimensions.width,
    height: dimensions.height,
    color,
  };
};
const writeImageMetadata = async (image: Buffer, outputPath: string) => {
  fs.writeFileSync(
    outputPath,
    _.toJson(await getImageMetadata(image)),
    "utf-8",
  );
};

const toThumbnail = async (image: Buffer) => {
  // console.log("toThumbnail", image);
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
const resizeMainVisual = async (image: Buffer) => {
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

const resizeImage = async (image: Buffer) => {
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

const resizeTo = (
  dimensions: { width: number; height: number },
  image: Buffer,
) =>
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

export const generateVisualsCache = async (works: Record<string, Work>) => {
  const promises = works
    .into(R.mapObjIndexed(generateVisualsCacheForWork))
    .into(R.values);
  await awaitAll(promises);
};
