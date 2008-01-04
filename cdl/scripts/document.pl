#!/usr/bin/perl

#########################################################################
# BEGIN COPYRIGHT, LICENSE AND WARRANTY NOTICE
# SOFTWARE NAME: Confort de lecture
# SOFTWARE RELEASE: 2.0.0
# COPYRIGHT NOTICE: Copyright (C) 2000-2007 GIE Confort de lecture (SQLI & HandicapZ�ro)
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

# File: document.pl
#	Script de traitement des documents distants

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use LWP::UserAgent;

use lib '../modules/includes';
use constants;
use general_utilities;
use session;
use config_manager;

use lib '../modules/general';
use general_html_utils;


# R�cup�ration de l'URL r��crite pour en extraire les informations n�cessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

# Extraction des diff�rents param�tres dans l'URL r��crite
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

# D�tection d'erreurs au niveau de l'identifiant du site
if (!$siteId) {
	die "Aucun identifiant de site n'a �t� renseign�";
	exit;
}
if (!existConfigDirectory($siteId)) {
	die "Aucun site ne correspond � l'identifiant : ".$siteId;
	exit;
}

# Cr�ation de l'objet CGI
my $cgi = new CGI;

# Cr�ation de la session et r�cup�ration de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

if ($action) {
	# G�n�ration de la table des hachage des param�tres
	my @paramKeys = param;
	my %requestParameters;
	foreach my $paramKey (@paramKeys) {
		if (param($paramKey)) {
			$requestParameters{$paramKey} = urlDecode(param($paramKey));
		}
	}
	delete($requestParameters{'cdlreferer'});

	# T�l�chargement du fichier
	redirectDownload($action, $requestMethod, "http".$secure."://".$urlToParse, $session, $siteId, %requestParameters);
} else {
	# Initialisation de l'ent�te
	print $session->header('Content-type' => "text/html; charset=UTF-8");

	# Chargement de la template principale de la page de document
	$documentPageTemplateString = loadConfig($cdlTemplatesPath."document.html");

	# Mettre les bonnes valeurs � la place des marqueurs dans le cha�ne template

	# La langue du site
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'LANGUAGE', $defaultLanguage);

	# Le type mime du document (donn� en param�tre)
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_TYPE', urlDecode($contentType));

	$thisCdlUrl =~ s/^([^\?]*)\??(.*?)$/$1."\?cdlreferer=".urlEncode($ENV{'HTTP_REFERER'})."&".$2/segi;

	$thisCdlUrl =~ s/^(\/document)(\/.*)$/$1."\/ouvrir".$2/segi;
	# L'URL du script pour ouverture directe
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_OPEN_URL', cleanIllegalChars($thisCdlUrl));

	$thisCdlUrl =~ s/^(\/document)\/ouvrir(\/.*)$/$1."\/telecharger".$2/segi;
	# L'URL du script pour t�l�chargement
	$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'DOCUMENT_DOWNLOAD_URL', cleanIllegalChars($thisCdlUrl));

	# L'URL de la page pr�c�dente pour annuler et retourner
	if ($ENV{'HTTP_REFERER'}) {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK', setValueInTemplateString(getPartOfTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK'), 'PREVIOUS_PAGE', cleanIllegalChars($ENV{'HTTP_REFERER'})));
	} else {
		$documentPageTemplateString = setValueInTemplateString($documentPageTemplateString, 'PREVIOUS_PAGE_BLOCK', "");
	}

	print $documentPageTemplateString;
}