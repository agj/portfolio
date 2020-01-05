
const fs = require('fs-extra');

const retrieveWorks = require('./source/js/retrieve-works');
const generateVisualsCache = require('./source/js/generate-visuals-cache');
const generateWorksJson = require('./source/js/generate-works-json');

const cfg = require('./source/js/config');


// fs.removeSync(cfg.cacheDir);

(async () => {
	const data = await retrieveWorks();

	await generateVisualsCache(data);

	await generateWorksJson(data);

})();
