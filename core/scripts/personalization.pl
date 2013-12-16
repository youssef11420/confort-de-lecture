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

# File: personalization.pl
#	Script de gestion des pages de personnalisation

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;


# Création de l'objet CGI
my $cgi  = new CGI;

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

# Récupération des paramètres
my ($action, $secure, $language, $contrast, $siteId, $urlToParse);
$thisCdlUrl =~ s/^\/personnalisation\-([^\/]*)(\-https)?\/([a-z]{2})\/(bn|nb)\/([^\/]*)(\/(.*))?$/
	($action, $secure, $language, $contrast, $siteId, $urlToParse) = ($1, $2, $3, $4, $5, $7);
	editInSession($session, 'language', $language);
	editInSession($session, 'contrast', $contrast);
	/segi;

# Gestion des langues
if (-e "../modules/dictionary/".$language.".pm") {
	require("../modules/dictionary/".$language.".pm");
} else {
	require("../modules/dictionary/fr.pm");
}

# Détection d'erreurs au niveau de l'identifiant du site
if (!$siteId) {
	$siteId = param('cdlid');
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné.\n";
		exit;
	}
}

if (!existConfigDirectory($siteId)) {
	$siteId = param('cdlid');
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné.\n";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId.".\n";
		exit;
	}
}

# Inclusion du module extension général à tous les sites
require($cdlSitesConfigPath."default_override.pm");

# Inclusion du module extension spécifique au site s'il y en a un
if (-e $cdlSitesConfigPath.$siteId."/override/main.pm") {
	require($cdlSitesConfigPath.$siteId."/override/main.pm");
}

# Chargement des paramètres du site
my $defaultConfiguration = loadConfig($cdlSitesConfigPath."default.ini");
my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
my $siteDomainNames = getConfig($siteConfiguration, 'siteDomainNames');
my @siteDomainNamesArray = split(/\t+/, $siteDomainNames);
my $siteLogo = getConfig($siteConfiguration, 'logo');
my $siteTitle = getConfig($siteConfiguration, 'siteLabel');

my $enableAudio = getConfig($siteConfiguration, 'enableAudio');
if ($enableAudio eq "") {
	$enableAudio = getConfig($defaultConfiguration, 'enableAudio');
}
my $voiceChoice = getConfig($siteConfiguration, 'voiceChoice');
if ($voiceChoice eq "") {
	$voiceChoice = getConfig($defaultConfiguration, 'voiceChoice');
}

my $fontSize = loadFromSession($session, 'fontSize');
$fontSize = $fontSize ? $fontSize : "3";

my $personalizationTemplateString = "";
if ($action =~ m/^affichage$/si) {
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."display.html");

	my $backgroundColor = loadFromSession($session, 'backgroundColor');
	my $fontColor = loadFromSession($session, 'fontColor');
	$backgroundColor = $backgroundColor ? $backgroundColor : ($contrast eq "nb" ? "FFFFFF" : "000000");
	$fontColor = $fontColor ? $fontColor : ($contrast eq "nb" ? "000000" : "FFFFFF");

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR_'.$backgroundColor, " class=\"choiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR_'.$fontColor, " class=\"choiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE_'.$fontSize, " class=\"choiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE_[1-5]', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR2_'.$backgroundColor, " class=\"linkChoiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR2_'.$fontColor, " class=\"linkChoiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE2_'.$fontSize, " class=\"linkChoiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR2_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR2_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE2_[1-5]', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR', $backgroundColor);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR', $fontColor);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE_INDEX', $fontSize);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE', $fontSizes{$fontSize});
} elsif ($action =~ m/^avancee$/si) {
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."advanced.html");

	# Chargement des paramètres utilisateur
	my $positionLocation = loadFromSession($session, 'positionLocation');
	my $activateJavascript = loadFromSession($session, 'activateJavascript');
	my $activateFrames = loadFromSession($session, 'activateFrames');
	my $displayImages = loadFromSession($session, 'displayImages');
	my $displayObjects = loadFromSession($session, 'displayObjects');
	my $displayApplets = loadFromSession($session, 'displayApplets');
	my $parseTablesToList = loadFromSession($session, 'parseTablesToList');

	# Si un paramètre n'est pas renseigné, on met celui par défaut du site
	if ($positionLocation eq "") {
		$positionLocation = getConfig($siteConfiguration, 'positionLocation');
	}
	if ($activateJavascript eq "") {
		$activateJavascript = getConfig($siteConfiguration, 'activateJavascript');
	}
	if ($activateFrames eq "") {
		$activateFrames = getConfig($siteConfiguration, 'activateFrames');
	}
	if ($displayImages eq "") {
		$displayImages = getConfig($siteConfiguration, 'displayImages');
	}
	if ($displayObjects eq "") {
		$displayObjects = getConfig($siteConfiguration, 'displayObjects');
	}
	if ($displayApplets eq "") {
		$displayApplets = getConfig($siteConfiguration, 'displayApplets');
	}
	if ($parseTablesToList eq "") {
		$parseTablesToList = getConfig($siteConfiguration, 'parseTablesToList');
	}

	# Si un paramètre n'est pas renseigné, on met celui par défaut
	if ($positionLocation eq "") {
		$positionLocation = getConfig($defaultConfiguration, 'positionLocation');
	}
	if ($activateJavascript eq "") {
		$activateJavascript = getConfig($defaultConfiguration, 'activateJavascript');
	}
	if ($activateFrames eq "") {
		$activateFrames = getConfig($defaultConfiguration, 'activateFrames');
	}
	if ($displayImages eq "") {
		$displayImages = getConfig($defaultConfiguration, 'displayImages');
	}
	if ($displayObjects eq "") {
		$displayObjects = getConfig($defaultConfiguration, 'displayObjects');
	}
	if ($displayApplets eq "") {
		$displayApplets = getConfig($defaultConfiguration, 'displayApplets');
	}
	if ($parseTablesToList eq "") {
		$parseTablesToList = getConfig($defaultConfiguration, 'parseTablesToList');
	}

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ARIANE_TOP', $positionLocation eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ARIANE_BOTTOM', $positionLocation eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'IMG_YES', $displayImages eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'IMG_NO', $displayImages eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'OBJECT_YES', $displayObjects eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'OBJECT_NO', $displayObjects eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'TABLE_YES', $parseTablesToList eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'TABLE_NO', $parseTablesToList eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'JS_YES', $activateJavascript eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'JS_NO', $activateJavascript eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'FRAME_YES', $activateFrames eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'FRAME_NO', $activateFrames eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'APPLET_YES', $displayApplets eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'APPLET_NO', $displayApplets eq "1" ? "" : " checked");
} elsif ($action =~ m/^audio$/si) {
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."audio.html");

	my $activateAudio = loadFromSession($session, 'activateAudio');
	my $voice = loadFromSession($session, 'voice');
	my $speed = loadFromSession($session, 'speed');
	$activateAudio = $activateAudio ne "" ? $activateAudio : "1";
	$voice = $voice ne "" ? $voice : $defaultVoice;
	$speed = $speed ne "" ? $speed : $defaultSpeed;

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ACTIVATE_AUDIO_YES', $activateAudio eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ACTIVATE_AUDIO_NO', $activateAudio eq "1" ? "" : " checked");

	my $voiceChoices = "";

	if (keys(%voices) == 0) {
		$voiceChoice = 0;
	}
	foreach my $voiceItem (sort keys(%voices)) {
		my $voiceItem2 = $voiceItem;
		$voiceItem2 =~ s/^\d//sgi;
		$voiceChoices .= "<option class=\"cdlDemoVoice-".$voiceItem2."\" title=\"###_DICO_JE_M_APPELLE### ".$voices{$voiceItem}."\" value=\"".$voiceItem2."\"".($voiceItem2 eq $voice ? " selected" : "").">".$voices{$voiceItem};
	}
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO_VOICE_CHOICES', $voiceChoices);

	my %speedTitles = (1 => "###_DICO_TRES_LENTE###", 2 => "###_DICO_LENTE###", 3 => "###_DICO_STANDARD###", 4 => "###_DICO_RAPIDE###", 5 => "###_DICO_TRES_RAPIDE###");

	my $speedChoices = "";
	my $i = 1;
	foreach my $speedItem (@speeds) {
		$speedChoices .= "<option class=\"cdlDemoSpeed-".$speedItem."\" title=\"###_DICO_VITESSE_DE_LECTURE### ".$speedTitles{$i}."\" value=\"".$speedItem."\"".($speedItem eq $speed ? " selected" : "").">".$speedTitles{$i};
		$i++;
	}
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO_SPEED_CHOICES', $speedChoices);
} elsif ($action =~ m/^aide\-audio$/si) {
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."audio_help.html");
} elsif ($action =~ m/^palette\-couleurs\-(b|f)$/si) {
	my $paramToSet = $1;
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."more_colors.html");

	my $color;
	if ($paramToSet eq "b") {
		$color = loadFromSession($session, 'backgroundColor');
		$color = $color ? $color : ($contrast eq "nb" ? "FFFFFF" : "000000");
	} else {
		$color = loadFromSession($session, 'fontColor');
		$color = $color ? $color : ($contrast eq "nb" ? "000000" : "FFFFFF");
	}

	$colorChoices = "";
	foreach my $colorItem (@allColors) {
		$colorChoices .= "<li id=\"cdlColorConfig".$colorItem."\"".($colorItem eq $color ? " class=\"choiceSelected\"" : "")."><a href=\"/personnalisation?more".($paramToSet eq "b" ? "background" : "font")."colors=1&amp;cdl###PARAM_TO_SET###c=".$colorItem."&amp;cdlid=###SITE_ID###&amp;cdlurl=###URL_TO_PARSE####cdlColorConfig".$colorItem."\"><span class=\"cdlTransPix\"><img src=\"/design/images/transparent_pix.png\" alt=\"\" style=\"background-color:#".$colorItem."\"><span class=\"cdlClearBoth\"></span></span><span class=\"cdlSpanHidden\">###_DICO_LABEL_COULEUR### #<span>".$colorItem."</span></span></a>";
	}
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'COLOR_LIST', $colorChoices);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'PARAM_TO_SET', $paramToSet);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'COLOR_CHOSEN', $color);
} else {
	$language = loadFromSession($session, 'language');
	$language = $language ? $language : "fr";
	$contrast = loadFromSession($session, 'contrast');
	$contrast = $contrast ? $contrast : "bn";

	# Mettre les paramètres en session
	if (param('cdlbc') ne "") {
		editInSession($session, 'backgroundColor', param('cdlbc'));
	}
	if (param('cdlfc') ne "") {
		editInSession($session, 'fontColor', param('cdlfc'));
	}
	if (param('cdlfs') ne "") {
		editInSession($session, 'fontSize', param('cdlfs'));
	}
	if (param('cdlariane') ne "") {
		editInSession($session, 'positionLocation', param('cdlariane'));
	}
	if (param('cdljs') ne "") {
		editInSession($session, 'activateJavascript', param('cdljs'));
	}
	if (param('cdlframe') ne "") {
		editInSession($session, 'activateFrames', param('cdlframe'));
	}
	if (param('cdlimg') ne "") {
		editInSession($session, 'displayImages', param('cdlimg'));
	}
	if (param('cdlobject') ne "") {
		editInSession($session, 'displayObjects', param('cdlobject'));
	}
	if (param('cdlapplet') ne "") {
		editInSession($session, 'displayApplets', param('cdlapplet'));
	}
	if (param('cdltable') ne "") {
		editInSession($session, 'parseTablesToList', param('cdltable'));
	}
	if (param('cdlaudio') ne "") {
		editInSession($session, 'activateAudio', param('cdlaudio'));
	}
	if (param('cdlvoice') ne "") {
		editInSession($session, 'voice', param('cdlvoice'));
	}
	if (param('cdlspeed') ne "") {
		editInSession($session, 'speed', param('cdlspeed'));
	}

	# Envoyer le cookie représentant la session
	my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);

	if ($action =~ m/^audio\-acces\-direct$/si) {
		if ($enableAudio) {
			editInSession($session, 'activateAudio', "1");
		} else {
			editInSession($session, 'activateAudio', "0");
		}

		# Rediriger vers le script principal (page filtrée)
		my $redirectUrl = "/le-filtre".$secure."/".$siteId."/".$urlToParse;

		print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
		exit;
	}

	if ($action =~ m/^acces\-direct$/si) {
		editInSession($session, 'activateAudio', "0");

		# Rediriger vers le script principal (page filtrée)
		my $redirectUrl = "/le-filtre".$secure."/".$siteId."/".$urlToParse;

		print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
		exit;
	}

	$urlToParse = urlDecode(param('cdlurl'));

	if (param('cdlvalidate') or $action =~ m/^audio\-acces\-direct$/si) {
		# Rediriger vers le script principal (page filtrée)
		my $redirectUrl = "/le-filtre".$secure."/".$siteId."/".$urlToParse;

		print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
		exit;
	}

	if (param('cdladvancedparameters')) {
		print $cgi->header(-status=>"302 Moved", -location=>"/personnalisation-avancee".$secure."/".$language."/".$contrast."/".$siteId."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('morebackgroundcolors')) {
		print $cgi->header(-status=>"302 Moved", -location=>"/personnalisation-palette-couleurs-b".$secure."/".$language."/".$contrast."/".$siteId."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('morefontcolors')) {
		print $cgi->header(-status=>"302 Moved", -location=>"/personnalisation-palette-couleurs-f".$secure."/".$language."/".$contrast."/".$siteId."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('cdlvalidateadvanced') or param('cdlchangedisplay')) {
		print $cgi->header(-status=>"302 Moved", -location=>"/personnalisation-affichage".$secure."/".$language."/".$contrast."/".$siteId."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('cdlchangeaudio')) {
		print $cgi->header(-status=>"302 Moved", -location=>"/personnalisation-audio".$secure."/".$language."/".$contrast."/".$siteId."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('cdlchangeaudiohelp')) {
		print $cgi->header(-status=>"302 Moved", -location=>"/personnalisation-aide-audio".$secure."/".$language."/".$contrast."/".$siteId."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
}

if ($enableAudio eq "1") {
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO_ACTIONS', getPartOfTemplateString($personalizationTemplateString, 'AUDIO_ACTIONS'));
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'JS_AUDIO_FILE_INCLUDE', getPartOfTemplateString($personalizationTemplateString, 'JS_AUDIO_FILE_INCLUDE'));
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO', getPartOfTemplateString($personalizationTemplateString, 'AUDIO'));
} else {
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO_ACTIONS', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'JS_AUDIO_FILE_INCLUDE', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO', "");
}
if ($voiceChoice eq "1") {
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'VOICE_CHOICE', getPartOfTemplateString($personalizationTemplateString, 'VOICE_CHOICE'));
} else {
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'VOICE_CHOICE', "");
}

$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'SERVER_NAME', $ENV{'SERVER_NAME'});

$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'SITE_ID', $siteId);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'LANGUAGE', $language);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'CONTRAST', $contrast);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'URL_TO_PARSE', urlEncode($urlToParse));

$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'SITE_URL', "http://".$siteDomainNamesArray[0]."/");
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'SITE_LOGO', $siteLogo);
utf8::decode($siteTitle);
utf8::encode($siteTitle);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'SITE_TITLE', $siteTitle);
if ($contrast eq "nb") {
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'CONTRAST_BODY_STYLE', " class=\"cdlContrasted\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'CONTRAST_CSS', getPartOfTemplateString($personalizationTemplateString, 'CONTRAST_CSS'));
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'FLASH_FONT_COLOR', "000000");
} else {
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'CONTRAST_BODY_STYLE', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'CONTRAST_CSS', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'FLASH_FONT_COLOR', "FFFFFF");
}
$fontSize = 3;
if (isBigCursorNotAllowed()) {
	$fontSize = 1;
}
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'FONT_SIZE_BROWSER_DEPENDS', $fontSize);

my @now = localtime(time);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ANNEE_COURANTE', 1900 + $now[5]);


$personalizationTemplateString =~ s/\#\#\#_DICO_([^\#]*)\#\#\#/$dictionary{$1}/segi;

print $session->header('Content-type' => "text/html; charset=UTF-8");
print $personalizationTemplateString;