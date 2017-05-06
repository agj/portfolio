
///////////////////////////

var checks = [];
var cats = [];
var works;

///////////////////////////

window.addEventListener("load", onLoad, false);

function onLoad(e) {
	//var nodes = document.getElementById("filter").childNodes;
	var nodes = document.getElementById("filter").getElementsByTagName("INPUT");
	
	var len = nodes.length;
	var node, nodeID;
	for (var i = 0; i < len; i++) {
		node = nodes.item(i);
		checks.push(node);
		
		nodeID = node.getAttribute("id");
		if (nodeID.substr(0, 6) == "check-") {
			cats.push(nodeID.substr(6));
		}
		
		node.addEventListener("click", onClickCheckbox, false);
	}
	
	// List works.
	
	works = getChildrenByClassName(document.body, "work");
	
	//alert("Loaded.");
	
	update();
}


function onClickCheckbox(e) {
	//alert("Clicked checkbox");
	
	e = e || window.event;
	
	update();
}

function update() {
	var activeCats = getActiveCats();
	
	var len = works.length;
	var el, show, cat, vis;
	for (var i = 0; i < len; i++) {
		el = works[i];
		show = false;
		
		for (var j = 0; j < activeCats.length; j++) {
			if (hasClassName(el, "cat-" + activeCats[j])) {
				show = true;
			}
		}
		
		vis = show ? "block" : "none";
		el.style.display = vis;
	}
}

function getActiveCats() {
	var result = [];
	
	var len = checks.length;
	for (var i = 0; i < len; i++) {
		if (checks[i].checked) {
			result.push(cats[i]);
		}
	}
	
	return result;
}




function getChildrenByClassName(oElm, className) {
	var nodes = oElm.childNodes;
	var returnList = [];
	
	className = className.replace(/\-/g, "\\-");
	var regex = new RegExp("(^|\\s)" + className + "(\\s|$)");
	
	var el;
	for (var i = 0; i < nodes.length; i++) {
		el = nodes.item(i);
		if (el.hasAttribute && el.hasAttribute("class")) {
			if (regex.test(el.getAttribute("class"))) {
				returnList.push(el);
			}
		}
	}
	
	return returnList;
}

function hasClassName(el, className) {
	className = className.replace(/\-/g, "\\-");
	var regex = new RegExp("(^|\\s)" + className + "(\\s|$)");
	
	if (el.hasAttribute && el.hasAttribute("class")) {
		if (regex.test(el.getAttribute("class"))) {
			return true;
		}
	}
	
	return false;
}




