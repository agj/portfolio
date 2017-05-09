
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
	var getViewportW = function () { return Math.max(document.documentElement.clientWidth, window.innerWidth || 0) };
	var getViewportH = function () { return Math.max(document.documentElement.clientHeight, window.innerHeight || 0) };


	//

	var isYoutube = test(/.*youtube\.com.*/);
	var isVimeo = test(/.*vimeo\.com.*/);
	var isImage = test(/\.(jpg|jpeg|png|gif)$/);

	var popup = sel('#popup');
	var popupContent = popup.querySelector('.content');

	var popupSettings = {};

	function listenPopup(el) {
		var url = el.href;
		var data = el.getAttribute('data-popup').split(' ');
		var settings = {
			width: parseInt(data[0]),
			height: parseInt(data[1]),
			color: data[2],
		};
		el.addEventListener('click', function (e) {
			showPopup(url, settings);
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
			return '<img class="image" src="' + url + '" />';
		} else {
			return '<iframe class="other" src="' + url + '" />';
		}
	}

	function resizePopup() {
		var video = popup.querySelector('.content > .video, .content > .other');
		if (video) {
			var vw = getViewportW();
			var vh = getViewportH();
			video.style.width = Math.min(popupSettings.width / popupSettings.height * vh, vw) + 'px';
			video.style.height = Math.min(popupSettings.height / popupSettings.width * vw, vh) + 'px';
		}
	}

	function resetPopup() {
		popupContent.innerHTML = '';
		popup.classList.remove('showing');
		popupSettings = {};
	}

	function showPopup(url, settings) {
		resetPopup();
		popupSettings = settings;
		popupContent.innerHTML = buildHTML(url);
		resizePopup();
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
		window.addEventListener('resize', debounce(0.5, resizePopup));
	});

})();
