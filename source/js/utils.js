
const R = require('ramda');
const fs = require('fs-extra');

const log = R.tap(console.log);
const prepend = R.curry((prep, text) => prep + text);
const writeFile = R.curry((filename, data) => fs.writeFileSync(filename, data, 'utf-8'));
const multiGroupBy = R.curry((getGroups, list) =>
	list.reduce((r, item) =>
		getGroups(item).reduce((r, group) =>
			R.set(R.lensProp(group),
			      R.append(item, R.has(group, r) ? r[group] : []),
			      r),
			r),
		{})
	.into(R.map(R.uniq)));


module.exports = {
	log,
	prepend,
	writeFile,
	multiGroupBy,
};
