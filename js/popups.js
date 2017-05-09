
(function () {
	'use strict';

	// Utilities.

	var onLoad = function (cb) { /interactive|complete/.test(document.readyState) ? setTimeout(cb, 0) : document.addEventListener('DOMContentLoaded', cb); };
	var selAll = document.querySelectorAll.bind(document);
	var sel = document.querySelector.bind(document);
	var toArray = Function.prototype.call.bind([].slice);
	var prepend = function (a) { return function (b) { return a + b } };
	var not = function (f) { return function () { return !f.apply(this, toArray(arguments)) } };
	var test = function (regex) { return function (text) { return regex.test(text) } };
	var debounce = function (secs, fn) {
		var delay = secs * 1000;
		var timeoutID;
		function exec(t, args) { fn.apply(t, args); };
		return function () {
			clearTimeout(timeoutID);
			timeoutID = setTimeout(exec, delay, this, toArray(arguments));
		};
	};

	//

	var isYoutube = test(/.*youtube\.com.*/);
	var isVimeo = test(/.*vimeo\.com.*/);
	var isImage = test(/\.(jpg|jpeg|png|gif)$/);

	var popup = sel('#popup');
	var popupContent = popup.querySelector('.content');

	function listenPopup(el) {
		el.addEventListener('click', function (e) {
			showPopup(el.href);
			e.preventDefault();
		});
	}

	function objectToURL(obj) {
		return Object.keys(obj).map(function (key) {
				return key + '=' + encodeURIComponent(obj[key]);
			}).join('&');
	};

	function buildHTML(url) {
		if (isVimeo(url)) {
			var id = url.match(/vimeo.com\/(.+)$/)[1];
			return '<iframe class="video" src="https://player.vimeo.com/video/' + id + '?color=ffffff&title=0&byline=0&portrait=0" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>';
		} else if (isYoutube(url)) {
			var id = url.match(/watch\?v=(.+)$/)[1];
			return '<iframe class="video" src="https://www.youtube-nocookie.com/embed/' + id + '?rel=0&amp;showinfo=0" frameborder="0" allowfullscreen></iframe>';
		} else if (isImage(url)) {
			return '<img src="' + url + '" />';
		} else {
			return '<iframe src="' + url + '" />';
		}
	}

	function autoResizePopup() {
		var video = popup.querySelector('.content > .video');
		if (video) {
			video.style.height = '500px';
		}
	}

	function resetPopup() {
		popupContent.innerHTML = '';
		popup.classList.remove('showing');
	}

	function showPopup(url) {
		resetPopup();
		popupContent.innerHTML = buildHTML(url);
		setAutoResizer();
		popup.classList.add('showing');
	}

	onLoad(function () {
		selAll('.open-popup')
		.forEach(function (el) {
			if (el.tagName.toLowerCase() === 'a') listenPopup(el);
			else el.querySelectorAll('a').forEach(listenPopup);
		});
		popup.querySelector('.close-button').addEventListener('click', resetPopup);
		popup.addEventListener('click', function (e) {
			if (e.target === popup) resetPopup();
		});
		document.addEventListener('keyup', function (e) {
			if (e.key === 'Escape') resetPopup();
		})
		window.addEventListener('resize', debounce(0.5, autoResizePopup));
	});

})();
