
const worksFolder = "works"

module.exports = {
    elmDir: 'source/elm/',
    copyDir: 'source/copy/',
    dataDir: 'source/data/',
    worksDir: `source/data/${ worksFolder }/`,
    cacheDir: `cache/${ worksFolder }/`,
    outputDir: 'output/',
    worksFolder: worksFolder,
    thumbnailSize: 300,

    visualType: {
        image: 'Image',
        video: 'Video',
    },
    hostType: {
        youtube: 'Youtube',
        vimeo: 'Vimeo',
    },

    languages: ['en', 'es', 'ja'], // First one maps to `default`.
};
