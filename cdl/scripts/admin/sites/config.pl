#!/usr/bin/perl

#########################################################################
# BEGIN COPYRIGHT, LICENSE AND WARRANTY NOTICE
# SOFTWARE NAME: Confort de lecture
# SOFTWARE RELEASE: 2.0.0
# COPYRIGHT NOTICE: Copyright (C) 2000-2007 GIE Confort de lecture (SQLI & HandicapZ�ro)
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


# Cr�ation de l'objet CGI
my $cgi  = new CGI;

# Chargement de la template principale de l'interface de configuration
$configPageTemplateString = loadConfig($cdlTemplatesPath."config.html");

# G�n�ration de la table des hachage des param�tres
my @paramKeys = param;
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	$requestParameters{$paramKey} = param($paramKey);
}

# R�cup�ration de l'URL r��crite pour en extraire les informations n�cessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;


# Affichage du formulaire d'ajout d'un site
if ($thisCdlUrl =~ m/^\/admin\/create(\?.*?)?$/si) {
	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Ajout d'un nouveau site");

	# R�cup�ration de la partie du formulaire d'�dition
	my $formTemplateString = getPartOfTemplateString($configPageTemplateString, 'EDIT_FORM');

	# Mettre l'identifiant du site � cr�er
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID', "create");

	# On rajoute le champ correspondant � l'identifiant du site � cr�er
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_FIELD', getPartOfTemplateString($configPageTemplateString, 'SITE_ID_FIELD'));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_TITLE', "");

	# Mettre l'identifiant du site saisi d�j� qui est re�u en param�tre. Si c'est la premi�re fois, il est vide
	my $siteId = cleanIllegalChars($requestParameters{'siteId'});
	$siteId =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_VALUE', $siteId);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAIN_NAME', $requestParameters{'siteDomainName'});
	# Aucun nom de domaine au d�part => liste vide
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAINE_NAMES_LIST', "");

	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URI', $requestParameters{'homePageUri'});
	# Aucun URI de page d'accueil au d�part => liste vide
	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URIS_LIST', "");

	# Pour chacun des param�tres de configuration suivants, on teste si on revient du formulaire � cause d'une erreur, on met la bonne valeur de configuration
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

	# Affichage des messages d'erreur � l'ajout
	if (param('m') eq "2") {
		# Aucun identifiant renseign�
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">Veuillez renseigner un identifiant pour le site</div><br />");
	} elsif (param('m') eq "3") {
		# Identifiant saisi existe d�j�
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">L'identifiant que vous avez renseign� existe d�j�</div><br />");
	} elsif (param('m') eq "5") {
		# Utilisation de caract�res non permis
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">L'identifiant que vous avez renseign� n'est pas au bon format</div><br />");
	} else {
		# Aucune erreur
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "");
	}

	# On vide la partie de la template r�serv�e � la page de liste
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# On met � jour dans la template tout le formulaire ainsi rempli
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', $formTemplateString);

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Ajout du nouveau site
if ($thisCdlUrl =~ m/^\/admin\/edit\/create(\?m=\d&|\?|&)?(.*?)$/si) {
	# R�cup�ration de l'identifiant du site
	my $siteId = $requestParameters{'siteId'};

	$parametersString = $2;

	# D�tection erreurs au niveau de l'identifiant du site
	if ($siteId =~ m/[^a-z\d\-_\.]/si) {
		# Erreur de caract�re()s ill�gal(aux) dans l'identifiant
		print $cgi->redirect("/admin/create?m=5&".$parametersString);
		exit;
	}
	if (!$siteId) {
		# Aucun identifiant n'a �t� renseign�
		print $cgi->redirect("/admin/create?m=2&".$parametersString);
		exit;
	}
	if (existConfigDirectory($siteId)) {
		# L'identifiant sp�cifi� existe d�j�
		print $cgi->redirect("/admin/create?m=3&".$parametersString);
		exit;
	}

	# Cr�ation et initialisation du site
	createSiteConfig($siteId);

	# Chargement des param�tres de configuration du site qui vient d'�tre cr��
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Mise � jour des valeurs de configuration sp�cifi�es par l'administrateur
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

		# Vu qu'il n'y a pas encore de nom de domaine sp�cifi�, on peut directement mettre celui pass� en param�tre
		$siteConfig = setValueForKey($siteConfig, 'siteDomainNames', $requestParameters{'siteDomainName'});

		# Vu qu'il n'y a pas encore d'URI de page d'accueil sp�cifi�, on peut directement mettre celle pass�e en param�tre
		$siteConfig = setValueForKey($siteConfig, 'homePageUris', $requestParameters{'homePageUri'});

		# On sauvegarde la configuration ainsi mise � jour
		saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);

		# On redirige vers la page de modification du site venant d'�tre cr��
		print $cgi->redirect("/admin/site/".$siteId."?m=4");
	}
	exit;
}

# Affichage du formulaire de modification du site s�lectionn�
if ($thisCdlUrl =~ m/^\/admin\/site\/(.*?)(\?|$)/si) {
	# R�cup�ration de l'identifiant du site � cr�er
	my $siteId = $1;

	# D�tection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a �t� renseign�";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond � l'identifiant : ".$siteId;
		exit;
	}

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Modification du site : '".$siteId."'");

	# R�cup�ration de la partie du formulaire d'�dition
	my $formTemplateString = getPartOfTemplateString($configPageTemplateString, 'EDIT_FORM');

	# Chargement des param�tre de configuration du site
	$siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# On rajoute un titre correspondant � l'identifiant du site � modifier
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_FIELD', "");
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_TITLE', getPartOfTemplateString($configPageTemplateString, 'SITE_ID_TITLE'));

	# Mettre l'identifiant du site � modifier
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID', $siteId);


	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAIN_NAME', $requestParameters{'siteDomainName'});
	# Lister les valeurs des noms de domaine du site
	@domaineNameArray = split(/\t+/, getValueForKey($siteConfig, 'siteDomainNames'));

	# G�n�ration de la liste � puce des noms de domaine
	$domaineNamesListString = @domaineNameArray ? "<ul>" : "";

	foreach $domainName (@domaineNameArray) {
		$domaineNamesListString .= "<li>".$domainName."&nbsp;<a href=\"/admin/delete/param/".$siteId."/siteDomainNames?paramValue=".urlEncode($domainName)."\" title=\"Supprimer le nom de domaine : ".$domainName."\"><img src='/admin/images/supprimer.png' alt=\"Supprimer le nom de domaine : ".$domainName."\" /></a></li>";
	}
	$domaineNamesListString .= @domaineNameArray ? "</ul>" : "";

	# Afficher dans la template la liste des noms de domaine r�cup�r�e du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAINE_NAMES_LIST', $domaineNamesListString);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URI', $requestParameters{'homePageUri'});
	# Lister les valeurs des URIs de la page d'acceuil
	@homePageUrisArray = split(/\t+/, getValueForKey($siteConfig, 'homePageUris'));

	# G�n�ration de la liste � puce des URIs de la page d'accueil
	$homePageUrisListString = @homePageUrisArray ? "<ul>" : "";
	foreach $homePageUri (@homePageUrisArray) {
		$homePageUrisListString .= "<li>".$homePageUri."&nbsp;<a href=\"/admin/delete/param/".$siteId."/homePageUris?paramValue=".urlEncode($homePageUri)."\" title=\"Supprimer l'URI '".$homePageUri."' de la page d'accueil\"><img src='/admin/images/supprimer.png' alt=\"Supprimer l'URI ".$homePageUri." de la page d'accueil\"/></a></li>";
	}
	$homePageUrisListString .= @homePageUrisArray ? "</ul>" : "";

	# Afficher dans la template la liste des URIs de la page d'accueil r�cup�r�e du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URIS_LIST', $homePageUrisListString);

	# R�cup�ration des param�tres de configuration du javascript
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

	# R�cup�ration des param�tres de configuration des frames
	$activateFrames = getValueForKey($siteConfig, 'activateFrames');
	if (!$activateFrames or $activateFrames eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', "");
	}

	# R�cup�ration des param�tres des medias
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

	# R�cup�ration des param�tres des tables.
	$parseTablesToList = getValueForKey($siteConfig, 'parseTablesToList');
	if (!$parseTablesToList or $parseTablesToList eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', " checked=\"checked\"");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', "");
	}

	# R�cup�ration des param�tres : titre, langue, logo.
	$siteLabel = getValueForKey($siteConfig, 'siteLabel');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LABEL', $siteLabel);

	$defaultLanguage = getValueForKey($siteConfig, 'defaultLanguage');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'DEFAULT_LANGUAGE', $defaultLanguage);

	$logo = getValueForKey($siteConfig, 'logo');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LOGO', $logo);

	# Gestion des messages d'information
	if (param('m') eq "1") {
		# La modification s'est bien pass�e
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageOk\">La configuration a bien �t� mise � jour</div><br />");
	} elsif (param('m') eq "4") {
		# L'ajout s'est bien pass�e
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageOk\">Le site ".$siteId." a bien �t� cr��</div><br />");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "");
	}

	# On vide la partie de la template r�serv�e � la page de liste
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# On met � jour dans la template tout le formulaire ainsi rempli
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', $formTemplateString);

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Modification du site s�lectionn�
if ($thisCdlUrl =~ m/^\/admin\/edit\/(.*?)(\?.*)?$/si) {
	my $siteId = $1;

	# D�tection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a �t� renseign�";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond � l'identifiant : ".$siteId;
		exit;
	}

	# Chargement des param�tre de configuration du site
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Mise � jour des valeurs de configuration sp�cifi�es par l'administrateur
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

		# R�cup�ration du nom de domaine en param�tre
		my $siteDomainName = $requestParameters{'siteDomainName'};

		if ($siteDomainName) {
			# Echappement des caract�res sp�ciaux d'expression r�guli�re
			$siteDomainName =~ s/(\?|\/)/\\$1/sgi;
			# Suppression du nom de domaine s'il existe d�j�
			$siteDomaineNames =~ s/(^|\t+)$siteDomainName(\t+|$)/$1.$2/segi;

			# Suppression des �ventuelles tabulations en d�but et en fin de cha�ne
			$siteDomaineNames =~ s/^\t*//sgi;
			$siteDomaineNames =~ s/\t*$//sgi;

			# Suppression du caract�re d'�chappement \ pour insertion
			$siteDomainName =~ s/\\(\?|\/)/$1/sgi;
			# Insertion du nouveau nom de domaine dans la cha�ne des noms de domaine
			if (!$siteDomaineNames) {
				$siteDomaineNames = $siteDomainName;
			} else {
				$siteDomaineNames .= "\t".$siteDomainName;
			}

			# Mise � jour dans la cha�ne contenant configuration du site, du param�tre siteDomainNames
			$siteConfig = setValueForKey($siteConfig, 'siteDomainNames', $siteDomaineNames);
		}

		# Lister les valeurs du nom du domaine du site
		$homePageUris = getValueForKey($siteConfig, 'homePageUris');

		# R�cup�ration de l'URI de la page d'accueil en param�tre
		my $homePageUri = $requestParameters{'homePageUri'};

		if ($homePageUri) {
			# Echappement des caract�res sp�ciaux d'expression r�guli�re
			$homePageUri =~ s/(\?|\/)/\\$1/sgi;
			# Suppression de l'URI si elle existe d�j�
			$homePageUris =~ s/(^|\t+)$homePageUri(\t+|$)/$1.$2/segi;

			# Suppression des �ventuelles tabulations en d�but et en fin de cha�ne
			$homePageUris =~ s/^\t*//sgi;
			$homePageUris =~ s/\t*$//sgi;

			# Suppression du caract�re d'�chappement \ pour insertion
			$homePageUri =~ s/\\(\?|\/)/$1/sgi;
			# Insertion de la nouvelle URI de page d'accueil dans la cha�ne des URIs
			if (!$homePageUris) {
				$homePageUris = $homePageUri;
			} else {
				$homePageUris .= "\t".$homePageUri;
			}

			# Mise � jour dans la cha�ne contenant configuration du site, du param�tre homePageUris
			$siteConfig = setValueForKey($siteConfig, 'homePageUris', $homePageUris);
		}

		# Sauvegarder la config dans le fichier .ini
		saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);
	}

	# Redirection vers le formulaire de modification du site, avec un message d'information pour notifier le bon d�roulement de la modification
	print $cgi->redirect("/admin/site/".$siteId."?m=1");
	exit;
}

# Suppression d'un param�tre un item dans un param�tre de configuration
if ($thisCdlUrl =~ m/^\/admin\/delete\/param\/(.*?)\/(.*?)\/?\?(.*)$/si) {
	# R�cup�ration de l'identifiant du site � traiter
	my $siteId = $1;

	# D�tection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a �t� renseign�";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond � l'identifiant : ".$siteId;
		exit;
	}

	# R�cup�ration du nom de param�tre de configuration � modifier
	my $configKey = $2;
	# La valeur de la partie du param�tre � supprimer
	my $configValuePart = urlDecode(param('paramValue'));

	# Chargement des param�tre de configuration du site
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Lister les valeurs du param�tre
	my $configValue = getValueForKey($siteConfig, $configKey);

	# Echappement de caract�res d'expression r�guli�re
	$configValuePart =~ s/(\\|\?|\/|\||\.|\*|\(|\)|\[|\]|\{|\}|\+|\-|\^|\$)/\\$1/sgi;

	# Suppression de la partie demand�e
	$configValue =~ s/(^|\t+)$configValuePart(\t+|$)/$1.$2/segi;

	# Suppression des �ventuelles tabulations en d�but et en fin de cha�ne
	$configValue =~ s/^\t*//sgi;
	$configValue =~ s/\t*$//sgi;

	# Mise � jour du param�tre
	$siteConfig = setValueForKey($siteConfig, $configKey, $configValue);

	# Sauvegarder la config dans le fichier .ini
	saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);

	# Redirection vers le formulaire de modification du site, avec un message d'information pour notifier le bon d�roulement de la modification
	print $cgi->redirect("/admin/site/".$siteId."?m=1");
	exit;
}

# Lister les sites pris en compte par CDL
if ($thisCdlUrl =~ m/^\/admin\/sites(\?.*?)?$/si) {
	# R�cup�ration de la liste des r�pertoires correspondant aux identifiants
	my @sites = getSitesIds;

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Liste des sites (".@sites.")");

	# Affichage du message d'information pour le bon d�roulement de la suppression d'un site
	my $sitesListString = $requestParameters{'m'} eq "6" ? "<div class=\"messageOk\">Le site a bien �t� supprim�</div><div class=\"clearBoth\"></div><br />" : "";

	# G�n�ration de la cha�ne HTML correspondant � la liste � puce des sites
	$sitesListString .= @sites ? "<ul>" : "";
	foreach my $site (@sites) {
		$sitesListString .= "<li><a href='/admin/site/".$site."'>".$site."</a>&nbsp;<a href=\"/admin/delete/site/".$site."\" title=\"Supprimer le site : ".$site."\" onclick=\"if (confirm('Voulez vous vraiment supprimer le site ".$site." ?')) {window.location.href = '/admin/delete/site/".$site."'} return false;\"><img src='/admin/images/supprimer.png' alt=\"Supprimer le site : ".$site."\" /></a>&nbsp;<a href=\"/le-filtre/".$site."\" title=\"Visualiser le site : ".$site."\" target=\"_blank\"><img src='/admin/images/voir.gif' alt=\"Visualiser le site : ".$site."\" /></a></li>";
	}
	$sitesListString .= @sites ? "</ul>" : "";

	# Mise � jour dans la template pour afficher la liste des sites
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "<p><a href=\"/admin/create\" class=\"black\">Cr�er un site</a></p>".($sitesListString ? $sitesListString : "<p><strong>Aucun site n'a �t� cr��.</strong></p>"));
	# Vider de la partie r�serv�e au formulaire d'�dition
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', "");

	# Affichage de la template finale
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Suppression d'un site
if ($thisCdlUrl =~ m/^\/admin\/delete\/site\/(.*?)$/si) {
	# Suppression r�cursive de tout le r�pertoire correspondant
	rmtree($cdlRootPath.$cdlSitesConfigPath.$1);

	# Redirection vers la page de liste avec un message d'information
	print $cgi->redirect("/admin/sites?m=6");
	exit;
}

# Si on passe ici, c'est qu'il y a eu une erreur de manipulation de l'URL appel�e
print "Content-type: text/html\n\n";
print "<h1>requ�te inccorecte !</h1><a href=\"/admin/sites\">Retour � la liste des sites</a>";