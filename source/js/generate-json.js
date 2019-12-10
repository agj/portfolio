

const R = require('ramda');
const mkdirp = require('mkdirp');
require('dot-into').install();

const _ = require('./utils');


// Generate JSON

const generateJSON = async () => {
	mkdirp.sync('output/');

	const data = require('./data.js');

	data.characters
	.into(data => JSON.stringify(data, null, '\t'))
	.into(_.prepend('\ufeff'))
	.into(_.writeFile('output/data.json'));
};


module.exports = generateJSON;
