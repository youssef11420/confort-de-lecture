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

# File: styles.pl
#	Script de génération du style CDL à partir d'une template CSS

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use Cwd;

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;


# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";
$thisCdlUrl =~ s/^(\/cdl)?.*/$embeddedMode = $1/segi;

# Récupération de l'id du site courant
my $siteId = param('cdlid');
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

# Création de l'objet CGI utile pour la session
my $cgi = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Chargement de la template de style CDL
my $styleToLoad = param('cdln');
if ($styleToLoad eq "") {
	$styleToLoad = "default";
}
my $styleString = loadConfig($cdlTemplatesPath."css/".$styleToLoad.".css");

$styleString = setValueInTemplateString($styleString, 'EMBEDDED_URL', $embeddedMode);

my ($backgroundColor, $fontColor, $linkColor, $fontSize, $letterSpacing, $wordSpacing, $lineHeight) = (param("cdlbc"), param("cdlfc"), param("cdllc"), param("cdlfs"), param("cdlls"), param("cdlws"), param("cdllh"));

my $pagePaddingTop = $fontSize eq "" ? "94" : "".66+0.7*(($fontSize - 1)*20);
my $pageMarginTop = $fontSize eq "" ? "86" : "".58+0.7*(($fontSize - 1)*20);
my $inputSize = $fontSize eq "" ? "58" : "".30+0.7*(($fontSize - 1)*20);
my $inputBorder = $fontSize eq "" ? "9" : "".5+0.1*(($fontSize - 1)*20);

$fontSize = $fontSize ? $fontSize : '3';
$styleString = setValueInTemplateString($styleString, 'FONT_SIZE_INDEX', isBigCursorNotAllowed() ? 1 : $fontSize);
$styleString = setValueInTemplateString($styleString, 'FONT_SIZE_BROWSER_DEPENDS', isBigCursorNotAllowed() ? 1 : 3);

$backgroundColor = $backgroundColor ? $backgroundColor : '000000';
$fontColor = $fontColor ? $fontColor : 'FFFFFF';
$linkColor = $linkColor ? $linkColor : $linkColor;

$fontSize = $fontSizes{$fontSize};

$letterSpacing = $letterSpacings{$letterSpacing};
$wordSpacing = $wordSpacings{$wordSpacing};
$lineHeight = $lineHeights{$lineHeight};

my $selectArrowSize = $fontSize eq "" ? "9" : "".int($fontSize/18);

# Remplissage des markers dans la template de style par les valeurs récupérés en session

$styleString = setValueInTemplateString($styleString, 'FONT_COLOR', $fontColor);
$styleString = setValueInTemplateString($styleString, 'LINK_COLOR', $linkColor);
$styleString = setValueInTemplateString($styleString, 'BACKGROUND_COLOR', $backgroundColor);
$styleString = setValueInTemplateString($styleString, 'FONT_SIZE', $fontSize);
$styleString = setValueInTemplateString($styleString, 'LETTER_SPACING', $letterSpacing);
$styleString = setValueInTemplateString($styleString, 'WORD_SPACING', $wordSpacing);
$styleString = setValueInTemplateString($styleString, 'LINE_HEIGHT', $lineHeight);
$styleString = setValueInTemplateString($styleString, 'PAGE_PADDING_TOP', $pagePaddingTop);
$styleString = setValueInTemplateString($styleString, 'PAGE_MARGIN_TOP', $pageMarginTop);
$styleString = setValueInTemplateString($styleString, 'INPUT_SIZE', $inputSize);
$styleString = setValueInTemplateString($styleString, 'INPUT_HALF_SIZE', $inputSize / 2);
$styleString = setValueInTemplateString($styleString, 'INPUT_BORDER', $inputBorder);
$styleString = setValueInTemplateString($styleString, 'SELECT_ARROW_SIZE', $selectArrowSize);
$styleString = setValueInTemplateString($styleString, 'SELECT_DOUBLE_ARROW_SIZE', $selectArrowSize * 4);
$styleString = setValueInTemplateString($styleString, 'SELECT_HALF_ARROW_SIZE', $selectArrowSize / 2);

print $session->header('Content-type' => "text/css; charset=UTF-8");
print $styleString;