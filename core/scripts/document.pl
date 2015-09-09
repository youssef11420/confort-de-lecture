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

# File: document.pl
#	Script de traitement des documents distants

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use LWP::UserAgent;

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;

use lib '../modules/html';
use misc_html;


# Création de l'objet CGI
my $cgi = new CGI;

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

# Extraction des différents paramètres dans l'URL réécrite
my ($action, $siteId, $contentType, $requestMethod, $defaultLanguage, $urlToParse, $secure);
$thisCdlUrl =~ s/^(\/document\-https(\/(ouvrir|telecharger))?\/(.*?)\/(.*?)\/(.*?)\/(.*?)\/cdl\-url\/(.*?)(\?|$))/
	$action = $3;
	$siteId = $4;
	$contentType = $5;
	$requestMethod = $6;
	$defaultLanguage = $7;
	$urlToParse = $8;
	$secure = "s";
	$1/segi;
$thisCdlUrl =~ s/^(\/document(\/(ouvrir|telecharger))?\/(.*?)\/(.*?)\/(.*?)\/(.*?)\/cdl\-url\/(.*?)(\?|$))/
	$action = $3;
	$siteId = $4;
	$contentType = $5;
	$requestMethod = $6;
	$defaultLanguage = $7;
	$urlToParse = $8;
	$1/segi;

# Détection d'erreurs au niveau de l'identifiant du site
if (!$siteId) {
	die "Aucun identifiant de site n'a été renseigné.\n";
	exit;
}
if (!existConfigDirectory($siteId)) {
	die "Aucun site ne correspond à l'identifiant : ".$siteId.".\n";
	exit;
}

# Inclusion du module extension général à tous les sites
require($cdlSitesConfigPath."default_override.pm");

# Inclusion du module extension spécifique au site s'il y en a un
if (-e $cdlSitesConfigPath.$siteId."/override/main.pm") {
	require($cdlSitesConfigPath.$siteId."/override/main.pm");
}

my $defaultConfiguration = loadConfig($cdlSitesConfigPath."default.ini");
my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
my $enableAudio = getConfig($siteConfiguration, 'enableAudio');
if ($enableAudio eq "") {
	$enableAudio = getConfig($defaultConfiguration, 'enableAudio');
}

if ($action) {
	# Génération de la table des hachage des paramètres
	my @paramKeys = param;
	my %requestParameters;
	foreach my $paramKey (@paramKeys) {
		my @paramValuesArray = param($paramKey);
		$requestParameters{$paramKey} = \@paramValuesArray;
	}
	delete($requestParameters{'cdlreferer'});

	# Téléchargement du fichier
	redirectDownload($action, uc($requestMethod), "http".$secure."://".$urlToParse, $session, $siteId, %requestParameters);
} else {
	# Initialisation de l'entête
	print $session->header('Content-type' => "text/html; charset=UTF-8");

	# Chargement de la template principale de la page de document
	$documentPageTemplateString = loadConfig($cdlTemplatesPath."document.html");

	# Mettre les bonnes valeurs à la place des marqueurs dans le chaîne template

	# L'identifiant du site
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'SITE_ID', $siteId);

	# La langue du site
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'LANGUAGE', $defaultLanguage);

	# Le type mime du document (donné en paramètre)
	$contentType =~ s/\+/ /sgi;
	$contentType =~ s/_/\+/sgi;
	$contentType =~ s/\/x-/\//sgi;
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_TYPE', urlDecode($contentType));

	$thisCdlUrl =~ s/^(\/document)(\/.*)$/$1."\/ouvrir".$2/segi;
	# L'URL du script pour ouverture directe
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_OPEN_URL', $thisCdlUrl);

	$thisCdlUrl =~ s/^(\/document)\/ouvrir(\/.*)$/$1."\/telecharger".$2/segi;
	# L'URL du script pour téléchargement
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_DOWNLOAD_URL', $thisCdlUrl);

	# L'URL de la page précédente pour annuler et retourner
	if ($ENV{'HTTP_REFERER'}) {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK', setValueInTemplateString(getPartOfTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK'), 'PREVIOUS_PAGE', $ENV{'HTTP_REFERER'}));
	} else {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK', "");
	}

	# Gestion du cache :
	# Sauvegarder du contenu de la page dans un fichier temporaire
	my $pageContentFile = savePageContentInCache($requestMethod, putParametersInUrl($urlToParse, %requestParameters), $documentPageTemplateString, loadFromSession($session, 'positionLocation')."_".loadFromSession($session, 'activateJavascript')."_".loadFromSession($session, 'activateFrames')."_".loadFromSession($session, 'displayImages')."_".loadFromSession($session, 'displayObjects')."_".loadFromSession($session, 'displayApplets')."_".loadFromSession($session, 'parseTablesToList'));

	# Mettre le nom de ce fichier temporaire en parametre du lien vers le script de génération en audio
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'CONTENT_TO_READ_WITH_ACAPELA', $pageContentFile);

	if ($enableAudio) {
		# Récupération de la session de la variable indiquant si l'audio est activé
		$activateAudio = loadFromSession($session, 'activateAudio');
	}

	my $fontSize = loadFromSession($session, 'fontSize');
	$fontSize = $fontSize ? $fontSize : 3;
	if ($activateAudio eq "1") {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'JS_LIBRARY', getPartOfTemplateString($documentPageTemplateString, 'JS_LIBRARY'));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', getPartOfTemplateString($documentPageTemplateString, 'JS_AUDIO_FILE_INCLUDE'));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO', getPartOfTemplateString($documentPageTemplateString, 'AUDIO'));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'MP3_PLAYER_WIDTH', 250+3.4*(($fontSize - 1)*20));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'MP3_PLAYER_HEIGHT', 50+0.7*(($fontSize - 1)*20));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DIV_MP3_PLAYER_HEIGHT', 40+0.7*(($fontSize - 1)*20));
		# Mettre le nom de domaine pour complèter les URLs absolues
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'SERVER_NAME', $ENV{'SERVER_NAME'});
	} else {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'JS_LIBRARY', "");
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', "");
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO', "");
	}

	my $backgroundColor = loadFromSession($session, 'backgroundColor');
	my $fontColor = loadFromSession($session, 'fontColor');
	$backgroundColor = $backgroundColor ? $backgroundColor : '000000';
	$fontColor = $fontColor ? $fontColor : 'FFFFFF';

	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'B_COLOR', $backgroundColor);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'F_COLOR', $fontColor);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'F_SIZE', $fontSize);
	if (isBigCursorNotAllowed()) {
		$fontSize = 1;
	}
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'FONT_SIZE_BROWSER_DEPENDS', $fontSize);

	my @now = localtime(time);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'ANNEE_COURANTE', 1900 + $now[5]);

	print $documentPageTemplateString;
}