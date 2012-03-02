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
#	Exécution du script index principal
#
# Paramètres:
#	
sub processIndexPage
{
	# Création de l'objet CGI
	my $cgi = new CGI;

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

	# Chargement de la configuration
	my ($siteLabel, $siteDefaultLanguage, $positionLocation, $activateJavascript, $parseJavascript, $activateFrames, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $enableAudio, $activateAudio, $siteDomainNames, $homePageUri, $pagesNoCache, $cacheExpiry) = getAllConfigs($session, $siteId);

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
	$pageUriWithoutServerName =~ s/^([^\/]*)\///sgi;
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
		renderCachedPage($pageContent, $pageContentFile, $session, $siteId, $pageUri, $contentType, $enableAudio, $activateAudio, %requestParameters);
	}

	if ($siteDomainNames and $urlToParse =~ m/^https?:\/\/($siteDomainNames)/si) {

		# On effectue la requête HTTP en récupérant la réponse
		my $response = sendRequest($requestMethod, $urlToParse, $siteId, $siteRootUrl, $session, %requestParameters);

		# Récupération du type d'encodage des caractères reçus dans la réponse HTTP
		my $contentType = getContentTypeFromHttpResponseHeader($response);

		# Si le code retour est succès, on traite le contenu de la réponse
		if ($response->is_success) {
			# Si le contenu est de type texte/HTML, on le parse et on l'affiche,
			# sinon on redirige vers la page de gestion des documents
			if ($contentType =~ m/text\/html/si) {
				my $htmlCode = getCleanedPageContent($response, $contentType);

				renderIndexPage($htmlCode, $session, $siteId, $siteLabel, $siteDefaultLanguage, $homePageUri, $requestMethod, $secure, $urlToParse, $pageUri, $siteRootUrl, $pagePath, $contentType, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $enableAudio, $activateAudio, %requestParameters);
			} else {
				redirectToDocumentPage($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $response, $urlToParse, $siteRootUrl, $pageUri, $pagePath, $secure, %requestParameters);
			}
		} elsif ($response->is_redirect) {
			redirectToAnotherPage($cgi, $session, $siteId, $response, $siteRootUrl, $pageUri, $pagePath, $secure);
		} elsif ($response->code eq "401") {
			redirectToProtectedAccessLogin($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $response, $urlToParse, $secure, %requestParameters);
		} else {
			# Affichage de la page de signelement d'une erreur au niveau de la requête HTTP vers le site distant
			renderErrorPage($session, $siteId, $siteDefaultLanguage, $activateAudio, $requestMethod, $response, $urlToParse, %requestParameters);
		}
	} else {
		accessAnotherSite($cgi, $session, $siteId, $siteDefaultLanguage, $urlToParse, $secure, %requestParameters);
	}
}

# Function: renderErrorPage
#	Affichage de la page de signelement d'une erreur au niveau de la requête HTTP vers le site distant
#
# Paramètres:
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$siteDefaultLanguage - Langue par défaut du site
#	$requestMethod - méthode d'envoi de la requête (GET, POST ou HEAD)
#	$response - objet réponse HTTP d'où le code et l'intitulé de l'erreur
#	$urlToParse - URL de la page en erreur
#	%requestParameters - paramètres à coller à l'URL
sub renderErrorPage #($session, $siteId, $siteDefaultLanguage, $activateAudio, $requestMethod, $response, $urlToParse, %requestParameters)
{
	my ($session, $siteId, $siteDefaultLanguage, $activateAudio, $requestMethod, $response, $urlToParse, %requestParameters) = @_;

	# Chargement de la template d'erreur
	my $errorPageTemplateString = loadConfig($cdlTemplatesPath."error_page.html");

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'SITE_ID', $siteId);

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'LANGUAGE', $siteDefaultLanguage);

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'ERROR_NUMBER', $response->code);

	# Ajout des paramètres éventuels
	if ($requestMethod =~ m/post/si) {
		$urlToParse = putParametersInUrlForHtml($urlToParse, %requestParameters);
	}
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'PAGE_ON_ERROR_URL', $urlToParse);

	my $cdlPageUrl = $ENV{'REQUEST_URI'};
	my $previousPageUrl = $ENV{'REQUEST_URI'};
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
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'JS_LIBRARY', getPartOfTemplateString($errorPageTemplateString, 'JS_LIBRARY'));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', getPartOfTemplateString($errorPageTemplateString, 'JS_AUDIO_FILE_INCLUDE'));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO', getPartOfTemplateString($errorPageTemplateString, 'AUDIO'));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'MP3_PLAYER_WIDTH', 250+3.4*(($fontSize - 1)*20));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'MP3_PLAYER_HEIGHT', 50+0.7*(($fontSize - 1)*20));
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'DIV_MP3_PLAYER_HEIGHT', 40+0.7*(($fontSize - 1)*20));
		# Mettre le nom de domaine pour complèter les URLs absolues
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'SERVER_NAME', $ENV{'SERVER_NAME'});
	} else {
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'JS_LIBRARY', "");
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', "");
		$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'AUDIO', "");
	}

	my $backgroundColor = loadFromSession($session, 'backgroundColor');
	my $fontColor = loadFromSession($session, 'fontColor');
	$backgroundColor = $backgroundColor ? $backgroundColor : '000000';
	$fontColor = $fontColor ? $fontColor : 'FFFFFF';

	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'B_COLOR', $backgroundColor);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'F_COLOR', $fontColor);
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'F_SIZE', $fontSize);
	if (isBigCursorNotAllowed()) {
		$fontSize = 1;
	}
	$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'F_SIZE_BROWSER_DEPENDS', $fontSize);

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
#	%requestParameters - paramètres passés à la page
sub renderIndexPage #($htmlCode, $session, $siteId, $siteDefaultLanguage, $homePageUri, $requestMethod, $secure, $urlToParse, $pageUri, $siteRootUrl, $pagePath, $contentType, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, %requestParameters)
{
	my ($htmlCode, $session, $siteId, $siteLabel, $siteDefaultLanguage, $homePageUri, $requestMethod, $secure, $urlToParse, $pageUri, $siteRootUrl, $pagePath, $contentType, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $enableAudio, $activateAudio, %requestParameters) = @_;

	# Chargement de la template principale de la page
	my $entirePageTemplateString = loadConfig($cdlTemplatesPath."entire_page.html");

	# Identifiant du site
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'SITE_ID', $siteId);

	# Langue de la page
	my $pageLanguage = getDocumentLanguage($htmlCode, $siteDefaultLanguage);

	# Récupération de l'URL de base d'où extraire le chemin des liens relatifs de la page
	my $baseHref = getBaseHref($htmlCode);
	if ($baseHref) {
		$baseHref =~ s/^($siteRootUrl(\/(.*))?)$/$pagePath = $2; $1/segi;
	}

	# Mise à jour de l'attribut href de la balise base en mettant l'entête de base de tous les liens http://{CDL_SERVER_NAME}/le-filtre/{SITE_ID}/{SITE_SERVER_NAME}
	my $siteServerName = $siteRootUrl;
	$siteServerName =~ s/^https?:\/\///sgi;
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BASE_HREF', "http".$secure."://".$ENV{'SERVER_NAME'}."/le-filtre".($secure eq "s" ? "-https" : "")."/".$siteId."/".$siteServerName."/");

	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'LANGUAGE', $pageLanguage);

	# Parse et remplissage du head
	($htmlCode, $entirePageTemplateString) = parseAllHead($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $contentType, $activateJavascript, $parseJavascript, $siteId);

	# Chargement de la template de cadre
	my $cadreTemplateString = loadConfig($cdlTemplatesPath."cadre.html");

	if (positionTagExists($htmlCode)) {
		# Parse de la balise position
		($htmlCode, $entirePageTemplateString) = parsePosition($htmlCode, $siteRootUrl, $pagePath, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $entirePageTemplateString, $cadreTemplateString, $siteId, $pageUri);

		# Chargement de la template de retour vers l'accueil
		my $backHomeTemplateString = loadConfig($cdlTemplatesPath."back_home_link.html");

		# Affichage du lien Retour à l'accueil
		$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BACK_HOME_LINK', setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', setValueInTemplateString($backHomeTemplateString, 'HOME_URL', parseLinkHrefAttribute($homePageUri, $pagePath, $siteId, $siteRootUrl, $pageUri))));
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

	# Parse et remplissage des navs
	($htmlCode, $entirePageTemplateString) = parseAllNavs($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $entirePageTemplateString, $cadreTemplateString);

	# Parse et remplissage des blocs
	($htmlCode, $entirePageTemplateString) = parseAllBlocs($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $entirePageTemplateString, $cadreTemplateString);

	# Gestion des attributs du body (listeners javascript et attributs génériques)
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BODY_ATTRIBUTES', $activateJavascript ? getBodyAttributes($htmlCode, $parseJavascript) : "");

	# Sauvegarder du contenu de la page dans un fichier
	$urlToParse =~ s/^https?:\/\///segi;
	# Ajout des paramètres éventuels
	if ($requestMethod =~ m/post/si) {
		$urlToParse = putParametersInUrl($urlToParse, %requestParameters);
	}
	my $pageContentFile = savePageContentInCache($requestMethod, $urlToParse, $entirePageTemplateString, loadFromSession($session, 'positionLocation')."_".loadFromSession($session, 'activateJavascript')."_".loadFromSession($session, 'activateFrames')."_".loadFromSession($session, 'displayImages')."_".loadFromSession($session, 'displayObjects')."_".loadFromSession($session, 'displayApplets')."_".loadFromSession($session, 'parseTablesToList'));

	renderCachedPage($entirePageTemplateString, $pageContentFile, $session, $siteId, $pageUri, $contentType, $enableAudio, $activateAudio, %requestParameters);
}

# Function: renderCachedPage
#	Affichage du rendu final de la page parsée récupérée du cache ou mise en cache
#
# Paramètres:
#	$pageContent - code HTML de la page finale
#	$pageContentFile - Nom du fichier de cache où le contenu de la page est stocké
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$pageUri - URI de la page en cours
#	$contentType - type de contenu et encodage de la page
#	$enableAudio - booléen indiquant si l'option audio activé pour ce site
#	$activateAudio - booléen indiquant si l'utilisateur a choisi de vocaliser les pages
#	%requestParameters - paramètres passés à la page
sub renderCachedPage #($pageContent, $pageContentFile, $session, $siteId, $pageUri, $contentType, $enableAudio, $activateAudio, %requestParameters)
{
	my ($pageContent, $pageContentFile, $session, $siteId, $pageUri, $contentType, $enableAudio, $activateAudio, %requestParameters) = @_;

	# Mettre les liens qui permettent d'aller modifier la personnalisation
	my $language = loadFromSession($session, 'language');
	my $contrast = loadFromSession($session, 'contrast');
	$language = $language ? $language : "fr";
	$contrast = $contrast ? $contrast : "bn";

	my $pageUriForHtml = $pageUri;
	$pageUriForHtml =~ s/&amp;/&/sgi;
	$pageUriForHtml =~ s/&/&amp;/sgi;
	$pageContent = setValueInTemplateString($pageContent, 'PERSONALIZATION_URL', $language."/".$contrast."/".$siteId."/".($requestMethod =~ m/post/si ? putParametersInUrlForHtml($pageUriForHtml, %requestParameters) : $pageUriForHtml));

	# Mettre le nom de ce fichier temporaire en parametre du lien vers le script de génération en audio
	$pageContent = setValueInTemplateString($pageContent, 'CONTENT_TO_READ_WITH_ACAPELA', $pageContentFile);

	my $fontSize = loadFromSession($session, 'fontSize');
	$fontSize = $fontSize ? $fontSize : '3';

	if ($activateAudio eq "1") {
		$pageContent = setValueInTemplateString($pageContent, 'JS_LIBRARY', getPartOfTemplateString($pageContent, 'JS_LIBRARY'));
		$pageContent = setValueInTemplateString($pageContent, 'JS_AUDIO_FILE_INCLUDE', getPartOfTemplateString($pageContent, 'JS_AUDIO_FILE_INCLUDE'));
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO', getPartOfTemplateString($pageContent, 'AUDIO'));
		$pageContent = setValueInTemplateString($pageContent, 'MP3_PLAYER_WIDTH', 250+3.4*(($fontSize - 1)*20));
		$pageContent = setValueInTemplateString($pageContent, 'MP3_PLAYER_HEIGHT', 50+0.7*(($fontSize - 1)*20));
		$pageContent = setValueInTemplateString($pageContent, 'DIV_MP3_PLAYER_HEIGHT', 40+0.7*(($fontSize - 1)*20));
		# Mettre le nom de domaine pour complèter les URLs absolues
		$pageContent = setValueInTemplateString($pageContent, 'SERVER_NAME', $ENV{'SERVER_NAME'});
	} else {
		$pageContent = setValueInTemplateString($pageContent, 'JS_LIBRARY', "");
		$pageContent = setValueInTemplateString($pageContent, 'JS_AUDIO_FILE_INCLUDE', "");
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO', "");
	}
	if ($enableAudio eq "1") {
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO_ACTIONS', getPartOfTemplateString($pageContent, 'AUDIO_ACTIONS'));
	} else {
		$pageContent = setValueInTemplateString($pageContent, 'AUDIO_ACTIONS', "");
	}

	my $backgroundColor = loadFromSession($session, 'backgroundColor');
	my $fontColor = loadFromSession($session, 'fontColor');
	$backgroundColor = $backgroundColor ? $backgroundColor : '000000';
	$fontColor = $fontColor ? $fontColor : 'FFFFFF';
	$pageContent = setValueInTemplateString($pageContent, 'B_COLOR', $backgroundColor);
	$pageContent = setValueInTemplateString($pageContent, 'F_COLOR', $fontColor);
	$pageContent = setValueInTemplateString($pageContent, 'F_SIZE', $fontSize);
	if (isBigCursorNotAllowed()) {
		$fontSize = 1;
	}
	$pageContent = setValueInTemplateString($pageContent, 'F_SIZE_BROWSER_DEPENDS', $fontSize);

	# Initialisation de l'entête et affichage de la page finale
	print $session->header('Content-type' => $contentType);
	print $pageContent;
	exit;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;