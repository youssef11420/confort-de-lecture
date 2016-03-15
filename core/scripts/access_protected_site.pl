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

# File: access_protected_site.pl
#	Script de traitement des sites protégés (suite à un retour HTTP 401)

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use Cwd;

use LWP::UserAgent;

use Digest::SHA1  qw(sha1_hex);

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;

use lib '../modules/html';
use misc_html;


# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";

# Extraction des différents paramètres dans l'URL réécrite
my ($siteId, $requestMethod, $defaultLanguage, $urlToParse, $secure);
$thisCdlUrl =~ s/^((\/cdl)?\/acces\-protege(\-http(s))?\/([^\/]*)\/([^\/]*)\/([^\/]*)\/cdl\-url\/([^\?]*))/
	$embeddedMode = $2;
	$secure = $4;
	$siteId = $5;
	$requestMethod = $6;
	$defaultLanguage = $7;
	$urlToParse = $8;
	$1/segi;

if (!$siteId and $embeddedMode ne "") {
	my $siteDomain = $ENV{'SERVER_NAME'};
	$siteId = getSiteFromDomain($siteDomain);
}

# Détection d'erreurs au niveau de l'identifiant du site
if (!$siteId) {
	die "Aucun identifiant de site n'a été renseigné.\n";
	exit;
}
if (!existConfigDirectory($siteId)) {
	die "Aucun site ne correspond à l'identifiant : ".$siteId.".\n";
	exit;
}

my $defaultConfiguration = loadConfig($cdlSitesConfigPath."default.ini");
my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
my $activateAudio = getConfig($siteConfiguration, 'activateAudio');
if ($activateAudio eq "") {
	$activateAudio = getConfig($defaultConfiguration, 'activateAudio');
}

# Création de l'objet CGI
my $cgi = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

my @paramKeys = param;

# Génération de la table des hachage des paramètres
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	my @paramValuesArray = param($paramKey);
	$requestParameters{$paramKey} = \@paramValuesArray;
}

if ((param('cdlact') eq "c") and (param('cdlloginerror') ne "1")) {
	# Suppression des paramètres propres à CDL pour qu'ils ne soient pas envoyés dans la requête
	delete($requestParameters{'cdlact'});

	# Récupération du login de l'utilisateur
	my $userLogin = $requestParameters{'cdllogin'};
	delete($requestParameters{'cdllogin'});
	# Récupération du mot de passe de l'utilisateur
	my $passwd = $requestParameters{'cdlpasswd'};
	delete($requestParameters{'cdlpasswd'});

	delete($requestParameters{'cdlvalider'});

	# Récupération du paramètre d'authentification realm
	my $realm = loadFromSession($session, 'cdl_'.$siteId.'_realm');

	# Accès à la page protégée
	connectProtectedSite($cgi, $requestMethod, "http".$secure."://".$urlToParse, $userLogin->[0], $passwd->[0], $realm, $session, $siteId, %requestParameters);
} else {
	# Initialisation de l'entête
	print $session->header('Content-type' => "text/html; charset=UTF-8");

	# Chargement de la template principale de la page de document
	my $protectedPageTemplateString = loadConfig($cdlTemplatesPath."access_protected_login_form.html");

	# Mettre les bonnes valeurs à la place des marqueurs dans le chaîne template

	# L'identifiant du site
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'SITE_ID', $siteId);

	# La langue du site
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'LANGUAGE', $defaultLanguage);

	# Tous les paramètres reçus (cf index.pl)
	my $hiddenParams = "";

	foreach my $paramKey (keys(%requestParameters)) {
		if ($paramKey !~ m/^cdl/si) {
			my $refParamValues = $requestParameters{$paramKey};
			my @paramValues = @$refParamValues;
			foreach my $paramValue (@paramValues) {
				$hiddenParams .= "<input type=\"hidden\" name=\"".$paramKey."\" value=\"".$paramValue."\">\n";
			}
		} else {
			delete($requestParameters{$paramKey});
		}
	}

	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'HIDDEN_PARAMETERS', $hiddenParams);

	# S'il y a eu une erreur d'authentification, on en notifie l'utilisateur
	if (param('cdlloginerror') eq "1") {
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'ERROR_LOGIN_MESSAGE', "<strong>Vos identifiants sont incorrects. Veuillez r&eacute;essayer.</strong>");
	} else {
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'ERROR_LOGIN_MESSAGE', "");
	}

	# Gestion du cache :
	# Sauvegarder du contenu de la page dans un fichier temporaire
	my $pageContentFile = savePageContentInCache($requestMethod, putParametersInUrl($urlToParse, %requestParameters), $protectedPageTemplateString, loadFromSession($session, 'positionLocation')."_".loadFromSession($session, 'activateJavascript')."_".loadFromSession($session, 'activateFrames')."_".loadFromSession($session, 'displayImages')."_".loadFromSession($session, 'displayObjects')."_".loadFromSession($session, 'displayApplets')."_".loadFromSession($session, 'parseTablesToList'));

	# Mettre le nom de ce fichier temporaire en parametre du lien vers le script de génération en audio
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'CONTENT_TO_READ_WITH_ACAPELA', $pageContentFile);

	if ($activateAudio) {
		# Récupération de la session de la variable indiquant si l'audio est activé
		$activateAudio = loadFromSession($session, 'activateAudio');
	}

	my $fontSize = loadFromSession($session, 'fontSize');
	$fontSize = $fontSize ? $fontSize : 3;
	if ($activateAudio eq "1") {
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'JS_LIBRARY', getPartOfTemplateString($protectedPageTemplateString, 'JS_LIBRARY'));
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', getPartOfTemplateString($protectedPageTemplateString, 'JS_AUDIO_FILE_INCLUDE'));
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'AUDIO', getPartOfTemplateString($protectedPageTemplateString, 'AUDIO'));
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'MP3_PLAYER_WIDTH', 200+3.85*(($fontSize - 1)*20));
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'MP3_PLAYER_HEIGHT', 50+0.7*(($fontSize - 1)*20));
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'DIV_MP3_PLAYER_HEIGHT', 40+0.7*(($fontSize - 1)*20));
		# Mettre le nom de domaine pour complèter les URLs absolues
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'SERVER_NAME', $ENV{'SERVER_NAME'});
	} else {
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'JS_LIBRARY', "");
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', "");
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'AUDIO', "");
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

	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'B_COLOR', $backgroundColor);
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'F_COLOR', $fontColor);
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'L_COLOR', $linkColor);
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'F_SIZE', $fontSize);
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'L_SPACING', $letterSpacing);
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'W_SPACING', $wordSpacing);
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'L_HEIGHT', $lineHeight);
	if (isBigCursorNotAllowed()) {
		$fontSize = 1;
	}
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'FONT_SIZE_BROWSER_DEPENDS', $fontSize);

	my @now = localtime(time);
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);

	print $protectedPageTemplateString;
}
