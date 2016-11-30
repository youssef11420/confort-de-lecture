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
var playDirection = "";
var playMode = "";
var isInProtectedField = false;
var isPaused = false;
var isStopped = true;
var myScrollTop = 0;
var focusedSelect = null;
var focusedSelectedIndex = null;
var firstFieldIndex = null;
var lecteurAudioHTML5 = document.getElementById("lecteurAudioCDL");
var lecteurAudioParentHTML5 = (window.opener && window.opener.document)
    ? window.opener.document.getElementById("lecteurAudioCDL")
    : null;
var cdlAudioPrev = jQuery(".cdlAudioPrevBloc,.cdlAudioPrevLine");
var cdlAudioPlayPause = jQuery(".cdlAudioPlayPause");
var cdlAudioStop = jQuery(".cdlAudioStop");
var cdlAudioNext = jQuery(".cdlAudioNextBloc,.cdlAudioNextLine");
var pausePosition = 0;

jQuery.fn.outer = function () {
    "use strict";
    return jQuery(jQuery("<div></div>").html(this.clone())).html();
};

// Positionne le flag de lecture à faux mais le flag de pause à vrai
function estPretEnPause() {
    "use strict";
    isReading = false;
    isPaused = true;
}
// Positionne le flag de lecture à faux
function estPret() {
    "use strict";
    isReading = false;
}

// A appeler à l'arrêt de la lecture
function stopLecture() {
    "use strict";
    jQuery(".cdlInversedColor input[type=\"text\"], .cdlInversedColor input[type=\"color\"], .cdlInversedColor input[type=\"date\"], .cdlInversedColor input[type=\"datetime\"], .cdlInversedColor input[type=\"datetime-local\"], .cdlInversedColor input[type=\"email\"], .cdlInversedColor input[type=\"month\"], .cdlInversedColor input[type=\"number\"], .cdlInversedColor input[type=\"range\"], .cdlInversedColor input[type=\"search\"], .cdlInversedColor input[type=\"tel\"], .cdlInversedColor input[type=\"time\"], .cdlInversedColor input[type=\"url\"], .cdlInversedColor input[type=\"week\"], .cdlInversedColor input[type=\"password\"], .cdlInversedColor textarea, .cdlInversedColor select").blur();
    jQuery(".cdlInversedColor").removeClass("cdlInversedColor");

    jQuery("body").animate({scrollTop: 0}, 500);

    // Réinitialise l'indice
    currentIndice = 0;
    isReading = false;
    isPaused = false;
    isStopped = true;
}

function updateLecteur(mode) {
    "use strict";
    switch (mode) {
    case "play":
        cdlAudioPlayPause.removeClass("cdlAudioPlay").addClass("cdlAudioPause");
        if (currentIndice > 0) {
            cdlAudioPrev.removeClass("cdlDisabled");
        } else {
            cdlAudioPrev.addClass("cdlDisabled");
        }
        if (currentIndice < pageParts.length - 1) {
            cdlAudioNext.removeClass("cdlDisabled");
        } else {
            cdlAudioNext.addClass("cdlDisabled");
        }
        cdlAudioStop.removeClass("cdlDisabled");
        break;
    case "pause":
        cdlAudioPlayPause.removeClass("cdlAudioPause").addClass("cdlAudioPlay");
        cdlAudioStop.removeClass("cdlDisabled");
        break;
    case "stop":
        cdlAudioPlayPause.removeClass("cdlAudioPause").addClass("cdlAudioPlay");
        if (currentIndice > 0) {
            cdlAudioPrev.removeClass("cdlDisabled");
        } else {
            cdlAudioPrev.addClass("cdlDisabled");
        }
        if (currentIndice < pageParts.length - 1) {
            cdlAudioNext.removeClass("cdlDisabled");
        } else {
            cdlAudioNext.addClass("cdlDisabled");
        }
        cdlAudioStop.addClass("cdlDisabled");
        break;
    default:
        cdlAudioPlayPause.removeClass("cdlAudioPause").addClass("cdlAudioPlay");
        cdlAudioPrev.addClass("cdlDisabled");
        cdlAudioStop.addClass("cdlDisabled");
    }
}

function cdlLit(text, playDirectionParam, playModeParam) {
    "use strict";
    playDirection = playDirectionParam;
    playMode = playModeParam;

    if (text) {
        updateLecteur("play");

        lecteurAudioHTML5.src = (window.cdlEmbeddedURL || "") + "/audio-text/" + window.cdlSiteId + "/?cdltext=" + encodeURIComponent(text) + (
            window.cdlVoice
                ? "&cdlvoice=" + encodeURIComponent(window.cdlVoice)
                : ""
        ) + (
            window.cdlSpeed
                ? "&cdlspeed=" + encodeURIComponent(window.cdlSpeed)
                : ""
        );
        lecteurAudioHTML5.currentTime = pausePosition;
        lecteurAudioHTML5.play();
        pausePosition = 0;
    } else {
        updateLecteur("stop");
    }
}

function cdlPauseIt() {
    "use strict";
    pausePosition = lecteurAudioHTML5.currentTime;

    lecteurAudioHTML5.pause();

    estPretEnPause();
    updateLecteur("pause");
}

function cdlStopIt(initPausePos) {
    "use strict";
    lecteurAudioHTML5.pause();
    lecteurAudioHTML5.currentTime = 0;

    if (initPausePos) {
        pausePosition = 0;
    }

    updateLecteur("stop");
}

// Vérifie le statut de lecture
// -> si la lecture est en cours, on la stoppe et  on repositionne le status à faux
// -> puis on la repasse  en mode lecture
function initLecture() {
    "use strict";
    if (isReading || isPaused) {
        if (lecteurAudioHTML5 && lecteurAudioHTML5.pause) {
            cdlStopIt(false);
        } else if (window.thisMovie("lecteurCDL") && window.thisMovie("lecteurCDL").stopIt) {
            window.thisMovie("lecteurCDL").stopIt();
        }
    }
    isReading = true;
    isStopped = false;
    window.clearTimeout(timer);
}

function cdlPlayIt() {
    "use strict";
    updateLecteur("play");

    initLecture();
    timer = window.setTimeout(function () {
        window.lectureMorceau(currentIndice, "down", "auto");
    }, 0);
}

function cdlStopItDefinitely() {
    "use strict";
    cdlStopIt(true);
    currentIndice = 0;
}

//Permet de passer au morceau précédent
function backward() {
    "use strict";
    initLecture();
    currentIndice -= 1;
    timer = window.setTimeout(function () {
        window.lectureMorceau(currentIndice, "down", (isInProtectedField && playMode !== "manual")
            ? "auto"
            : "manual");
    }, 0);
    return false;
}
function backward2() {
    "use strict";
    initLecture();
    currentIndice -= 1;
    timer = window.setTimeout(function () {
        window.lectureMorceau(currentIndice, "down", "manual");
    }, 0);
    return false;
}

// Permet de passer au morceau suivant
function forward() {
    "use strict";
    initLecture();
    currentIndice += 1;
    timer = window.setTimeout(function () {
        window.lectureMorceau(currentIndice, "down", (isInProtectedField && playMode !== "manual")
            ? "auto"
            : "manual");
    }, 0);
    return false;
}
function forward2() {
    "use strict";
    initLecture();
    currentIndice += 1;
    timer = window.setTimeout("lectureMorceau(currentIndice,'down','manual')", 0);
    return false;
}

function getPreviousBloc() {
    "use strict";
    initLecture();
    if (currentFirstCadreElementIndice > 0) {
        currentFirstCadreElementIndice -= 1;
        currentIndice = firstCadreElementsIndexes[currentFirstCadreElementIndice];
        timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + playMode + "')", 0);
    }
    return false;
}

function getNextBloc() {
    "use strict";
    initLecture();
    if (currentFirstCadreElementIndice + 1 < firstCadreElementsIndexes.length) {
        currentFirstCadreElementIndice += 1;
        currentIndice = firstCadreElementsIndexes[currentFirstCadreElementIndice];
        timer = window.setTimeout("lectureMorceau(currentIndice,'down','" + playMode + "')", 0);
    }
    return false;
}

function lectureMorceau(index, paramPlayDirection, paramPlayMode) {
    "use strict";
    var foundIndice;
    var playModeTmp;

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
            jQuery("body").animate({scrollTop: 0}, 500);
        } else {
            if (isNaN(index)) {
                content = index;
                playModeTmp = "manual";
            } else {
                content = pageParts[index].outer();
                jQuery("input", pageParts[index]).each(function () {
                    if (!jQuery(this).attr("type") || !jQuery(this).attr("type").match(new RegExp("^(submit|button|reset|hidden|image)$", "i"))) {
                        if (!jQuery(this).attr("type") || !jQuery(this).attr("type").match(new RegExp("^(text|password|file|color|date|datetime|datetime-local|email|month|number|range|search|tel|time|url|week)$", "i"))) {
                            content = content.replace(/value="([^"]*)"/, "");
                            if (jQuery(this).val()) {
                                content = content.replace(/<input/, "<input value=\"" + jQuery(this).val() + "\"");
                            }
                        }
                        content = jQuery("label[for=\"" + jQuery(this).attr("id") + "\"]").outer() + content;
                        if (!jQuery(this).attr("type") || !jQuery(this).attr("type").match(new RegExp("^(radio|checkbox)$", "i"))) {
                            if (playMode !== "manual") {
                                isInProtectedField = true;
                            }
                            playModeTmp = "manual";
                        }
                    }
                });
                jQuery("select, textarea", pageParts[index]).each(function () {
                    if (jQuery(this).is("textarea")) {
                        if (jQuery(this).val() !== "") {
                            content = content.replace(/<textarea\s([^>]*)>(.*?)<\/textarea>/, "<" + "textarea $1>" + jQuery(this).val() + "</textarea>");
                        }
                    }
                    if (jQuery(this).is("select")) {
                        content = content.replace(/\sselected/, "");
                        if (jQuery(this).val()) {
                            content = content.replace(" value=\"" + jQuery(this).val() + "\"", " value=\"" + jQuery(this).val() + "\" selected");
                        }
                    }
                    content = jQuery("label[for=\"" + jQuery(this).attr("id") + "\"]").outer() + content;
                    if (playMode !== "manual") {
                        isInProtectedField = true;
                    }
                    playModeTmp = "manual";
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
                window.setTimeout(function () {
                    window.highlighterMain(index);
                }, duree);
            }
        }

        // On lance la lecture de ce nouveau morceau
        if (lecteurAudioHTML5 && lecteurAudioHTML5.play) {
            if (arguments.length > 1) {
                cdlLit(content, playDirection, playModeTmp);
            } else {
                cdlLit(content);
            }
        } else if (window.thisMovie("lecteurCDL") && window.thisMovie("lecteurCDL").lit) {
            if (arguments.length > 1) {
                window.thisMovie("lecteurCDL").lit(content, playDirection, playModeTmp);
            } else {
                window.thisMovie("lecteurCDL").lit(content);
            }
        }
    }
}

function thisMovie(movieName) {
    "use strict";
    if (window[movieName]) {
        return window[movieName];
    }
    if (document[movieName]) {
        return document[movieName];
    }

    return null;
}
function parentMovie(movieName) {
    "use strict";
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
    "use strict";
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
                timer = window.setTimeout(function () {
                    lectureMorceau(currentIndice, "down", "auto");
                }, 0);
            } else {
                currentIndice += 1;
                timer = window.setTimeout(function () {
                    lectureMorceau(currentIndice, "down", "auto");
                }, 0);
            }
            return;
        // autres
        default:
            return;
        }
    }
}

function detectKeyUp(e) {
    "use strict";
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
                    timer = window.setTimeout(function () {
                        lectureMorceau(currentIndice, "down", playMode);
                    }, 0);
                }
            }
            break;
        default:
            if (kc !== 9) {
                if (focusedSelect && focusedSelect.size() > 0 && (focusedSelectedIndex === null || focusedSelectedIndex !== focusedSelect.prop("selectedIndex"))) {
                    if (!isStopped) {
                        focusedSelectedIndex = focusedSelect.prop("selectedIndex");
                        initLecture();
                        timer = window.setTimeout(function () {
                            lectureMorceau("<select id=\"cdlGhostSelect\">" + jQuery("option", focusedSelect).eq(focusedSelectedIndex).outer() + "</select>", playDirection, playMode);
                        }, 0);
                    }
                }
            }
            return;
        }
    }
}

function detectKeyDownForFocusable(e) {
    "use strict";
    var kc;
    var char;
    var lecteurChar;
    var majuscule;
    var lecteurCharMaj;

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
                    timer = window.setTimeout(function () {
                        lectureMorceau(currentIndice, "down", "manual");
                    }, 0);
                }
            } else {
                if (currentFocusableIndice < focusablesIndexes.length - 1) {
                    currentFocusableIndice += 1;
                    currentIndice = focusablesIndexes[currentFocusableIndice];
                    timer = window.setTimeout(function () {
                        lectureMorceau(currentIndice, "down", "manual");
                    }, 0);
                }
            }
            return;
        // maj
        case 16:
            shiftKeyPressed = true;
            return;
        // ctrl
        case 17:
            return;
        // alt
        case 18:
            return;
        // windows
        case 91:
            return;
        // windows
        case 92:
            return;
        // select/menu key
        case 93:
            return;
        // enter
        case 13:
            return;
        // autres
        default:
            if (jQuery(this).is("input[type=\"text\"], input[type=\"color\"], input[type=\"date\"], input[type=\"datetime\"], input[type=\"datetime-local\"], input[type=\"email\"], input[type=\"month\"], input[type=\"number\"], input[type=\"range\"], input[type=\"search\"], input[type=\"tel\"], input[type=\"time\"], input[type=\"url\"], input[type=\"week\"], input[type=\"password\"], textarea")) {
                if (kc >= 65 && kc <= 90) {
                    if (e.altKey && e.ctrlKey && !e.shiftKey && kc === 69) {
                        char = "euro";
                    } else if (!e.altKey && !e.ctrlKey) {
                        char = String.fromCharCode(kc);
                        majuscule = e.shiftKey;
                    }
                }
                if (kc >= 96 && kc <= 105 && !e.altKey && !e.ctrlKey && !e.shiftKey) {
                    char = kc - 96;
                    char = char.toString();
                }
                if (kc >= 48 && kc <= 57) {
                    if (!e.altKey && !e.ctrlKey && e.shiftKey) {
                        char = kc - 48;
                        char = char.toString();
                    } else if (e.altKey && e.ctrlKey && !e.shiftKey) {
                        switch (kc) {
                        case 48:
                            char = "arobase";
                            break;
                        case 50:
                            char = "tilde";
                            break;
                        case 51:
                            char = "diese";
                            break;
                        case 52:
                            char = "acollade_ouvrante";
                            break;
                        case 53:
                            char = "crochet_ouvrant";
                            break;
                        case 54:
                            char = "barre_verticale";
                            break;
                        case 55:
                            char = "accent_grave";
                            break;
                        case 56:
                            char = "anti_slash";
                            break;
                        case 57:
                            char = "accent_circonflexe";
                            break;
                        }
                    } else if (!e.altKey && !e.ctrlKey && !e.shiftKey) {
                        switch (kc) {
                        case 48:
                            char = "a_accent_grave";
                            break;
                        case 49:
                            char = "et_commercial";
                            break;
                        case 50:
                            char = "e_accent_aigu";
                            break;
                        case 51:
                            char = "guillemet";
                            break;
                        case 52:
                            char = "apostrophe";
                            break;
                        case 53:
                            char = "parenthese_ouvrante";
                            break;
                        case 54:
                            char = "tiret";
                            break;
                        case 55:
                            char = "e_accent_grave";
                            break;
                        case 56:
                            char = "souligne";
                            break;
                        case 57:
                            char = "c_cedille";
                            break;
                        }
                    }
                }
                switch (kc) {
                case 222:
                    if (!e.altKey && !e.ctrlKey && !e.shiftKey) {
                        char = "exposant_2";
                    }
                    break;
                case 219:
                    if (!e.altKey && !e.ctrlKey && e.shiftKey) {
                        char = "degre";
                    } else if (e.altKey && e.ctrlKey && !e.shiftKey) {
                        char = "crochet_fermant";
                    } else if (!e.altKey && !e.ctrlKey && !e.shiftKey) {
                        char = "parenthese_fermante";
                    }
                    break;
                case 187:
                    if (!e.altKey && !e.ctrlKey && e.shiftKey) {
                        char = "pluss";
                    } else if (e.altKey && e.ctrlKey && !e.shiftKey) {
                        char = "acollade_fermante";
                    } else if (!e.altKey && !e.ctrlKey && !e.shiftKey) {
                        char = "egal";
                    }
                    break;
                case 186:
                    if (!e.altKey && !e.ctrlKey && e.shiftKey) {
                        char = "livre_sterling";
                    } else if (e.altKey && e.ctrlKey && !e.shiftKey) {
                        char = "symbole_monetaire";
                    } else if (!e.altKey && !e.ctrlKey && !e.shiftKey) {
                        char = "dollar";
                    }
                    break;
                case 8:
                    char = "retour";
                    break;
                case 46:
                    if (!e.shiftKey) {
                        char = "supprimer";
                    }
                    break;
                }
                if (!e.altKey && !e.ctrlKey) {
                    switch (kc) {
                    case 221:
                        char = e.shiftKey
                            ? "trema"
                            : "accent_circonflexe";
                        break;
                    case 192:
                        char = e.shiftKey
                            ? "pourcent"
                            : "u_accent_grave";
                        break;
                    case 220:
                        char = e.shiftKey
                            ? "mu"
                            : "etoile";
                        break;
                    case 223:
                        char = e.shiftKey
                            ? "signe_section"
                            : "point_dexclamation";
                        break;
                    case 191:
                        char = e.shiftKey
                            ? "slash"
                            : "deux_points";
                        break;
                    case 190:
                        char = e.shiftKey
                            ? "point"
                            : "point_virgule";
                        break;
                    case 188:
                        char = e.shiftKey
                            ? "point_dinterrogation"
                            : "virgule";
                        break;
                    case 226:
                        char = e.shiftKey
                            ? "chevron_fermant"
                            : "chevron_ouvrant";
                        break;
                    case 32:
                        char = "espace";
                        break;
                    case 106:
                        char = "multiplie_par";
                        break;
                    case 107:
                        char = "pluss";
                        break;
                    case 109:
                        char = "moins";
                        break;
                    case 111:
                        char = "divise_par";
                        break;
                    case 110:
                        char = "point";
                        break;
                    }
                }
                if (char) {
                    lecteurChar = document.getElementById("lecteurAudioCDL_" + char.toLowerCase());
                    if (lecteurChar) {
                        lecteurChar.pause();
                        lecteurChar.currentTime = 0;
                        lecteurCharMaj = document.getElementById("lecteurAudioCDL_majuscule");
                        if (lecteurCharMaj) {
                            lecteurCharMaj.pause();
                            lecteurCharMaj.currentTime = 0;
                        }
                        if (majuscule) {
                            jQuery(lecteurCharMaj).bind("ended", function () {
                                lecteurChar.play();
                            });
                            lecteurCharMaj.play();
                        } else {
                            lecteurChar.play();
                        }
                    }
                }
            }
            return;
        }
    }
}
function trim(myString) {
    "use strict";
    return myString.replace(/^\s+/g, "").replace(/\s+$/g, "");
}

var isFirstElementInCadre;
var currentFocusableIndiceForInit = 0;
var isFirstField = true;
function highlightedElements(theElement) {
    "use strict";
    theElement.children(":not(script,noscript)").each(function () {
        if (jQuery("div,p,h1,h2,h3,h4,h5,h6,ul,ol,li,dl,dt,dd,address,blockquote,ins,del,form,fieldset,legend,span.cdlInputText,span.cdlOtherInput,span.cdlButtons,span.cdlButtonExit,table,caption,thead,tbody,th,td,span.cdlPartOfText,a,strong.cdlSelectInput,textarea,br,hr,img,label,noscript", jQuery(this)).size() === 0 || jQuery(this).is("a") || jQuery(this).is("span.cdlButtons,span.cdlButtonExit")) {
            var elementContent = trim(jQuery(this).text());
            if ((elementContent && elementContent.match(new RegExp("[^-\\!\"'\\(\\),\\.\/:;<>\\?\\[\\\\\\]\\^_`\\{\\|\\}~‘’¡¤¦§¨ª«¬¯´¶·¸¹»¿• " + String.fromCharCode(160) + "\t\n]", "i"))) || jQuery(this).is("span.cdlInputText,span.cdlOtherInput,span.cdlButtons,span.cdlButtonExit,strong.cdlSelectInput,textarea") || (jQuery(this).is("img") && (jQuery(this).attr("alt") || jQuery(this).attr("title"))) || (jQuery(this).is("a") && jQuery("img", jQuery(this)).size() > 0)) {
                if (!jQuery(this).is("label")) {
                    if (isFirstElementInCadre) {
                        firstCadreElementsIndexes.push(i);
                        currentFocusableIndiceForInit = i;
                        isFirstElementInCadre = false;
                    }
                    if (jQuery(this).children("input[type!=\"hidden\"],button").size() === 1 || jQuery(this).is("strong.cdlSelectInput,textarea")) {
                        jQuery(this).wrap("<span class=\"cdlFormFieldsHighlighted\"></span>");
                        pageParts.push(jQuery(this).parent());
                        jQuery(this).parent().addClass("cdlToRead" + i);
                        pageFirstPartsRelated.push(currentFocusableIndiceForInit);
                        focusablesIndexes.push(i);
                        if (isFirstField) {
                            firstFieldIndex = i;
                            isFirstField = false;
                        }
                    } else {
                        pageParts.push(jQuery(this));
                        jQuery(this).addClass("cdlToRead" + i);
                        pageFirstPartsRelated.push(currentFocusableIndiceForInit);
                    }

                    if (jQuery(this).is("a")) {
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
    "use strict";
    var tmp = el.offsetTop;
    el = el.offsetParent;
    while (el) {
        tmp += el.offsetTop;
        el = el.offsetParent;
    }
    return tmp;
}
function highlighterMain(index) {
    "use strict";
    if (!isStopped) {
        jQuery(".cdlInversedColor input[type=\"text\"], .cdlInversedColor input[type=\"color\"], .cdlInversedColor input[type=\"date\"], .cdlInversedColor input[type=\"datetime\"], .cdlInversedColor input[type=\"datetime-local\"], .cdlInversedColor input[type=\"email\"], .cdlInversedColor input[type=\"month\"], .cdlInversedColor input[type=\"number\"], .cdlInversedColor input[type=\"range\"], .cdlInversedColor input[type=\"search\"], .cdlInversedColor input[type=\"tel\"], .cdlInversedColor input[type=\"time\"], .cdlInversedColor input[type=\"url\"], .cdlInversedColor input[type=\"week\"], .cdlInversedColor input[type=\"password\"], .cdlInversedColor textarea, .cdlInversedColor select").blur();
        jQuery(".cdlInversedColor").removeClass("cdlInversedColor");
        if (pageParts[index]) {
            myScrollTop = ds_gettop(pageParts[index].get(0));
            jQuery("input, select, textarea", pageParts[index]).each(function () {
                var cdlFieldLabel = jQuery("label[for=\"" + jQuery(this).attr("id") + "\"]");
                if (jQuery(this).attr("type") && jQuery(this).attr("type").match(new RegExp("text|password|radio|checkbox|file|color|date|datetime|datetime-local|email|month|number|range|search|tel|time|url|week", "i")) && cdlFieldLabel.size() > 0) {
                    myScrollTop = Math.min(myScrollTop, ds_gettop(cdlFieldLabel.get(0)));
                }
            });

            jQuery("body").animate({scrollTop: myScrollTop - 300 - jQuery("div.cdlUtilLinksContainer").get(0).offsetHeight - 7}, duree);

            pageParts[index].addClass("cdlInversedColor");
            pageParts[index].focus();

            jQuery("input", pageParts[index]).each(function () {
                if (jQuery(this).attr("type") && jQuery(this).attr("type").match(new RegExp("text|password|radio|checkbox|file|color|date|datetime|datetime-local|email|month|number|range|search|tel|time|url|week", "i"))) {
                    jQuery("label[for=\"" + jQuery(this).attr("id") + "\"]").addClass("cdlInversedColor");
                }
                jQuery(this).focus();
            });
            jQuery("button", pageParts[index]).each(function () {
                jQuery(this).focus();
            });
            jQuery("select, textarea", pageParts[index]).each(function () {
                jQuery("label[for=\"" + jQuery(this).attr("id") + "\"]").addClass("cdlInversedColor");
                jQuery(this).focus();
            });
        }

        if (index === pageParts.length) {
            jQuery("body").animate({scrollTop: 0}, 500);
        }
    }
}

if (jQuery("div.cdlTopPage").size()) {
    jQuery("div.cdlTopPage div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery("div.cdlPageContent").size()) {
    jQuery("div.cdlPageContent div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery("div.cdlPageNavigation").size()) {
    jQuery("div.cdlPageNavigation div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery("div.cdlBottomPage").size()) {
    jQuery("div.cdlBottomPage div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery("div.cdlBackHome").size()) {
    jQuery("div.cdlBackHome div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery("div.documentContent").size()) {
    jQuery("div.documentContent div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery("div.protectedPageLoginContent").size()) {
    jQuery("div.protectedPageLoginContent div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery("div.exitContent").size()) {
    jQuery("div.exitContent div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
if (jQuery("div.errorContent").size()) {
    jQuery("div.errorContent div.cdlCadre").each(function () {
        "use strict";
        isFirstElementInCadre = true;
        highlightedElements(jQuery(this));
    });
}
var pCdlCopyright = jQuery("p.cdlCopyright");
if (pCdlCopyright.size()) {
    pageParts.push(pCdlCopyright);
    pCdlCopyright.addClass("cdlToRead" + i);
    pageFirstPartsRelated.push(i);
    i += 1;
}

var textFields = jQuery("input[type=\"text\"], input[type=\"color\"], input[type=\"date\"], input[type=\"datetime\"], input[type=\"datetime-local\"], input[type=\"email\"], input[type=\"month\"], input[type=\"number\"], input[type=\"range\"], input[type=\"search\"], input[type=\"tel\"], input[type=\"time\"], input[type=\"url\"], input[type=\"week\"], input[type=\"password\"], textarea, select");
textFields.on("paste", function () {
    "use strict";
    var element = this;
    window.setTimeout(function () {
        var value = "Contenu du champ après coller : " + jQuery(element).val();
        var lecteurAudioCDLPaste = document.getElementById("lecteurAudioCDL_paste");
        if (!lecteurAudioCDLPaste) {
            jQuery(".lecteursAudioCDL").append("<audio autoplay src=\"" + (window.cdlEmbeddedURL || "") + "/audio-text-letter/" + window.cdlSiteId + "/?cdltext=" + encodeURIComponent(value) + (
                window.cdlVoice
                    ? "&cdlvoice=" + encodeURIComponent(window.cdlVoice)
                    : ""
            ) + (
                window.cdlSpeed
                    ? "&cdlspeed=" + encodeURIComponent(window.cdlSpeed)
                    : ""
            ) + "\" class=\"cdlHidden\" id=\"lecteurAudioCDL_paste\"></audio>");
        } else {
            jQuery(lecteurAudioCDLPaste).attr("src", (window.cdlEmbeddedURL || "") + "/audio-text-letter/" + window.cdlSiteId + "/?cdltext=" + encodeURIComponent(value) + (
                window.cdlVoice
                    ? "&cdlvoice=" + encodeURIComponent(window.cdlVoice)
                    : ""
            ) + (
                window.cdlSpeed
                    ? "&cdlspeed=" + encodeURIComponent(window.cdlSpeed)
                    : ""
            ));
            lecteurAudioCDLPaste.pause();
            lecteurAudioCDLPaste.currentTime = 0;
            lecteurAudioCDLPaste.play();
        }
    }, 100);
}).on("focus", function () {
    "use strict";
    focusOnAField = true;
    if (jQuery(this).is("select")) {
        focusedSelect = jQuery(this);
        focusedSelectedIndex = focusedSelect.prop("selectedIndex");
    }
}).on("blur", function () {
    "use strict";
    focusOnAField = false;
    focusedSelect = null;
    focusedSelectedIndex = null;
});


jQuery(".cdlCadre a, button, input[type=\"submit\"], input[type=\"button\"], input[type=\"reset\"]").on("click", function () {
    "use strict";
    if (isReading) {
        if (lecteurAudioHTML5 && lecteurAudioHTML5.pause) {
            cdlPauseIt();
        } else if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").pauseIt) {
            thisMovie("lecteurCDL").pauseIt();
        }
    }
});

if (textFields.size() > 0) {
    var cdlLecteursAudioCDL = jQuery(".lecteursAudioCDL");
    if (cdlLecteursAudioCDL.size() > 0 && cdlLecteursAudioCDL.data("loadplayers")) {
        jQuery.get(cdlLecteursAudioCDL.data("loadplayers"), function (data) {
            "use strict";
            cdlLecteursAudioCDL.html(data);
        });
    }
}


jQuery("html").on("keydown", detectKeyDown).on("keyup", detectKeyUp);

jQuery("input, select, textarea, button, a").on("keydown", detectKeyDownForFocusable);

jQuery("select").on("click", function () {
    "use strict";
    if (!isStopped) {
        if (jQuery(this).is(".cdlInversedColor select")) {
            if (focusedSelect && focusedSelect.size() > 0 && (focusedSelectedIndex === null || focusedSelectedIndex !== focusedSelect.prop("selectedIndex"))) {
                focusedSelectedIndex = focusedSelect.prop("selectedIndex");
                initLecture();
                timer = window.setTimeout(function () {
                    lectureMorceau("<select id=\"cdlGhostSelect\">" + jQuery("option", focusedSelect).eq(focusedSelectedIndex).outer() + "</select>", playDirection, playMode);
                }, duree);
            }
        }
    }
});

jQuery("object#lecteurCDL").on("mouseout", function () {
    "use strict";
    if (thisMovie("lecteurCDL") && thisMovie("lecteurCDL").hideCursor) {
        thisMovie("lecteurCDL").hideCursor();
    }
});

lecteurAudioHTML5.addEventListener("play", function () {
    "use strict";
    updateLecteur("play");
});

lecteurAudioHTML5.addEventListener("pause", function () {
    "use strict";
    updateLecteur("pause");
});

lecteurAudioHTML5.addEventListener("ended", function () {
    "use strict";
    if (playMode === "manual") {
        estPret();
        updateLecteur("stop");
    } else {
        timer = window.setTimeout(function () {
            var upOrDown = (playDirection === "up")
                ? -1
                : 1;
            lectureMorceau(currentIndice + upOrDown, playDirection, playMode);
        }, 0);
    }
});

jQuery(".cdlAudioControls a").on("click", function () {
    "use strict";
    var lienAudio = jQuery(this);

    if (!lienAudio.hasClass("cdlDisabled")) {
        if (lienAudio.hasClass("cdlAudioPause")) {
            cdlPauseIt();
        } else if (lienAudio.hasClass("cdlAudioPlay")) {
            cdlPlayIt();
        } else if (lienAudio.hasClass("cdlAudioStop")) {
            cdlStopIt(true);
        } else if (lienAudio.hasClass("cdlAudioPrevLine")) {
            backward();
            updateLecteur("play");
        } else if (lienAudio.hasClass("cdlAudioNextLine")) {
            forward();
            updateLecteur("play");
        } else if (lienAudio.hasClass("cdlAudioPrevBloc")) {
            getPreviousBloc();
            updateLecteur("play");
        } else if (lienAudio.hasClass("cdlAudioNextBloc")) {
            getNextBloc();
            updateLecteur("play");
        }
    }
    return false;
});

function initAnchorLinks() {
    "use strict";
    if (jQuery.address) {
        jQuery.address.change(function (event) {
            if (event.value !== "/") {
                jQuery("[name=\"" + event.value + "\"]:first, #" + event.value).each(function () {
                    var cdlToReadClassName;
                    var anchorRelated;
                    if (jQuery(this).is("[class*=\"cdlToRead\"]")) {
                        cdlToReadClassName = jQuery(this).attr("class");
                    } else {
                        anchorRelated = jQuery("[class*=\"cdlToRead\"]:first", jQuery(this));
                        if (anchorRelated.size() > 0) {
                            cdlToReadClassName = anchorRelated.attr("class");
                        } else {
                            anchorRelated = jQuery(this).nextAll("[class*=\"cdlToRead\"]:first");
                            if (anchorRelated.size() > 0) {
                                cdlToReadClassName = anchorRelated.attr("class");
                            } else {
                                anchorRelated = jQuery("[class*=\"cdlToRead\"]:first", jQuery(this).nextAll());
                                if (anchorRelated.size() > 0) {
                                    cdlToReadClassName = anchorRelated.attr("class");
                                } else {
                                    cdlToReadClassName = "cdlToRead0";
                                }
                            }
                        }
                    }
                    cdlToReadClassName = cdlToReadClassName.replace(/.*?cdlToRead(\d+).*?/, "$1");
                    initLecture();
                    currentIndice = cdlToReadClassName;
                    timer = window.setTimeout(function () {
                        lectureMorceau(currentIndice, "down", playMode);
                    }, 0);
                });
            }
            return false;
        });
    }
}