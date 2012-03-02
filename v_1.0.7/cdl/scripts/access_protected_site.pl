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

# File: access_protected_site.pl
#	Script de traitement des sites protégés (suite à un retour HTTP 401)

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


# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

# Extraction des différents paramètres dans l'URL réécrite
my ($action, $siteId, $contentType, $requestMethod, $defaultLanguage, $urlToParse, $secure);
$thisCdlUrl =~ s/^(\/acces\-protege\-https\/(.*?)\/(.*?)\/(.*?)\/cdl\-url\/(.*?)(\?|$))/
	$siteId = $2;
	$requestMethod = $3;
	$defaultLanguage = $4;
	$urlToParse = $5;
	$secure = "s";
	$1/segi;
$thisCdlUrl =~ s/^(\/acces\-protege\/(.*?)\/(.*?)\/(.*?)\/cdl\-url\/(.*?)(\?|$))/
	$siteId = $2;
	$requestMethod = $3;
	$defaultLanguage = $4;
	$urlToParse = $5;
	$1/segi;

# Détection d'erreurs au niveau de l'identifiant du site
if (!$siteId) {
	die "Aucun identifiant de site n'a été renseigné";
	exit;
}
if (!existConfigDirectory($siteId)) {
	die "Aucun site ne correspond à l'identifiant : ".$siteId;
	exit;
}

# Création de l'objet CGI
my $cgi = new CGI;

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

my @paramKeys = param;

# Génération de la table des hachage des paramètres
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	if (param($paramKey)) {
		my @paramValuesArray = param($paramKey);
		$requestParameters{$paramKey} = \@paramValuesArray;
	}
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
	connectProtectedSite($cgi, $requestMethod, "http".$secure."://".$urlToParse, $userLogin, $passwd, $realm, $session, $siteId, %requestParameters);
} else {
	# Initialisation de l'entête
	print $session->header('Content-type' => "text/html; charset=UTF-8");

	# Chargement de la template principale de la page de document
	$protectedPageTemplateString = loadConfig($cdlTemplatesPath."access_protected_login_form.html");

	# Mettre les bonnes valeurs à la place des marqueurs dans le chaîne template

	# La langue du site
	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'LANGUAGE', $defaultLanguage);

	# Tous les paramètres reçus (cf index.pl)
	my $hiddenParams = "";

	foreach my $paramKey (keys(%requestParameters)) {
		if ($param !~ /^cdl/si) {
			my $refParamValues = $requestParameters{$paramKey};
			my @paramValues = @$refParamValues;
			foreach my $paramValue (@paramValues) {
				$hiddenParams .= "\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"".$paramKey."\" value=\"".$paramValue."\" />\n";
			}
		}
	}

	$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'HIDDEN_PARAMETERS', $hiddenParams);

	# S'il y a eu une erreur d'authentification, on en notifie l'utilisateur
	if (param('cdlloginerror') eq "1") {
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'ERROR_LOGIN_MESSAGE', "<strong>Vos identifiants sont incorrects. Veuillez réessayer.</strong>");
	} else {
		$protectedPageTemplateString = setValueInTemplateString($protectedPageTemplateString, 'ERROR_LOGIN_MESSAGE', "");
	}

	print $protectedPageTemplateString;
}