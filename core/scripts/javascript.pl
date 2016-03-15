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

# File: javascript.pl
#	Script de traitement des fichiers javascript distants pour nettoyer et adapter le code javascript

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use Cwd;

use LWP::UserAgent;

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;

use lib '../modules/html';
use misc_html;
use javascript;


# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";

# Extraction des différents paramètres dans l'URL réécrite
my ($secure, $siteId, $urlToParse);
$thisCdlUrl =~ s/^((\/cdl)?\/javascript(\-http(s))?\/([^\/]*)\/([^\?]*))/
	$embeddedMode = $2;
	$secure = $4;
	$siteId = $5;
	$urlToParse = $6;
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

# Génération de la table des hachage des paramètres
my @paramKeys = param;
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	my @paramValuesArray = param($paramKey);
	$requestParameters{$paramKey} = \@paramValuesArray;
}

# Récupération de l'URL racine du script et du chemin vers ce script  à partir de la racine
$urlToParse = "http".$secure."://".urlDecode($urlToParse);
my ($siteRootUrl, $pagePath);
$urlToParse =~ s/^((https?:\/\/[^\/]+)(.*?)(\/([^\/]*))?)/$siteRootUrl = $2; $pagePath = $3; $1/segi;

print "Content-type: text/javascript\n\n";

# Création de l'objet CGI
my $cgi = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Création de l'agent HTTP
my $userAgent = initHTTPAgent;

# Initialisation de la requête HTTP
my $request = initRequest('get', $urlToParse, $cdlAccept, '', %requestParameters);

# Initialisation du cookie avant l'envoi de la requête
$request = sendCookie($request, $session, $siteId);

# Initialisation de l'authentification au site distant, s'il y a besoin (i.e. s'il y a des codes d'accès sont présents en session)
my ($userLogin, $passwd, $realm) = (loadFromSession($session, 'cdl_'.$siteId.'_login'), loadFromSession($session, 'cdl_'.$siteId.'_passwd'), loadFromSession($session, 'cdl_'.$siteId.'_realm'));

if ($userLogin and $passwd) {
	my $uri = $request->uri;
	$userAgent->credentials($uri->host_port, $realm, $userLogin, $passwd);
}

# Envoi de la requête HTTP et réception de la réponse dans l'objet $response
my $response = getResponse($userAgent, $request);

# Récupération du cookie dans la réponse HTTP et sauvegarde dans la session
putCookieInSession($response, $session, $siteId);

# Récupération du type d'encodage des caractères reçus dans la réponse HTTP
my $contentType = $response->header('Content-type');

# Si le code retour est OK (200) on traite le code javascript
if ($response->code eq "200" and $contentType =~ m/javascript/si) {
	print parseJavascriptCode($response->content, $siteId, $pagePath, $siteRootUrl);
}