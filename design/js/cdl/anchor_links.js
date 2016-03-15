function ds_gettop2(el) {
    var tmp = el.offsetTop;
    el = el.offsetParent;
    while (el) {
        tmp += el.offsetTop;
        el = el.offsetParent;
    }
    return tmp;
}

if (!(window.lecteurCDL) && !(document.lecteurCDL)) {
    jQuery('a[href*="#"]').click(function () {
        var urlLien = jQuery(this).attr('href').replace(/^(.*)#(.*)$/, "$1"), urlPage = document.location.href.replace(/^(.*)#(.*)$/, "$1"), cibleLien = jQuery(this).attr('href').replace(/^(.*)#(.*)$/, "$2");

        if (urlPage.indexOf(urlLien) > -1) {
            jQuery.address.value(cibleLien);
        }
    });
    jQuery.address.change(function (event) {
        if (event.value !== '/') {
            jQuery('[name="' + event.value.replace(/^\/(.*)$/, "$1") + '"]:first, #' + event.value.replace(/^\/(.*)$/, "$1")).each(function () {
                var myScrollTop = ds_gettop2(jQuery(this).get(0));

                jQuery('body').animate({scrollTop: myScrollTop - jQuery('div.cdlUtilLinksContainer').height() - 7}, 250);
            });
        }
        return false;
    });
}