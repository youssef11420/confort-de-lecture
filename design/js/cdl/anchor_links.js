function ds_gettop2(el) {
    "use strict";
    var tmp = el.offsetTop;
    el = el.offsetParent;
    while (el) {
        tmp += el.offsetTop;
        el = el.offsetParent;
    }
    return tmp;
}

if (!(window.lecteurCDL) && !(document.lecteurCDL)) {
    jQuery("a[href*=\"#\"]").click(function () {
        "use strict";
        var urlLien = jQuery(this).attr("href").replace(/^(.*)#(.*)$/, "$1");
        var urlPage = document.location.href.replace(/^(.*)#(.*)$/, "$1");
        var cibleLien = jQuery(this).attr("href").replace(/^(.*)#(.*)$/, "$2");

        if (urlPage.indexOf(urlLien) > -1) {
            jQuery.address.value(cibleLien);
        }
    });
    jQuery.address.change(function (event) {
        "use strict";
        if (event.value !== "/") {
            jQuery("[name=\"" + event.value.replace(/^\/(.*)$/, "$1") + "\"]:first, #" + event.value.replace(/^\/(.*)$/, "$1")).each(function () {
                var myScrollTop = ds_gettop2(jQuery(this).get(0));

                jQuery("body").animate({scrollTop: myScrollTop - jQuery("div.cdlUtilLinksContainer").height() - 7}, 250);
            });
        }
        return false;
    });
}