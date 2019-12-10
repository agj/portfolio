
const R = require('ramda');
const fs = require('fs-extra');
const xre = require('xregexp');


const getFile = filename =>
	fs.readFileSync(filename, 'utf-8')
	.split('\n')
	.filter(notEmpty);
const getUnihanFile = filename =>
	getFile(filename)
	.map(R.split('\t'))
	.reduce((obj, [code, key, value]) => {
		const char = unicodeToChar(code);
		if (!R.has(char, obj)) obj[char] = {};
		obj[char][key] = value;
		return obj;
	}, {});
const notEmpty = R.pipe(
	R.trim,
	line => line.length > 0 && line[0] !== '#' && !/^\/\*/.test(line));


module.exports = {
	characters: normalizedCharacters,
};
