#########################################################################
# BEGIN COPYRIGHT, LICENSE AND WARRANTY NOTICE
# SOFTWARE NAME: Confort de lecture
# SOFTWARE RELEASE: 2.0.0
# COPYRIGHT NOTICE: Copyright (C) 2000-2007 GIE Confort de lecture (aYaline & HandicapZéro)
# SOFTWARE LICENSE: GNU General Public License v3
# NOTICE:
# This file is part of Confort de lecture.
#
# Confort de lecture is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# Confort de lecture is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Confort de lecture. If not, see <http://www.gnu.org/licenses/>.
#########################################################################

# File: index_main.pm
#	Module central d'exécution du script principal

# Function: processIndexMain
#	Exécution du script index principal (partie initialisation de base)
#
# Paramètres:
#
sub processIndexPage
{
	# Création de l'objet CGI
	my $cgi = CGI->new();

	# Création de la session et récupération de l'objet de gestion de la session
	my $session = createOrGetSession($cgi);

	# Récupération des paramètres et de la méthode d'appel du script
	my $requestMethod = $ENV{'REQUEST_METHOD'};

	# Génération de la table des hachage des paramètres
	my %requestParameters = getRequestParameters;

	# Récupération du paramètre id et de l'uri à parser
	my ($siteId, $pageUri, $secure) = getIndexUrlParameters;

	# Détection d'erreurs au niveau de l'identifiant du site
	$siteId = verifySiteId($siteId);

	# Inclusion du module extension général à tous les sites
	require($cdlSitesConfigPath."default_override.pm");

	# Inclusion du module extension spécifique au site s'il y en a un
	if (-e $cdlSitesConfigPath.$siteId."/override/main.pm") {
		require($cdlSitesConfigPath.$siteId."/override/main.pm");
	}

	processIndexPageFinal($cgi, $session, $requestMethod, $siteId, $pageUri, $secure, %requestParameters);
}

# Function: processIndexPageFinal
#	Exécution du script index principal (partie exécution de la requête HTTP et traitement du retour)
#
# Paramètres:
#	$cgi - objet CGI pour les session et le traitement/rendu de la page
#	$session - objet session utile pour la gestion des cookies
#	$requestMethod - méthode d'envoi de la requête (GET, POST ou HEAD)
#	$siteId - Identifiant du site parsé
#	$pageUri - URI de la page en cours
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
#	%requestParameters - paramètres à coller à l'URL
sub processIndexPageFinal #($cgi, $session, $requestMethod, $siteId, $pageUri, $secure, %requestParameters)
{
	my ($cgi, $session, $requestMethod, $siteId, $pageUri, $secure, %requestParameters) = @_;

	# Récupération des personnalisations d'affichage et audio dans le cas où l'internaute arrive d'un autre site en version CDL
	{
		my $backgroundColor = param('cdlbc');
		if (defined $backgroundColor and $backgroundColor ne "") {
			editInSession($session, 'backgroundColor', $backgroundColor);
		}
		my $fontColor = param('cdlfc');
		if (defined $fontColor and $fontColor ne "") {
			editInSession($session, 'fontColor', $fontColor);
		}
		my $linkColor = param('cdllc');
		if (defined $linkColor and $linkColor ne "") {
			editInSession($session, 'linkColor', $linkColor);
		}
		my $fontSize = param('cdlfs');
		if (defined $fontSize and $fontSize ne "") {
			editInSession($session, 'fontSize', $fontSize);
		}
		my $letterSpacing = param('cdlls');
		if (defined $letterSpacing and $letterSpacing ne "") {
			editInSession($session, 'letterSpacing', $letterSpacing);
		}
		my $wordSpacing = param('cdlws');
		if (defined $wordSpacing and $wordSpacing ne "") {
			editInSession($session, 'wordSpacing', $wordSpacing);
		}
		my $lineHeight = param('cdllh');
		if (defined $lineHeight and $lineHeight ne "") {
			editInSession($session, 'lineHeight', $lineHeight);
		}
		my $positionLocation = param('cdlpl');
		if (defined $positionLocation and $positionLocation ne "") {
			editInSession($session, 'positionLocation', $positionLocation);
		}
		my $activateJavascript = param('cdlaj');
		if (defined $activateJavascript and $activateJavascript ne "") {
			editInSession($session, 'activateJavascript', $activateJavascript);
		}
		my $activateFrames = param('cdlaf');
		if (defined $activateFrames and $activateFrames ne "") {
			editInSession($session, 'activateFrames', $activateFrames);
		}
		my $displayImages = param('cdldi');
		if (defined $displayImages and $displayImages ne "") {
			editInSession($session, 'displayImages', $displayImages);
		}
		my $displayObjects = param('cdldo');
		if (defined $displayObjects and $displayObjects ne "") {
			editInSession($session, 'displayObjects', $displayObjects);
		}
		my $displayApplets = param('cdlda');
		if (defined $displayApplets and $displayApplets ne "") {
			editInSession($session, 'displayApplets', $displayApplets);
		}
		my $parseTablesToList = param('cdlpt');
		if (defined $parseTablesToList and $parseTablesToList ne "") {
			editInSession($session, 'parseTablesToList', $parseTablesToList);
		}
		my $activateAudio = param('cdlaa');
		if (defined $activateAudio and $activateAudio ne "") {
			editInSession($session, 'activateAudio', $activateAudio);
		}
		my $language = param('cdll');
		if (defined $language and $language ne "") {
			editInSession($session, 'language', $language);
		}
		my $contrast = param('cdlc');
		if (defined $contrast and $contrast ne "") {
			editInSession($session, 'contrast', $contrast);
		}
	}

	# Chargement de la configuration
	my ($siteLabel, $siteDefaultLanguage, $positionLocation, $activateJavascript, $parseJavascript, $activateFrames, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $enableAudio, $activateAudio, $siteDomainNames, $trustedDomainNames, $homePageUri, $pagesNoCache, $cacheExpiry) = getAllConfigs($session, $siteId);

	# Récupération de l'URI à parser pour en construire une URL
	my ($urlToParse, $siteRootUrl, $pagePath) = buildUrlToParse($cgi, $session, $pageUri, $secure, $siteDomainNames, $homePageUri);

	my $pageUrl = $urlToParse;
	$pageUrl =~ s/^https?:\/\///segi;
	if ($requestMethod =~ m/post/si) {
		$pageUrl = putParametersInUrl($pageUrl, %requestParameters);
	}

	my $pageContent = "";
	my $pageContentFile = "";
	my $pageUriWithoutServerName = $pageUri;
	if ($embeddedMode eq "") {
		$pageUriWithoutServerName =~ s/^([^\/]*)\///sgi;
	}
	if ($requestMethod !~ m/post/si and ($pagesNoCache eq "" or $pageUriWithoutServerName !~ m/($pagesNoCache)/si)) {
		($pageContentFile, $pageContent) = getPageContentFromCache($requestMethod, $pageUrl, loadFromSession($session, 'positionLocation')."_".loadFromSession($session, 'activateJavascript')."_".loadFromSession($session, 'activateFrames')."_".loadFromSession($session, 'displayImages')."_".loadFromSession($session, 'displayObjects')."_".loadFromSession($session, 'displayApplets')."_".loadFromSession($session, 'parseTablesToList'), $cacheExpiry);
	}

	if ($pageContent ne "") {
		my $contentType = "";
		$pageContent =~ s/(<meta( [^>]*)? content=(\"|\')([^>]*?)\3[^>]* http-equiv=(\"|\')Content-Type\5[^>]*>)/$contentType = $4; $1/segi;

		if ($contentType eq "") {
			$pageContent =~ s/(<meta( [^>]*)? http-equiv=(\"|\')Content-Type\3[^>]* content=(\"|\')([^>]*?)\4[^>]*>)/$contentType = $5; $1/segi;
		}
		$pageContent = $pageContent."\n<div class=\"cdlPageCached\"></div>";
		renderCachedPage($pageContent, $pageContentFile, $session, $siteId, $pageUri, $secure, $contentType, $enableAudio, $activateAudio, $requestMethod, %requestParameters);
		exit;
	}

	if (($siteDomainNames and $urlToParse =~ m/^https?:\/\/($siteDomainNames)/si) or ($embeddedMode ne "" and $ENV{'SERVER_NAME'} =~ m/($siteDomainNames)/si)) {

		# On effectue la requête HTTP en récupérant la réponse
		my $response = sendRequest($requestMethod, $urlToParse, $siteId, $siteRootUrl, $session, %requestParameters);

		# Récupération du type d'encodage des caractères reçus dans la réponse HTTP
		my $contentType = getContentTypeFromHttpResponseHeader($response);

		# Si le code retour est succès, on traite le contenu de la réponse
		if ($response->is_success) {
			# Si le contenu est de type texte/HTML, on le parse et on l'affiche,
			# sinon on redirige vers la page de gestion des documents
			if ($contentType =~ m/text\/html/si) {
				my $htmlCode = getCleanedPageContent($response, $contentType, $activateAudio);

				renderIndexPage($htmlCode, $session, $siteId, $siteLabel, $siteDefaultLanguage, $homePageUri, $requestMethod, $secure, $urlToParse, $pageUri, $siteRootUrl, $pagePath, $contentType, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $enableAudio, $activateAudio, $trustedDomainNames, %requestParameters);
			} else {
				redirectToDocumentPage($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $response, $urlToParse, $secure, %requestParameters);
			}
		} elsif ($response->is_redirect) {
			redirectToAnotherPage($cgi, $session, $siteId, $response, $siteRootUrl, $pageUri, $pagePath, $secure, $trustedDomainNames);
		} elsif ($response->code eq "401") {
			redirectToProtectedAccessLogin($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $response, $urlToParse, $secure, %requestParameters);
		} else {
			# Affichage de la page de signelement d'une erreur au niveau de la requête HTTP vers le site distant
			renderErrorPage($session, $siteId, $enableAudio, $activateAudio, $requestMethod, $response, $urlToParse, $secure, %requestParameters);
		}
	} else {
		accessAnotherSite($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $urlToParse, $secure, $trustedDomainNames, %requestParameters);
	}
}

# Function: renderErrorPage
#	Affichage de la page de signelement d'une erreur au niveau de la requête HTTP vers le site distant
#
# Paramètres:
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$activateAudio - booléen indiquant si l'utilisateur a choisi de vocaliser les pages
#	enableAudio - booléen indiquant si l'option audio activé pour ce site
#	$requestMethod - méthode d'envoi de la requête (GET, POST ou HEAD)
#	$response - objet réponse HTTP d'où le code et l'intitulé de l'erreur
#	$urlToParse - URL de la page en erreur
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
#	%requestParameters - paramètres à coller à l'URL
sub renderErrorPage #($session, $siteId, $enableAudio, $activateAudio, $requestMethod, $response, $urlToParse, $secure, %requestParameters)
{
	my ($session, $siteId, $enableAudio, $activateAudio, $requestMethod, $response, $urlToParse, $secure, %requestParameters) = @_;

	# Mettre les liens qui permettent d'aller modifier la personnalisation
	my $language = loadFromSession($session, 'language');
	my $contrast = loadFromSession($session, 'contrast');
	$language = $language ? $language : ($defaultLanguage ? $defaultLanguage : "fr");
	$contrast = $contrast ? $contrast : "bn";

	my $pageUriForHtml = $urlToParse;
	$pageUriForHtml =~ s/&amp;/&/sgi;
	$pageUriForHtml =~ s/&/&amp;/sgi;

	if ($embeddedMode ne "") {
		$pageUriForHtml =~ s/^https?:\/\/[^\/]+\/?//sgi;
	} else {
		$pageUriForHtml =~ s/^https?:\/\///sgi;
	}

	# Chargement de la template d'erreur
	my $errorPageTemplateString = loadConfig($cdlTemplatesPath."error_page.html");

	# Gestion des langues
	if (-e "../modules/dictionary/".$language.".pm") {
		require("../modules/dictionary/".$language.".pm");
	} else {
		require("../modules/dictionary/fr.pm");
	}

	$errorPageTemplateString =~ s/\#\#\#_DICO_([^\#]*)\#\#\#/$dictionary{$1}/segi;

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'EMBEDDED_URL', $embeddedMode);

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'SITE_ID', $siteId);

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'LANGUAGE', $language);

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'PERSONALIZATION_URL', $language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".($requestMethod =~ m/post/si ? putParametersInUrlForHtml($pageUriForHtml, %requestParameters) : $pageUriForHtml));

	my $iconContent;
	open ICON_FILE, "< ".$cdlRootPath."/design/images/display.svg";
	$iconContent = do { local $/; <ICON_FILE> };
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'DISPLAY_ICON', $iconContent);

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'ERROR_NUMBER', $response->code);

	# Ajout des paramètres éventuels
	if ($requestMethod =~ m/post/si) {
		$urlToParse = putParametersInUrlForHtml($urlToParse, %requestParameters);
	}
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'PAGE_ON_ERROR_URL', $urlToParse);

	my $cdlPageUrl = $ENV{'REQUEST_URI'};
	my $previousPageUrl = "http".$secure."://".$ENV{'SERVER_NAME'}.($embeddedMode ne "" ? $embeddedMode."/f" : "/le-filtre/".$siteId);
	$cdlPageUrl =~ s/&/&amp;/sgi;
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'CDL_PAGE_URL', $cdlPageUrl);

	# L'URL de la page précédente
	if ($previousPageUrl) {
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'PREVIOUS_CDL_PAGE_BLOCK', setValueInTemplateString(getPartOfTemplateString($errorPageTemplateString, 'PREVIOUS_CDL_PAGE_BLOCK'), 'PREVIOUS_CDL_PAGE', $previousPageUrl));
	} else {
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'PREVIOUS_CDL_PAGE_BLOCK', "");
	}

	# Gestion du cache :
	# Sauvegarder du contenu de la page dans un fichier temporaire
	if ($requestMethod =~ m/post/si) {
		$urlToParse = putParametersInUrl($urlToParse, %requestParameters);
	}
	my $pageContentFile = savePageContentInCache("ERROR_".$requestMethod, $urlToParse, $errorPageTemplateString, loadFromSession($session, 'positionLocation')."_".loadFromSession($session, 'activateJavascript')."_".loadFromSession($session, 'activateFrames')."_".loadFromSession($session, 'displayImages')."_".loadFromSession($session, 'displayObjects')."_".loadFromSession($session, 'displayApplets')."_".loadFromSession($session, 'parseTablesToList'));

	# Mettre le nom de ce fichier temporaire en parametre du lien vers le script de génération en audio
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'CONTENT_TO_READ_WITH_ACAPELA', $pageContentFile);

	my $fontSize = loadFromSession($session, 'fontSize');
	$fontSize = $fontSize ? $fontSize : 3;
	if ($activateAudio eq "1") {
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', getPartOfTemplateString($errorPageTemplateString, 'JS_AUDIO_FILE_INCLUDE'));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO', getPartOfTemplateString($errorPageTemplateString, 'AUDIO'));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'MP3_PLAYER_WIDTH', 250+3.4*(($fontSize - 1)*20));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'MP3_PLAYER_HEIGHT', 50+0.7*(($fontSize - 1)*20));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'DIV_MP3_PLAYER_HEIGHT', 40+0.7*(($fontSize - 1)*20));

		# Mettre le nom de domaine pour complèter les URLs absolues
		my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
		my $ttsServerName = getConfig($siteConfiguration, 'ttsServerName');
		my $ttsUri = getConfig($siteConfiguration, 'ttsUri');
		my $ttsTextParamName = getConfig($siteConfiguration, 'ttsTextParamName');

		my $audioServerName = $ENV{'SERVER_NAME'}.$embeddedMode;
		if ($ttsUri =~ m/^\/audio\-text/si && $ttsTextParamName eq "cdltext") {
			$audioServerName = $ttsServerName;
		}
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO_SERVER_NAME', $audioServerName);

		my $voice = loadFromSession($session, 'voice');
		if (!$voice) {
			$voice = "";
		}
		if ($voice and !exists($unordoredVoices{$voice})) {
			$voice = $defaultVoice;
			editInSession($session, 'voice', $voice);
		}

		my $speed = loadFromSession($session, 'speed');
		if (!$speed) {
			$speed = "";
		}
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'VOICE', $voice);
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'SPEED', $speed);
	} else {
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', "");
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO', "");
	}
	if ($enableAudio eq "1") {
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO_ACTIONS', getPartOfTemplateString($errorPageTemplateString, 'AUDIO_ACTIONS'));

		open ICON_FILE, "< ".$cdlRootPath."/design/images/audio.svg";
		$iconContent = do { local $/; <ICON_FILE> };
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO_ICON', $iconContent);

		open ICON_FILE, "< ".$cdlRootPath."/design/images/audio_help.svg";
		$iconContent = do { local $/; <ICON_FILE> };
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO_HELP_ICON', $iconContent);
	} else {
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO_ACTIONS', "");
	}

	my $backgroundColor = loadFromSession($session, 'backgroundColor');
	my $fontColor = loadFromSession($session, 'fontColor');
	my $linkColor = loadFromSession($session, 'linkColor');
	$backgroundColor = $backgroundColor ? $backgroundColor : '000000';
	$fontColor = $fontColor ? $fontColor : 'FFFFFF';
	$linkColor = $linkColor ? $linkColor : $fontColor;
	my $letterSpacing = loadFromSession($session, 'letterSpacing');
	my $wordSpacing = loadFromSession($session, 'wordSpacing');
	my $lineHeight = loadFromSession($session, 'lineHeight');
	$letterSpacing = $letterSpacing ? $letterSpacing : '1';
	$wordSpacing = $wordSpacing ? $wordSpacing : '1';
	$lineHeight = $lineHeight ? $lineHeight : '1';

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'B_COLOR', $backgroundColor);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'F_COLOR', $fontColor);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'L_COLOR', $linkColor);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'F_SIZE', $fontSize);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'ICON_SIZE', 40+0.7*(($fontSize - 1)*20));
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'L_SPACING', $letterSpacing);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'W_SPACING', $wordSpacing);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'L_HEIGHT', $lineHeight);
	if (isBigCursorNotAllowed()) {
		$fontSize = 1;
	}
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'F_SIZE_BROWSER_DEPENDS', $fontSize);

	my @now = localtime(time);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);

	print $session->header('Content-type' => "text/html; charset=utf-8");
	print $errorPageTemplateString;
}

# Function: renderIndexPage
#	Affichage du rendu final de la page parsée en passant par la template
#
# Paramètres:
#	$htmlCode - code HTML de la page originale
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$siteLabel - Label du site à mettre sur la page d'accueil
#	$siteDefaultLanguage - Langue par défaut du site
#	$homePageUri - URI de la page d'accueil configurée par défaut
#	$requestMethod - méthode HTTP avec laquelle la page a été appelée
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
#	$urlToParse - URL de la page à transformer
#	$pageUri - URI de la page en cours
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$contentType - type de contenu et encodage de la page
#	$positionLocation - position du fil d'Ariane
#	$activateJavascript - booléen indiquant si le javascript est activé
#	$parseJavascript - booléen indiquant si le javascript est traité pour adaptation à la page parsée
#	$displayImages - booléen indiquant si les images sont affichées
#	$displayObjects - booléen indiquant si les balises object sont affichées
#	$displayApplets - booléen indiquant si les applets sont affichées
#	$parseTablesToList - booléen indiquant si les tableaux sont linéarisés
#	$activateFrames - booléen indiquant si les frames sont activées
#	$enableAudio - booléen indiquant si l'option audio activé pour ce site
#	$activateAudio - booléen indiquant si l'utilisateur a choisi de vocaliser les pages
#	$trustedDomainNames - noms de domaine configuré de confiance
#	%requestParameters - paramètres passés à la page
sub renderIndexPage #($htmlCode, $session, $siteId, $siteLabel, $siteDefaultLanguage, $homePageUri, $requestMethod, $secure, $urlToParse, $pageUri, $siteRootUrl, $pagePath, $contentType, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $enableAudio, $activateAudio, $trustedDomainNames, %requestParameters)
{
	my ($htmlCode, $session, $siteId, $siteLabel, $siteDefaultLanguage, $homePageUri, $requestMethod, $secure, $urlToParse, $pageUri, $siteRootUrl, $pagePath, $contentType, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $enableAudio, $activateAudio, $trustedDomainNames, %requestParameters) = @_;

	# Chargement de la template principale de la page
	my $entirePageTemplateString = loadConfig($cdlTemplatesPath."entire_page.html");

	# Identifiant du site
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'SITE_ID', $siteId);

	# Langue de la page
	my $pageLanguage = getDocumentLanguage($htmlCode, $siteDefaultLanguage);

	editInSession($session, 'language', $pageLanguage);

	# Gestion des langues
	if (-e "../modules/dictionary/".$pageLanguage.".pm") {
		require("../modules/dictionary/".$pageLanguage.".pm");
	} else {
		require("../modules/dictionary/fr.pm");
	}

	# Récupération de l'URL de base d'où extraire le chemin des liens relatifs de la page
	my $baseHref = getBaseHref($htmlCode);
	if ($baseHref) {
		$baseHref =~ s/^($siteRootUrl(\/(.*))?)$/$pagePath = $2; $1/segi;
	}

	# Mise à jour de l'attribut href de la balise base en mettant l'entête de base de tous les liens http://{CDL_SERVER_NAME}/le-filtre/{SITE_ID}/{SITE_SERVER_NAME}
	my $siteServerName = $siteRootUrl;
	$siteServerName =~ s/^https?:\/\///sgi;
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BASE_HREF', "http".$secure."://".$ENV{'SERVER_NAME'}.($embeddedMode ne "" ? $embeddedMode."/f".$secure."/" : "/le-filtre".($secure eq "s" ? "-https" : "")."/".$siteId."/".$siteServerName."/"));

	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'LANGUAGE', $pageLanguage);

	# Parse et remplissage du head
	($htmlCode, $entirePageTemplateString) = parseAllHead($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $contentType, $activateJavascript, $parseJavascript, $siteId, $trustedDomainNames);

	# Chargement de la template de cadre
	my $cadreTemplateString = loadConfig($cdlTemplatesPath."cadre.html");

	if (positionTagExists($htmlCode)) {
		# Parse de la balise position
		($htmlCode, $entirePageTemplateString) = parsePosition($htmlCode, $siteRootUrl, $pagePath, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $entirePageTemplateString, $cadreTemplateString, $siteId, $pageUri);

		# Chargement de la template de retour vers l'accueil
		my $backHomeTemplateString = loadConfig($cdlTemplatesPath."back_home_link.html");

		# Affichage du lien Retour à l'accueil
		$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BACK_HOME_LINK', setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', setValueInTemplateString($backHomeTemplateString, 'HOME_URL', parseLinkHrefAttribute($homePageUri, $pagePath, $siteId, $siteRootUrl, $pageUri, 'get', $trustedDomainNames))));
	} else {
		# Chargement de la template de titre du site
		my $siteTitleTemplateString = loadConfig($cdlTemplatesPath."site_title.html");

		# Remplissage de la template de titre du site avec le titre du site parsé
		if ($contentType !~ m/charset=utf\-?\d+/si and $htmlCode !~ m/charset=utf\-?\d+/si) {
			utf8::decode($siteLabel);
		}
		$siteTitleTemplateString = setValueInTemplateString($siteTitleTemplateString, 'SITE_TITLE', $siteLabel ? $siteLabel : "Accueil : ".$siteId);

		# Remplissage de la template générale avec le titre de la page
		$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'PAGE_TOP', setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', $siteTitleTemplateString)."\n");

		# On remplace par rien l'emplacement du lien retour vers la page d'accueil
		$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'PAGE_BOTTOM', "");
		$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BACK_HOME_LINK', "");
	}

	$entirePageTemplateString =~ s/\#\#\#_DICO_([^\#]*)\#\#\#/$dictionary{$1}/segi;

	# Parse et remplissage des navs
	($htmlCode, $entirePageTemplateString) = parseAllNavs($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $trustedDomainNames, $entirePageTemplateString, $cadreTemplateString);

	# Parse et remplissage des blocs
	($htmlCode, $entirePageTemplateString) = parseAllBlocs($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $trustedDomainNames, $entirePageTemplateString, $cadreTemplateString);

	# Gestion des attributs du body (listeners javascript et attributs génériques)
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BODY_ATTRIBUTES', $activateJavascript ? getBodyAttributes($htmlCode, $siteId, $pagePath, $siteRootUrl, $trustedDomainNames, $parseJavascript) : "");

	# Sauvegarder du contenu de la page dans un fichier
	$urlToParse =~ s/^https?:\/\///segi;
	# Ajout des paramètres éventuels
	if ($requestMethod =~ m/post/si) {
		$urlToParse = putParametersInUrl($urlToParse, %requestParameters);
	}
	my $pageContentFile = savePageContentInCache($requestMethod, $urlToParse, $entirePageTemplateString, loadFromSession($session, 'positionLocation')."_".loadFromSession($session, 'activateJavascript')."_".loadFromSession($session, 'activateFrames')."_".loadFromSession($session, 'displayImages')."_".loadFromSession($session, 'displayObjects')."_".loadFromSession($session, 'displayApplets')."_".loadFromSession($session, 'parseTablesToList'));

	renderCachedPage($entirePageTemplateString, $pageContentFile, $session, $siteId, $pageUri, $secure, $contentType, $enableAudio, $activateAudio, $requestMethod, %requestParameters);
}

# Function: printPage
#	Affichage du contenu de la page finale avec les paramètres utilisateurs
#
# Paramètres:
#	$session - objet session utile pour la gestion des cookies
#	$contentType - type de contenu et encodage de la page
#	$pageContent - code HTML de la page finale
sub printPage #($pageContent, $pageContentFile, $session)
{
	my ($session, $contentType, $pageContent) = @_;

	print $session->header('Content-type' => $contentType);
	print $pageContent;
}

# Function: renderCachedPage
#	Affichage du rendu final de la page parsée récupérée du cache ou mise en cache
#
# Paramètres:
#	$pageContent - code HTML de la page finale
#	$pageContentFile - Nom du fichier de cache où le contenu de la page est stocké
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$pageUri - URI de la page en cours
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
#	$contentType - type de contenu et encodage de la page
#	$enableAudio - booléen indiquant si l'option audio activé pour ce site
#	$activateAudio - booléen indiquant si l'utilisateur a choisi de vocaliser les pages
#	$requestMethod - méthode d'envoi de la requête (GET, POST ou HEAD)
#	%requestParameters - paramètres passés à la page
sub renderCachedPage #($pageContent, $pageContentFile, $session, $siteId, $pageUri, $secure, $contentType, $enableAudio, $activateAudio, $requestMethod, %requestParameters)
{
	my ($pageContent, $pageContentFile, $session, $siteId, $pageUri, $secure, $contentType, $enableAudio, $activateAudio, $requestMethod, %requestParameters) = @_;

	# Mettre les liens qui permettent d'aller modifier la personnalisation
	my $language = loadFromSession($session, 'language');
	my $contrast = loadFromSession($session, 'contrast');
	$language = $language ? $language : "fr";
	$contrast = $contrast ? $contrast : "bn";

	my $pageUriForHtml = $pageUri;
	$pageUriForHtml =~ s/&amp;/&/sgi;
	$pageUriForHtml =~ s/&/&amp;/sgi;

	$pageContent = setValueInTemplateString($pageContent, 'ORIGINAL_URL', "http".$secure."://".($embeddedMode ne "" ? $ENV{'SERVER_NAME'} : "").($pageUri !~ m/^\//si ? "/" : "").$pageUri);

	$pageContent = setValueInTemplateString($pageContent, 'PERSONALIZATION_URL', $language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".($requestMethod =~ m/post/si ? putParametersInUrlForHtml($pageUriForHtml, %requestParameters) : $pageUriForHtml));

	my $iconContent;
	open ICON_FILE, "< ".$cdlRootPath."/design/images/display.svg";
	$iconContent = do { local $/; <ICON_FILE> };
	$pageContent = setValueInTemplateString($pageContent, 'DISPLAY_ICON', $iconContent);

	# Mettre le nom de ce fichier temporaire en parametre du lien vers le script de génération en audio
	$pageContent = setValueInTemplateString($pageContent, 'CONTENT_TO_READ_WITH_ACAPELA', $pageContentFile);

	my $fontSize = loadFromSession($session, 'fontSize');
	$fontSize = $fontSize ? $fontSize : '3';

	if ($activateAudio eq "1") {
		$pageContent = setValueInTemplateString($pageContent, 'JS_AUDIO_FILE_INCLUDE', getPartOfTemplateString($pageContent, 'JS_AUDIO_FILE_INCLUDE'));
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO', getPartOfTemplateString($pageContent, 'AUDIO'));
		$pageContent = setValueInTemplateString($pageContent, 'MP3_PLAYER_WIDTH', 250+3.4*(($fontSize - 1)*20));
		$pageContent = setValueInTemplateString($pageContent, 'MP3_PLAYER_HEIGHT', 50+0.7*(($fontSize - 1)*20));
		$pageContent = setValueInTemplateString($pageContent, 'DIV_MP3_PLAYER_HEIGHT', 40+0.7*(($fontSize - 1)*20));

		# Mettre le nom de domaine pour complèter les URLs absolues
		my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
		my $ttsServerName = getConfig($siteConfiguration, 'ttsServerName');
		my $ttsUri = getConfig($siteConfiguration, 'ttsUri');
		my $ttsTextParamName = getConfig($siteConfiguration, 'ttsTextParamName');

		my $audioServerName = $ENV{'SERVER_NAME'}.$embeddedMode;
		if ($ttsUri =~ m/^\/audio\-text/si && $ttsTextParamName eq "cdltext") {
			$audioServerName = $ttsServerName;
		}
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO_SERVER_NAME', $audioServerName);

		my $defaultConfiguration = loadConfig($cdlSitesConfigPath."default.ini");
		my $voice = loadFromSession($session, 'voice');
		if (!$voice) {
			$voice = "";
		}
		if ($voice and !exists($unordoredVoices{$voice})) {
			$voice = $defaultVoice;
			editInSession($session, 'voice', $voice);
		}

		my $speed = loadFromSession($session, 'speed');
		if (!$speed) {
			$speed = "";
		}
		$pageContent = setValueInTemplateString($pageContent, 'VOICE', $voice);
		$pageContent = setValueInTemplateString($pageContent, 'SPEED', $speed);

		use Digest::SHA::PurePerl qw(sha1_hex);
		use MIME::Base64;

		my $lettersPlayers = "";
		my $lettersHtmlCacheFile = "letters_".($voice ? $voice : $defaultVoice)."_".(($speed ne "" ? $speed : $defaultSpeed)*2).".html";
		if (!-e $cdlAudioCachePath.$lettersHtmlCacheFile) {
			foreach my $letterKey (keys(%lettersToSpell)) {
				my $fileName = sha1_hex(($siteId ne "" ? $siteId."\n" : "").$lettersToSpell{$letterKey});
				$lettersPlayers .= "<audio preload=\"auto\" src=\"data:audio/mpeg;base64,".encode_base64(vocalize($fileName, $siteId, $defaultConfiguration, $voice, $speed, $lettersToSpell{$letterKey}))."\" class=\"cdlHidden\" id=\"lecteurAudioCDL_".$letterKey."\"></audio>\n";
			}
			open(WRITER, ">", $cdlAudioCachePath.$lettersHtmlCacheFile) or die "Erreur d'ouverture du fichier : ".$cdlAudioCachePath.$lettersHtmlCacheFile.".\n";
			print WRITER ($lettersPlayers);
			close(WRITER);
		}

		$pageContent = setValueInTemplateString($pageContent, 'LETTERS_PLAYERS_FILE', $embeddedMode."/cache/audio/".$lettersHtmlCacheFile);

		$pageContent = setValueInTemplateString($pageContent, 'ARROW_TOP_ICON_CONTAINER', "");
	} else {
		$pageContent = setValueInTemplateString($pageContent, 'JS_AUDIO_FILE_INCLUDE', "");
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO', "");

		$pageContent = setValueInTemplateString($pageContent, 'ARROW_TOP_ICON_CONTAINER', getPartOfTemplateString($pageContent, 'ARROW_TOP_ICON_CONTAINER'));

		if ($embeddedMode eq "") {
			$pageUriForHtml =~ s/^[^\/]+\///sgi;
		}
		$pageContent = setValueInTemplateString($pageContent, 'CURRENT_PAGE_URI', $pageUriForHtml);

		open ICON_FILE, "< ".$cdlRootPath."/design/images/arrow_top.svg";
		$iconContent = do { local $/; <ICON_FILE> };
		$pageContent = setValueInTemplateString($pageContent, 'ARROW_TOP_ICON', $iconContent);
	}
	if ($enableAudio eq "1") {
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO_ACTIONS', getPartOfTemplateString($pageContent, 'AUDIO_ACTIONS'));

		open ICON_FILE, "< ".$cdlRootPath."/design/images/audio.svg";
		$iconContent = do { local $/; <ICON_FILE> };
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO_ICON', $iconContent);

		open ICON_FILE, "< ".$cdlRootPath."/design/images/audio_help.svg";
		$iconContent = do { local $/; <ICON_FILE> };
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO_HELP_ICON', $iconContent);
	} else {
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO_ACTIONS', "");
	}

	open ICON_FILE, "< ".$cdlRootPath."/design/images/close_icon.svg";
	$iconContent = do { local $/; <ICON_FILE> };
	$pageContent = setValueInTemplateString($pageContent, 'GALLERY_CLOSE_ICON', $iconContent);

	open ICON_FILE, "< ".$cdlRootPath."/design/images/arrow_left.svg";
	$iconContent = do { local $/; <ICON_FILE> };
	$pageContent = setValueInTemplateString($pageContent, 'GALLERY_PREV_ICON', $iconContent);

	open ICON_FILE, "< ".$cdlRootPath."/design/images/arrow_right.svg";
	$iconContent = do { local $/; <ICON_FILE> };
	$pageContent = setValueInTemplateString($pageContent, 'GALLERY_NEXT_ICON', $iconContent);

	$pageContent = setValueInTemplateString($pageContent, 'EMBEDDED_URL', $embeddedMode);

	my $backgroundColor = loadFromSession($session, 'backgroundColor');
	my $fontColor = loadFromSession($session, 'fontColor');
	my $linkColor = loadFromSession($session, 'linkColor');
	$backgroundColor = $backgroundColor ? $backgroundColor : '000000';
	$fontColor = $fontColor ? $fontColor : 'FFFFFF';
	$linkColor = $linkColor ? $linkColor : $fontColor;
	my $letterSpacing = loadFromSession($session, 'letterSpacing');
	my $wordSpacing = loadFromSession($session, 'wordSpacing');
	my $lineHeight = loadFromSession($session, 'lineHeight');
	$letterSpacing = $letterSpacing ? $letterSpacing : '1';
	$wordSpacing = $wordSpacing ? $wordSpacing : '1';
	$lineHeight = $lineHeight ? $lineHeight : '1';
	$pageContent = setValueInTemplateString($pageContent, 'B_COLOR', $backgroundColor);
	$pageContent = setValueInTemplateString($pageContent, 'F_COLOR', $fontColor);
	$pageContent = setValueInTemplateString($pageContent, 'L_COLOR', $linkColor);
	$pageContent = setValueInTemplateString($pageContent, 'F_SIZE', $fontSize);
	$pageContent = setValueInTemplateString($pageContent, 'ICON_SIZE', 40+0.7*(($fontSize - 1)*20));
	$pageContent = setValueInTemplateString($pageContent, 'L_SPACING', $letterSpacing);
	$pageContent = setValueInTemplateString($pageContent, 'W_SPACING', $wordSpacing);
	$pageContent = setValueInTemplateString($pageContent, 'L_HEIGHT', $lineHeight);
	if (isBigCursorNotAllowed()) {
		$fontSize = 1;
	}
	$pageContent = setValueInTemplateString($pageContent, 'F_SIZE_BROWSER_DEPENDS', $fontSize);

	my @now = localtime(time);
	$pageContent = setValueInTemplateString($pageContent, 'CURRENT_YEAR', 1900 + $now[5]);

	# Initialisation de l'entête et affichage de la page finale
	printPage($session, $contentType, $pageContent);
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;
