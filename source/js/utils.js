
const R = require('ramda');
const fs = require('fs-extra');
const ow = require('ow').default;
require('dot-into').install();

const log = R.tap(console.log);
const prepend = R.curry((prep, text) => prep + text);
const multiGroupBy = R.curry((getGroups, list) =>
	list.reduce((r, item) =>
		getGroups(item).reduce((r, group) =>
			R.set(R.lensProp(group),
			      R.append(item, R.has(group, r) ? r[group] : []),
			      r),
			r),
		{})
	.into(R.map(R.uniq)));
const toJson = (data) =>
	JSON.stringify(data, null, '\t');
const isUrl = (url) =>
	ow.isValid(url, ow.string.url);


module.exports = {
	log,
	prepend,
	multiGroupBy,
	toJson,
	isUrl,
};
