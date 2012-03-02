#!/usr/bin/perl

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

# File: config.pl
#	Script de gestion de l'administration : sites, glossaire

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use File::Path;

use lib '../../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;


# Création de l'objet CGI
my $cgi  = new CGI;

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Chargement de la template principale de l'interface de configuration
$configPageTemplateString = loadConfig($cdlTemplatesPath."config.html");

# Génération de la table des hachage des paramètres
my @paramKeys = param;
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	my @paramValuesArray = param($paramKey);
	$requestParameters{$paramKey} = \@paramValuesArray;
}

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

my $cdlAdmin = loadFromSession($session, 'cdlAdmin');

# Gestion de l'identification
if (!$cdlAdmin and $thisCdlUrl !~ m/^\/admin\/login(\/action)?(\?.*?)?$/si) {
	print $cgi->redirect("/admin/login?m=8");
	exit;
}
if ($thisCdlUrl =~ m/^\/admin\/login(\?.*?)?$/si) {
	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Identification");

	# Récupération de la partie du formulaire d'identification
	my $formTemplateString = getPartOfTemplateString($configPageTemplateString, 'IDENT_FORM');

	if (param('m') eq "6") {
		# Identifiant et/ou mot de passe non renseigné
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">Veuillez renseigner l'identifiant et le mot de passe.</div><br>");
	}
	if (param('m') eq "7") {
		# identifiant et/ou mot de passe incorrect
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">Identifiant et/ou Mot de passe incorrect(s).</div><br>");
	}
	if (param('m') eq "8") {
		# identifiant et/ou mot de passe incorrect
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">Veuillez vous identifier pour accéder à l'administration.</div><br>");
	}

	$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "");

	# On met à jour dans la template tout le formulaire ainsi rempli
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'IDENT_FORM', $formTemplateString);
	# Vider de la partie réservée à la liste des sites
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# Vider de la partie réservée au formulaire d'édition
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', "");
	# On vide la partie de la template réservée au glossaire
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'GLOSSARY_FORM', "");

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}
if ($thisCdlUrl =~ m/^\/admin\/login\/action(\?.*?)?$/si) {
	if (!param('loginAdmin') or !param('passwdAdmin')) {
		print $cgi->redirect("/admin/login?m=6");
		exit;
	}

	my $encryptedIdentLine = param('loginAdmin').":".crypt(param('passwdAdmin'), param('passwdAdmin'));

	open(READER, '<', $cdlRootPath."/configuration/.htpasswd");
	my @encryptedIdentLines = <READER>;
	close(READER);

	if (grep(/$encryptedIdentLine/, @encryptedIdentLines) > 0) {
		editInSession($session, 'cdlAdmin', param('loginAdmin'));

		# Envoyer le cookie représentant la session
		my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
		print $cgi->header(-status=>"302 Moved", -location=>"/admin", -cookie=>$cookie);
	} else {
		print $cgi->redirect("/admin/login?m=7");
	}
	exit;
}

# Affichage du formulaire d'ajout d'un site
if ($thisCdlUrl =~ m/^\/admin\/sites\/create(\?.*?)?$/si) {
	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Ajout d'un nouveau site");

	# Récupération de la partie du formulaire d'édition d'un site
	my $formTemplateString = getPartOfTemplateString($configPageTemplateString, 'EDIT_FORM');

	# Mettre l'identifiant du site à créer
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID', "");
	$formTemplateString = setValueInTemplateString($formTemplateString, 'EDIT_ACTION', "create");

	# On rajoute le champ correspondant à l'identifiant du site à créer
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_FIELD', getPartOfTemplateString($configPageTemplateString, 'SITE_ID_FIELD'));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_TITLE', "");

	# Mettre l'identifiant du site saisi déjà qui est reçu en paramètre. Si c'est la première fois, il est vide
	my $siteId = $requestParameters{'siteId'}[0];
	$siteId =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_VALUE', $siteId);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAIN_NAME', $requestParameters{'siteDomainName'}[0]);
	# Aucun nom de domaine au départ => liste vide
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAINE_NAMES_LIST', "");

	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URI', $requestParameters{'homePageUri'}[0]);
	# Aucun URI de page d'accueil au départ => liste vide
	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URIS_LIST', "");

	# Pour chacun des paramètres de configuration suivants, on teste si on revient du formulaire à cause d'une erreur, on met la bonne valeur de configuration
	if (!$requestParameters{'positionLocation'}[0] or $requestParameters{'positionLocation'}[0] eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', "");
	}

	if ($requestParameters{'activateJavascript'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', "");
	}

	if (!$requestParameters{'parseJavascript'}[0] or $requestParameters{'parseJavascript'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', "");
	}

	if ($requestParameters{'activateFrames'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', "");
	}

	if ($requestParameters{'displayImages'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', "");
	}

	if (!$requestParameters{'displayObjects'}[0] or $requestParameters{'displayObjects'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', "");
	}

	if (!$requestParameters{'displayApplets'}[0] or $requestParameters{'displayApplets'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', "");
	}

	if ($requestParameters{'parseTablesToList'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', "");
	}

	my $siteLabel = $requestParameters{'siteLabel'}[0];
	$siteLabel =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LABEL', $siteLabel);

	my $defaultLanguage = $requestParameters{'defaultLanguage'}[0];
	$defaultLanguage =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'DEFAULT_LANGUAGE', $defaultLanguage);

	my $logo = $requestParameters{'logo'}[0];
	$logo =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LOGO', $logo);
	$formTemplateString = setValueInTemplateString($formTemplateString, 'LOGO_IMG', $requestParameters{'logo'}[0] ? getPartOfTemplateString($formTemplateString, 'LOGO_IMG') : "");

	# Affichage des messages d'erreur à l'ajout
	if (param('m') eq "2") {
		# Aucun identifiant renseigné
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">Veuillez renseigner un identifiant pour le site.</div><br>");
	} elsif (param('m') eq "3") {
		# Identifiant saisi existe déjà
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">L'identifiant que vous avez renseigné existe déjà.</div><br>");
	} elsif (param('m') eq "5") {
		# Utilisation de caractères non permis
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">L'identifiant que vous avez renseigné n'est pas au bon format.</div><br>");
	} else {
		# Aucune erreur
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "");
	}

	# On vide la partie de la template réservée à la page de liste
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# On met à jour dans la template tout le formulaire ainsi rempli
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', $formTemplateString);
	# On vide la partie de la template réservée au glossaire
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'GLOSSARY_FORM', "");
	# On vide la partie de la template réservée à l'identification
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'IDENT_FORM', "");

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Ajout du nouveau site
if ($thisCdlUrl =~ m/^\/admin\/sites\/create\-action(\?m=\d&|\?|&)?(.*?)$/si) {
	# Récupération de l'identifiant du site
	my $siteId = $requestParameters{'siteId'}[0];

	$parametersString = $2;

	# Détection erreurs au niveau de l'identifiant du site
	if ($siteId =~ m/[^a-z\d\-_\.]/si) {
		# Erreur de caractère()s illégal(aux) dans l'identifiant
		print $cgi->redirect("/admin/sites/create?m=5&".$parametersString);
		exit;
	}
	if (!$siteId) {
		# Aucun identifiant n'a été renseigné
		print $cgi->redirect("/admin/sites/create?m=2&".$parametersString);
		exit;
	}
	if (existConfigDirectory($siteId)) {
		# L'identifiant spécifié existe déjà
		print $cgi->redirect("/admin/sites/create?m=3&".$parametersString);
		exit;
	}

	# Création et initialisation du site
	createSiteConfig($siteId);

	# Chargement des paramètres de configuration du site qui vient d'être créé
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Mise à jour des valeurs de configuration spécifiées par l'administrateur
	if (param('valider') or param('ajouterSiteDomainNames') or param('ajouterHomePageUris')) {
		if ($requestParameters{'positionLocation'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'positionLocation', $requestParameters{'positionLocation'}[0]);
		}
		if ($requestParameters{'activateJavascript'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'activateJavascript', $requestParameters{'activateJavascript'}[0]);
		}
		if ($requestParameters{'parseJavascript'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'parseJavascript', $requestParameters{'parseJavascript'}[0]);
		}
		if ($requestParameters{'activateFrames'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'activateFrames', $requestParameters{'activateFrames'}[0]);
		}
		if ($requestParameters{'displayImages'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'displayImages', $requestParameters{'displayImages'}[0]);
			}
		if ($requestParameters{'displayObjects'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'displayObjects', $requestParameters{'displayObjects'}[0]);
		}
		if ($requestParameters{'displayApplets'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'displayApplets', $requestParameters{'displayApplets'}[0]);
		}
		if ($requestParameters{'parseTablesToList'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'parseTablesToList', $requestParameters{'parseTablesToList'}[0]);
		}
		$siteConfig = setConfig($siteConfig, 'siteLabel', $requestParameters{'siteLabel'}[0]);
		$siteConfig = setConfig($siteConfig, 'defaultLanguage', $requestParameters{'defaultLanguage'}[0]);
		$siteConfig = setConfig($siteConfig, 'logo', $requestParameters{'logo'}[0]);

		# Vu qu'il n'y a pas encore de nom de domaine spécifié, on peut directement mettre celui passé en paramètre
		$siteConfig = setConfig($siteConfig, 'siteDomainNames', $requestParameters{'siteDomainName'}[0]);

		# Vu qu'il n'y a pas encore d'URI de page d'accueil spécifié, on peut directement mettre celle passée en paramètre
		$siteConfig = setConfig($siteConfig, 'homePageUris', $requestParameters{'homePageUri'}[0]);

		# On sauvegarde la configuration ainsi mise à jour
		saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);

		# On redirige vers la page de modification du site venant d'être créé
		print $cgi->redirect("/admin/sites/modify/".$siteId."?m=4");
	}
	exit;
}

# Affichage du formulaire de modification du site sélectionné
if ($thisCdlUrl =~ m/^\/admin\/sites\/modify\/(.*?)(\?|$)/si) {
	# Récupération de l'identifiant du site à créer
	my $siteId = $1;

	# Détection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné.\n";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId.".\n";
		exit;
	}

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Modification du site : \"".$siteId."\"");

	# Récupération de la partie du formulaire d'édition d'édition
	my $formTemplateString = getPartOfTemplateString($configPageTemplateString, 'EDIT_FORM');

	# Chargement des paramètre de configuration du site
	$siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# On rajoute un titre correspondant à l'identifiant du site à modifier
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_FIELD', "");
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_TITLE', getPartOfTemplateString($configPageTemplateString, 'SITE_ID_TITLE'));

	# Mettre l'identifiant du site à modifier
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID', "/".$siteId);
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_ID_VALUE', $siteId);
	$formTemplateString = setValueInTemplateString($formTemplateString, 'EDIT_ACTION', "modify");


	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAIN_NAME', $requestParameters{'siteDomainName'}[0]);
	# Lister les valeurs des noms de domaine du site
	my @domaineNameArray = split(/\t+/, getConfig($siteConfig, 'siteDomainNames'));

	# Génération de la liste à puce des noms de domaine
	$domaineNamesListString = @domaineNameArray ? "<ul>" : "";

	foreach $domainName (@domaineNameArray) {
		$domaineNamesListString .= "<li>".$domainName."&nbsp;<!--cdlReplace--><!--|&nbsp;--><!--/cdlReplace--><a href=\"/admin/sites/delete-param/".$siteId."/siteDomainNames?paramValue=".urlEncode($domainName)."\" title=\"Supprimer le nom de domaine : ".$domainName."\"><img src='/design/images/delete.png' alt=\"Supprimer le nom de domaine : ".$domainName."\"></a></li>";
	}
	$domaineNamesListString .= @domaineNameArray ? "</ul>" : "";

	# Afficher dans la template la liste des noms de domaine récupérée du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAINE_NAMES_LIST', $domaineNamesListString);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URI', $requestParameters{'homePageUri'}[0]);
	# Lister les valeurs des URIs de la page d'acceuil
	@homePageUrisArray = split(/\t+/, getConfig($siteConfig, 'homePageUris'));

	# Génération de la liste à puce des URIs de la page d'accueil
	$homePageUrisListString = @homePageUrisArray ? "<ul>" : "";
	foreach $homePageUri (@homePageUrisArray) {
		$homePageUrisListString .= "<li>".$homePageUri."&nbsp;<!--cdlReplace--><!--|&nbsp;--><!--/cdlReplace--><a href=\"/admin/sites/delete-param/".$siteId."/homePageUris?paramValue=".urlEncode($homePageUri)."\" title=\"Supprimer l'URI '".$homePageUri."' de la page d'accueil\"><img src='/design/images/delete.png' alt=\"Supprimer l'URI ".$homePageUri." de la page d'accueil\"/></a></li>";
	}
	$homePageUrisListString .= @homePageUrisArray ? "</ul>" : "";

	# Afficher dans la template la liste des URIs de la page d'accueil récupérée du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URIS_LIST', $homePageUrisListString);

	# Récupération de la configuration de la position du fil d'Ariane
	$positionLocation = getConfig($siteConfig, 'positionLocation');
	if (!$positionLocation or $positionLocation eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', "");
	}

	# Récupération des paramètres de configuration du javascript
	$activateJavascript = getConfig($siteConfig, 'activateJavascript');
	if (!$activateJavascript or $activateJavascript eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', "");
	}

	$parseJavascript = getConfig($siteConfig, 'parseJavascript');
	if (!$parseJavascript or $parseJavascript eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', "");
	}

	# Récupération des paramètres de configuration des frames
	$activateFrames = getConfig($siteConfig, 'activateFrames');
	if (!$activateFrames or $activateFrames eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', "");
	}

	# Récupération des paramètres des medias
	$displayImages = getConfig($siteConfig, 'displayImages');
	if (!$displayImages or $displayImages eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', "");
	}

	$displayObjects = getConfig($siteConfig, 'displayObjects');
	if (!$displayObjects or $displayObjects eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', "");
	}

	$displayApplets = getConfig($siteConfig, 'displayApplets');
	if (!$displayApplets or $displayApplets eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', "");
	}

	# Récupération des paramètres des tables.
	$parseTablesToList = getConfig($siteConfig, 'parseTablesToList');
	if (!$parseTablesToList or $parseTablesToList eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', "");
	}

	# Récupération des paramètres : titre, langue, logo.
	$siteLabel = getConfig($siteConfig, 'siteLabel');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LABEL', $siteLabel);

	$defaultLanguage = getConfig($siteConfig, 'defaultLanguage');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'DEFAULT_LANGUAGE', $defaultLanguage);

	$logo = getConfig($siteConfig, 'logo');
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LOGO', $logo);

	# Gestion des messages d'information
	if (param('m') eq "1") {
		# La modification s'est bien passée
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageOk\">La configuration a bien été mise à jour.</div><br>");
	} elsif (param('m') eq "4") {
		# L'ajout s'est bien passée
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageOk\">Le site ".$siteId." a bien été créé.</div><br>");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "");
	}

	# On vide la partie de la template réservée à la page de liste
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# On met à jour dans la template tout le formulaire ainsi rempli
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', $formTemplateString);
	# On vide la partie de la template réservée au glossaire
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'GLOSSARY_FORM', "");
	# On vide la partie de la template réservée à l'identification
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'IDENT_FORM', "");

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Modification du site sélectionné
if ($thisCdlUrl =~ m/^\/admin\/sites\/modify\-action\/(.*?)(\?.*)?$/si) {
	my $siteId = $1;

	# Détection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné.\n";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId.".\n";
		exit;
	}

	# Chargement des paramètre de configuration du site
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Mise à jour des valeurs de configuration spécifiées par l'administrateur
	if (param('valider') or param('ajouterSiteDomainNames') or param('ajouterHomePageUris')) {
		if ($requestParameters{'positionLocation'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'positionLocation', $requestParameters{'positionLocation'}[0]);
		}
		if ($requestParameters{'activateJavascript'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'activateJavascript', $requestParameters{'activateJavascript'}[0]);
		}
		if ($requestParameters{'parseJavascript'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'parseJavascript', $requestParameters{'parseJavascript'}[0]);
		}
		if ($requestParameters{'activateFrames'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'activateFrames', $requestParameters{'activateFrames'}[0]);
		}
		if ($requestParameters{'displayImages'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'displayImages', $requestParameters{'displayImages'}[0]);
			}
		if ($requestParameters{'displayObjects'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'displayObjects', $requestParameters{'displayObjects'}[0]);
		}
		if ($requestParameters{'displayApplets'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'displayApplets', $requestParameters{'displayApplets'}[0]);
		}
		if ($requestParameters{'parseTablesToList'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'parseTablesToList', $requestParameters{'parseTablesToList'}[0]);
		}
		$siteConfig = setConfig($siteConfig, 'siteLabel', $requestParameters{'siteLabel'}[0]);
		$siteConfig = setConfig($siteConfig, 'defaultLanguage', $requestParameters{'defaultLanguage'}[0]);
		$siteConfig = setConfig($siteConfig, 'logo', $requestParameters{'logo'}[0]);

		# Lister les valeurs du nom du domaine du site
		my $siteDomaineNames = getConfig($siteConfig, 'siteDomainNames');

		# Récupération du nom de domaine en paramètre
		my $siteDomainName = $requestParameters{'siteDomainName'}[0];

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
			$siteConfig = setConfig($siteConfig, 'siteDomainNames', $siteDomaineNames);
		}

		# Lister les valeurs du nom du domaine du site
		$homePageUris = getConfig($siteConfig, 'homePageUris');

		# Récupération de l'URI de la page d'accueil en paramètre
		my $homePageUri = $requestParameters{'homePageUri'}[0];

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
			$siteConfig = setConfig($siteConfig, 'homePageUris', $homePageUris);
		}

		# Sauvegarder la config dans le fichier .ini
		saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);
	}

	# Redirection vers le formulaire de modification du site, avec un message d'information pour notifier le bon déroulement de la modification
	print $cgi->redirect("/admin/sites/modify/".$siteId."?m=1");
	exit;
}

# Suppression d'un paramètre un item dans un paramètre de configuration
if ($thisCdlUrl =~ m/^\/admin\/sites\/delete\-param\/(.*?)\/(.*?)\/?\?(.*)$/si) {
	# Récupération de l'identifiant du site à traiter
	my $siteId = $1;

	# Détection d'erreurs au niveau de l'identifiant du site
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné.\n";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId.".\n";
		exit;
	}

	# Récupération du nom de paramètre de configuration à modifier
	my $configKey = $2;
	# La valeur de la partie du paramètre à supprimer
	my $configValuePart = urlDecode(param('paramValue'));

	# Chargement des paramètre de configuration du site
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Lister les valeurs du paramètre
	my $configValue = getConfig($siteConfig, $configKey);

	# Echappement de caractères d'expression régulière
	$configValuePart =~ s/(\\|\?|\/|\||\.|\*|\(|\)|\[|\]|\{|\}|\+|\-|\^|\$)/\\$1/sgi;

	# Suppression de la partie demandée
	$configValue =~ s/(^|\t+)$configValuePart(\t+|$)/$1.$2/segi;

	# Suppression des éventuelles tabulations en début et en fin de chaîne
	$configValue =~ s/^\t*//sgi;
	$configValue =~ s/\t*$//sgi;

	# Mise à jour du paramètre
	$siteConfig = setConfig($siteConfig, $configKey, $configValue);

	# Sauvegarder la config dans le fichier .ini
	saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);

	# Redirection vers le formulaire de modification du site, avec un message d'information pour notifier le bon déroulement de la modification
	print $cgi->redirect("/admin/sites/modify/".$siteId."?m=1");
	exit;
}

# Lister les sites pris en compte par CDL
if ($thisCdlUrl =~ m/^\/admin\/sites(\/list)?(\?.*?)?$/si) {
	# Récupération de la liste des répertoires correspondant aux identifiants
	my @sites = getSitesIds;

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Liste des sites (".@sites.")");

	# Affichage du message d'information pour le bon déroulement de la suppression d'un site
	my $sitesListString = $requestParameters{'m'}[0] eq "6" ? "<div class=\"messageOk\">Le site a bien été supprimé.</div><div class=\"clearBoth\"></div><br>" : "";

	# Génération de la chaîne HTML correspondant à la liste à puce des sites
	$sitesListString .= @sites ? "<ul>" : "";
	foreach my $site (@sites) {
		$sitesListString .= "<li><a href='/admin/sites/modify/".$site."'>".$site."</a>&nbsp;<!--cdlReplace--><!--|&nbsp;--><!--/cdlReplace--><a href=\"/le-filtre/".$site."\" title=\"Visualiser le site : ".$site."\" target=\"_blank\"><img src='/design/images/view.png' alt=\"Visualiser le site : ".$site."\"></a>&nbsp;<!--cdlReplace--><!--|&nbsp;--><!--/cdlReplace--><a href=\"/admin/sites/delete-site/".$site."\" title=\"Supprimer le site : ".$site."\" onclick=\"if (confirm('Voulez vous vraiment supprimer le site ".$site." ?')) {window.location.href = '/admin/sites/delete-site/".$site."'} return false;\"><img src='/design/images/delete.png' alt=\"Supprimer le site : ".$site."\"></a>";
	}
	$sitesListString .= @sites ? "</ul>" : "";

	# Mise à jour dans la template pour afficher la liste des sites
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "<h1>Gestion des sites</h1><!--cdlNav--><p><a href=\"/admin/sites/create\" class=\"black addLink\">Créer un site</a><!--/cdlNav-->".($sitesListString ? "<!--cdlBloc-->".$sitesListString."<!--/cdlBloc-->" : "<!--cdlBloc--><p><strong>Aucun site n'a été créé.</strong><!--/cdlBloc-->"));
	# On vide la partie réservée au formulaire d'édition
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', "");
	# On vide la partie de la template réservée au glossaire
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'GLOSSARY_FORM', "");
	# On vide la partie de la template réservée à l'identification
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'IDENT_FORM', "");

	# Affichage de la template finale
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Suppression d'un site
if ($thisCdlUrl =~ m/^\/admin\/sites\/delete\-site\/(.*?)$/si) {
	# Suppression récursive de tout le répertoire correspondant
	rmtree($cdlSitesConfigPath.$1);

	# Redirection vers la page de liste avec un message d'information
	print $cgi->redirect("/admin/sites/list?m=6");
	exit;
}

# Affichage de la page d'édition du glossaire
if ($thisCdlUrl =~ m/^\/admin\/glossary(\/index)?(\?.*)?$/si) {
	my $noPage = param('p');
	$noPage = $noPage ? $noPage : 1;

	# Affichage du message d'information pour le bon déroulement de la mise à jour du glossaire
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'MESSAGE_GLOSSARY', $requestParameters{'m'}[0] eq "7" ? "<div class=\"messageOk\">Le glossaire a bien été modifié.</div><div class=\"clearBoth\"></div><br>" : "");

	# Récupération de la partie du formulaire d'édition du glossaire
	my $rowTemplateString = getPartOfTemplateString($configPageTemplateString, 'GLOSSARY_ROWS');

	my @glossaryItems = getGlossaryItems(0, 1000000);

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Gestion du glossaire (".@glossaryItems.")");

	my $formRows = "";
	my $index = 0;
	foreach my $glossaryItem (@glossaryItems) {
		$index++;
		my @glossaryItemParts = split(/\t/, $glossaryItem);
		$glossaryItemParts[2] =~ s/\"/&quot;/sgi;
		my $formRow = setValueInTemplateString(setValueInTemplateString(setValueInTemplateString(setValueInTemplateString($rowTemplateString, 'ICASE_YES', $glossaryItemParts[3] eq "1" ? " selected" : ""), 'ICASE_NO', $glossaryItemParts[3] eq "0" ? " selected=\"selected\"" : ""), 'PATTERN', $glossaryItemParts[1]), 'REPLACEMENT', $glossaryItemParts[2]);
		$formRow = setValueInTemplateString(setValueInTemplateString(setValueInTemplateString($formRow, 'SEPL_0', $glossaryItemParts[4] eq "0" ? "selected" : ""), 'SEPL_1', $glossaryItemParts[4] eq "1" ? "selected=\"selected\"" : ""), 'SEPL_2', $glossaryItemParts[4] eq "2" ? "selected=\"selected\"" : "");
		$formRow = setValueInTemplateString(setValueInTemplateString(setValueInTemplateString($formRow, 'SEPR_0', $glossaryItemParts[5] eq "0" ? "selected" : ""), 'SEPR_1', $glossaryItemParts[5] eq "1" ? "selected=\"selected\"" : ""), 'SEPR_2', $glossaryItemParts[5] eq "2" ? "selected=\"selected\"" : "");
		$formRows .= $formRow;
		if ($index%20 eq 0) {
			$formRows .= '<tr><td colspan="300"><input type="submit" name="save" value="Sauvegarder" class="submit">';
		}
	}

	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'GLOSSARY_ROWS', $formRows);
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'GLOSSARY_FORM', getPartOfTemplateString($configPageTemplateString, 'GLOSSARY_FORM'));

	# Vider de la partie réservée à la liste des sites
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# Vider de la partie réservée au formulaire d'édition
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', "");
	# On vide la partie de la template réservée à l'identification
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'IDENT_FORM', "");

	# Affichage de la template finale
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Affichage de la page d'édition du glossaire
if ($thisCdlUrl =~ m/^\/admin\/glossary\/edit\-action(\?.*)?$/si) {
	my $noPage = param('p');

	my @patterns = getArrayWithParameterValues('pattern',%requestParameters);
	my @replacements = getArrayWithParameterValues('replacement',%requestParameters);
	my @icases = getArrayWithParameterValues('icase',%requestParameters);
	my @sepls = getArrayWithParameterValues('sepl',%requestParameters);
	my @seprs = getArrayWithParameterValues('sepr',%requestParameters);
	my $language = "fr";

	my $glossaryContent;
	my $index = 0;
	foreach my $pattern (@patterns) {
		if ($pattern !~ m/^\s*$/si) {
			$glossaryContent .= $language."\t".$pattern."\t".($replacements[$index] ? $replacements[$index] : "")."\t".($icases[$index] eq "0" ? "0" : "1")."\t".($sepls[$index] ? $sepls[$index] : "0")."\t".($seprs[$index] ? $seprs[$index] : "0")."\n";
		}
		$index++;
	}
	$glossaryContent =~ s/\n$//sgi;

	my ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst) = localtime(time);
	rename($cdlGlossaryConfigPath."/pronunciation_corrections.txt", $cdlRootPath.$cdlGlossaryConfigPath."/pronunciation_corrections_".($year+1900)."-".($month+1)."-".$mday."-".$hour.$min.$sec.".txt");

	saveConfig($cdlGlossaryConfigPath."/pronunciation_corrections.txt", $glossaryContent);

	# Redirection vers la page d'index du glossaire
	print $cgi->redirect("/admin/glossary/index?m=7".($noPage ? "&p=".$noPage : ""));
	exit;
}

# Si on passe ici, c'est qu'il y a eu une erreur de manipulation de l'URL appelée
print "Content-type: text/html; charset=UTF-8\n\n";
print "<title>Interface d'administration &bull; Confort de lecture</title><link href=\"/favicon.png\" rel=\"shortcut icon\"><!--cdlBloc--><h1>Interface d'administration</h1><a href=\"/admin/sites/list\">Accès à la liste des sites</a><br><a href=\"/admin/glossary/index\">Accès au glossaire</a><!--/cdlBloc-->";