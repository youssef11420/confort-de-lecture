var pageParts = new Array();
var pageFirstPartsRelated = new Array();
var focusablesIndexes = new Array();
var firstCadreElementsIndexes = new Array();
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

jQuery.fn.outer = function() {
	return jQuery(jQuery('<div></div>').html(this.clone())).html();
}

function getStatut() {
	return isStopped;
}

function debug(texte,valeur) {
	console.log(texte + " : " + valeur);
}

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
	jQuery('.cdlInversedColor input[type="text"], .cdlInversedColor input[type="password"], .cdlInversedColor textarea, .cdlInversedColor select').blur();
	jQuery('.cdlInversedColor').removeClass('cdlInversedColor');

	jQuery('div.cdlAllPageContainer').animate({scrollTop: 0}, 500);

	// Réinitialise l'indice
	currentIndice = 0;
	isReading = false;
	isPaused = false;
	isStopped = true;
}

// Vérifie le statut de lecture
// -> si la lecture est en cours, on la stoppe et  on repositionne le status à faux
// -> puis on la repasse  en mode lecture
function initLecture() {
	if (isReading || isPaused) {
		thisMovie("lecteurCDL").stopIt();
	}
	isReading = true;
	isStopped = false;
	clearTimeout(timer);
}

function getIndice() {
	return currentIndice;
}


//Permet de passer au morceau précédent
function backward() {
	initLecture();
	--currentIndice;
	timer = setTimeout("lectureMorceau(currentIndice,'down','"+(isInProtectedField && playMode != "manual" ? "auto" : "manual")+"')",0);
	return false;
}
function backward2() {
	initLecture();
	--currentIndice;
	timer = setTimeout("lectureMorceau(currentIndice,'down','manual')",0);
	return false;
}

// Permet de passer au morceau suivant
function forward() {
	initLecture();
	++currentIndice;
	timer = setTimeout("lectureMorceau(currentIndice,'down','"+(isInProtectedField && playMode != "manual" ? "auto" : "manual")+"')",0);
	return false;
}
function forward2() {
	initLecture();
	++currentIndice;
	timer = setTimeout("lectureMorceau(currentIndice,'down','manual')",0);
	return false;
}

function getPreviousBloc() {
	initLecture();
	if (currentFirstCadreElementIndice > 0) {
		currentIndice = firstCadreElementsIndexes[--currentFirstCadreElementIndice];
		timer = setTimeout("lectureMorceau(currentIndice,'down','"+playMode+"')",0);
	}
	return false;
}

function getNextBloc() {
	initLecture();
	if (currentFirstCadreElementIndice+1 < firstCadreElementsIndexes.length) {
		currentIndice = firstCadreElementsIndexes[++currentFirstCadreElementIndice];
		timer = setTimeout("lectureMorceau(currentIndice,'down','"+playMode+"')",0);
	}
	return false;
}
function firstField() {
	initLecture();
	if (firstFieldIndex != null) {
		currentIndice = firstFieldIndex;
		timer = setTimeout("lectureMorceau(currentIndice,'down','"+playMode+"')",0);
	}
	return false;
}

function lectureMorceau(index) {
	if (!isStopped) {
		if (arguments.length > 1) {
			playDirection = arguments[1];
			if (playMode == "manual" && arguments[2] != "manual" && !isPaused && !isInProtectedField) {
				playMode = arguments[2];
				lectureMorceau(index+1,"down","auto");
				return;
			}
			playMode = arguments[2];
		}
		isPaused = false;
		isInProtectedField = false;
		
		var playModeTmp = playMode;

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
				jQuery("input", pageParts[index]).each(function() {
					if (jQuery(this).attr('type') == "text") {
						content = content.replace(/value=\"([^\"]*)\"/,"");
						if (jQuery(this).val() != "") {
							content = content.replace(/<input/,"<input value=\""+jQuery(this).val()+"\"");
						}
					}
					if (jQuery(this).attr('type') && jQuery(this).attr('type').match(new RegExp('text|password|radio|checkbox|file', "i"))) {
						content = jQuery('label[for="'+jQuery(this).attr('id')+'"]').outer() + content;
					}
					if (jQuery(this).attr('type') && jQuery(this).attr('type').match(new RegExp('text|password', "i"))) {
						if (playMode != "manual") {
							isInProtectedField = true;
						}
						playModeTmp = 'manual';
					}
				});
				jQuery("select, textarea", pageParts[index]).each(function() {
					if (jQuery(this).is("textarea")) {
						if (jQuery(this).val() != "") {
							content = content.replace(/<textarea ([^>]*)>(.*?)<\/textarea>/,"<textarea $1>"+jQuery(this).val()+"</textarea>");
						}
					}
					if (jQuery(this).is("select")) {
						content = content.replace(/ selected/,"");
						if (jQuery(this).val() != "") {
							content = content.replace(" value=\""+jQuery(this).val()+"\""," value=\""+jQuery(this).val()+"\" selected");
						}
					}
					content = jQuery('label[for="'+jQuery(this).attr('id')+'"]').outer() + content;
					if (playMode != "manual") {
						isInProtectedField = true;
					}
					playModeTmp = 'manual';
				});

				// Synchronise les indices actions scripts et js
				currentIndice = index;
				if ((foundIndice = jQuery.inArray(currentIndice, focusablesIndexes)) != -1) {
					currentFocusableIndice = foundIndice;
				}

				if ((foundIndice = jQuery.inArray(pageFirstPartsRelated[currentIndice], firstCadreElementsIndexes)) != -1) {
					currentFirstCadreElementIndice = foundIndice;
				}

				// Ne fait un highlight que si on est en cours de lecture
				setTimeout("highlighterMain("+index+")",duree);
			}
		}
		
		// On lance la lecture de ce nouveau morceau
		if (arguments.length > 1) {
			thisMovie("lecteurCDL").lit(content,playDirection,playModeTmp);
		} else {
			thisMovie("lecteurCDL").lit(content);
		}
	}
}

function thisMovie(movieName) {
	if (window[movieName]) {
		return window[movieName];
	} else {
		return document[movieName];
	}
}
function parentMovie(movieName) {
	try
	{
		if (window.opener) {
			if (window.opener[movieName]) {
				return window.opener[movieName];
			} else {
				return window.opener.document[movieName];
			}
		}
	} catch (err) {}

	return null;
}

function detectKeyDown(Event) {
	if(Event == null)
		Event=event;

	kc = Event.keyCode;

	if (!kc)
		kc = Event.wich;

	if (!focusOnAField) {
		switch (kc) {
			// p
			case 80:
				if (!isReading) {
					thisMovie("lecteurCDL").playIt();
				} else {
					thisMovie("lecteurCDL").pauseIt();
				}
				return;
			// s
			case 83:
				thisMovie("lecteurCDL").stopItDefinitely();
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
				case 37: case 38:
					return backward2();
				// right, down
				case 39: case 40:
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
					--currentIndice;
					timer = setTimeout("lectureMorceau(currentIndice,'down','"+playMode+"')",0);
				} else {
					++currentIndice;
					timer = setTimeout("lectureMorceau(currentIndice,'down','"+playMode+"')",0);
				}
				return;
			// autres
			default: 
				return;
		}
	}
}

function detectKeyUp(Event) {
	if (!isStopped) {
		if(Event == null)
			Event=event;

		kc = Event.keyCode;

		if (!kc)
			kc = Event.wich;

		switch (kc) {
			// maj
			case 16:
				shiftKeyPressed = false;
				break;
			// entrée
			case 13:
				if (focusedSelect != null) {
					if (!isStopped) {
						focusedSelect.blur();
						initLecture();
						++currentIndice;
						timer = setTimeout("lectureMorceau(currentIndice,'down','"+playMode+"')",0);
					}
				}
				break;
			default:
				if (kc != 9) {
					if (focusedSelect != null && (focusedSelectedIndex == null || focusedSelectedIndex != focusedSelect.prop('selectedIndex'))) {
						if (!isStopped) {
							focusedSelectedIndex = focusedSelect.prop('selectedIndex');
							initLecture();
							console.log(focusedSelect);
							timer = setTimeout("lectureMorceau('<select id=\"cdlGhostSelect\">'+jQuery('option',focusedSelect).eq(focusedSelectedIndex).outer()+'</select>',playDirection,playMode)",0);
						}
					}
				}
				return;
		}
	}
}

function detectKeyDownForFocusable(Event) {
	if (!isStopped) {
		if(Event == null)
			Event=event;

		kc = Event.keyCode;

		if (!kc)
			kc = Event.wich;

		switch (kc) {
			// tab
			case 9:
				initLecture();
				if (shiftKeyPressed) {
					if (currentFocusableIndice > 0) {
						currentIndice = focusablesIndexes[--currentFocusableIndice];
						timer = setTimeout("lectureMorceau(currentIndice,'down','manual')",0);
					}
				} else {
					if (currentFocusableIndice < focusablesIndexes.length-1) {
						currentIndice = focusablesIndexes[++currentFocusableIndice];
						timer = setTimeout("lectureMorceau(currentIndice,'down','manual')",0);
					}
				}
				return;
			// maj
			case 16:
				shiftKeyPressed = true;
				return;
			// autres
			default:
				return;
		}
	}
}
function trim(myString) {
	return myString.replace(/^\s+/g,'').replace(/\s+$/g,'');
}

var isFirstElementInCadre;
var currentFocusableIndiceForInit = 0;
var isFirstField = true;
var firstFieldIndex = null;
function highlightedElements(theElement) {
	theElement.children(":not(script,noscript)").each(function() {
		if (jQuery("div,p,h1,h2,h3,h4,h5,h6,ul,ol,li,dl,dt,dd,address,blockquote,ins,del,form,fieldset,legend,span.cdlInputText,span.cdlOtherInput,span.cdlButtons,table,caption,thead,tbody,th,td,span.cdlPartOfText,a,select,textarea,br,hr,img,label,noscript", jQuery(this)).size() == 0 || jQuery(this).is("a") || jQuery(this).is("span.cdlButtons")) {
			var elementContent = trim(jQuery(this).text());
			if ((elementContent && elementContent.match(new RegExp('[^\-\!\"\'\(\)\*\,\.\/\:\;\<\>\?\[\\\]\^\_\`\{\|\}\~\‘\’\¡\¤\¦\§\¨\ª\«\¬\­\¯\´\¶\·\¸\¹\»\¿\• '+String.fromCharCode(160)+'\t\n]', "i")) != null) || jQuery(this).is('span.cdlInputText, span.cdlOtherInput, span.cdlButtons, select, textarea') || (jQuery(this).is('img') && (jQuery(this).attr('alt') != "" || jQuery(this).attr('title') != "")) || (jQuery(this).is("a") && jQuery('img',jQuery(this)).size() > 0)) {
				if (!jQuery(this).is('label')) {
					if (isFirstElementInCadre) {
						firstCadreElementsIndexes.push(i);
						currentFocusableIndiceForInit = i;
						isFirstElementInCadre = false;
					}
					if (jQuery(this).children('input[type!="hidden"],button').size() == 1 || jQuery(this).is('select,textarea')) {
						jQuery(this).wrap("<span class=\"cdlFormFieldsHighlighted\"></span>");
						pageParts.push(jQuery(this).parent());
						jQuery(this).parent().addClass('cdlToRead'+i);
						pageFirstPartsRelated.push(currentFocusableIndiceForInit);
						focusablesIndexes.push(i);
						if (isFirstField) {
							firstFieldIndex = i;
							isFirstField = false;
						}
					} else {
						pageParts.push(jQuery(this));
						jQuery(this).addClass('cdlToRead'+i);
						pageFirstPartsRelated.push(currentFocusableIndiceForInit);
					}

					if (jQuery(this).is('a')) {
						focusablesIndexes.push(i);
					}
					++i;
				}
			}
		} else {
			highlightedElements(jQuery(this));
		}
	});
}

function ds_gettop(el) {
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
function highlighterMain(index) {
	if (!isStopped) {
		jQuery('.cdlInversedColor input[type="text"], .cdlInversedColor input[type="password"], .cdlInversedColor textarea, .cdlInversedColor select').blur();
		jQuery('.cdlInversedColor').removeClass('cdlInversedColor');
		if (pageParts[index]) {
			myScrollTop = ds_gettop(pageParts[index].get(0));
			jQuery("input", pageParts[index]).each(function() {
				if (jQuery(this).attr('type') && jQuery(this).attr('type').match(new RegExp('text|password|radio|checkbox|file', "i")) && jQuery('label[for="'+jQuery(this).attr('id')+'"]').size() > 0) {
					myScrollTop = Math.min(myScrollTop, ds_gettop(jQuery('label[for="'+jQuery(this).attr('id')+'"]').get(0)));
				}
			});
			jQuery("select, textarea", pageParts[index]).each(function() {
				if (jQuery(this).attr('type') && jQuery(this).attr('type').match(new RegExp('text|password|radio|checkbox|file', "i")) && jQuery('label[for="'+jQuery(this).attr('id')+'"]').size() > 0) {
					myScrollTop = Math.min(myScrollTop, ds_gettop(jQuery('label[for="'+jQuery(this).attr('id')+'"]').get(0)));
				}
			});

			jQuery('div.cdlAllPageContainer').animate({scrollTop: myScrollTop-300-jQuery('div.cdlUtilLinksContainer').get(0).offsetHeight-7}, duree);

			pageParts[index].addClass('cdlInversedColor');
			pageParts[index].focus();

			jQuery("input", pageParts[index]).each(function() {
				if (jQuery(this).attr('type') && jQuery(this).attr('type').match(new RegExp('text|password|radio|checkbox|file', "i"))) {
					jQuery('label[for="'+jQuery(this).attr('id')+'"]').addClass('cdlInversedColor');
				}
				jQuery(this).focus();
			});
			jQuery("button", pageParts[index]).each(function() {
				jQuery(this).focus();
			});
			jQuery("select, textarea", pageParts[index]).each(function() {
				jQuery('label[for="'+jQuery(this).attr('id')+'"]').addClass('cdlInversedColor');
				jQuery(this).focus();
			});
		}

		if (index == pageParts.length) {
			jQuery('div.cdlAllPageContainer').animate({scrollTop: 0}, 500);
		}
	}
}

if (jQuery('div.cdlTopPage').size()) {
	jQuery('div.cdlTopPage div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('div.cdlPageContent').size()) {
	jQuery('div.cdlPageContent div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('div.cdlPageNavigation').size()) {
	jQuery('div.cdlPageNavigation div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('div.cdlBottomPage').size()) {
	jQuery('div.cdlBottomPage div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('div.cdlBackHome').size()) {
	jQuery('div.cdlBackHome div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('div.documentContent').size()) {
	jQuery('div.documentContent div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('div.protectedPageLoginContent').size()) {
	jQuery('div.protectedPageLoginContent div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('div.exitContent').size()) {
	jQuery('div.exitContent div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('div.errorContent').size()) {
	jQuery('div.errorContent div.cdlCadre').each(function () {isFirstElementInCadre = true;highlightedElements(jQuery(this));});
}
if (jQuery('p.cdlCopyright').size()) {
	pageParts.push(jQuery('p.cdlCopyright'));
	jQuery('p.cdlCopyright').addClass('cdlToRead'+i);
	pageFirstPartsRelated.push(i);
	++i;
}

jQuery('input[type="text"], input[type="password"], textarea, select').bind('focus', function() {
	focusOnAField = true;
	if (jQuery(this).is('select')) {
		focusedSelect = jQuery(this);
		focusedSelectedIndex = focusedSelect.prop('selectedIndex');
	}
});
jQuery('input[type="text"], input[type="password"], textarea, select').bind('blur', function() {
	focusOnAField = false;
	focusedSelect = null;
	focusedSelectedIndex = null;
});


jQuery('a, button, input[type="submit"], input[type="button"]').bind('click', function() {
	if (isReading) {
		thisMovie("lecteurCDL").pauseIt();
	}
});


jQuery('html').bind('keydown', detectKeyDown);
jQuery('html').bind('keyup', detectKeyUp);

jQuery('input, select, textarea, button, a').bind('keydown', detectKeyDownForFocusable);

jQuery('select').bind('click', function() {
	if (!isStopped) {
		if (jQuery(this).is('.cdlInversedColor select')) {
			if (focusedSelect != null && (focusedSelectedIndex == null || focusedSelectedIndex != focusedSelect.prop('selectedIndex'))) {
				focusedSelectedIndex = focusedSelect.prop('selectedIndex');
				initLecture();
				timer = setTimeout("lectureMorceau('<select id=\"cdlGhostSelect\">'+jQuery('option',focusedSelect).eq(focusedSelectedIndex).outer()+'</select>',playDirection,playMode)",duree);
			}
		}
	}
});

jQuery('object#lecteurCDL').bind('mouseout',function () {
	thisMovie("lecteurCDL").hideCursor();
});

function initAnchorLinks() {
	jQuery.address.change(function(event) {
		if (event.value != '/') {
			jQuery('[name="'+event.value+'"]:first, #'+event.value).each(function () {
				var cdlToReadClassName;
				if (jQuery(this).is('[class*="cdlToRead"]')) {
					cdlToReadClassName = jQuery(this).attr('class');
				} else {
					var anchorRelated = jQuery('[class*="cdlToRead"]:first', jQuery(this));
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
				timer = setTimeout("lectureMorceau(currentIndice,'down','"+playMode+"')",0);
			});
		}
		return false;
	});
}