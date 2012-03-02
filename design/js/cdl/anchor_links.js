function ds_gettop2(el) {
	if (true) {
		var tmp = el.offsetTop;
		el = el.offsetParent;
		while(el) {
			tmp += el.offsetTop;
			el = el.offsetParent;
		}
		return tmp;
	} else {
		return el.offsetTop;
	}
}

if (!(window["lecteurCDL"]) && !(document["lecteurCDL"])) {
	jQuery.address.change(function(event) {
		if (event.value != '/') {
			jQuery('[name="'+event.value+'"]:first, #'+event.value).each(function () {
				myScrollTop = ds_gettop2(jQuery(this).get(0));
				jQuery('div.cdlAllPageContainer').animate({scrollTop: myScrollTop-jQuery('div.cdlUtilLinksContainer').get(0).offsetHeight-7}, 250);
			});
		}
		return false;
	});
}