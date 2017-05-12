
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
	var partialL = function (f, args) { return function () { return f.apply(null, args.concat(toArray(arguments))) } };
	var eq = function (a) { return function (b) { return b === a } };


	//

	var isYoutube = test(/.*youtube\.com.*/);
	var isVimeo = test(/.*vimeo\.com.*/);
	var isImage = test(/\.(jpg|jpeg|png|gif)$/);

	var popup, popupContent;

	var currentOpener, currentGroup;

	function elToOpener(element) {
		var data = element.getAttribute('data-popup').split(' ');
		return {
			element: element,
			url: element.href,
			width: parseInt(data[0]),
			height: parseInt(data[1]),
			color: data[2],
		};
	}

	function listenOpener(group, opener) {
		opener.element.addEventListener('click', function (e) {
			if (e.altKey || e.ctrlKey || e.metaKey || e.shiftKey) return;
			showPopup(opener, group);
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
			if (currentOpener.width && currentOpener.height) {
				video.style.width = Math.min(currentOpener.width / currentOpener.height * vh, vw) + 'px';
				video.style.height = Math.min(currentOpener.height / currentOpener.width * vw, vh) + 'px';
			} else {
				video.style.width = vw + 'px';
				video.style.height = vh + 'px';
			}
		}
	}

	function resetPopup() {
		popupContent.innerHTML = '';
		popup.classList.remove('showing');
		currentOpener = null;
		currentGroup = null;
		resetNavigation();
	}

	function resetNavigation() {
		popup.classList.remove('has-previous', 'has-next');
		if (!currentGroup) return;
		var index = currentGroup.findIndex(eq(currentOpener));
		if (index > 0) popup.classList.add('has-previous');
		if (index < currentGroup.length - 1) popup.classList.add('has-next');
	}

	function showPopup(opener, group) {
		resetPopup();
		currentOpener = opener;
		currentGroup = group;
		popupContent.innerHTML = buildHTML(opener.url);
		resizePopup();
		resetNavigation();
		popup.classList.add('showing');
	}

	function popupNavigate(offset) {
		console.log(offset);
		var index = currentGroup.findIndex(eq(currentOpener)) + offset;
		if (index > -1 && index < currentGroup.length)
			showPopup(currentGroup[index], currentGroup);
	}

	onLoad(function () {
		sel('body').insertAdjacentHTML('beforeend',
			'<div id="popup">' +
				'<div class="close button">×</div>' +
				'<div class="content"></div>' +
				'<div class="previous button">⟨</div>' +
				'<div class="next button">⟩</div>' +
			'</div>'
		);

		popup = sel('#popup');
		popupContent = popup.querySelector('.content');

		selAll('.popup-group')
		.forEach(function (el) {
			var group =
				toArray(el.querySelectorAll('a.open-popup'))
				.map(elToOpener);
			group.forEach(partialL(listenOpener, [group]));
		});

		popup.querySelector('.previous.button').addEventListener('click', partialL(popupNavigate, [-1]));
		popup.querySelector('.next.button').addEventListener('click', partialL(popupNavigate, [1]));

		popup.querySelector('.close.button').addEventListener('click', resetPopup);
		popup.addEventListener('click', function (e) {
			if (e.target === popup) resetPopup();
		});
		document.addEventListener('keyup', function (e) {
			if (e.key === 'Escape') resetPopup();
		});

		window.addEventListener('resize', debounce(0.5, resizePopup));
	});

})();
