#!/usr/bin/perl

#########################################################################
# BEGIN COPYRIGHT, LICENSE AND WARRANTY NOTICE
# SOFTWARE NAME: Confort de lecture
# SOFTWARE RELEASE: 2.0.0
# COPYRIGHT NOTICE: Copyright (C) 2000-2007 GIE Confort de lecture (SQLI & HandicapZéro)
# SOFTWARE LICENSE: GNU General Public License v3
# NOTICE:
# This file is part of Confort de lecture.
#
# Confort de lecture is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# Confort de lecture is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Confort de lecture.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################

# File: index.pl
#	Script principal de traitement des pages HTML, et de centralisation des autres traitements

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use LWP::UserAgent;
use HTML::Entities;

use lib '../modules/includes';
use constants;
use general_utilities;
use session;
use config_manager;

use lib '../modules/general';
use page_head;
use general_html_utils;
use images_maps;
use applets;
use frames_iframes;
use javascript;
use links;
use forms;
use objects;
use tables;

use lib '../modules/cdl_tags';
use utils;
use bloc;
use nav;
use exclure;
use combobox_to_link;
use change_replace;
use position;


# Création de l'objet CGI
my $cgi = new CGI;

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Récupération des paramètres et de la méthode d'appel du script
my $httpMethod = $ENV{'REQUEST_METHOD'};

# Chargement de la configuration par défaut
my $defaultConfiguration = loadConfig($cdlSitesConfigPath."default.ini");
my $activateJavascript;
my $parseJavascript;
my $activateFrames;
my $displayImages;
my $displayObjects;
my $displayApplets;

# Génération de la table des hachage des paramètres
my @paramKeys = param;
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	if (param($paramKey)) {
		$requestParameters{$paramKey} = param($paramKey);
	}
}

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

# Récupération du paramètre id et de l'uri à parser
my ($siteId, $pageUri);
if ($httpMethod eq "GET") {
	$thisCdlUrl =~ s/^\/le\-filtre\/(.*?)(\/(.*?)(\?.*)?)?$/$siteId = urlDecode($1); $pageUri = urlDecode($3);/segi;
} elsif ($httpMethod eq "POST") {
	$thisCdlUrl =~ s/^\/le\-filtre\/(.*?)(\/(.*?)(\?.*)?)?$/$siteId = urlDecode($1); $pageUri = urlDecode($2);/segi;
}

# Détection d'erreurs au niveau de l'identifiant du site
if (!$siteId) {
	if (!param('cdlid')) {
		die "Aucun identifiant de site n'a été renseigné";
		exit;
	}
}
if (!existConfigDirectory($siteId)) {
	if (!param('cdlid')) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId;
		exit;
	}
	$siteId = param('cdlid');
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId;
		exit;
	}
}

# Inclusion du module extension général à tous les sites
require($cdlRootPath.$cdlSitesConfigPath."default.pm");

# Inclusion du module extension spécifique au site s'il y en a un
if (-e $cdlRootPath.$cdlSitesConfigPath.$siteId."/".$siteId.".pm") {
	require($cdlRootPath.$cdlSitesConfigPath.$siteId."/".$siteId.".pm");
}


# Si le paramètre id (identifiant du site qui correspond au répertoire du site) est renseigné, on traite ça comme le point d'entrée dans la veresion filtrée
if (param('cdlfirst')) {
	# Mettre les paramètres en session
	editInSession($session, 'fontColor', (param("cdlfc")) ? param("cdlfc") : "FFFFFF");
	editInSession($session, 'backgroundColor', (param("cdlbc")) ? param("cdlbc") : "000000");
	editInSession($session, 'fontSize', (param("cdlfs")) ? param("cdlfs") : "4");
	editInSession($session, 'activateJavascript', param("cdljs"));
	editInSession($session, 'activateFrames', param("cdlframes"));
	editInSession($session, 'displayImages', param("cdlimg"));
	editInSession($session, 'displayObjects', param("cdlobject"));
	editInSession($session, 'displayApplets', param("cdlapplet"));
	editInSession($session, 'parseTablesToList', param("cdtable"));
	editInSession($session, 'personalizationStyle', param("cdlstyle"));

	# Rediriger vers le script principal mais avec une url propre
	my $redirectUrl = "/le-filtre/".param('cdlid')."/".urlDecode(param("cdlurl"));

	# Envoyer le cookie de représentant la session fraichement créée
	my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
	print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
	
} else {
	my ($siteConfiguration, $siteDomainNames, $homePageUris, $activateJavascript, $parseJavascript, $activateFrames, $displayImages, $displayObjects, $displayApplets) = ("", "", "", "", "", "", "", "", "");

	# Chargement des paramètres du site
	my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
	
	# Récupérer la liste de tous les noms de domaine du site
	@siteDomainNames = split(/\t/, getValueForKey($siteConfiguration, 'siteDomainNames'));
	@homePageUris = split(/\t/, getValueForKey($siteConfiguration, 'homePageUris'));

	# Chargement des paramètres utilisateur
	$activateJavascript = loadFromSession($session, 'activateJavascript', param("cdljs"));
	$activateFrames = loadFromSession($session, 'activateFrames', param("cdlframes"));
	$displayImages = loadFromSession($session, 'displayImages', param("cdlimg"));
	$displayObjects = loadFromSession($session, 'displayObjects', param("cdlobject"));
	$displayApplets = loadFromSession($session, 'displayApplets', param("cdlapplet"));
	$parseTablesToList = loadFromSession($session, 'parseTablesToList', param("cdtable"));

	# Si un paramètre n'est pas renseigné, on met celui par défaut du site
	if ($activateJavascript eq "") {
		$activateJavascript = getValueForKey($siteConfiguration, 'activateJavascript');
	}
	if ($activateFrames eq "") {
		$activateFrames = getValueForKey($siteConfiguration, 'activateFrames');
	}
	if ($displayImages eq "") {
		$displayImages = getValueForKey($siteConfiguration, 'displayImages');
	}
	if ($displayObjects eq "") {
		$displayObjects = getValueForKey($siteConfiguration, 'displayObjects');
	}
	if ($displayApplets eq "") {
		$displayApplets = getValueForKey($siteConfiguration, 'displayApplets');
	}
	if ($parseTablesToList eq "") {
		$parseTablesToList = getValueForKey($siteConfiguration, 'parseTablesToList');
	}

	$parseJavascript = getValueForKey($siteConfiguration, 'parseJavascript');
	$siteLabel = getValueForKey($siteConfiguration, 'siteLabel');
	$siteDefaultLanguage = getValueForKey($siteConfiguration, 'defaultLanguage');

	# Si un paramètre n'est pas renseigné, on met celui par défaut
	if ($activateJavascript eq "") {
		$activateJavascript = getValueForKey($defaultConfiguration, 'activateJavascript');
	}
	if ($parseJavascript eq "") {
		$parseJavascript = getValueForKey($defaultConfiguration, 'parseJavascript');
	}
	if ($activateFrames eq "") {
		$activateFrames = getValueForKey($defaultConfiguration, 'activateFrames');
	}
	if ($displayImages eq "") {
		$displayImages = getValueForKey($defaultConfiguration, 'displayImages');
	}
	if ($displayObjects eq "") {
		$displayObjects = getValueForKey($defaultConfiguration, 'displayObjects');
	}
	if ($displayApplets eq "") {
		$displayApplets = getValueForKey($defaultConfiguration, 'displayApplets');
	}
	if ($parseTablesToList eq "") {
		$parseTablesToList = getValueForKey($defaultConfiguration, 'parseTablesToList');
	}
	if ($siteDefaultLanguage eq "") {
		$siteDefaultLanguage = getValueForKey($defaultConfiguration, 'defaultLanguage');
	}
	# On écrase la constante par défaut qui est générale à tous les sites si elle a été redéfinie dans la confiration du site
	if ($siteDefaultLanguage) {
		$defaultLanguage = $siteDefaultLanguage;
	}

	# Récupération de l'URI à parser pour en construire une URL
	$urlToParse = $pageUri;

	if (!$urlToParse) {
		$urlToParse = "/";
	}

	# Construction de l'URL racine du site
	my $siteRootUrl = "http://".$siteDomainNames[0];

	# Si l'URL n'est pas absolue on la met en absolue
	if ($urlToParse !~ m/^(\d|\w)*?:\/\//si) {
		$urlToParse = makeUrlAbsolute($urlToParse, $siteRootUrl, "");
	}

	my $pagePath;
	# Intialisation du chemin vers la page depuis la racine
	$urlToParse =~ s/^($siteRootUrl(.*)(\/(.*?)))/$pagePath = $2; $1/segi;


	# Si l'URL pointe vers le site parsée, on traite la page correspondante
	if ($urlToParse =~ m/^$siteRootUrl/si) {
		# Création de l'agent HTTP
		my $userAgent = initHTTPAgent;

		# Initialisation de la requête HTTP
		my $request = initRequest($httpMethod, $urlToParse, $cdlAccept, getReferer($ENV{'HTTP_REFERER'}, $siteRootUrl), %requestParameters);

		# Initialisation du cookie avant l'envoi de la requête
		$request = sendCookie($request, $session, $siteId);

		# Initialisation de l'authentification au site distant, s'il y a besoin (i.e. s'il y a des codes d'accès sont présents en session)
		my ($userLogin, $passwd, $realm) = (loadFromSession($session, 'cdl_'.$siteId.'_login'), loadFromSession($session, 'cdl_'.$siteId.'_passwd'), loadFromSession($session, 'cdl_'.$siteId.'_realm'));

		if ($userLogin) {
			my $uri = $request->uri;
			$userAgent->credentials($uri->host_port, $realm, $userLogin, $passwd);
		}

		# Envoi de la requête HTTP et réception de la réponse dans l'objet $response
		my $response = getResponse($userAgent, $request);

		# Récupération du cookie dans la réponse HTTP et sauvegarde dans la session
		getCookieInSession($response, $session, $siteId);

		# Récupération du type d'encodage des caractères reçus dans la réponse HTTP
		$contentType = $response->header('Content-type');

		# Si le code retour est succès, on traite le contenu de la réponse
		if ($response->is_success) {
			# Si le contenu est de type texte/HTML, on le parse et on l'affiche,
			# sinon on redirige vers la page de gestion des documents (document.pl)
			if ($contentType =~ /text\/html/) {
				# Récupération de l'encodage de caractères
				$contentType =~ s/((charset)=((\w|\d|\-)*?))([^\w\d\-]|$)/$charset = $3; $1/segi;

				# Initialisation de l'entête
				print $session->header('Content-type' => "text/html; charset=".$charset);

				# Récupération du contenu de la réponse
				$htmlCode = $response->content;

				# Chargement de la template principale de la page
				my $entirePageTemplateString = loadConfig($cdlTemplatesPath."entire_page.html");

				# Langue de la page
				$pageLanguage = getDocumentLanguage($htmlCode, $defaultLanguage);

				# Récupération de l'URL de base d'où extraire le chemin des liens relatifs de la page
				$baseHref = getBaseHref($htmlCode);
				if ($baseHref) {
					$baseHref =~ s/^($siteRootUrl\/(.*))/$pagePath = $2; $1/segi;
				}

				# Mise à jour de l'attribut href de la balise base en mettant l'entête de base de tous les liens http://{SERVER_NAME}/le-filtre/{ID_SITE}/
				$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BASE_HREF', "http://".$ENV{'SERVER_NAME'}."/le-filtre/".$siteId."/");

				$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'LANGUAGE', $pageLanguage);

				# Parse et remplissage du head
				($htmlCode, $entirePageTemplateString) = parseAllHead($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $siteId);

				# Chargement de la template de cadre
				$cadreTemplateString = loadConfig($cdlTemplatesPath."cadre.html");

				if (positionTagExists($htmlCode)) {
					# Parse de la balise position
					($htmlCode, $entirePageTemplateString) = parsePosition($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $entirePageTemplateString, $cadreTemplateString, $siteId);

					# Chargement de la template de retour vers l'accueil
					$backHomeTemplateString = loadConfig($cdlTemplatesPath."back_home_link.html");

					# Affichage du lien Retour à l'accueil
					$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BACK_HOME_LINK', setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', setValueInTemplateString($backHomeTemplateString, 'HOME_URL', parseLinkHrefAttribute($siteRootUrl.$homePageUris[0], $pagePath, $siteId))));
				} else {
					# Chargement de la template de titre du site
					my $siteTitleTemplateString = loadConfig($cdlTemplatesPath."site_title.html");

					# Remplissage de la template de titre du site avec le titre du site parsé
					$siteTitleTemplateString = setValueInTemplateString($siteTitleTemplateString, 'SITE_TITLE', $siteLabel ? $siteLabel : "Accueil : ".$siteId);

					# Remplissage de la template générale avec le titre de la page
					$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'PAGE_TOP', setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', $siteTitleTemplateString)."\n");
					
					# On remplace par rien l'emplacement du lien retour vers la page d'accueil
					$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BACK_HOME_LINK', "");
				}

				# Parse et remplissage des navs
				($htmlCode, $entirePageTemplateString) = parseAllNavs($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $entirePageTemplateString, $cadreTemplateString);

				# Parse et remplissage des blocs
				($htmlCode, $entirePageTemplateString) = parseAllBlocs($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $entirePageTemplateString, $cadreTemplateString);

				# Chargement de la template de ComboToLink
				$comboToLinkTemplateString = loadConfig($cdlTemplatesPath."combobox_to_link.html");

				# Gestion des balises CDL ComboToLink
				$entirePageTemplateString = parseAllComboToLinks($entirePageTemplateString, $pagePath, $comboToLinkTemplateString, $siteId);

				# Gestion des attributs du body (listeners javascript et attributs génériques)
				$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'BODY_ATTRIBUTES', $activateJavascript ? getBodyAttributes($htmlCode, $parseJavascript) : "");

				# Mettre le lien qui permets d'aller modifier la personalisation des styles
				$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'STYLE_PERSONALIZATION_LINK', "/style_personalization/parametrage.php?id=".$siteId."&amp;p=".urlEncode(putParametersInUrl($pageUri, %requestParameters))."&amp;b=".loadFromSession($session, 'backgroundColor')."&amp;f=".loadFromSession($session, 'fontColor')."&amp;s=".loadFromSession($session, 'fontSize')."&amp;js=".loadFromSession($session, 'activateJavascript')."&amp;frame=".loadFromSession($session, 'activateFrames')."&amp;img=".loadFromSession($session, 'displayImages')."&amp;object=".loadFromSession($session, 'displayObjects')."&amp;applet=".loadFromSession($session, 'displayApplets')."&amp;table=".loadFromSession($session, 'parseTablesToList')."&amp;style=".loadFromSession($session, 'personalizationStyle'));

				# Affichage de la page finale;
				print $entirePageTemplateString;
				exit;
			} else {
				# On récupère plutôt le type mime à partir de son contenu (les premiers octets du fichier)
				# pour éviter les informations incomplètes du Content-type du site distant.
				$contentType = getDocumentContentType($response->content, $session, $siteId, 1);

				$contentType =~ s/(.*?)\/(.*?)(;|$)(.*)/$1\-$2/sgi;
				$urlToParse =~ s/^$siteRootUrl\/?//segi;

				# On redirige vers la page proposition de téléchargement du document
				my $redirectUrl = "/document/".$siteId."/".$contentType."/".$httpMethod."/".$defaultLanguage."/cdl-url/".$urlToParse;

				# Ajout des paramètres éventuels
				$redirectUrl = putParametersInUrl($redirectUrl, %requestParameters);

				my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
				print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
				exit;
			}
		} elsif ($response->code eq "302") {
			# On récupère l'url vers laquelle on redirige dans l'entête Location
			my $redirectUrl = $response->header("Location");

			# Transformation de l'URL pour rester dans CDL
			my $redirectUrl = "/le-filtre/".$siteId."/".parseLinkHrefAttribute($redirectUrl, $pagePath, $siteId);

			my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
			print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
			exit;
		} elsif ($response->code eq "401") {
			# On récupère dans les entêtes de la réponse le paramètre realm indispensable pour l'authentification
			my $wwwAthentificate = $response->header('WWW-Authenticate');
			my $realm;
			$wwwAthentificate =~ s/\s(realm)\s*=\s*\"(.*?)\"/$realm = $2;/segi;
			# Sauvegarde en session du paramètre realm
			editInSession($session, 'cdl_'.$siteId.'_realm', $realm);

			$urlToParse =~ s/^$siteRootUrl\/?//segi;

			# On redirige vers la page d'authentification au site
			my $redirectUrl = "/acces-protege/".$siteId."/".$httpMethod."/".$defaultLanguage."/cdl-url/".$urlToParse;

			$redirectUrl = putParametersInUrl($redirectUrl, %requestParameters);

			my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
			print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
			exit;
		} else {
			# Affichage de la page de signelement d'une erreur au niveau de la requête HTTP vers le site distant

			# Chargement de la template d'erreur
			my $errorPageTemplateString = loadConfig($cdlTemplatesPath."error_page.html");

			$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'LANGUAGE', $defaultLanguage);

			$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'ERROR_NUMBER', $response->code);
			$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'ERROR_CODE', $response->status_line);
			$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'PAGE_ON_ERROR_URL', putParametersInUrl($urlToParse, %requestParameters));
			$errorPageTemplateString = setValueInTemplateString($errorPageTemplateString, 'CDL_PAGE_URL', $ENV{'REQUEST_URI'});

			print $session->header('Content-type' => "text/html; charset=ISO-8859-1");
			print $errorPageTemplateString;
			exit;
		}
	} else {
		# On teste si le site est pris en compte par CDL
		my $siteDomain = "";
		$urlToParse =~ s/(http:\/\/(.*?)(\/(.*)|$))/$siteDomain = $2; $pageUri = $4; $1/segi;

		$siteId = getSiteFromDomain($siteDomain);

		# Si le site existe, on redirige vers ce script mais avec le bon siteId et la bonne uri
		if ($siteId) {
			my $redirectUrl = "/le-filtre/".$siteId."/".urlDecode($pageUri);

			$redirectUrl = putParametersInUrl($redirectUrl, %requestParameters);

			print $cgi->redirect($redirectUrl);
			exit;
		}

		# On redirige vers la page de sortie de CDL vers un autre site
		my $redirectUrl = "/sortie/".$defaultLanguage."/".$urlToParse;

		$redirectUrl = putParametersInUrl($redirectUrl ,%requestParameters);

		print $cgi->redirect($redirectUrl);
		exit;
	}
}