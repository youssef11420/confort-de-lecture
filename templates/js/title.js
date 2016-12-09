var elementsTitres = [];
var elementCourantTitre = null;

jQuery(document).ready(function () {
    "use strict";
    var indiceElementsTitres = 0;
    var cdlToolTipDiv;
    var htmlElt = jQuery("html");
    var bodyElt = jQuery("body");

    bodyElt.append("<div id='cdlToolTipDiv'></div>");

    cdlToolTipDiv = jQuery("#cdlToolTipDiv");

    jQuery("[title]").each(function () {
        var elementCourant = jQuery(this);

        if (elementCourant.attr("title")) {
            elementsTitres["cdlTitled" + indiceElementsTitres] = elementCourant.attr("title");
            elementCourant.attr("class", "cdlTitled" + indiceElementsTitres + " " + elementCourant.attr("class"));

            elementCourant.on("mouseenter", function () {
                var elementCourant2 = jQuery(this);
                var thisClassName = elementCourant2.attr("class");
                var aAppliquer = false;
                var elementCourantTitreClassName;

                thisClassName = thisClassName.replace(/^([^\s]*)\s(.*)/, "$1");

                if (!elementCourantTitre || elementCourantTitre.length === 0) {
                    aAppliquer = true;
                } else {
                    elementCourantTitreClassName = elementCourantTitre.attr("class").replace(/^([^\s]*)\s(.*)/, "$1");
                    if (elementCourant2.is("." + elementCourantTitreClassName + " ." + thisClassName)) {
                        aAppliquer = true;
                    }
                }
                if (aAppliquer) {
                    elementCourantTitre = elementCourant2;
                    cdlToolTipDiv.stop(true, true);
                    if (!elementCourant2.attr("title")) {
                        thisClassName = elementCourant2.attr("class").replace(/^([^\s]*)\s(.*)/, "$1");
                        elementCourant2.attr("title", elementsTitres[thisClassName]);
                    }
                    cdlToolTipDiv.html(elementCourant2.attr("title")).fadeIn(200);
                    jQuery("[alt]", elementCourant2).attr("alt", "");
                    elementCourant2.attr("title", "");
                } else {
                    elementCourant2.attr("title", "");
                }
            });

            elementCourant.on("mouseleave", function () {
                var elementCourant2 = jQuery(this);
                var thisClassName = elementCourant2.attr("class");

                cdlToolTipDiv.stop(true, true);
                cdlToolTipDiv.fadeOut(200);
                thisClassName = thisClassName.replace(/^([^\s]*)\s(.*)/, "$1");
                elementCourant2.attr("title", elementsTitres[thisClassName]);
                elementCourantTitre = null;
            }).on("click", function () {
                var elementCourant2 = jQuery(this);
                var thisClassName = elementCourant2.attr("class");

                cdlToolTipDiv.stop(true, true);
                cdlToolTipDiv.fadeOut(200);
                thisClassName = thisClassName.replace(/^([^\s]*)\s(.*)/, "$1");
                elementCourant2.attr("title", elementsTitres[thisClassName]);
                elementCourantTitre = null;
            }).on("mousemove", function (e) {
                var cursorSize = parseInt("###CURSOR_SIZE###", 10);
                var elementCourant2 = jQuery(this);
                cdlToolTipDiv.css({"top": e.pageY, "left": e.pageX + cursorSize});
                if (e.pageX + cursorSize + cdlToolTipDiv.width() + 14 > htmlElt.width()) {
                    cdlToolTipDiv.css({"top": e.pageY + cursorSize, "left": htmlElt.width() - cdlToolTipDiv.width() - 14 - cursorSize});
                } else {
                    cdlToolTipDiv.css({"top": e.pageY, "left": e.pageX + cursorSize});
                }
                if (!elementCourantTitre || elementCourantTitre.length === 0) {
                    elementCourant2.mouseenter();
                }
            });
            indiceElementsTitres += 1;
        } else {
            elementCourant.removeAttr("title");
        }
    });

    htmlElt.niceScroll({
        cursorwidth: 25,
        background: "transparent",
        cursorborder: "2px solid " + (window.cdlBackgroundColor || ""),
        cursorcolor: window.cdlFontColor || "",
        autohidemode: false,
        zindex: 114200
    });

    jQuery(".cdlCadre img").each(function () {
        if (jQuery(this).width() < 600) {
            jQuery(this).width(600);
        }
    });
});