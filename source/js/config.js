const worksFolder = "works";

export default {
  elmDir: "source/elm/",
  copyDir: "source/copy/",
  dataDir: "source/data/",
  worksDir: `source/data/${worksFolder}/`,
  cacheDir: `cache/${worksFolder}/`,
  outputDir: "output/",
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
};
