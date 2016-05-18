var pageParts = [];
var pageFirstPartsRelated = [];
var focusablesIndexes = [];
var firstCadreElementsIndexes = [];
var i = 0;
var currentIndice = 0;
var currentFocusableIndice = 0;
var currentFirstCadreElementIndice = 0;
var shiftKeyPressed = false;
var isReading = false;
var focusOnAField = false;
var timer;
var duree = 250;
var content = "";
var playDirection = '';
var playMode = '';
var isInProtectedField = false;
var isPaused = false;
var isStopped = true;
var myScrollTop = 0;
var focusedSelect = null;
var focusedSelectedIndex = null;
var firstFieldIndex = null;
var lecteurAudioHTML5 = document.getElementById('lecteurAudioCDL');
var cdlAudioPrev = jQuery('.cdlAudioPrevBloc,.cdlAudioPrevLine');
var cdlAudioPlayPause = jQuery('.cdlAudioPlayPause');
var cdlAudioStop = jQuery('.cdlAudioStop');
var cdlAudioNext = jQuery('.cdlAudioNextBloc,.cdlAudioNextLine');
var pausePosition = 0;

jQuery.fn.outer = function () {
    return jQuery(jQuery('<div></div>').html(this.clone())).html();
};

// Positionne le flag de lecture à faux mais le flag de pause à vrai
function estPretEnPause() {
    isReading = false;
    isPaused = true;
}
// Positionne le flag de lecture à faux
function estPret() {
    isReading = false;
}

// A appeler à l'arrêt de la lecture
function stopLecture() {
    jQuery('.cdlInversedColor input[type="text"], .cdlInversedColor input[type="color"], .cdlInversedColor input[type="date"], .cdlInversedColor input[type="datetime"], .cdlInversedColor input[type="datetime-local"], .cdlInversedColor input[type="email"], .cdlInversedColor input[type="month"], .cdlInversedColor input[type="number"], .cdlInversedColor input[type="range"], .cdlInversedColor input[type="search"], .cdlInversedColor input[type="tel"], .cdlInversedColor input[type="time"], .cdlInversedColor input[type="url"], .cdlInversedColor input[type="week"], .cdlInversedColor input[type="password"], .cdlInversedColor textarea, .cdlInversedColor select').blur();
    jQuery('.cdlInversedColor').removeClass('cdlInversedColor');

    jQuery('div.cdlAllPageContainer').animate({scrollTop: 0}, 500);

    // Réinitialise l'indice
    currentIndice = 0;
    isReading = false;
    isPaused = false;
    isStopped = true;
}

function updateLecteur(mode) {
    switch (mode) {
    case 'play':
        cdlAudioPlayPause.removeClass('cdlAudioPlay').addClass('cdlAudioPause');
        if (currentIndice > 0) {
            cdlAudioPrev.removeClass('cdlDisabled');
        } else {
            cdlAudioPrev.addClass('cdlDisabled');
        }
        if (currentIndice < pageParts.length - 1) {
            cdlAudioNext.removeClass('cdlDisabled');
        } else {
            cdlAudioNext.addClass('cdlDisabled');
        }
        cdlAudioStop.removeClass('cdlDisabled');
        break;
    case 'pause':
        cdlAudioPlayPause.removeClass('cdlAudioPause').addClass('cdlAudioPlay');
        cdlAudioStop.removeClass('cdlDisabled');
        break;
    case 'stop':
        cdlAudioPlayPause.removeClass('cdlAudioPause').addClass('cdlAudioPlay');
        if (currentIndice > 0) {
            cdlAudioPrev.removeClass('cdlDisabled');
        } else {
            cdlAudioPrev.addClass('cdlDisabled');
        }
        if (currentIndice < pageParts.length - 1) {
            cdlAudioNext.removeClass('cdlDisabled');
        } else {
            cdlAudioNext.addClass('cdlDisabled');
        }
        cdlAudioStop.addClass('cdlDisabled');
        break;
    default:
        cdlAudioPlayPause.removeClass('cdlAudioPause').addClass('cdlAudioPlay');
        cdlAudioPrev.addClass('cdlDisabled');
        cdlAudioStop.addClass('cdlDisabled');
        break;
    }
}

function cdlLit(text, playDirectionParam, playModeParam) {
    playDirection = playDirectionParam;
    playMode = playModeParam;

    if (text) {
        updateLecteur('play');

        lecteurAudioHTML5.src = (window.cdlEmbeddedURL || "") + "/audio-text/" + window.cdlSiteId + "/?cdltext=" + encodeURIComponent(content);
        lecteurAudioHTML5.currentTime = pausePosition;
        lecteurAudioHTML5.play();
        pausePosition = 0;
    } else {
        updateLecteur('stop');
    }
}

function cdlPauseIt() {
    pausePosition = lecteurAudioHTML5.currentTime;

    lecteurAudioHTML5.pause();

    estPretEnPause();
    updateLecteur('pause');
}

function cdlStopIt(initPausePos) {
    lecteurAudioHTML5.pause();
    lecteurAudioHTML5.currentTime = 0;

    if (initPausePos) {
        pausePosition = 0;
    }

    updateLecteur('stop');
}

// Vérifie le statut de lecture
// -> si la lecture est en cours, on la stoppe et  on repositionne le status à faux
// -> puis on la repasse  en mode lecture
function initLecture() {
    if (isReading || isPaused) {
        if (lecteurAudioHTML5 && lecteurAudioHTML5.pause) {
            cdlStopIt(false);
        } else if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").stopIt) {
            thisMovie("lecteurCDL").stopIt();
        }
    }
    isReading = true;
    isStopped = false;
    window.clearTimeout(timer);
}

function cdlPlayIt() {
    updateLecteur('play');

    initLecture();
    timer = window.setTimeout("lectureMorceau(currentIndice, 'down', 'auto')", 0);
}

function cdlStopItDefinitely() {
    cdlStopIt(true);
    currentIndice = 0;
}

function getIndice() {
    return currentIndice;
}


//Permet de passer au morceau précédent
function backward() {
    initLecture();
    currentIndice -= 1;
    timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + (isInProtectedField && playMode !== "manual" ? "auto" : "manual") + "')", 0);
    return false;
}
function backward2() {
    initLecture();
    currentIndice -= 1;
    timer = window.setTimeout("lectureMorceau(currentIndice,'down','manual')", 0);
    return false;
}

// Permet de passer au morceau suivant
function forward() {
    initLecture();
    currentIndice += 1;
    timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + (isInProtectedField && playMode !== "manual" ? "auto" : "manual") + "')", 0);
    return false;
}
function forward2() {
    initLecture();
    currentIndice += 1;
    timer = window.setTimeout("lectureMorceau(currentIndice,'down','manual')", 0);
    return false;
}

function getPreviousBloc() {
    initLecture();
    if (currentFirstCadreElementIndice > 0) {
        currentFirstCadreElementIndice -= 1;
        currentIndice = firstCadreElementsIndexes[currentFirstCadreElementIndice];
        timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + playMode + "')", 0);
    }
    return false;
}

function getNextBloc() {
    initLecture();
    if (currentFirstCadreElementIndice + 1 < firstCadreElementsIndexes.length) {
        currentFirstCadreElementIndice += 1;
        currentIndice = firstCadreElementsIndexes[currentFirstCadreElementIndice];
        timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + playMode + "')", 0);
    }
    return false;
}

function lectureMorceau(index, paramPlayDirection, paramPlayMode) {
    var foundIndice, playModeTmp;

    if (!isStopped) {
        if (arguments.length > 1) {
            playDirection = paramPlayDirection;
            if (playMode === "manual" && paramPlayMode !== "manual" && !isPaused && !isInProtectedField) {
                playMode = paramPlayMode;
                lectureMorceau(index + 1, "down", "auto");
                return;
            }
            playMode = paramPlayMode;
        }
        isPaused = false;
        isInProtectedField = false;

        playModeTmp = playMode;

        // Récupère le contenu du nouveau morceau
        if (!isNaN(index) && (index >= pageParts.length || index < 0)) {
            // Passe une chaîne vide au lecteur
            content = "";

            stopLecture();

            // Scroll vers le haut de la page
            jQuery('div.cdlAllPageContainer').animate({scrollTop: 0}, 500);
        } else {
            if (isNaN(index)) {
                content = index;
                playModeTmp = 'manual';
            } else {
                content = pageParts[index].outer();
                jQuery("input", pageParts[index]).each(function () {
                    if (!jQuery(this).attr('type') || !jQuery(this).attr('type').match(new RegExp('^(submit|button|reset|hidden|image)$', "i"))) {
                        if (!jQuery(this).attr('type') || !jQuery(this).attr('type').match(new RegExp('^(text|password|file|color|date|datetime|datetime-local|email|month|number|range|search|tel|time|url|week)$', "i"))) {
                            content = content.replace(/value="([^"]*)"/, "");
                            if (jQuery(this).val()) {
                                content = content.replace(/<input/, "<input value=\"" + jQuery(this).val() + "\"");
                            }
                        }
                        content = jQuery('label[for="' + jQuery(this).attr('id') + '"]').outer() + content;
                        if (!jQuery(this).attr('type') || !jQuery(this).attr('type').match(new RegExp('^(radio|checkbox)$', "i"))) {
                            if (playMode !== "manual") {
                                isInProtectedField = true;
                            }
                            playModeTmp = 'manual';
                        }
                    }
                });
                jQuery("select, textarea", pageParts[index]).each(function () {
                    if (jQuery(this).is("textarea")) {
                        if (jQuery(this).val() !== "") {
                            content = content.replace(/<textarea ([^>]*)>(.*?)<\/textarea>/, "<" + "textarea $1>" + jQuery(this).val() + "</textarea>");
                        }
                    }
                    if (jQuery(this).is("select")) {
                        content = content.replace(/ selected/, "");
                        if (jQuery(this).val()) {
                            content = content.replace(" value=\"" + jQuery(this).val() + "\"", " value=\"" + jQuery(this).val() + "\" selected");
                        }
                    }
                    content = jQuery('label[for="' + jQuery(this).attr('id') + '"]').outer() + content;
                    if (playMode !== "manual") {
                        isInProtectedField = true;
                    }
                    playModeTmp = 'manual';
                });

                // Synchronise les indices actions scripts et js
                currentIndice = index;
                foundIndice = jQuery.inArray(currentIndice, focusablesIndexes);
                if (foundIndice > -1) {
                    currentFocusableIndice = foundIndice;
                }

                foundIndice = jQuery.inArray(pageFirstPartsRelated[currentIndice], firstCadreElementsIndexes);
                if (foundIndice > -1) {
                    currentFirstCadreElementIndice = foundIndice;
                }

                // Ne fait un highlight que si on est en cours de lecture
                window.setTimeout("highlighterMain(" + index + ")", duree);
            }
        }

        // On lance la lecture de ce nouveau morceau
        if (lecteurAudioHTML5 && lecteurAudioHTML5.play) {
            if (arguments.length > 1) {
                cdlLit(content, playDirection, playModeTmp);
            } else {
                cdlLit(content);
            }
        } else if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").lit) {
            if (arguments.length > 1) {
                thisMovie("lecteurCDL").lit(content, playDirection, playModeTmp);
            } else {
                thisMovie("lecteurCDL").lit(content);
            }
        }
    }
}

function thisMovie(movieName) {
    if (window[movieName]) {
        return window[movieName];
    }
    if (document[movieName]) {
        return document[movieName];
    }

    return null;
}
function parentMovie(movieName) {
    try {
        if (window.opener) {
            if (window.opener[movieName]) {
                return window.opener[movieName];
            }
            return window.opener.document[movieName];
        }
    } catch (err) {
        if (window.console) {
            window.console.log(err.message);
        }
    }

    return null;
}

function detectKeyDown(e) {
    var kc;

    e = e || window.event;

    kc = e.keyCode || e.which;

    if (!focusOnAField) {
        switch (kc) {
        // p
        case 80:
            if (!isReading) {
                if (lecteurAudioHTML5 && lecteurAudioHTML5.play) {
                    cdlPlayIt();
                } else if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").playIt) {
                    thisMovie("lecteurCDL").playIt();
                }
            } else {
                if (lecteurAudioHTML5 && lecteurAudioHTML5.pause) {
                    cdlPauseIt();
                } else if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").pauseIt) {
                    thisMovie("lecteurCDL").pauseIt();
                }
            }
            return;
        // s
        case 83:
            if (lecteurAudioHTML5 && lecteurAudioHTML5.pause) {
                cdlStopItDefinitely();
            } else if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").stopItDefinitely) {
                thisMovie("lecteurCDL").stopItDefinitely();
            }
            stopLecture();
            return;
        // autres
        default:
            break;
        }
    }

    if (!isStopped) {
        if (!focusOnAField) {
            switch (kc) {
            // left, up
            case 37:
            case 38:
                return backward2();
            // right, down
            case 39:
            case 40:
                return forward2();
            // page up
            case 33:
                return getPreviousBloc();
            // page down
            case 34:
                return getNextBloc();
            // autres
            default:
                break;
            }
        }
        switch (kc) {
        // maj
        case 16:
            shiftKeyPressed = true;
            break;
        // esc
        case 27:
            // Passe au morceau suivant
            initLecture();
            if (shiftKeyPressed) {
                currentIndice -= 1;
                timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + playMode + "')", 0);
            } else {
                currentIndice += 1;
                timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + playMode + "')", 0);
            }
            return;
        // autres
        default:
            return;
        }
    }
}

function detectKeyUp(e) {
    var kc;

    if (!isStopped) {
        e = e || window.event;

        kc = e.keyCode || e.which;

        switch (kc) {
        // maj
        case 16:
            shiftKeyPressed = false;
            break;
        // entrée
        case 13:
            if (focusedSelect && focusedSelect.size() > 0) {
                if (!isStopped) {
                    focusedSelect.blur();
                    initLecture();
                    currentIndice += 1;
                    timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + playMode + "')", 0);
                }
            }
            break;
        default:
            if (kc !== 9) {
                if (focusedSelect && focusedSelect.size() > 0 && (focusedSelectedIndex === null || focusedSelectedIndex !== focusedSelect.prop('selectedIndex'))) {
                    if (!isStopped) {
                        focusedSelectedIndex = focusedSelect.prop('selectedIndex');
                        initLecture();
                        timer = window.setTimeout("lectureMorceau('<select id=\"cdlGhostSelect\">'+jQuery('option',focusedSelect).eq(focusedSelectedIndex).outer()+'</select>',playDirection,playMode)", 0);
                    }
                }
            }
            return;
        }
    }
}

function detectKeyDownForFocusable(e) {
    var kc, char;

    if (!isStopped) {
        e = e || window.event;

        kc = e.keyCode || e.which;

        switch (kc) {
        // tab
        case 9:
            initLecture();
            if (shiftKeyPressed) {
                if (currentFocusableIndice > 0) {
                    currentFocusableIndice -= 1;
                    currentIndice = focusablesIndexes[currentFocusableIndice];
                    timer = window.setTimeout("lectureMorceau(currentIndice,'down','manual')", 0);
                }
            } else {
                if (currentFocusableIndice < focusablesIndexes.length - 1) {
                    currentFocusableIndice += 1;
                    currentIndice = focusablesIndexes[currentFocusableIndice];
                    timer = window.setTimeout("lectureMorceau(currentIndice,'down','manual')", 0);
                }
            }
            return;
        // maj
        case 16:
            shiftKeyPressed = true;
            return;
        // autres
        default:
            if (jQuery(this).is('input[type="text"], input[type="color"], input[type="date"], input[type="datetime"], input[type="datetime-local"], input[type="email"], input[type="month"], input[type="number"], input[type="range"], input[type="search"], input[type="tel"], input[type="time"], input[type="url"], input[type="week"], input[type="password"], textarea') && ((kc >= 48 && kc <= 90) || (kc >= 96 && kc <= 111) || (kc >= 186 && kc <= 222))) {
                char = String.fromCharCode(kc);
                if (char) {
                    timer = window.setTimeout("lectureMorceau('" + char.replace(/'/, "\\'") + "',playDirection,playMode)", duree);
                }
            }
            return;
        }
    }
}
function trim(myString) {
    return myString.replace(/^\s+/g, '').replace(/\s+$/g, '');
}

var isFirstElementInCadre;
var currentFocusableIndiceForInit = 0;
var isFirstField = true;
function highlightedElements(theElement) {
    theElement.children(":not(script,noscript)").each(function () {
        if (jQuery("div,p,h1,h2,h3,h4,h5,h6,ul,ol,li,dl,dt,dd,address,blockquote,ins,del,form,fieldset,legend,span.cdlInputText,span.cdlOtherInput,span.cdlButtons,table,caption,thead,tbody,th,td,span.cdlPartOfText,a,span.cdlSelectInput,textarea,br,hr,img,label,noscript", jQuery(this)).size() === 0 || jQuery(this).is("a") || jQuery(this).is("span.cdlButtons")) {
            var elementContent = trim(jQuery(this).text());
            if ((elementContent && elementContent.match(new RegExp("[^-\\!\"'\\(\\),\\.\/:;<>\\?\\[\\\\\\]\\^_`\\{\\|\\}~‘’¡¤¦§¨ª«¬­¯´¶·¸¹»¿• " + String.fromCharCode(160) + "\t\n]", "i"))) || jQuery(this).is('span.cdlInputText, span.cdlOtherInput, span.cdlButtons, span.cdlSelectInput, textarea') || (jQuery(this).is('img') && (jQuery(this).attr('alt') || jQuery(this).attr('title'))) || (jQuery(this).is("a") && jQuery('img', jQuery(this)).size() > 0)) {
                if (!jQuery(this).is('label')) {
                    if (isFirstElementInCadre) {
                        firstCadreElementsIndexes.push(i);
                        currentFocusableIndiceForInit = i;
                        isFirstElementInCadre = false;
                    }
                    if (jQuery(this).children('input[type!="hidden"],button').size() === 1 || jQuery(this).is('span.cdlSelectInput,textarea')) {
                        jQuery(this).wrap("<span class=\"cdlFormFieldsHighlighted\"></span>");
                        pageParts.push(jQuery(this).parent());
                        jQuery(this).parent().addClass('cdlToRead' + i);
                        pageFirstPartsRelated.push(currentFocusableIndiceForInit);
                        focusablesIndexes.push(i);
                        if (isFirstField) {
                            firstFieldIndex = i;
                            isFirstField = false;
                        }
                    } else {
                        pageParts.push(jQuery(this));
                        jQuery(this).addClass('cdlToRead' + i);
                        pageFirstPartsRelated.push(currentFocusableIndiceForInit);
                    }

                    if (jQuery(this).is('a')) {
                        focusablesIndexes.push(i);
                    }
                    i += 1;
                }
            }
        } else {
            highlightedElements(jQuery(this));
        }
    });
}

function ds_gettop(el) {
    var tmp = el.offsetTop;
    el = el.offsetParent;
    while (el) {
        tmp += el.offsetTop;
        el = el.offsetParent;
    }
    return tmp;
}
function highlighterMain(index) {
    if (!isStopped) {
        jQuery('.cdlInversedColor input[type="text"], .cdlInversedColor input[type="color"], .cdlInversedColor input[type="date"], .cdlInversedColor input[type="datetime"], .cdlInversedColor input[type="datetime-local"], .cdlInversedColor input[type="email"], .cdlInversedColor input[type="month"], .cdlInversedColor input[type="number"], .cdlInversedColor input[type="range"], .cdlInversedColor input[type="search"], .cdlInversedColor input[type="tel"], .cdlInversedColor input[type="time"], .cdlInversedColor input[type="url"], .cdlInversedColor input[type="week"], .cdlInversedColor input[type="password"], .cdlInversedColor textarea, .cdlInversedColor select').blur();
        jQuery('.cdlInversedColor').removeClass('cdlInversedColor');
        if (pageParts[index]) {
            myScrollTop = ds_gettop(pageParts[index].get(0));
            jQuery("input, select, textarea", pageParts[index]).each(function () {
                var cdlFieldLabel = jQuery('label[for="' + jQuery(this).attr('id') + '"]');
                if (jQuery(this).attr('type') && jQuery(this).attr('type').match(new RegExp('text|password|radio|checkbox|file|color|date|datetime|datetime-local|email|month|number|range|search|tel|time|url|week', "i")) && cdlFieldLabel.size() > 0) {
                    myScrollTop = Math.min(myScrollTop, ds_gettop(cdlFieldLabel.get(0)));
                }
            });

            jQuery('div.cdlAllPageContainer').animate({scrollTop: myScrollTop - 300 - jQuery('div.cdlUtilLinksContainer').get(0).offsetHeight - 7}, duree);

            pageParts[index].addClass('cdlInversedColor');
            pageParts[index].focus();

            jQuery("input", pageParts[index]).each(function () {
                if (jQuery(this).attr('type') && jQuery(this).attr('type').match(new RegExp('text|password|radio|checkbox|file|color|date|datetime|datetime-local|email|month|number|range|search|tel|time|url|week', "i"))) {
                    jQuery('label[for="' + jQuery(this).attr('id') + '"]').addClass('cdlInversedColor');
                }
                jQuery(this).focus();
            });
            jQuery("button", pageParts[index]).each(function () {
                jQuery(this).focus();
            });
            jQuery("select, textarea", pageParts[index]).each(function () {
                jQuery('label[for="' + jQuery(this).attr('id') + '"]').addClass('cdlInversedColor');
                jQuery(this).focus();
            });
        }

        if (index === pageParts.length) {
            jQuery('div.cdlAllPageContainer').animate({scrollTop: 0}, 500);
        }
    }
}

if (jQuery('div.cdlTopPage').size()) {
    jQuery('div.cdlTopPage div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery('div.cdlPageContent').size()) {
    jQuery('div.cdlPageContent div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery('div.cdlPageNavigation').size()) {
    jQuery('div.cdlPageNavigation div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery('div.cdlBottomPage').size()) {
    jQuery('div.cdlBottomPage div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery('div.cdlBackHome').size()) {
    jQuery('div.cdlBackHome div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery('div.documentContent').size()) {
    jQuery('div.documentContent div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery('div.protectedPageLoginContent').size()) {
    jQuery('div.protectedPageLoginContent div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery('div.exitContent').size()) {
    jQuery('div.exitContent div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery('div.errorContent').size()) {
    jQuery('div.errorContent div.cdlCadre').each(function () {
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
var pCdlCopyright = jQuery('p.cdlCopyright');
if (pCdlCopyright.size()) {
    pageParts.push(pCdlCopyright);
    pCdlCopyright.addClass('cdlToRead' + i);
    pageFirstPartsRelated.push(i);
    i += 1;
}

jQuery('input[type="text"], input[type="color"], input[type="date"], input[type="datetime"], input[type="datetime-local"], input[type="email"], input[type="month"], input[type="number"], input[type="range"], input[type="search"], input[type="tel"], input[type="time"], input[type="url"], input[type="week"], input[type="password"], textarea, select').on('focus', function () {
    focusOnAField = true;
    if (jQuery(this).is('select')) {
        focusedSelect = jQuery(this);
        focusedSelectedIndex = focusedSelect.prop('selectedIndex');
    }
}).on('blur', function () {
    focusOnAField = false;
    focusedSelect = null;
    focusedSelectedIndex = null;
});


jQuery('.cdlCadre a, button, input[type="submit"], input[type="button"]').on('click', function () {
    if (isReading) {
        if (lecteurAudioHTML5 && lecteurAudioHTML5.pause) {
            cdlPauseIt();
        } else if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").pauseIt) {
            thisMovie("lecteurCDL").pauseIt();
        }
    }
});


jQuery('html').on('keydown', detectKeyDown).on('keyup', detectKeyUp);

jQuery('input, select, textarea, button, a').on('keydown', detectKeyDownForFocusable);

jQuery('select').on('click', function () {
    if (!isStopped) {
        if (jQuery(this).is('.cdlInversedColor select')) {
            if (focusedSelect && focusedSelect.size() > 0 && (focusedSelectedIndex === null || focusedSelectedIndex !== focusedSelect.prop('selectedIndex'))) {
                focusedSelectedIndex = focusedSelect.prop('selectedIndex');
                initLecture();
                timer = window.setTimeout("lectureMorceau('<select id=\"cdlGhostSelect\">'+jQuery('option',focusedSelect).eq(focusedSelectedIndex).outer()+'</select>',playDirection,playMode)", duree);
            }
        }
    }
});

jQuery('object#lecteurCDL').on('mouseout', function () {
    if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").hideCursor) {
        thisMovie("lecteurCDL").hideCursor();
    }
});

lecteurAudioHTML5.addEventListener('play', function () {
    updateLecteur('play');
});

lecteurAudioHTML5.addEventListener('pause', function () {
    updateLecteur('pause');
});

lecteurAudioHTML5.addEventListener('ended', function () {
    if (playMode === "manual") {
        estPret();
        updateLecteur('stop');
    } else {
        timer = window.setTimeout("lectureMorceau(currentIndice" + (playDirection === "up" ? "-" : "+") + "1,playDirection,playMode)", 0);
    }
});

jQuery('.cdlAudioControls a').on('click', function () {
    var lienAudio = jQuery(this);

    if (!lienAudio.hasClass('cdlDisabled')) {
        if (lienAudio.hasClass('cdlAudioPause')) {
            cdlPauseIt();
        } else if (lienAudio.hasClass('cdlAudioPlay')) {
            cdlPlayIt();
        } else if (lienAudio.hasClass('cdlAudioStop')) {
            cdlStopIt(true);
        } else if (lienAudio.hasClass('cdlAudioPrevLine')) {
            backward();
            updateLecteur('play');
        } else if (lienAudio.hasClass('cdlAudioNextLine')) {
            forward();
            updateLecteur('play');
        } else if (lienAudio.hasClass('cdlAudioPrevBloc')) {
            getPreviousBloc();
            updateLecteur('play');
        } else if (lienAudio.hasClass('cdlAudioNextBloc')) {
            getNextBloc();
            updateLecteur('play');
        }
    }
    return false;
});

function initAnchorLinks() {
    if (jQuery.address) {
        jQuery.address.change(function (event) {
            if (event.value !== '/') {
                jQuery('[name="' + event.value + '"]:first, #' + event.value).each(function () {
                    var cdlToReadClassName, anchorRelated;
                    if (jQuery(this).is('[class*="cdlToRead"]')) {
                        cdlToReadClassName = jQuery(this).attr('class');
                    } else {
                        anchorRelated = jQuery('[class*="cdlToRead"]:first', jQuery(this));
                        if (anchorRelated.size() > 0) {
                            cdlToReadClassName = anchorRelated.attr('class');
                        } else {
                            anchorRelated = jQuery(this).nextAll('[class*="cdlToRead"]:first');
                            if (anchorRelated.size() > 0) {
                                cdlToReadClassName = anchorRelated.attr('class');
                            } else {
                                anchorRelated = jQuery('[class*="cdlToRead"]:first', jQuery(this).nextAll());
                                if (anchorRelated.size() > 0) {
                                    cdlToReadClassName = anchorRelated.attr('class');
                                } else {
                                    cdlToReadClassName = "cdlToRead0";
                                }
                            }
                        }
                    }
                    cdlToReadClassName = cdlToReadClassName.replace(/.*?cdlToRead(\d+).*?/, "$1");
                    initLecture();
                    currentIndice = cdlToReadClassName;
                    timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + playMode + "')", 0);
                });
            }
            return false;
        });
    }
}