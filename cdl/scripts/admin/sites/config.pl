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

# File: config.pl
#	Script de gestion de l'administration des sites

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);

use File::Path;

use lib '../../../modules/includes';
use constants;
use general_utilities;
use config_manager;


# Création de l'objet CGI
my $cgi  = new CGI;

# Chargement de la template principale de l'interface de configuration
$configPageTemplateString = loadConfig($cdlTemplatesPath."config.html");

# Génération de la table des hachage des paramètres
my @paramKeys = param;
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	$requestParameters{$paramKey} = param($paramKey);
}

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;


# Affichage du formulaire d'ajout d'un site
if ($thisCdlUrl =~ m/^\/admin\/create(\?.*?)?$/si) {
	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Ajout d'un nouveau site");

	# Récupération de la partie du formulaire d'édition
	my $formTemplateString = getPartOfTemplateString($configPageTemplateString, 'EDIT_FORM');

	# Mettre l'identifiant du site à créer
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID', "create");

	# On rajoute le champ correspondant à l'identifiant du site à créer
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_FIELD', getPartOfTemplateString($configPageTemplateString, 'SITE_ID_FIELD'));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_TITLE', "");

	# Mettre l'identifiant du site saisi déjà qui est reçu en paramètre. Si c'est la première fois, il est vide
	my $siteId = cleanIllegalChars($requestParameters{'siteId'});
	$siteId =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_VALUE', $siteId);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAIN_NAME', $requestParameters{'siteDomainName'});
	# Aucun nom de domaine au départ => liste vide
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAINE_NAMES_LIST', "");

	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URI', $requestParameters{'homePageUri'});
	# Aucun URI de page d'accueil au départ => liste vide
	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URIS_LIST', "");

	# Pour chacun des paramètres de configuration suivants, on teste si on revient du formulaire à cause d'une erreur, on met la bonne valeur de configuration
	if (!$requestParameters{'activateJavascript'} or $requestParameters{'activateJavascript'} eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', "");
	}

	if (!$requestParameters{'parseJavascript'} or $requestParameters{'parseJavascript'} eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', "");
	}

	if (!$requestParameters{'activateFrames'} or $requestParameters{'activateFrames'} eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', "");
	}

	if (!$requestParameters{'displayImages'} or $requestParameters{'displayImages'} eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', "");
	}

	if (!$requestParameters{'displayObjects'} or $requestParameters{'displayObjects'} eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', "");
	}

	if (!$requestParameters{'displayApplets'} or $requestParameters{'displayApplets'} eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', "");
	}

	if (!$requestParameters{'parseTablesToList'} or $requestParameters{'parseTablesToList'} eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', "");
	}

	my $siteLabel = cleanIllegalChars($requestParameters{'siteLabel'});
	$siteLabel =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LABEL', $siteLabel);

	my $defaultLanguage = cleanIllegalChars($requestParameters{'defaultLanguage'});
	$defaultLanguage =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'DEFAULT_LANGUAGE', $defaultLanguage);

	my $logo = cleanIllegalChars($requestParameters{'logo'});
	$logo =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LOGO', $logo);
	$formTemplateString = setValueInTemplateString($formTemplateString, 'LOGO_IMG', $requestParameters{'logo'} ? getPartOfTemplateString($formTemplateString, 'LOGO_IMG') : "");

	# Affichage des messages d'erreur à l'ajout
	if (param('m') eq "2") {
		# Aucun identifiant renseigné
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">Veuillez renseigner un identifiant pour le site</div><br />");
	} elsif (param('m') eq "3") {
		# Identifiant saisi existe déjà
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">L'identifiant que vous avez renseigné existe déjà</div><br />");
	} elsif (param('m') eq "5") {
		# Utilisation de caractères non permis
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">L'identifiant que vous avez renseigné n'est pas au bon format</div><br />");
	} else {
		# Aucune erreur
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "");
	}

	# On vide la partie de la template réservée à la page de liste
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# On met à jour dans la template tout le formulaire ainsi rempli
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', $formTemplateString);

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Ajout du nouveau site
if ($thisCdlUrl =~ m/^\/admin\/edit\/create(\?m=\d&|\?|&)?(.*?)$/si) {
	# Récupération de l'identifiant du site
	my $siteId = $requestParameters{'siteId'};

	$parametersString = $2;

	# Détection erreurs au niveau de l'identifiant du site
	if ($siteId =~ m/[^a-z\d\-_\.]/si) {
		# Erreur de caractère()s illégal(aux) dans l'identifiant
		print $cgi->redirect("/admin/create?m=5&".$parametersString);
		exit;
	}
	if (!$siteId) {
		# Aucun identifiant n'a été renseigné
		print $cgi->redirect("/admin/create?m=2&".$parametersString);
		exit;
	}
	if (existConfigDirectory($siteId)) {
		# L'identifiant spécifié existe déjà
		print $cgi->redirect("/admin/create?m=3&".$parametersString);
		exit;
	}

	# Création et initialisation du site
	createSiteConfig($siteId);

	# Chargement des paramètres de configuration du site qui vient d'être créé
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Mise à jour des valeurs de configuration spécifiées par l'administrateur
	if (param('valider') or param('ajouterSiteDomainNames') or param('ajouterHomePageUris')) {
		if ($requestParameters{'activateJavascript'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'activateJavascript', $requestParameters{'activateJavascript'});
		}
		if ($requestParameters{'parseJavascript'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'parseJavascript', $requestParameters{'parseJavascript'});
		}
		if ($requestParameters{'activateFrames'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'activateFrames', $requestParameters{'activateFrames'});
		}
		if ($requestParameters{'displayImages'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'displayImages', $requestParameters{'displayImages'});
			}
		if ($requestParameters{'displayObjects'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'displayObjects', $requestParameters{'displayObjects'});
		}
		if ($requestParameters{'displayApplets'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'displayApplets', $requestParameters{'displayApplets'});
		}
		if ($requestParameters{'parseTablesToList'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'parseTablesToList', $requestParameters{'parseTablesToList'});
		}
		$siteConfig = setValueForKey($siteConfig, 'siteLabel', $requestParameters{'siteLabel'});
		$siteConfig = setValueForKey($siteConfig, 'defaultLanguage', $requestParameters{'defaultLanguage'});
		$siteConfig = setValueForKey($siteConfig, 'logo', $requestParameters{'logo'});

		# Vu qu'il n'y a pas encore de nom de domaine spécifié, on peut directement mettre celui passé en paramètre
		$siteConfig = setValueForKey($siteConfig, 'siteDomainNames', $requestParameters{'siteDomainName'});

		# Vu qu'il n'y a pas encore d'URI de page d'accueil spécifié, on peut directement mettre celle passée en paramètre
		$siteConfig = setValueForKey($siteConfig, 'homePageUris', $requestParameters{'homePageUri'});

		# On sauvegarde la configuration ainsi mise à jour
		saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);

		# On redirige vers la page de modification du site venant d'être créé
		print $cgi->redirect("/admin/site/".$siteId."?m=4");
	}
	exit;
}

# Affichage du formulaire de modification du site sélectionné
if ($thisCdlUrl =~ m/^\/admin\/site\/(.*?)(\?|$)/si) {
	# Récupération de l'identifiant du site à créer
	my $siteId = $1;

	# Détection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId;
		exit;
	}

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Modification du site : '".$siteId."'");

	# Récupération de la partie du formulaire d'édition
	my $formTemplateString = getPartOfTemplateString($configPageTemplateString, 'EDIT_FORM');

	# Chargement des paramètre de configuration du site
	$siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# On rajoute un titre correspondant à l'identifiant du site à modifier
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_FIELD', "");
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_TITLE', getPartOfTemplateString($configPageTemplateString, 'SITE_ID_TITLE'));

	# Mettre l'identifiant du site à modifier
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID', $siteId);


	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAIN_NAME', $requestParameters{'siteDomainName'});
	# Lister les valeurs des noms de domaine du site
	@domaineNameArray = split(/\t+/, getValueForKey($siteConfig, 'siteDomainNames'));

	# Génération de la liste à puce des noms de domaine
	$domaineNamesListString = @domaineNameArray ? "<ul>" : "";

	foreach $domainName (@domaineNameArray) {
		$domaineNamesListString .= "<li>".$domainName."&nbsp;<a href=\"/admin/delete/param/".$siteId."/siteDomainNames?paramValue=".urlEncode($domainName)."\" title=\"Supprimer le nom de domaine : ".$domainName."\"><img src='/admin/images/supprimer.png' alt=\"Supprimer le nom de domaine : ".$domainName."\" /></a></li>";
	}
	$domaineNamesListString .= @domaineNameArray ? "</ul>" : "";

	# Afficher dans la template la liste des noms de domaine récupérée du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAINE_NAMES_LIST', $domaineNamesListString);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URI', $requestParameters{'homePageUri'});
	# Lister les valeurs des URIs de la page d'acceuil
	@homePageUrisArray = split(/\t+/, getValueForKey($siteConfig, 'homePageUris'));

	# Génération de la liste à puce des URIs de la page d'accueil
	$homePageUrisListString = @homePageUrisArray ? "<ul>" : "";
	foreach $homePageUri (@homePageUrisArray) {
		$homePageUrisListString .= "<li>".$homePageUri."&nbsp;<a href=\"/admin/delete/param/".$siteId."/homePageUris?paramValue=".urlEncode($homePageUri)."\" title=\"Supprimer l'URI '".$homePageUri."' de la page d'accueil\"><img src='/admin/images/supprimer.png' alt=\"Supprimer l'URI ".$homePageUri." de la page d'accueil\"/></a></li>";
	}
	$homePageUrisListString .= @homePageUrisArray ? "</ul>" : "";

	# Afficher dans la template la liste des URIs de la page d'accueil récupérée du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URIS_LIST', $homePageUrisListString);

	# Récupération des paramètres de configuration du javascript
	$activateJavascript = getValueForKey($siteConfig, 'activateJavascript');
	if (!$activateJavascript or $activateJavascript eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', "");
	}

	$parseJavascript = getValueForKey($siteConfig, 'parseJavascript');
	if (!$parseJavascript or $parseJavascript eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', "");
	}

	# Récupération des paramètres de configuration des frames
	$activateFrames = getValueForKey($siteConfig, 'activateFrames');
	if (!$activateFrames or $activateFrames eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', "");
	}

	# Récupération des paramètres des medias
	$displayImages = getValueForKey($siteConfig, 'displayImages');
	if (!$displayImages or $displayImages eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', "");
	}

	$displayObjects = getValueForKey($siteConfig, 'displayObjects');
	if (!$displayObjects or $displayObjects eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', "");
	}

	$displayApplets = getValueForKey($siteConfig, 'displayApplets');
	if (!$displayApplets or $displayApplets eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', "");
	}

	# Récupération des paramètres des tables.
	$parseTablesToList = getValueForKey($siteConfig, 'parseTablesToList');
	if (!$parseTablesToList or $parseTablesToList eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', "");
	}

	# Récupération des paramètres : titre, langue, logo.
	$siteLabel = getValueForKey($siteConfig, 'siteLabel');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LABEL', $siteLabel);

	$defaultLanguage = getValueForKey($siteConfig, 'defaultLanguage');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'DEFAULT_LANGUAGE', $defaultLanguage);

	$logo = getValueForKey($siteConfig, 'logo');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LOGO', $logo);

	# Gestion des messages d'information
	if (param('m') eq "1") {
		# La modification s'est bien passée
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageOk\">La configuration a bien été mise à jour</div><br />");
	} elsif (param('m') eq "4") {
		# L'ajout s'est bien passée
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageOk\">Le site ".$siteId." a bien été créé</div><br />");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "");
	}

	# On vide la partie de la template réservée à la page de liste
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# On met à jour dans la template tout le formulaire ainsi rempli
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', $formTemplateString);

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Modification du site sélectionné
if ($thisCdlUrl =~ m/^\/admin\/edit\/(.*?)(\?.*)?$/si) {
	my $siteId = $1;

	# Détection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId;
		exit;
	}

	# Chargement des paramètre de configuration du site
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Mise à jour des valeurs de configuration spécifiées par l'administrateur
	if (param('valider') or param('ajouterSiteDomainNames') or param('ajouterHomePageUris')) {
		if ($requestParameters{'activateJavascript'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'activateJavascript', $requestParameters{'activateJavascript'});
		}
		if ($requestParameters{'parseJavascript'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'parseJavascript', $requestParameters{'parseJavascript'});
		}
		if ($requestParameters{'activateFrames'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'activateFrames', $requestParameters{'activateFrames'});
		}
		if ($requestParameters{'displayImages'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'displayImages', $requestParameters{'displayImages'});
			}
		if ($requestParameters{'displayObjects'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'displayObjects', $requestParameters{'displayObjects'});
		}
		if ($requestParameters{'displayApplets'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'displayApplets', $requestParameters{'displayApplets'});
		}
		if ($requestParameters{'parseTablesToList'} ne "") {
			$siteConfig = setValueForKey($siteConfig, 'parseTablesToList', $requestParameters{'parseTablesToList'});
		}
		$siteConfig = setValueForKey($siteConfig, 'siteLabel', $requestParameters{'siteLabel'});
		$siteConfig = setValueForKey($siteConfig, 'defaultLanguage', $requestParameters{'defaultLanguage'});
		$siteConfig = setValueForKey($siteConfig, 'logo', $requestParameters{'logo'});

		# Lister les valeurs du nom du domaine du site
		my $siteDomaineNames = getValueForKey($siteConfig, 'siteDomainNames');

		# Récupération du nom de domaine en paramètre
		my $siteDomainName = $requestParameters{'siteDomainName'};

		if ($siteDomainName) {
			# Echappement des caractères spéciaux d'expression régulière
			$siteDomainName =~ s/(\?|\/)/\\$1/sgi;
			# Suppression du nom de domaine s'il existe déjà
			$siteDomaineNames =~ s/(^|\t+)$siteDomainName(\t+|$)/$1.$2/segi;

			# Suppression des éventuelles tabulations en début et en fin de chaîne
			$siteDomaineNames =~ s/^\t*//sgi;
			$siteDomaineNames =~ s/\t*$//sgi;

			# Suppression du caractère d'échappement \ pour insertion
			$siteDomainName =~ s/\\(\?|\/)/$1/sgi;
			# Insertion du nouveau nom de domaine dans la chaîne des noms de domaine
			if (!$siteDomaineNames) {
				$siteDomaineNames = $siteDomainName;
			} else {
				$siteDomaineNames .= "\t".$siteDomainName;
			}

			# Mise à jour dans la chaîne contenant configuration du site, du paramètre siteDomainNames
			$siteConfig = setValueForKey($siteConfig, 'siteDomainNames', $siteDomaineNames);
		}

		# Lister les valeurs du nom du domaine du site
		$homePageUris = getValueForKey($siteConfig, 'homePageUris');

		# Récupération de l'URI de la page d'accueil en paramètre
		my $homePageUri = $requestParameters{'homePageUri'};

		if ($homePageUri) {
			# Echappement des caractères spéciaux d'expression régulière
			$homePageUri =~ s/(\?|\/)/\\$1/sgi;
			# Suppression de l'URI si elle existe déjà
			$homePageUris =~ s/(^|\t+)$homePageUri(\t+|$)/$1.$2/segi;

			# Suppression des éventuelles tabulations en début et en fin de chaîne
			$homePageUris =~ s/^\t*//sgi;
			$homePageUris =~ s/\t*$//sgi;

			# Suppression du caractère d'échappement \ pour insertion
			$homePageUri =~ s/\\(\?|\/)/$1/sgi;
			# Insertion de la nouvelle URI de page d'accueil dans la chaîne des URIs
			if (!$homePageUris) {
				$homePageUris = $homePageUri;
			} else {
				$homePageUris .= "\t".$homePageUri;
			}

			# Mise à jour dans la chaîne contenant configuration du site, du paramètre homePageUris
			$siteConfig = setValueForKey($siteConfig, 'homePageUris', $homePageUris);
		}

		# Sauvegarder la config dans le fichier .ini
		saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);
	}

	# Redirection vers le formulaire de modification du site, avec un message d'information pour notifier le bon déroulement de la modification
	print $cgi->redirect("/admin/site/".$siteId."?m=1");
	exit;
}

# Suppression d'un paramètre un item dans un paramètre de configuration
if ($thisCdlUrl =~ m/^\/admin\/delete\/param\/(.*?)\/(.*?)\/?\?(.*)$/si) {
	# Récupération de l'identifiant du site à traiter
	my $siteId = $1;

	# Détection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId;
		exit;
	}

	# Récupération du nom de paramètre de configuration à modifier
	my $configKey = $2;
	# La valeur de la partie du paramètre à supprimer
	my $configValuePart = urlDecode(param('paramValue'));

	# Chargement des paramètre de configuration du site
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Lister les valeurs du paramètre
	my $configValue = getValueForKey($siteConfig, $configKey);

	# Echappement de caractères d'expression régulière
	$configValuePart =~ s/(\\|\?|\/|\||\.|\*|\(|\)|\[|\]|\{|\}|\+|\-|\^|\$)/\\$1/sgi;

	# Suppression de la partie demandée
	$configValue =~ s/(^|\t+)$configValuePart(\t+|$)/$1.$2/segi;

	# Suppression des éventuelles tabulations en début et en fin de chaîne
	$configValue =~ s/^\t*//sgi;
	$configValue =~ s/\t*$//sgi;

	# Mise à jour du paramètre
	$siteConfig = setValueForKey($siteConfig, $configKey, $configValue);

	# Sauvegarder la config dans le fichier .ini
	saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);

	# Redirection vers le formulaire de modification du site, avec un message d'information pour notifier le bon déroulement de la modification
	print $cgi->redirect("/admin/site/".$siteId."?m=1");
	exit;
}

# Lister les sites pris en compte par CDL
if ($thisCdlUrl =~ m/^\/admin\/sites(\?.*?)?$/si) {
	# Récupération de la liste des répertoires correspondant aux identifiants
	my @sites = getSitesIds;

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Liste des sites (".@sites.")");

	# Affichage du message d'information pour le bon déroulement de la suppression d'un site
	my $sitesListString = $requestParameters{'m'} eq "6" ? "<div class=\"messageOk\">Le site a bien été supprimé</div><div class=\"clearBoth\"></div><br />" : "";

	# Génération de la chaîne HTML correspondant à la liste à puce des sites
	$sitesListString .= @sites ? "<ul>" : "";
	foreach my $site (@sites) {
		$sitesListString .= "<li><a href='/admin/site/".$site."'>".$site."</a>&nbsp;<a href=\"/admin/delete/site/".$site."\" title=\"Supprimer le site : ".$site."\" onclick=\"if (confirm('Voulez vous vraiment supprimer le site ".$site." ?')) {window.location.href = '/admin/delete/site/".$site."'} return false;\"><img src='/admin/images/supprimer.png' alt=\"Supprimer le site : ".$site."\" /></a>&nbsp;<a href=\"/le-filtre/".$site."\" title=\"Visualiser le site : ".$site."\" target=\"_blank\"><img src='/admin/images/voir.gif' alt=\"Visualiser le site : ".$site."\" /></a></li>";
	}
	$sitesListString .= @sites ? "</ul>" : "";

	# Mise à jour dans la template pour afficher la liste des sites
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "<p><a href=\"/admin/create\" class=\"black\">Créer un site</a></p>".($sitesListString ? $sitesListString : "<p><strong>Aucun site n'a été créé.</strong></p>"));
	# Vider de la partie réservée au formulaire d'édition
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', "");

	# Affichage de la template finale
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Suppression d'un site
if ($thisCdlUrl =~ m/^\/admin\/delete\/site\/(.*?)$/si) {
	# Suppression récursive de tout le répertoire correspondant
	rmtree($cdlRootPath.$cdlSitesConfigPath.$1);

	# Redirection vers la page de liste avec un message d'information
	print $cgi->redirect("/admin/sites?m=6");
	exit;
}

# Si on passe ici, c'est qu'il y a eu une erreur de manipulation de l'URL appelée
print "Content-type: text/html\n\n";
print "<h1>requête inccorecte !</h1><a href=\"/admin/sites\">Retour à la liste des sites</a>";