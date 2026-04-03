const worksFolder = "works";

type Config = typeof config;

export type LanguageId = Config["languages"][number];

export type VisualType = Config["visualType"][keyof Config["visualType"]];

export type HostType = Config["hostType"][keyof Config["hostType"]];

const config = {
  worksDir: `source/data/${worksFolder}/`,
  cacheDir: `cache/${worksFolder}/`,
  outputDir: "public/",
  worksFolder: worksFolder,

  mainVisualSize: 1200,
  mainVisualAR: 1.77,
  visualMaxSize: 2000,
  thumbnailSize: 300,

  visualType: {
    image: "Image",
    video: "Video",
  },
  hostType: {
    youtube: "Youtube",
    vimeo: "Vimeo",
  },

  languages: ["en", "es", "ja"], // First one maps to `default`.
} as const;

export const defaultLanguageId = config.languages[0];

export default config;
