var elementsTitres = [];
var elementCourantTitre = null;

jQuery(document).ready(function () {
    var indiceElementsTitres = 0, cdlToolTipDiv, htmlElt = jQuery('html'), bodyElt = jQuery('body');

    bodyElt.append("<div id='cdlToolTipDiv'></div>");

    cdlToolTipDiv = jQuery("#cdlToolTipDiv");

    jQuery("[title]").each(function () {
        var elementCourant = jQuery(this);

        if (elementCourant.attr('title')) {
            elementsTitres['cdlTitled' + indiceElementsTitres] = elementCourant.attr('title');
            elementCourant.attr('class', "cdlTitled" + indiceElementsTitres + " " + elementCourant.attr('class'));

            elementCourant.on('mouseenter', function () {
                var elementCourant2 = jQuery(this), thisClassName = elementCourant2.attr('class'), aAppliquer = false, elementCourantTitreClassName;

                thisClassName = thisClassName.replace(/^([^ ]*) (.*)/, "$1");

                if (!elementCourantTitre || elementCourantTitre.size() === 0) {
                    aAppliquer = true;
                } else {
                    elementCourantTitreClassName = elementCourantTitre.attr('class').replace(/^([^ ]*) (.*)/, "$1");
                    if (elementCourant2.is('.' + elementCourantTitreClassName + " ." + elementCourant2)) {
                        aAppliquer = true;
                    }
                }
                if (aAppliquer) {
                    elementCourantTitre = elementCourant2;
                    cdlToolTipDiv.stop(true, true);
                    if (!elementCourant2.attr('title')) {
                        thisClassName = elementCourant2.attr('class').replace(/^([^ ]*) (.*)/, "$1");
                        elementCourant2.attr('title', elementsTitres[thisClassName]);
                    }
                    cdlToolTipDiv.html(elementCourant2.attr('title')).fadeIn(200);
                    jQuery("[alt]", elementCourant2).attr('alt', "");
                    elementCourant2.attr('title', "");
                } else {
                    elementCourant2.attr('title', "");
                }
            });

            elementCourant.on('mouseleave', function () {
                var elementCourant2 = jQuery(this), thisClassName = elementCourant2.attr('class');

                cdlToolTipDiv.stop(true, true);
                cdlToolTipDiv.fadeOut(200);
                thisClassName = thisClassName.replace(/^([^ ]*) (.*)/, "$1");
                elementCourant2.attr('title', elementsTitres[thisClassName]);
                elementCourantTitre = null;
            }).on('click', function () {
                var elementCourant2 = jQuery(this), thisClassName = elementCourant2.attr('class');

                cdlToolTipDiv.stop(true, true);
                cdlToolTipDiv.fadeOut(200);
                thisClassName = thisClassName.replace(/^([^ ]*) (.*)/, "$1");
                elementCourant2.attr('title', elementsTitres[thisClassName]);
                elementCourantTitre = null;
            }).on('mousemove', function (e) {
                var cursorSize = parseInt('###CURSOR_SIZE###', 10), elementCourant2 = jQuery(this);
                cdlToolTipDiv.css({'top': e.pageY, 'left': e.pageX + cursorSize});
                if (e.pageX + cursorSize + cdlToolTipDiv.width() + 14 > htmlElt.width()) {
                    cdlToolTipDiv.css({'top': e.pageY + cursorSize, 'left': htmlElt.width() - cdlToolTipDiv.width() - 14 - cursorSize});
                } else {
                    cdlToolTipDiv.css({'top': e.pageY, 'left': e.pageX + cursorSize});
                }
                if (!elementCourantTitre || elementCourantTitre.size() === 0) {
                    elementCourant2.mouseenter();
                }
            });
            indiceElementsTitres += 1;
        } else {
            elementCourant.removeAttr('title');
        }
    });

    if (bodyElt.width() < 680) {
        jQuery('.cdlFormPersonalization, .cdlAllPageContainer').css('overflow', "visible").css('margin-top', "0");
        jQuery('html, body').css('overflow', "auto").css('height', "auto");
        jQuery('.cdlUtilLinksContainer').css('margin', "0 0 10px 0").css('padding', "2px 0 2px 0").css('border-width', "2px").css('left', "0").appendTo('.cdlGlobalPage');
    }

    htmlElt.niceScroll({
        cursorwidth: 25,
        background: "transparent",
        cursorborder: "2px solid " + (window.cdlBackgroundColor || ""),
        cursorcolor: window.cdlFontColor || "",
        autohidemode: false,
        zindex: 114200
    });
});