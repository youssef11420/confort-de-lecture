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

# File: styles.pl
#	Script de génération du style CDL à partir d'une template CSS

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use lib '../../includes';
use constants;
use session;
use config_manager;


# Création de l'objet CGI utile pour la session
my $cgi = new CGI;

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

print $session->header('Content-type' => "text/css", 'Cache-Control' => "no-cache, must-revalidate");

my $backgroundColor = loadFromSession($session, 'backgroundColor');
my $fontColor = loadFromSession($session, 'fontColor');
my $fontSize = loadFromSession($session, 'fontSize');

if ($fontColor eq "") {
	$fontColor = "FFFFFF";
}
if ($backgroundColor eq "") {
	$backgroundColor = "000000";
}
if ($fontSize eq "") {
	$fontSize = "200";
} else {
	$fontSize = $fontSizes{$fontSize};
}

# chargement de la template de style CDL
my $styleString = loadConfig($cdlTemplatesPath."styles".(param('n') eq "ie" ? "_ie" : "").".css");

# Remplissage des markers dans la template de style par les valeurs récupérés en session
$styleString = setValueInTemplateString($styleString, 'FONT_FAMILY', $fontFamily);

$styleString = setValueInTemplateString($styleString, 'FONT_COLOR', $fontColor);
$styleString = setValueInTemplateString($styleString, 'BACKGROUND_COLOR', $backgroundColor);
$styleString = setValueInTemplateString($styleString, 'FONT_SIZE', $fontSize);

print $styleString;