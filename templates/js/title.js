var elementsTitres = [];
var elementCourantTitre = null;
var nbImagesGallery = 0;

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
            jQuery(this).width(Math.min(jQuery(this).width() * 2, 600));
        }
    });

    jQuery(document).on("click", ".cdlGalleryClose a", function (event) {
        jQuery(".cdlImageGallery").hide();
        event.preventDefault();
    });

    jQuery(document).on("click", ".cdlGalleryPrev a", function (event) {
        var activeImage = jQuery(".cdlZoomImageActive");
        var prevImageIndex = activeImage.data("cdlimageindex") - 1;
        var prevImage;

        jQuery(".cdlGalleryNext").show();
        if (prevImageIndex === 0) {
            jQuery(".cdlGalleryPrev").hide();
        }

        if (prevImageIndex < 0) {
            prevImageIndex = nbImagesGallery - 1;
        }
        prevImage = jQuery(".cdlZoomImage" + prevImageIndex);
        activeImage.removeClass("cdlZoomImageActive");
        prevImage.addClass("cdlZoomImageActive");
        jQuery(".cdlImageGallery").css("background-image", "url(" + prevImage.attr("href") + ")");
        event.preventDefault();
    });

    jQuery(document).on("click", ".cdlGalleryNext a", function (event) {
        var activeImage = jQuery(".cdlZoomImageActive");
        var nextImageIndex = 1 + activeImage.data("cdlimageindex");
        var nextImage;

        jQuery(".cdlGalleryPrev").show();
        if (nextImageIndex === nbImagesGallery - 1) {
            jQuery(".cdlGalleryNext").hide();
        }
        if (nextImageIndex >= nbImagesGallery) {
            nextImageIndex = 0;
        }
        nextImage = jQuery(".cdlZoomImage" + nextImageIndex);
        activeImage.removeClass("cdlZoomImageActive");
        nextImage.addClass("cdlZoomImageActive");
        jQuery(".cdlImageGallery").css("background-image", "url(" + nextImage.attr("href") + ")");
        event.preventDefault();
    });

    jQuery(document).on("click", ".cdlZoomImage", function (event) {
        var imagesGallery = jQuery(".cdlZoomImage");

        nbImagesGallery = imagesGallery.length;
        jQuery(".cdlGalleryPrev").hide();
        if (nbImagesGallery === 1) {
            jQuery(".cdlGalleryNext").hide();
        }
        imagesGallery.each(function (index) {
            jQuery(this).addClass("cdlZoomImage" + index).data("cdlimageindex", index);
        });
        jQuery(this).addClass("cdlZoomImageActive");
        jQuery(".cdlImageGallery").show().css("background-image", "url(" + jQuery(this).attr("href") + ")");
        event.preventDefault();
    });

    jQuery(".cdlBackToTop a").click(function (e) {
        jQuery("html, body").animate({scrollTop: 0});
        e.preventDefault();
        return false;
    });
});