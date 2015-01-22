elementsTitres = new Array();
elementCourantTitre = null;

jQuery(document).ready(function() {
	jQuery("body").append("<div id='cdlToolTipDiv'></div>");

	indiceElementsTitres = 0;
	jQuery("[title]").each(function () {
		if (jQuery(this).attr('title') != "") {
			elementsTitres['cdlTitled'+indiceElementsTitres] = jQuery(this).attr('title');
			jQuery(this).attr('class', "cdlTitled"+indiceElementsTitres+" "+jQuery(this).attr('class'));

			jQuery(this).mouseenter(function(e) {
				var thisClassName = jQuery(this).attr('class');
				thisClassName = thisClassName.replace(/^([^ ]*) (.*)/, "$1");
				aAppliquer = false;
				if (elementCourantTitre == null) {
					aAppliquer = true;
				} else {
					var elementCourantTitreClassName = elementCourantTitre.attr('class');
					elementCourantTitreClassName = elementCourantTitreClassName.replace(/^([^ ]*) (.*)/, "$1");
					if (jQuery(this).is('.'+elementCourantTitreClassName+" ."+thisClassName)) {
						aAppliquer = true;
					}
				}
				if (aAppliquer) {
					elementCourantTitre = jQuery(this);
					jQuery("#cdlToolTipDiv").stop(true, true);
					if (jQuery(this).attr('title') == "") {
						var thisClassName = jQuery(this).attr('class');
						thisClassName = thisClassName.replace(/^([^ ]*) (.*)/, "$1");
						jQuery(this).attr('title', elementsTitres[thisClassName]);
					}
					jQuery("#cdlToolTipDiv").html(jQuery(this).attr('title')).fadeIn(200);
					jQuery("[alt]", jQuery(this)).attr('alt', "");
					jQuery(this).attr('title',"");
				} else {
					jQuery(this).attr('title', "");
				}
			});

			jQuery(this).mouseleave(function(e) {
				jQuery("#cdlToolTipDiv").stop(true, true);jQuery("#cdlToolTipDiv").fadeOut(200);
				var thisClassName = jQuery(this).attr('class');
				thisClassName = thisClassName.replace(/^([^ ]*) (.*)/, "$1");
				jQuery(this).attr('title', elementsTitres[thisClassName]);
				elementCourantTitre = null;
			});
			jQuery(this).click(function(e) {
				jQuery("#cdlToolTipDiv").stop(true, true);jQuery("#cdlToolTipDiv").fadeOut(200);
				var thisClassName = jQuery(this).attr('class');
				thisClassName = thisClassName.replace(/^([^ ]*) (.*)/, "$1");
				jQuery(this).attr('title', elementsTitres[thisClassName]);
				elementCourantTitre = null;
			});
			jQuery(this).mousemove(function(e) {
				jQuery("#cdlToolTipDiv").css({'top': e.pageY, 'left': e.pageX + ###CURSOR_SIZE###});
				if (e.pageX + ###CURSOR_SIZE### + jQuery("#cdlToolTipDiv").width() + 14 > jQuery('html').width()) {
					jQuery("#cdlToolTipDiv").css({'top': e.pageY + ###CURSOR_SIZE###, 'left': jQuery('html').width() - jQuery("#cdlToolTipDiv").width() - 14 - ###CURSOR_SIZE###});
				} else {
					jQuery("#cdlToolTipDiv").css({'top': e.pageY, 'left': e.pageX + ###CURSOR_SIZE###});
				}
				if (elementCourantTitre == null) {
					jQuery(this).mouseenter();
				}
			});
			++indiceElementsTitres;
		} else {
			jQuery(this).removeAttr('title');
		}
	});

	if (jQuery('body').width() < 680) {
		jQuery('.cdlFormPersonalization, .cdlAllPageContainer').css('overflow', "visible").css('margin-top', "0");
		jQuery('html, body').css('overflow', "auto").css('height', "auto");
		jQuery('.cdlUtilLinksContainer').css('margin', "0 0 10px 0").css('padding', "2px 0 2px 0").css('border-width', "2px").css('left', "0").appendTo('.cdlGlobalPage');
	}
});