
(function (that) {

	'use strict';

	var onLoad = function (cb) { /interactive|complete/.test(document.readyState) ? setTimeout(cb, 0) : document.addEventListener('DOMContentLoaded', cb); };
	var selAll = document.querySelectorAll.bind(document);
	var sel = document.querySelector.bind(document);
	var toArray = Function.prototype.call.bind([].slice);
	var prepend = function (a) { return function (b) { return a + b } };
	var not = function (f) { return function () { return !f.apply(this, toArray(arguments)) } };
	var test = function (regex) { return function (text) { return regex.test(text) } };

	///////////////////////////

	var checks;

	function updateVisibility() {
		var works = sel('#works');
		var unrelatedClasses = toArray(works.classList).filter(not(test(/visible-cat-.*/)));
		var enabledCategoryClasses = checks.filter(checkIsChecked).map(checkToCategory).map(prepend('visible-cat-'));
		works.className = unrelatedClasses.concat(enabledCategoryClasses).join(' ');
	}

	function checkToCategory(checkEl) {
		return checkEl.id.replace(/check-(.*)/, '$1');
	}

	function checkIsChecked(checkEl) {
		return checkEl.checked;
	}

	onLoad(function () {
		checks = toArray(selAll('#filter input'));
		checks.forEach(function (el) {
			el.addEventListener('click', updateVisibility);
		});
		updateVisibility();
	});

}(this));




