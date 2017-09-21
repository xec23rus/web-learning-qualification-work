function getRealDisplay(elem) {
	if (elem.currentStyle) {
		return elem.currentStyle.display
	} else if (window.getComputedStyle) {
		var computedStyle = window.getComputedStyle(elem, null )

		return computedStyle.getPropertyValue('display')
	}
}

function hide(el) {
	if (!el.getAttribute('displayOld')) {
		el.setAttribute("displayOld", el.style.display)
	}

	el.style.display = "none"
}

displayCache = {}

function isHidden(el) {
	var width = el.offsetWidth, height = el.offsetHeight,
		tr = el.nodeName.toLowerCase() === "tr"

	return width === 0 && height === 0 && !tr ?
		true : width > 0 && height > 0 && !tr ? false :	getRealDisplay(el)
}

function toggle(el) {
	isHidden(el) ? show(el) : hide(el)
}


function show(el) {

	if (getRealDisplay(el) != 'none') return

	var old = el.getAttribute("displayOld");
	el.style.display = old || "";

	if ( getRealDisplay(el) === "none" ) {
		var nodeName = el.nodeName, body = document.body, display

		if ( displayCache[nodeName] ) {
			display = displayCache[nodeName]
		} else {
			var testElem = document.createElement(nodeName)
			body.appendChild(testElem)
			display = getRealDisplay(testElem)

			if (display === "none" ) {
				display = "block"
			}

			body.removeChild(testElem)
			displayCache[nodeName] = display
		}

		el.setAttribute('displayOld', display)
		el.style.display = display
	}
}

function toggleX(el) {
	/*if (event.path[0].dataset.outitemname) {
		dt = event.path[0].dataset.outitemname;
	} else if (event.path[1].dataset.outitemname) {
		dt = event.path[1].dataset.outitemname;
	} else if (event.path[2].dataset.outitemname) {
		dt = event.path[2].dataset.outitemname;
	};*/
	
	elem = document.querySelector('[data-outItemData="'+el+'"]');
	toggle(elem);
	elem = document.querySelector('[data-outItemName="'+el+'"]');
	toggleClass(elem, 'OINameOpen', 'OINameClose');
}

function nextstep(stp) {
	if (stp == 1) {
		hid_el = document.querySelector('[data-outItemData="contacts"]');
		chClElCl = document.querySelector('[data-outItemName="contacts"]');
		shw_el = document.querySelector('[data-outItemData="deliveryInfo"]');
		chClElOp = document.querySelector('[data-outItemName="deliveryInfo"]');
	} else if (stp == 2) {
		hid_el = document.querySelector('[data-outItemData="deliveryInfo"]');
		chClElCl = document.querySelector('[data-outItemName="deliveryInfo"]');
		shw_el = document.querySelector('[data-outItemData="confirm"]');
		chClElOp = document.querySelector('[data-outItemName="confirm"]');		
	} else if (stp == 3) {
		hid_el = document.getElementById('orderForm');
		shw_el = document.getElementById('confirmation');		
	};
	hide(hid_el);
	setClass(chClElCl, 'OINameClose');
	show(shw_el);
	setClass(chClElOp, 'OINameOpen');
};

function toggleClass(el, cl1, cl2) {
	//console.log(el);
	isClass(el, cl1) ? setClass(el, cl2) : setClass(el, cl1)
};

function isClass(el, cl) {
	return el.className == cl ? true : false
};

function setClass(el, cl) {
	el.className = cl;
};

function radioCopy(el) {
	var delivTypes = document.querySelectorAll('[data-deliveryType]');

	for (var i = 0; i < delivTypes.length; i++) {
		if (delivTypes[i].dataset.deliverytype != el.value) {hide(delivTypes[i]);} else {show(delivTypes[i]);};
	}	
};

function copyHTML(val, selec) {
	var elemList = document.querySelectorAll(selec);
	for (var i = 0; i < elemList.length; i++) {
		elemList[i].innerHTML = val;
	};	
};