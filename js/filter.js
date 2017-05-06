
(function (that) {

	"use strict";

	///////////////////////////

	var checks = [];
	var cats = [];
	var works;

	///////////////////////////

	window.addEvent("domready", onLoad, false);

	function onLoad(e) {
		//var nodes = document.getElementById("filter").childNodes;
		var nodes = $("filter").getElements("input");
		
		var len = nodes.length;
		var node, nodeID;
		for (var i = 0; i < len; i++) {
			node = nodes[i];
			checks.push(node);
			
			nodeID = node.get("id");
			if (nodeID.substr(0, 6) == "check-") {
				cats.push(nodeID.substr(6));
			}
			
			node.addEvent("click", onClickCheckbox, false);
		}
		
		// List works.
		
		works = $$(".work");
		
		update();
	}


	function onClickCheckbox(e) {
		update();
	}

	function update() {
		var activeCats = getActiveCats();
		
		var len = works.length;
		var el, show, cat;
		for (var i = 0; i < len; i++) {
			el = works[i];
			show = false;
			
			for (var j = 0; j < activeCats.length; j++) {
				if (el.hasClass("cat-" + activeCats[j])) {
					show = true;
				}
			}
			
			el.style.display = show ? "block" : "none";
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

}(this));




