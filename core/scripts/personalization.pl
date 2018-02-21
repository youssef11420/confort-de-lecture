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

use Cwd;

if (-e "./JSON") {
	use lib 'JSON';
}
use JSON;

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;

use lib '../modules/audio';
use misc_audio;


# Création de l'objet CGI
my $cgi  = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";

# Récupération des paramètres
my ($action, $secure, $secureEmbeddedMode, $language, $contrast, $siteId, $urlToParse);
$thisCdlUrl =~ s/^(\/cdl)\/personnalisation\-([^\/]*)(\-http(s))?\/([a-z]{2})\/(bn|nb)(\/(.*))?$/
	$embeddedMode = $1;
	($action, $secure, $secureEmbeddedMode, $language, $contrast, $siteId, $urlToParse) = ($2, $3, $4, $5, $6, "", $8);
	editInSession($session, 'language', $language);
	editInSession($session, 'contrast', $contrast);
	/segi;
$thisCdlUrl =~ s/^(\/cdl)\/personnalisation(\-http(s))?(\/|\?|$)/$embeddedMode = $1; $secure = $2; $secureEmbeddedMode = $3;/segi;
$thisCdlUrl =~ s/^\/personnalisation(\-http(s))?(\/|\?|$)/$secure = $1; $secureEmbeddedMode = $2;/segi;
$thisCdlUrl =~ s/^\/personnalisation\-([^\/]*)(\-https)?\/([a-z]{2})\/(bn|nb)\/([^\/]*)(\/(.*))?$/
	($action, $secure, $language, $contrast, $siteId, $urlToParse) = ($1, $2, $3, $4, $5, $7);
	editInSession($session, 'language', $language);
	editInSession($session, 'contrast', $contrast);
	/segi;

$thisCdlUrl =~ s/^(\/cdl)\/personnalisation-courante(\-http(s))?.svg$/
	$embeddedMode = $1;
	($action, $secure, $secureEmbeddedMode, $language, $contrast, $siteId, $urlToParse) = ("picto", $2, $3, "fr", "bn", "", "");
		editInSession($session, 'language', $language);
		editInSession($session, 'contrast', $contrast);
	/segi;

$thisCdlUrl =~ s/^\/personnalisation-courante([^\.]+)(\-https)?.svg$/
	($action, $secure, $language, $contrast, $siteId, $urlToParse) = ("picto", $2, "fr", "bn", "", "");
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
	if ($embeddedMode ne "") {
		my $siteDomain = $ENV{'SERVER_NAME'};
		$siteId = getSiteFromDomain($siteDomain);
	} else {
		$siteId = param('cdlid');
		if (!$siteId) {
			die "Aucun identifiant de site n'a été renseigné dans l'URL.\n";
			exit;
		}
	}
}

if (!existConfigDirectory($siteId)) {
	$siteId = param('cdlid');
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné en paramètre.\n";
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

my $backgroundColor = loadFromSession($session, 'backgroundColor');
my $fontColor = loadFromSession($session, 'fontColor');
my $linkColor = loadFromSession($session, 'linkColor');
$backgroundColor = $backgroundColor ? $backgroundColor : ($contrast eq "nb" ? "FFFFFF" : "000000");
$fontColor = $fontColor ? $fontColor : ($contrast eq "nb" ? "000000" : "FFFFFF");
$linkColor = $linkColor ? $linkColor : '';
my $letterSpacing = loadFromSession($session, 'letterSpacing');
my $wordSpacing = loadFromSession($session, 'wordSpacing');
my $lineHeight = loadFromSession($session, 'lineHeight');
$letterSpacing = $letterSpacing ? $letterSpacing : '1';
$wordSpacing = $wordSpacing ? $wordSpacing : '1';
$lineHeight = $lineHeight ? $lineHeight : '1';

use Digest::SHA::PurePerl qw(sha1_hex);
use MIME::Base64;

my $voice = loadFromSession($session, 'voice');
if (!$voice) {
	$voice = "";
}
if ($voice and !exists($unordoredVoices{$voice})) {
	$voice = $defaultVoice;
	editInSession($session, 'voice', $voice);
}

my $speed = loadFromSession($session, 'speed');
if (!$speed) {
	$speed = "";
}

my $lettersPlayers = "";
my $lettersHtmlCacheFile = "letters_bis_".($voice ? $voice : $defaultVoice)."_".($speed ne "" ? $speed : $defaultSpeed).".html";
if (!-e $cdlAudioCachePath.$lettersHtmlCacheFile) {
	foreach my $letterKey (keys(%checkedToSpell)) {
		$lettersPlayers .= "<audio preload=\"auto\" src=\"".$embeddedMode."/audio-text/".$siteId."/?cdltext=".urlEncode($checkedToSpell{$letterKey})."&amp;cdlvoice=".($voice ? $voice : $defaultVoice)."&amp;cdlspeed=".($speed ne "" ? $speed : $defaultSpeed)."\" class=\"cdlHidden\" id=\"lecteurAudioCDL_".$letterKey."\"></audio>\n";
	}
	open(WRITER, ">", $cdlAudioCachePath.$lettersHtmlCacheFile) or die "Erreur d'ouverture du fichier : ".$cdlAudioCachePath.$lettersHtmlCacheFile.".\n";
	print WRITER ($lettersPlayers);
	close(WRITER);
}

my $personalizationTemplateString = "";
if ($action =~ m/^affichage$/si) {
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."display.html");

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'EMBEDDED_URL', $embeddedMode);

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR_'.$backgroundColor, " class=\"choiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR_'.$fontColor, " class=\"choiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_COLOR_'.$linkColor, " class=\"choiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE_'.$fontSize, " class=\"choiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_COLOR_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE_\d+', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR2_'.$backgroundColor, " class=\"linkChoiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR2_'.$fontColor, " class=\"linkChoiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_COLOR2_'.$linkColor, " class=\"linkChoiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE2_'.$fontSize, " class=\"linkChoiceSelected\"");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR2_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR2_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_COLOR2_[0-9a-fA-F]{6}', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE2_\d+', "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR', $backgroundColor);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR', $fontColor);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_COLOR', $linkColor);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE_INDEX', $fontSize);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE', $fontSizes{$fontSize});
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_SPACING', $letterSpacing);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'W_SPACING', $wordSpacing);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_HEIGHT', $lineHeight);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ICON_SIZE', 40+0.7*(($fontSize - 1)*20));
} elsif ($action =~ m/^avancee$/si) {
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."advanced.html");

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'EMBEDDED_URL', $embeddedMode);

	# Chargement des paramètres utilisateur
	my $positionLocation = loadFromSession($session, 'positionLocation');
	my $activateJavascript = loadFromSession($session, 'activateJavascript');
	my $displayImages = loadFromSession($session, 'displayImages');
	my $displayObjects = loadFromSession($session, 'displayObjects');
	my $parseTablesToList = loadFromSession($session, 'parseTablesToList');

	# Si un paramètre n'est pas renseigné, on met celui par défaut du site
	if ($positionLocation eq "") {
		$positionLocation = getConfig($siteConfiguration, 'positionLocation');
	}
	if ($activateJavascript eq "") {
		$activateJavascript = getConfig($siteConfiguration, 'activateJavascript');
	}
	if ($displayImages eq "") {
		$displayImages = getConfig($siteConfiguration, 'displayImages');
	}
	if ($displayObjects eq "") {
		$displayObjects = getConfig($siteConfiguration, 'displayObjects');
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
	if ($displayImages eq "") {
		$displayImages = getConfig($defaultConfiguration, 'displayImages');
	}
	if ($displayObjects eq "") {
		$displayObjects = getConfig($defaultConfiguration, 'displayObjects');
	}
	if ($parseTablesToList eq "") {
		$parseTablesToList = getConfig($defaultConfiguration, 'parseTablesToList');
	}

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'LETTER_SPACINGS', encode_json(\%letterSpacings));
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'WORD_SPACINGS', encode_json(\%wordSpacings));
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'LINE_HEIGHTS', encode_json(\%lineHeights));

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_SPACING2_1', $letterSpacing eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_SPACING2_2', $letterSpacing eq "2" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_SPACING2_3', $letterSpacing eq "3" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'W_SPACING2_1', $wordSpacing eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'W_SPACING2_2', $wordSpacing eq "2" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'W_SPACING2_3', $wordSpacing eq "3" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_HEIGHT2_1', $lineHeight eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_HEIGHT2_2', $lineHeight eq "2" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_HEIGHT2_3', $lineHeight eq "3" ? " checked" : "");

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ARIANE_TOP', (!$positionLocation or $positionLocation eq "1" or $positionLocation eq "3") ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ARIANE_BOTTOM', ($positionLocation eq "2" or $positionLocation eq "3") ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'IMG_YES', $displayImages eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'IMG_NO', $displayImages eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'OBJECT_YES', $displayObjects eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'OBJECT_NO', $displayObjects eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'TABLE_YES', $parseTablesToList eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'TABLE_NO', $parseTablesToList eq "1" ? "" : " checked");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'JS_YES', $activateJavascript eq "1" ? " checked" : "");
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'JS_NO', $activateJavascript eq "1" ? "" : " checked");
} elsif ($action =~ m/^audio$/si) {
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."audio.html");

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'EMBEDDED_URL', $embeddedMode);

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

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'EMBEDDED_URL', $embeddedMode);
} elsif ($action =~ m/^palette\-couleurs\-(b|f|l)$/si) {
	my $paramToSet = $1;
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."more_colors.html");

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'EMBEDDED_URL', $embeddedMode);

	my $color;
	if ($paramToSet eq "b") {
		$color = loadFromSession($session, 'backgroundColor');
		$color = $color ? $color : ($contrast eq "nb" ? "FFFFFF" : "000000");
	} elsif ($paramToSet eq "f") {
		$color = loadFromSession($session, 'fontColor');
		$color = $color ? $color : ($contrast eq "nb" ? "FFFFFF" : "000000");
	} else {
		$color = loadFromSession($session, 'linkColor');
	}

	my $colorChoices = "";
	my $colorIndex = 1;
	foreach my $colorGroup (@allColors) {
		my @colorsGroup = split(/,/, $colorGroup);
		$colorChoices .= "<div class=\"cdlColors\"><ul>";
		foreach my $colorItem (@colorsGroup) {
			$colorChoices .= "<li id=\"cdlColorConfig".$colorItem."\"".($colorItem eq $color ? " class=\"choiceSelected\"" : "")."><a href=\"".$embeddedMode."/personnalisation?more".($paramToSet eq "b" ? "background" : ($paramToSet eq "f" ? "font" : ($paramToSet eq "l" ? "link" : "")))."colors=1&amp;cdl###PARAM_TO_SET###c=".$colorItem."&amp;cdlid=###SITE_ID###&amp;cdlurl=###URL_TO_PARSE####cdlColorConfig".$colorItem."\"><span><span>".sprintf("%02d", $colorIndex)."</span><span>".sprintf("%02d", $colorIndex)."</span></span><span class=\"cdlTransPix\" style=\"background-color:#".$colorItem."\"></span><span class=\"cdlSpanHidden\">###_DICO_LABEL_COULEUR### #<span>".$colorItem."</span></span></a>";
			$colorIndex++;
		}
		$colorChoices .= "</ul></div>";
	}
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'COLOR_LIST', $colorChoices);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'PARAM_TO_SET', $paramToSet);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'COLOR_CHOSEN', $color);
} elsif ($action =~ m/^tailles-texte$/si) {
	$personalizationTemplateString = loadConfig($cdlTemplatesPath."more_sizes.html");

	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'EMBEDDED_URL', $embeddedMode);

	my $size = loadFromSession($session, 'fontSize');

	my $sizeChoices = "";
	foreach my $sizeItem (sort keys(%fontSizes)) {
		$sizeChoices .= "<li id=\"cdlSizeConfig".$sizeItem."\"".($sizeItem eq $size ? " class=\"choiceSelected\"" : "")."><a href=\"".$embeddedMode."/personnalisation?moretextsizes=1&amp;cdlfs=".$sizeItem."&amp;cdlid=###SITE_ID###&amp;cdlurl=###URL_TO_PARSE####cdlSizeConfig".$sizeItem."\"><span class=\"cdlTransPix\" style=\"font-size:".$fontSizes{$sizeItem}."%\"></span><span class=\"cdlSpanHidden\">###_DICO_LABEL_TAILLE### <span>".$sizeItem."</span>, ###_DICO_TEXTE_SOIT###".$fontSizes{$sizeItem}."% (".int($fontSizes{$sizeItem} * 16 / 100)." pixels)</span></a>";
	}
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'SIZE_LIST', $sizeChoices);
	$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'SIZE_CHOSEN', $size);
} elsif ($action =~ m/^picto$/si) {
	$personalizationTemplateString = loadConfig($cdlRootPath."/design/images/profile_icon.svg");
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
	if (param('cdllc') ne "") {
		editInSession($session, 'linkColor', param('cdllc'));
	}
	if (param('cdlfs') ne "") {
		editInSession($session, 'fontSize', param('cdlfs'));
	}
	if (param('cdlls') ne "") {
		editInSession($session, 'letterSpacing', param('cdlls'));
	}
	if (param('cdlws') ne "") {
		editInSession($session, 'wordSpacing', param('cdlws'));
	}
	if (param('cdllh') ne "") {
		editInSession($session, 'lineHeight', param('cdllh'));
	}
	my @positionLocation = param('cdlariane[]');
	my $positionLocationLength = scalar @positionLocation;
	if ($positionLocationLength > 0) {
		editInSession($session, 'positionLocation', $positionLocationLength eq 2 ? "3" : $positionLocation[0]);
	}
	if (param('cdljs') ne "") {
		editInSession($session, 'activateJavascript', param('cdljs'));
	}
	if (param('cdlimg') ne "") {
		editInSession($session, 'displayImages', param('cdlimg'));
	}
	if (param('cdlobject') ne "") {
		editInSession($session, 'displayObjects', param('cdlobject'));
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
	my $cookie = CGI::Cookie->new(-name=>$session->name, -value=>$session->id);

	if ($action =~ m/^audio\-acces\-direct$/si) {
		if ($enableAudio) {
			editInSession($session, 'activateAudio', "1");
		} else {
			editInSession($session, 'activateAudio', "0");
		}

		# Rediriger vers le script principal (page filtrée)
		my $redirectUrl = ($embeddedMode ne "" ? $embeddedMode."/f".$secureEmbeddedMode : "/le-filtre".$secure."/".$siteId)."/".$urlToParse;

		print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
		exit;
	}

	if ($action =~ m/^acces\-direct$/si) {
		editInSession($session, 'activateAudio', "0");

		# Rediriger vers le script principal (page filtrée)
		my $redirectUrl = ($embeddedMode ne "" ? $embeddedMode."/f".$secureEmbeddedMode : "/le-filtre".$secure."/".$siteId)."/".$urlToParse;

		print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
		exit;
	}

	$urlToParse = urlDecode(param('cdlurl'));

	if (param('cdlvalidate') or $action =~ m/^audio\-acces\-direct$/si) {
		# Rediriger vers le script principal (page filtrée)
		my $redirectUrl = ($embeddedMode ne "" ? $embeddedMode."/f".$secureEmbeddedMode : "/le-filtre".$secure."/".$siteId)."/".$urlToParse;

		print $cgi->header(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
		exit;
	}

	if (param('cdladvancedparameters')) {
		print $cgi->header(-status=>"302 Moved", -location=>$embeddedMode."/personnalisation-avancee".$secure."/".$language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('morebackgroundcolors')) {
		print $cgi->header(-status=>"302 Moved", -location=>$embeddedMode."/personnalisation-palette-couleurs-b".$secure."/".$language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('moretextsizes')) {
		print $cgi->header(-status=>"302 Moved", -location=>$embeddedMode."/personnalisation-tailles-texte".$secure."/".$language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('morefontcolors')) {
		print $cgi->header(-status=>"302 Moved", -location=>$embeddedMode."/personnalisation-palette-couleurs-f".$secure."/".$language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('morelinkcolors')) {
		print $cgi->header(-status=>"302 Moved", -location=>$embeddedMode."/personnalisation-palette-couleurs-l".$secure."/".$language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('cdlvalidateadvanced') or param('cdlchangedisplay')) {
		print $cgi->header(-status=>"302 Moved", -location=>$embeddedMode."/personnalisation-affichage".$secure."/".$language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('cdlchangeaudio')) {
		print $cgi->header(-status=>"302 Moved", -location=>$embeddedMode."/personnalisation-audio".$secure."/".$language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
	if (param('cdlchangeaudiohelp')) {
		print $cgi->header(-status=>"302 Moved", -location=>$embeddedMode."/personnalisation-aide-audio".$secure."/".$language."/".$contrast.($embeddedMode ne "" ? "" : "/".$siteId)."/".$urlToParse, -cookie=>$cookie);
		exit;
	}
}

$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'SECURE', $secure);

my $iconContent;
open ICON_FILE, "< ".$cdlRootPath."/design/images/display.svg";
$iconContent = do { local $/; <ICON_FILE> };
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'DISPLAY_ICON', $iconContent);

open ICON_FILE, "< ".$cdlRootPath."/design/images/audio.svg";
$iconContent = do { local $/; <ICON_FILE> };
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO_ICON', $iconContent);

open ICON_FILE, "< ".$cdlRootPath."/design/images/audio_help.svg";
$iconContent = do { local $/; <ICON_FILE> };
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO_HELP_ICON', $iconContent);

$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'B_COLOR', $backgroundColor);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_COLOR', $fontColor);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_COLOR', $linkColor);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE_INDEX', $fontSize);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'F_SIZE', $fontSizes{$fontSize});
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_SPACING', $letterSpacing);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'W_SPACING', $wordSpacing);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'L_HEIGHT', $lineHeight);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'ICON_SIZE', 40+0.7*(($fontSize - 1)*20));
my $pageMarginTop = $fontSize eq "" ? "86" : "".58+0.7*(($fontSize - 1)*20);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'PAGE_MARGIN_TOP', $pageMarginTop);

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

$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'AUDIO_SERVER_NAME', $ENV{'SERVER_NAME'}.$embeddedMode);

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

$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'LETTERS_PLAYERS_FILE', $embeddedMode."/cache/audio/".$lettersHtmlCacheFile);

my @now = localtime(time);
$personalizationTemplateString = setValueInTemplateString($personalizationTemplateString, 'CURRENT_YEAR', 1900 + $now[5]);


$personalizationTemplateString =~ s/\#\#\#_DICO_([^\#]*)\#\#\#/$dictionary{$1}/segi;

my $typeMime = "text/html; charset=UTF-8";
if ($action =~ m/^picto$/si) {
	$typeMime = "image/svg+xml; charset=utf-8";
}

print $session->header('Content-type' => $typeMime);
print $personalizationTemplateString;