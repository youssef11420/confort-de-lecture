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

# File: exit_from_cdl.pl
#	Script de porte de sortie de CDL vers un site qui n'est pas géré par CDL

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use HTML::Entities;

use lib '../../includes';
use constants;
use general_utilities;
use session;
use config_manager;

use lib '../modules/general';
use general_html_utils;


# Création de l'objet CGI
my $cgi = new CGI;

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

print $session->header('Content-type' => "text/html; charset=ISO-8859-1");

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

# Extraction des différents paramètres dans l'URL réécrite
my ($defaultLanguage, $urlToParse);
$thisCdlUrl =~ s/^(\/sortie\/(.*?)\/(.*?)(\?|$))/
	$defaultLanguage = $2;
	$urlToParse = $3;
	$1/segi;

# Chargement de la template principale de la page de sortie vers un site externe
$exitPageTemplateString = loadConfig($cdlTemplatesPath."exit_from_cdl.html");

# La langue du site
$exitPageTemplateString = setValueInTemplateString($exitPageTemplateString, 'LANGUAGE', $defaultLanguage);

my @paramKeys = param;

# Génération de la table des hachage des paramètres
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	if ($paramKey !~ m/^cdl/si) {
		$requestParameters{$paramKey} = param($paramKey);
	}
}

# L'URL externe vers laquelle on sort
$exitPageTemplateString = setValueInTemplateString($exitPageTemplateString, 'EXTERNAL_URL', cleanIllegalChars(urlDecode(putParametersInUrl($urlToParse, %requestParameters))));

# L'URL de la page précédente pour annuler et retourner
$exitPageTemplateString = setValueInTemplateString($exitPageTemplateString, 'PREVIOUS_PAGE', cleanIllegalChars($ENV{'HTTP_REFERER'}));

print $exitPageTemplateString;