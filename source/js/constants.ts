export type LanguageId = (typeof languages)[number];

export type VisualType = "Image" | "Video";

export type HostType = (typeof hostTypes)[number];

export const worksFolder = "works";

export const worksDir = `source/data/${worksFolder}/`;

export const cacheDir = `cache/${worksFolder}/`;

export const outputDir = "public/";

export const mainVisualSize = 1200;

export const mainVisualAR = 1.77;

export const visualMaxSize = 2000;

export const thumbnailSize = 300;

export const hostTypes = ["Youtube", "Vimeo"];

export const languages = ["en", "es", "ja"] as const;

export const defaultLanguageId = languages[0];
