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

use Cwd;

use File::Path;

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;


# Création de l'objet CGI
my $cgi  = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

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

$embeddedMode = "";
$thisCdlUrl =~ s/^(\/cdl)/$embeddedMode = $1; ""/segi;

# Chargement de la template principale de l'interface de configuration
my $configPageTemplateString = loadConfig($cdlTemplatesPath."config.html");

$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EMBEDDED_URL', $embeddedMode);

# Gestion de l'identification
if (!$cdlAdmin and $thisCdlUrl !~ m/^\/admin\/login(\/action)?(\?.*?)?$/si) {
	print $cgi->redirect($embeddedMode."/admin/login?m=8&p=".urlEncode($embeddedMode.$thisCdlUrl));
	exit;
}
if ($thisCdlUrl =~ m/^\/admin\/login(\?.*?)?$/si) {
	my $pageRedirect = param('p');

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

	# l'URL de la page qui a été sollicité avant d'être redirigé vers le login
	$formTemplateString = setValueInTemplateString($formTemplateString, 'PAGE_REDIRECT', $pageRedirect);

	# On met à jour dans la template tout le formulaire ainsi rempli
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'IDENT_FORM', $formTemplateString);
	# Vider de la partie réservée à la liste des sites
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "");
	# Vider de la partie réservée au formulaire d'édition
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', "");
	# On vide la partie de la template réservée au glossaire
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'GLOSSARY_FORM', "");

	my @now = localtime(time);
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}
if ($thisCdlUrl =~ m/^\/admin\/login\/action(\?.*?)?$/si) {
	my $pageRedirect = param('p');
	if (!param('loginAdmin') or !param('passwdAdmin')) {
		print $cgi->redirect($embeddedMode."/admin/login?m=6&p=".urlEncode($pageRedirect));
		exit;
	}

	my $encryptedIdentLine = param('loginAdmin').":".crypt(param('passwdAdmin'), param('passwdAdmin'));

	open(READER, '<', $cdlRootPath."/configuration/.htpasswd");
	my @encryptedIdentLines = <READER>;
	close(READER);

	if (grep(/$encryptedIdentLine/, @encryptedIdentLines) > 0) {
		editInSession($session, 'cdlAdmin', param('loginAdmin'));

		# Envoyer le cookie représentant la session
		my $cookie = CGI::Cookie->new(-name=>$session->name, -value=>$session->id);
		print $cgi->header(-status=>"302 Moved", -location=>($pageRedirect ? $pageRedirect : $embeddedMode."/admin"), -cookie=>$cookie);
	} else {
		print $cgi->redirect($embeddedMode."/admin/login?m=7");
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

	$formTemplateString = setValueInTemplateString($formTemplateString, 'TRUSTED_DOMAIN_NAME', $requestParameters{'trustedDomainName'}[0]);
	# Aucun URI de page d'accueil au départ => liste vide
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TRUSTED_DOMAINE_NAMES_LIST', "");

	$formTemplateString = setValueInTemplateString($formTemplateString, 'PAGE_NO_CACHE', $requestParameters{'pageNoCache'}[0]);
	# Aucun URI de page d'accueil au départ => liste vide
	$formTemplateString = setValueInTemplateString($formTemplateString, 'PAGES_NO_CACHE_LIST', "");

	my $cdlUrl = $requestParameters{'cdlUrl'}[0];
	$cdlUrl =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'CDL_URL', $cdlUrl);

	if ($requestParameters{'embeddedMode'}[0] eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'EMBEDDED_MODE_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'EMBEDDED_MODE_NO', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'EMBEDDED_MODE_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'EMBEDDED_MODE_YES', "");
	}

	# Pour chacun des paramètres de configuration suivants, on teste si on revient du formulaire à cause d'une erreur, on met la bonne valeur de configuration
	if (!$requestParameters{'positionLocation'}[0] or $requestParameters{'positionLocation'}[0] eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP_AND_BOTTOM', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', "");
	} elsif ($requestParameters{'positionLocation'}[0] eq "3") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP_AND_BOTTOM', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP_AND_BOTTOM', "");
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
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_ONLY_WITH_ALT', "");
	} elsif ($requestParameters{'displayImages'}[0] eq "2") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_ONLY_WITH_ALT', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_ONLY_WITH_ALT', "");
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

	if ($requestParameters{'enableAudio'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_AUDIO_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_AUDIO_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_AUDIO_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_AUDIO_NO', "");
	}

	if ($requestParameters{'enableGlossary'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_GLOSSARY_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_GLOSSARY_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_GLOSSARY_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_GLOSSARY_NO', "");
	}

	if ($requestParameters{'voiceChoice'}[0] eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'VOICE_CHOICE_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'VOICE_CHOICE_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'VOICE_CHOICE_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'VOICE_CHOICE_NO', "");
	}

	if ($requestParameters{'ttsMode'}[0] eq "sdk") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_MODE_SDK', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_MODE_VAAS', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_MODE_VAAS', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_MODE_SDK', "");
	}

	my $ttsServerName = $requestParameters{'ttsServerName'}[0];
	$ttsServerName =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_SERVER_NAME', $ttsServerName);

	my $ttsPort = $requestParameters{'ttsPort'}[0];
	$ttsPort =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_PORT', $ttsPort);

	my $ttsUri = $requestParameters{'ttsUri'}[0];
	$ttsUri =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_URI', $ttsUri);

	my $ttsDefaultQueryString = $requestParameters{'ttsDefaultQueryString'}[0];
	$ttsDefaultQueryString =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_DEFAULT_QUERY_STRING', $ttsDefaultQueryString);

	my $ttsVoiceParamName = $requestParameters{'ttsVoiceParamName'}[0];
	$ttsVoiceParamName =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_VOICE_PARAM_NAME', $ttsVoiceParamName);

	my $ttsRateParamName = $requestParameters{'ttsRateParamName'}[0];
	$ttsRateParamName =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_RATE_PARAM_NAME', $ttsRateParamName);

	my $ttsTextParamName = $requestParameters{'ttsTextParamName'}[0];
	$ttsTextParamName =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_TEXT_PARAM_NAME', $ttsTextParamName);

	if ($requestParameters{'utf8DecodeContent'}[0] eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'UTF8_DECODE_CONTENT_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'UTF8_DECODE_CONTENT_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'UTF8_DECODE_CONTENT_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'UTF8_DECODE_CONTENT_NO', "");
	}

	my $cacheExpiry = $requestParameters{'cacheExpiry'}[0];
	$cacheExpiry =~ s/\"/&quot;/sgi;
	$formTemplateString = setValueInTemplateString($formTemplateString, 'CACHE_EXPIRY', $cacheExpiry);

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
	} elsif (param('m') eq "9") {
		# Utilisation de caractères non permis
		$formTemplateString = setValueInTemplateString($formTemplateString, 'MESSAGE', "<div class=\"messageErr\">La durée du cache doit être numérique.</div><br>");
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

	my @now = localtime(time);
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);

	# Affichage du code HTML
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Ajout du nouveau site
if ($thisCdlUrl =~ m/^\/admin\/sites\/create\-action(\?m=\d&|\?|&)?(.*?)$/si) {
	# Récupération de l'identifiant du site
	my $siteId = $requestParameters{'siteId'}[0];
	my $cacheExpiry = $requestParameters{'cacheExpiry'}[0];

	my $parametersString = $2;

	# Détection erreurs au niveau de l'identifiant du site
	if ($siteId =~ m/[^a-z\d\-_\.]/si) {
		# Erreur de caractère()s illégal(aux) dans l'identifiant
		print $cgi->redirect($embeddedMode."/admin/sites/create?m=5&".$parametersString);
		exit;
	}
	if (!$siteId) {
		# Aucun identifiant n'a été renseigné
		print $cgi->redirect($embeddedMode."/admin/sites/create?m=2&".$parametersString);
		exit;
	}
	if (existConfigDirectory($siteId)) {
		# L'identifiant spécifié existe déjà
		print $cgi->redirect($embeddedMode."/admin/sites/create?m=3&".$parametersString);
		exit;
	}
	if ($cacheExpiry !~ m/^([\-\+\/\*%]?\d+)*$/si) {
		print $cgi->redirect($embeddedMode."/admin/sites/create?m=9&".$parametersString);
		exit;
	}

	# Création et initialisation du site
	createSiteConfig($siteId);

	# Chargement des paramètres de configuration du site qui vient d'être créé
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Mise à jour des valeurs de configuration spécifiées par l'administrateur
	if (param('valider') or param('ajouterSiteDomainNames') or param('ajouterTrustedDomainNames') or param('ajouterHomePageUris')) {
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
		if ($requestParameters{'enableAudio'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'enableAudio', $requestParameters{'enableAudio'}[0]);
		}
		if ($requestParameters{'enableGlossary'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'enableGlossary', $requestParameters{'enableGlossary'}[0]);
		}
		if ($requestParameters{'voiceChoice'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'voiceChoice', $requestParameters{'voiceChoice'}[0]);
		}
		if ($requestParameters{'ttsMode'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'ttsMode', $requestParameters{'ttsMode'}[0]);
		}
		if ($requestParameters{'utf8DecodeContent'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'utf8DecodeContent', $requestParameters{'utf8DecodeContent'}[0]);
		}
		$siteConfig = setConfig($siteConfig, 'siteLabel', $requestParameters{'siteLabel'}[0]);
		$siteConfig = setConfig($siteConfig, 'defaultLanguage', $requestParameters{'defaultLanguage'}[0]);
		$siteConfig = setConfig($siteConfig, 'logo', $requestParameters{'logo'}[0]);

		$siteConfig = setConfig($siteConfig, 'ttsServerName', $requestParameters{'ttsServerName'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsPort', $requestParameters{'ttsPort'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsUri', $requestParameters{'ttsUri'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsDefaultQueryString', $requestParameters{'ttsDefaultQueryString'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsVoiceParamName', $requestParameters{'ttsVoiceParamName'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsRateParamName', $requestParameters{'ttsRateParamName'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsTextParamName', $requestParameters{'ttsTextParamName'}[0]);
		$siteConfig = setConfig($siteConfig, 'cacheExpiry', $cacheExpiry);

		# Vu qu'il n'y a pas encore de nom de domaine spécifié, on peut directement mettre celui passé en paramètre
		$siteConfig = setConfig($siteConfig, 'siteDomainNames', $requestParameters{'siteDomainName'}[0]);

		# Vu qu'il n'y a pas encore d'URI de page d'accueil spécifié, on peut directement mettre celle passée en paramètre
		$siteConfig = setConfig($siteConfig, 'homePageUris', $requestParameters{'homePageUri'}[0]);

		# Vu qu'il n'y a pas encore de nom de domaine spécifié, on peut directement mettre celui passé en paramètre
		$siteConfig = setConfig($siteConfig, 'trustedDomainNames', $requestParameters{'trustedDomainName'}[0]);

		# Vu qu'il n'y a pas encore de page en no cache, on peut directement mettre celle passée en paramètre
		$siteConfig = setConfig($siteConfig, 'pagesNoCache', $requestParameters{'pagesNoCache'}[0]);

		$siteConfig = setConfig($siteConfig, 'cdlUrl', $requestParameters{'cdlUrl'}[0]);

		if ($requestParameters{'embeddedMode'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'embeddedMode', $requestParameters{'embeddedMode'}[0]);
		}

		# On sauvegarde la configuration ainsi mise à jour
		saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);

		# On redirige vers la page de modification du site venant d'être créé
		print $cgi->redirect($embeddedMode."/admin/sites/modify/".$siteId."?m=4");
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
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné.\n";
		exit;
	}

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Modification du site : \"".$siteId."\"");

	# Récupération de la partie du formulaire d'édition d'édition
	my $formTemplateString = getPartOfTemplateString($configPageTemplateString, 'EDIT_FORM');

	# Chargement des paramètre de configuration du site
	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

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
	my $domaineNamesListString = @domaineNameArray ? "<ul>" : "";

	foreach my $domainName (@domaineNameArray) {
		$domaineNamesListString .= "<li>".$domainName."&nbsp;<a href=\"".$embeddedMode."/admin/sites/delete-param/".$siteId."/siteDomainNames?paramValue=".urlEncode($domainName)."\" title=\"Supprimer le nom de domaine : ".$domainName."\"><img src='".$embeddedMode."/design/images/delete.png' alt=\"Supprimer le nom de domaine : ".$domainName."\"></a>";
	}
	$domaineNamesListString .= @domaineNameArray ? "</ul>" : "";

	# Afficher dans la template la liste des noms de domaine récupérée du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_DOMAINE_NAMES_LIST', $domaineNamesListString);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URI', $requestParameters{'homePageUri'}[0]);
	# Lister les valeurs des URIs de la page d'acceuil
	my @homePageUrisArray = split(/\t+/, getConfig($siteConfig, 'homePageUris'));

	# Génération de la liste à puce des URIs de la page d'accueil
	my $homePageUrisListString = @homePageUrisArray ? "<ul>" : "";
	foreach my $homePageUri (@homePageUrisArray) {
		$homePageUrisListString .= "<li>".$homePageUri."&nbsp;<a href=\"".$embeddedMode."/admin/sites/delete-param/".$siteId."/homePageUris?paramValue=".urlEncode($homePageUri)."\" title=\"Supprimer l'URI '".$homePageUri."' de la page d'accueil\"><img src='".$embeddedMode."/design/images/delete.png' alt=\"Supprimer l'URI ".$homePageUri." de la page d'accueil\"/></a>";
	}
	$homePageUrisListString .= @homePageUrisArray ? "</ul>" : "";

	# Afficher dans la template la liste des URIs de la page d'accueil récupérée du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'HOME_PAGE_URIS_LIST', $homePageUrisListString);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'TRUSTED_DOMAIN_NAME', $requestParameters{'trustedDomainName'}[0]);
	# Lister les valeurs des noms de domaine de confiance
	@domaineNameArray = split(/\t+/, getConfig($siteConfig, 'trustedDomainNames'));

	# Génération de la liste à puce des noms de domaine de confiance
	$domaineNamesListString = @domaineNameArray ? "<ul>" : "";

	foreach my $domainName (@domaineNameArray) {
		$domaineNamesListString .= "<li>".$domainName."&nbsp;<a href=\"".$embeddedMode."/admin/sites/delete-param/".$siteId."/trustedDomainNames?paramValue=".urlEncode($domainName)."\" title=\"Supprimer le nom de domaine de confiance : ".$domainName."\"><img src='".$embeddedMode."/design/images/delete.png' alt=\"Supprimer le nom de domaine de confiance : ".$domainName."\"></a>";
	}
	$domaineNamesListString .= @domaineNameArray ? "</ul>" : "";

	# Afficher dans la template la liste des noms de domaine de confiance récupérée du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TRUSTED_DOMAINE_NAMES_LIST', $domaineNamesListString);

	$formTemplateString = setValueInTemplateString($formTemplateString, 'CDL_URL', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'cdlUrl')));

	my $embeddedModeConfig = getConfig($siteConfig, 'embeddedMode');
	if ($embeddedModeConfig eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'EMBEDDED_MODE_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'EMBEDDED_MODE_NO', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'EMBEDDED_MODE_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'EMBEDDED_MODE_YES', "");
	}

	# Récupération de la configuration de la position du fil d'Ariane
	my $positionLocation = getConfig($siteConfig, 'positionLocation');
	if (!$positionLocation or $positionLocation eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP_AND_BOTTOM', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', "");
	} elsif ($positionLocation eq "3") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP_AND_BOTTOM', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_BOTTOM', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP_AND_BOTTOM', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'POSITION_LOCATION_TOP', "");
	}

	# Récupération des paramètres de configuration du javascript
	my $activateJavascript = getConfig($siteConfig, 'activateJavascript');
	if (!$activateJavascript or $activateJavascript eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_JS_NO', "");
	}

	my $parseJavascript = getConfig($siteConfig, 'parseJavascript');
	if (!$parseJavascript or $parseJavascript eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_JS_NO', "");
	}

	# Récupération des paramètres de configuration des frames
	my $activateFrames = getConfig($siteConfig, 'activateFrames');
	if (!$activateFrames or $activateFrames eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ACTIVATE_FRAMES_NO', "");
	}

	# Récupération des paramètres des medias
	my $displayImages = getConfig($siteConfig, 'displayImages');
	if (!$displayImages or $displayImages eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_ONLY_WITH_ALT', "");
	} elsif ($displayImages eq "2") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_ONLY_WITH_ALT', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_NO', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_IMAGES_ONLY_WITH_ALT', "");
	}

	my $displayObjects = getConfig($siteConfig, 'displayObjects');
	if (!$displayObjects or $displayObjects eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_OBJECTS_NO', "");
	}

	my $displayApplets = getConfig($siteConfig, 'displayApplets');
	if (!$displayApplets or $displayApplets eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'DISPLAY_APPLETS_NO', "");
	}

	# Récupération des paramètres des tables.
	my $parseTablesToList = getConfig($siteConfig, 'parseTablesToList');
	if (!$parseTablesToList or $parseTablesToList eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'PARSE_TABLES_NO', "");
	}

	# Récupération des paramètres : titre, langue, logo.
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LABEL', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'siteLabel')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'DEFAULT_LANGUAGE', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'defaultLanguage')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'SITE_LOGO', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'logo')));

	my $enableAudio = getConfig($siteConfig, 'enableAudio');
	if ($enableAudio eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_AUDIO_NO', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_AUDIO_YES', " checked");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_AUDIO_YES', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_AUDIO_NO', " checked");
	}

	my $enableGlossary = getConfig($siteConfig, 'enableGlossary');
	if ($enableGlossary eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_GLOSSARY_NO', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_GLOSSARY_YES', " checked");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_GLOSSARY_YES', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'ENABLE_GLOSSARY_NO', " checked");
	}

	my $voiceChoice = getConfig($siteConfig, 'voiceChoice');
	if ($voiceChoice eq "1") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'VOICE_CHOICE_NO', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'VOICE_CHOICE_YES', " checked");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'VOICE_CHOICE_YES', "");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'VOICE_CHOICE_NO', " checked");
	}

	my $ttsMode = getConfig($siteConfig, 'ttsMode');
	if ($ttsMode eq "sdk") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_MODE_SDK', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_MODE_VAAS', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_MODE_VAAS', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_MODE_SDK', "");
	}

	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_SERVER_NAME', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'ttsServerName')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_PORT', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'ttsPort')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_URI', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'ttsUri')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_DEFAULT_QUERY_STRING', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'ttsDefaultQueryString')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_VOICE_PARAM_NAME', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'ttsVoiceParamName')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_RATE_PARAM_NAME', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'ttsRateParamName')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'TTS_TEXT_PARAM_NAME', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'ttsTextParamName')));
	$formTemplateString = setValueInTemplateString($formTemplateString, 'CACHE_EXPIRY', escapeDoubleQuoteForHtml(getConfig($siteConfig, 'cacheExpiry')));

	my $utf8DecodeContent = getConfig($siteConfig, 'utf8DecodeContent');
	if ($utf8DecodeContent eq "0") {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'UTF8_DECODE_CONTENT_NO', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'UTF8_DECODE_CONTENT_YES', "");
	} else {
		$formTemplateString = setValueInTemplateString($formTemplateString, 'UTF8_DECODE_CONTENT_YES', " checked");
		$formTemplateString = setValueInTemplateString($formTemplateString, 'UTF8_DECODE_CONTENT_NO', "");
	}

	$formTemplateString = setValueInTemplateString($formTemplateString, 'PAGE_NO_CACHE', $requestParameters{'pageNoCache'}[0]);
	# Lister les valeurs des pages sans cache
	my @pageNoCacheArray = split(/\t+/, getConfig($siteConfig, 'pagesNoCache'));

	# Génération de la liste à puce des pages sans cache
	my $pagesNoCacheListString = @pageNoCacheArray ? "<ul>" : "";

	foreach my $pageNoCache (@pageNoCacheArray) {
		$pagesNoCacheListString .= "<li>".$pageNoCache."&nbsp;<a href=\"".$embeddedMode."/admin/sites/delete-param/".$siteId."/pagesNoCache?paramValue=".urlEncode($pageNoCache)."\" title=\"Supprimer la page : ".$pageNoCache."\"><img src='".$embeddedMode."/design/images/delete.png' alt=\"Supprimer la page : ".$pageNoCache."\"></a>";
	}
	$pagesNoCacheListString .= @pageNoCacheArray ? "</ul>" : "";

	# Afficher dans la template la liste des pages sans cache récupérée du fichier de config du site
	$formTemplateString = setValueInTemplateString($formTemplateString, 'PAGES_NO_CACHE_LIST', $pagesNoCacheListString);

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

	my @now = localtime(time);
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);

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
	if (param('valider') or param('ajouterSiteDomainNames') or param('ajouterTrustedDomainNames') or param('ajouterHomePageUris')) {
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

		if ($requestParameters{'enableAudio'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'enableAudio', $requestParameters{'enableAudio'}[0]);
		}
		if ($requestParameters{'enableGlossary'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'enableGlossary', $requestParameters{'enableGlossary'}[0]);
		}
		if ($requestParameters{'voiceChoice'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'voiceChoice', $requestParameters{'voiceChoice'}[0]);
		}
		if ($requestParameters{'ttsMode'}[0] ne "") {
			$siteConfig = setConfig( $siteConfig, 'ttsMode', $requestParameters{'ttsMode'}[0] );
		}
		$siteConfig = setConfig($siteConfig, 'ttsServerName', $requestParameters{'ttsServerName'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsPort', $requestParameters{'ttsPort'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsUri', $requestParameters{'ttsUri'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsDefaultQueryString', $requestParameters{'ttsDefaultQueryString'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsVoiceParamName', $requestParameters{'ttsVoiceParamName'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsRateParamName', $requestParameters{'ttsRateParamName'}[0]);
		$siteConfig = setConfig($siteConfig, 'ttsTextParamName', $requestParameters{'ttsTextParamName'}[0]);
		$siteConfig = setConfig($siteConfig, 'siteLabel', $requestParameters{'siteLabel'}[0]);
		$siteConfig = setConfig($siteConfig, 'cacheExpiry', $requestParameters{'cacheExpiry'}[0]);
		if ($requestParameters{'utf8DecodeContent'}[0] ne "") {
			$siteConfig = setConfig( $siteConfig, 'utf8DecodeContent', $requestParameters{'utf8DecodeContent'}[0] );
		}

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
		my $homePageUris = getConfig($siteConfig, 'homePageUris');

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

		# Lister les valeurs du nom du domaine de confiance
		my $trustedDomaineNames = getConfig($siteConfig, 'trustedDomainNames');

		# Récupération du nom de domaine en paramètre
		my $trustedDomainName = $requestParameters{'trustedDomainName'}[0];

		if ($trustedDomainName) {
			# Echappement des caractères spéciaux d'expression régulière
			$trustedDomainName =~ s/(\?|\/)/\\$1/sgi;
			# Suppression du nom de domaine s'il existe déjà
			$trustedDomaineNames =~ s/(^|\t+)$trustedDomainName(\t+|$)/$1.$2/segi;

			# Suppression des éventuelles tabulations en début et en fin de chaîne
			$trustedDomaineNames =~ s/^\t*//sgi;
			$trustedDomaineNames =~ s/\t*$//sgi;

			# Suppression du caractère d'échappement \ pour insertion
			$trustedDomainName =~ s/\\(\?|\/)/$1/sgi;
			# Insertion du nouveau nom de domaine dans la chaîne des noms de domaine
			if (!$trustedDomaineNames) {
				$trustedDomaineNames = $trustedDomainName;
			} else {
				$trustedDomaineNames .= "\t".$trustedDomainName;
			}
		}
		# Mise à jour dans la chaîne contenant configuration du site, du paramètre trustedDomainNames
		$siteConfig = setConfig($siteConfig, 'trustedDomainNames', $trustedDomaineNames);

		# Lister les pages sans cache du site
		my $pagesNoCache = getConfig($siteConfig, 'pagesNoCache');

		# Récupération de la page sans cache en paramètre
		my $pageNoCache = $requestParameters{'pageNoCache'}[0];

		if ($pageNoCache) {
			# Echappement des caractères spéciaux d'expression régulière
			$pageNoCache =~ s/(\?|\/)/\\$1/sgi;
			# Suppression de la page si elle existe déjà
			$pagesNoCache =~ s/(^|\t+)$pageNoCache(\t+|$)/$1.$2/segi;

			# Suppression des éventuelles tabulations en début et en fin de chaîne
			$pagesNoCache =~ s/^\t*//sgi;
			$pagesNoCache =~ s/\t*$//sgi;

			# Suppression du caractère d'échappement \ pour insertion
			$pageNoCache =~ s/\\(\?|\/)/$1/sgi;
			# Insertion de la nouvelle page sans cache dans la chaîne des pages sans cache
			if (!$pagesNoCache) {
				$pagesNoCache = $pageNoCache;
			} else {
				$pagesNoCache .= "\t".$pageNoCache;
			}

			# Mise à jour dans la chaîne contenant configuration du site, du paramètre pagesNoCache
			$siteConfig = setConfig($siteConfig, 'pagesNoCache', $pagesNoCache);
		}

		$siteConfig = setConfig($siteConfig, 'cdlUrl', $requestParameters{'cdlUrl'}[0]);

		if ($requestParameters{'embeddedMode'}[0] ne "") {
			$siteConfig = setConfig($siteConfig, 'embeddedMode', $requestParameters{'embeddedMode'}[0]);
		}

		# Sauvegarder la config dans le fichier .ini
		saveConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini", $siteConfig);
	}

	# Redirection vers le formulaire de modification du site, avec un message d'information pour notifier le bon déroulement de la modification
	print $cgi->redirect($embeddedMode."/admin/sites/modify/".$siteId."?m=1");
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
	print $cgi->redirect($embeddedMode."/admin/sites/modify/".$siteId."?m=1");
	exit;
}

# Lister les sites pris en compte par CDL
if ($thisCdlUrl =~ m/^\/admin\/sites(\/list)?(\?.*?)?$/si) {
	# Récupération de la liste des répertoires correspondant aux identifiants
	my @sites = getSitesIds;

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Liste des sites (".@sites.")");

	# Affichage du message d'information pour le bon déroulement de la suppression d'un site
	my $sitesListString = $requestParameters{'m'}[0] eq "6" ? "<div class=\"messageOk\">Le site a bien été supprimé.</div><br>" : "";

	# Génération de la chaîne HTML correspondant à la liste à puce des sites
	$sitesListString .= @sites ? "<ul>" : "";
	foreach my $site (@sites) {
		$sitesListString .= "<li><a href='".$embeddedMode."/admin/sites/modify/".$site."'>".$site."</a>&nbsp;<a href='".$embeddedMode."/admin/glossary/".$site."' title=\"Glossaire du site : ".$site."\"><img src='".$embeddedMode."/design/images/glossary.png' alt=\"Glossaire du site : ".$site."\"></a>&nbsp;<a href=\"".($embeddedMode ne "" ? $embeddedMode."/f" : "/le-filtre/".$site)."\" title=\"Visualiser le site : ".$site."\" target=\"_blank\"><img src='".$embeddedMode."/design/images/view.png' alt=\"Visualiser le site : ".$site."\"></a>&nbsp;<a href=\"".$embeddedMode."/admin/sites/delete-site/".$site."\" title=\"Supprimer le site : ".$site."\" onclick=\"if (confirm('Voulez vous vraiment supprimer le site ".$site." ?')) {window.location.href = '".$embeddedMode."/admin/sites/delete-site/".$site."'} return false;\"><img src='".$embeddedMode."/design/images/delete.png' alt=\"Supprimer le site : ".$site."\"></a>";
	}
	$sitesListString .= @sites ? "</ul>" : "";

	# Mise à jour dans la template pour afficher la liste des sites
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITES_LIST', "<h1>Gestion des sites</h1><p><a href=\"".$embeddedMode."/admin/sites/create\" class=\"black addLink\">Créer un site</a><!--/cdlNav-->".($sitesListString ? $sitesListString : "<p><strong>Aucun site n'a été créé.</strong>"));
	# On vide la partie réservée au formulaire d'édition
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'EDIT_FORM', "");
	# On vide la partie de la template réservée au glossaire
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'GLOSSARY_FORM', "");
	# On vide la partie de la template réservée à l'identification
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'IDENT_FORM', "");

	my @now = localtime(time);
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);

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
	print $cgi->redirect($embeddedMode."/admin/sites/list?m=6");
	exit;
}

# Affichage de la page d'édition du glossaire
if ($thisCdlUrl =~ m/^\/admin\/glossary(\/([^\/\?]+))?(\?.*)?$/si) {
	my $siteId = $2;

	# Affichage du message d'information pour le bon déroulement de la mise à jour du glossaire
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'MESSAGE_GLOSSARY', $requestParameters{'m'}[0] eq "7" ? "<div class=\"messageOk\">Le glossaire".($siteId ? " spécifique au site ".$siteId : "")." a bien été modifié.</div><div class=\"clearBoth\"></div><br>" : "");

	# Récupération de la partie du formulaire d'édition du glossaire
	my $rowTemplateString = getPartOfTemplateString($configPageTemplateString, 'GLOSSARY_ROWS');

	my @glossaryItems = getGlossaryItems($siteId);

	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'SITE_ID', $siteId ? $siteId."/" : "");

	# Mettre le titre de la page
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'PAGE_TITLE', "Gestion du glossaire".($siteId ? " spécifique au site ".$siteId : "")." (".@glossaryItems.")");

	my $formRows = "";
	my $index = 0;
	foreach my $glossaryItem (@glossaryItems) {
		$index++;
		my @glossaryItemParts = split(/\t/, $glossaryItem);
		$glossaryItemParts[2] =~ s/\"/&quot;/sgi;
		my $formRow = setValueInTemplateString(setValueInTemplateString(setValueInTemplateString(setValueInTemplateString($rowTemplateString, 'ICASE_YES', $glossaryItemParts[3] eq "1" ? " selected" : ""), 'ICASE_NO', $glossaryItemParts[3] eq "0" ? " selected=\"selected\"" : ""), 'PATTERN', $glossaryItemParts[1]), 'REPLACEMENT', $glossaryItemParts[2]);
		$formRow = setValueInTemplateString(setValueInTemplateString(setValueInTemplateString($formRow, 'SEPL_0', $glossaryItemParts[4] eq "0" ? "selected" : ""), 'SEPL_1', $glossaryItemParts[4] eq "1" ? "selected=\"selected\"" : ""), 'SEPL_2', $glossaryItemParts[4] eq "2" ? "selected=\"selected\"" : "");
		$formRow = setValueInTemplateString(setValueInTemplateString(setValueInTemplateString($formRow, 'SEPR_0', $glossaryItemParts[5] eq "0" ? "selected" : ""), 'SEPR_1', $glossaryItemParts[5] eq "1" ? "selected=\"selected\"" : ""), 'SEPR_2', $glossaryItemParts[5] eq "2" ? "selected=\"selected\"" : "");
		$formRow = setValueInTemplateString($formRow, 'INDEX_ITEM', $index);
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

	my @now = localtime(time);
	$configPageTemplateString = setValueInTemplateString($configPageTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);

	# Affichage de la template finale
	print "Content-type: text/html\n\n";
	print $configPageTemplateString;
	exit;
}

# Affichage de la page d'édition du glossaire
if ($thisCdlUrl =~ m/^\/admin\/glossary\/([^\/]+\/)?edit\-action(\?.*)?$/si) {
	my $siteId = $1;

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

	my $glossaryDir = $siteId ? $cdlSitesConfigPath.$siteId : $cdlGlossaryConfigPath;

	my ($sec, $min, $hour, $mday, $month, $year) = localtime(time);
	if (-f $glossaryDir."/pronunciation_corrections.txt") {
		rename($glossaryDir."/pronunciation_corrections.txt", $glossaryDir."pronunciation_corrections_".($year + 1900)."-".($month + 1)."-".$mday."-".$hour.$min.$sec.".txt");
	}

	saveConfig($glossaryDir."pronunciation_corrections.txt", $glossaryContent);

	$siteId =~ s/\/$//sgi;

	# Redirection vers la page d'index du glossaire
	print $cgi->redirect($embeddedMode."/admin/glossary/".$siteId."?m=7");
	exit;
}

# Si on passe ici, c'est qu'il y a eu une erreur de manipulation de l'URL appelée
print "Content-type: text/html; charset=UTF-8\n\n";
print "<title>Interface d'administration &bull; Confort de lecture</title><link href=\"/favicon.png\" rel=\"shortcut icon\"><h1>Interface d'administration</h1><a href=\"".$embeddedMode."/admin/sites/list\">Accès à la liste des sites</a><br><a href=\"".$embeddedMode."/admin/glossary\">Accès au glossaire</a>";
