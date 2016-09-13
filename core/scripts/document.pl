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

use Cwd;

use LWP::UserAgent;

use Digest::SHA::PurePerl qw(sha1_hex);

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;

use lib '../modules/html';
use misc_html;


# Création de l'objet CGI
my $cgi = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";

# Extraction des différents paramètres dans l'URL réécrite
my ($action, $siteId, $contentType, $requestMethod, $defaultLanguage, $urlToParse, $secure);
$thisCdlUrl =~ s/^((\/cdl)?\/document(\-http(s))?(\/(ouvrir|telecharger))?\/(.*?)\/(.*?)\/(.*?)\/(.*?)\/cdl\-url\/(.*?)(\?|$))/
	$embeddedMode = $2;
	$action = $6;
	$siteId = $7;
	$contentType = $8;
	$requestMethod = $9;
	$defaultLanguage = $10;
	$urlToParse = $11;
	$secure = $4;
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

# Inclusion du module extension général à tous les sites
require($cdlSitesConfigPath."default_override.pm");

# Inclusion du module extension spécifique au site s'il y en a un
if (-e $cdlSitesConfigPath.$siteId."/override/main.pm") {
	require($cdlSitesConfigPath.$siteId."/override/main.pm");
}

my $defaultConfiguration = loadConfig($cdlSitesConfigPath."default.ini");
my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
my $enableAudio = getConfig($siteConfiguration, 'enableAudio');
$enableAudio = $enableAudio eq "" ? getConfig($defaultConfiguration, 'enableAudio') : $enableAudio;
my $activateAudio = $enableAudio ? loadFromSession($session, 'activateAudio') : 0;
my $ttsMode = getConfig($siteConfiguration, 'ttsMode');
$ttsMode = $ttsMode eq "" ? getConfig($defaultConfiguration, 'ttsMode') : $ttsMode;

# Génération de la table des hachage des paramètres
my @paramKeys = param;
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	my @paramValuesArray = param($paramKey);
	$requestParameters{$paramKey} = \@paramValuesArray;
}
delete($requestParameters{'cdlreferer'});

if ($action) {
	# Téléchargement du fichier
	redirectDownload($action, uc($requestMethod), "http".$secure."://".$urlToParse, $session, $siteId, %requestParameters);
} else {
	# Initialisation de l'entête
	print $session->header('Content-type' => "text/html; charset=UTF-8");

	# Chargement de la template principale de la page de document
	my $documentPageTemplateString = loadConfig($cdlTemplatesPath."document.html");

	# Mettre les bonnes valeurs à la place des marqueurs dans le chaîne template

	# Mettre les liens qui permettent d'aller modifier la personnalisation
	my $language = loadFromSession($session, 'language');
	my $contrast = loadFromSession($session, 'contrast');
	$language = $language ? $language : ($defaultLanguage ? $defaultLanguage : "fr");
	$contrast = $contrast ? $contrast : "bn";

	my $pageUriForHtml = $urlToParse;
	$pageUriForHtml =~ s/&amp;/&/sgi;
	$pageUriForHtml =~ s/&/&amp;/sgi;

	if ($embeddedMode ne "") {
		$pageUriForHtml =~ s/^(https?:\/\/)?[^\/]+\/?//sgi;
	}

	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'PERSONALIZATION_URL', $language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".($requestMethod =~ m/post/si ? putParametersInUrlForHtml($pageUriForHtml, %requestParameters) : $pageUriForHtml));

	my $iconContent;
	open ICON_FILE, "< ".$cdlRootPath."/design/images/display.svg";
	$iconContent = do { local $/; <ICON_FILE> };
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DISPLAY_ICON', $iconContent);

	# L'identifiant du site
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'SITE_ID', $siteId);

	# La langue du site
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'LANGUAGE', $language);

	# Le type mime du document (donné en paramètre)
	$contentType =~ s/\+/ /sgi;
	$contentType =~ s/_/\+/sgi;
	$contentType =~ s/\/x-/\//sgi;
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_TYPE', urlDecode($contentType));

	$thisCdlUrl =~ s/^($embeddedMode\/document)(\/.*)$/$1."\/ouvrir".$2/segi;
	# L'URL du script pour ouverture directe
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_OPEN_URL', $thisCdlUrl);

	$thisCdlUrl =~ s/^($embeddedMode\/document)\/ouvrir(\/.*)$/$1."\/telecharger".$2/segi;
	# L'URL du script pour téléchargement
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_DOWNLOAD_URL', $thisCdlUrl);

	# L'URL de la page précédente pour annuler et retourner
	if ($ENV{'HTTP_REFERER'}) {
		my $previousPage = $ENV{'HTTP_REFERER'};
		$previousPage =~ s///sgi;
		$previousPage =~ s/&amp;/&/sgi;
		$previousPage =~ s/&/&amp;/sgi;
		my $cryptedUrl = sha1_hex($pageUriForHtml);
		$pageUriForHtml = quotemeta $pageUriForHtml;
		if ($previousPage =~ /$pageUriForHtml$/) {
			$previousPage = loadFromSession($session, 'cdl_referer_for_document_'.$siteId.'_'.$cryptedUrl);
			if (!$previousPage) {
				$previousPage = "http".$secure."://".$ENV{'SERVER_NAME'}.($embeddedMode ne "" ? $embeddedMode."/f" : "/le-filtre/".$siteId);
			}
		} else {
			$previousPage = $ENV{'HTTP_REFERER'};
			editInSession($session, 'cdl_referer_for_document_'.$siteId.'_'.$cryptedUrl, $previousPage);
		}

		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK', setValueInTemplateString(getPartOfTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK'), 'PREVIOUS_PAGE', $previousPage));
	} else {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK', "");
	}

	# Gestion du cache :
	# Sauvegarder du contenu de la page dans un fichier temporaire
	my $pageContentFile = savePageContentInCache($requestMethod, putParametersInUrl($urlToParse, %requestParameters), $documentPageTemplateString, loadFromSession($session, 'positionLocation')."_".loadFromSession($session, 'activateJavascript')."_".loadFromSession($session, 'activateFrames')."_".loadFromSession($session, 'displayImages')."_".loadFromSession($session, 'displayObjects')."_".loadFromSession($session, 'displayApplets')."_".loadFromSession($session, 'parseTablesToList'));

	# Mettre le nom de ce fichier temporaire en parametre du lien vers le script de génération en audio
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'CONTENT_TO_READ_WITH_ACAPELA', $pageContentFile);

	my $fontSize = loadFromSession($session, 'fontSize');
	$fontSize = $fontSize ? $fontSize : 3;
	if ($activateAudio eq "1") {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', getPartOfTemplateString($documentPageTemplateString, 'JS_AUDIO_FILE_INCLUDE'));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO', getPartOfTemplateString($documentPageTemplateString, 'AUDIO'));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'MP3_PLAYER_WIDTH', 250+3.4*(($fontSize - 1)*20));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'MP3_PLAYER_HEIGHT', 50+0.7*(($fontSize - 1)*20));
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DIV_MP3_PLAYER_HEIGHT', 40+0.7*(($fontSize - 1)*20));
		# Mettre le nom de domaine pour complèter les URLs absolues
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO_SERVER_NAME', $ENV{'SERVER_NAME'}.$embeddedMode);
	} else {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'JS_AUDIO_FILE_INCLUDE', "");
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO', "");
	}
	if ($enableAudio eq "1") {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO_ACTIONS', getPartOfTemplateString($documentPageTemplateString, 'AUDIO_ACTIONS'));

		open ICON_FILE, "< ".$cdlRootPath."/design/images/audio.svg";
		$iconContent = do { local $/; <ICON_FILE> };
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO_ICON', $iconContent);

		open ICON_FILE, "< ".$cdlRootPath."/design/images/audio_help.svg";
		$iconContent = do { local $/; <ICON_FILE> };
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO_HELP_ICON', $iconContent);
	} else {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'AUDIO_ACTIONS', "");
	}

	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'EMBEDDED_URL', $embeddedMode);

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

	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'B_COLOR', $backgroundColor);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'F_COLOR', $fontColor);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'L_COLOR', $linkColor);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'F_SIZE', $fontSize);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'ICON_SIZE', 40+0.7*(($fontSize - 1)*20));
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'L_SPACING', $letterSpacing);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'W_SPACING', $wordSpacing);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'L_HEIGHT', $lineHeight);
	if (isBigCursorNotAllowed()) {
		$fontSize = 1;
	}
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'FONT_SIZE_BROWSER_DEPENDS', $fontSize);

	my @now = localtime(time);
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);

	print $documentPageTemplateString;
}