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

# File: index_nu.pl
#	Script principal d'affichage des pages HTML sans traitements

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


$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

# Création de l'objet CGI
my $cgi = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Récupération des paramètres et de la méthode d'appel du script
my $requestMethod = $ENV{'REQUEST_METHOD'};

# Génération de la table des hachage des paramètres
my @paramKeys = param;
my %requestParameters;
foreach my $paramKey (@paramKeys) {
	my @paramValuesArray = param($paramKey);
	$requestParameters{$paramKey} = \@paramValuesArray;
}

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";

# Récupération du paramètre id et de l'uri à parser
my ($siteId, $pageUri, $secure);
$thisCdlUrl =~ s/^(\/cdl)?\/le\-filtre\-pour\-ajax\/([^\/]*)(\/(([^\?]*?)(\?.*)?)?)?$/$embeddedMode = $1; $siteId = urlDecode($2); $pageUri = $requestMethod eq "POST" ? $4 : urlDecode($5);/segi;

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
	if (!param('cdlid')) {
		die "Aucun site ne correspond à l'identifiant : ".$siteId.".\n";
		exit;
	}
	$siteId = param('cdlid');
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

# Récupération de l'URI à parser pour en construire une URL
my $urlToParse = $pageUri;

# Si l'URL n'est pas absolue on la met en absolue
if ($urlToParse !~ m/^[\w\d]+:\/\//si) {
	$urlToParse = "http".$secure."://".$urlToParse;
}

# Initialisation du chemin vers la page depuis la racine et construction de l'URL racine du site
my ($siteRootUrl, $pagePath);
$urlToParse =~ s/^(https?:\/\/[^\/]+)$/$siteRootUrl = $1; $1/segi;
$urlToParse =~ s/^((https?:\/\/[^\/]+)(.*)\/([^\/]*?))/$siteRootUrl = $2; $pagePath = $3; $1/segi;

# On effectue la requête HTTP en récupérant la réponse
my $response = sendRequest($requestMethod, $urlToParse, $siteId, $siteRootUrl, $session, %requestParameters);

# Récupération du cookie dans la réponse HTTP et sauvegarde dans la session
putCookieInSession($response, $session, $siteId);

# Récupération du type d'encodage des caractères reçus dans la réponse HTTP
my $contentType = $response->header('Content-type');


# Initialisation de l'entête
print $session->header('Content-type' => $contentType);

# Si le code retour est succès, on traite le contenu de la réponse
if ($response->is_success) {
	# Récupération du contenu de la réponse
	my $htmlCode;
	if ($contentType =~ m/charset=utf\-?\d+/si) {
		$htmlCode = $response->content;
	} else {
		$htmlCode = $response->decoded_content;
	}

	# Affichage de la page finale;
	print $htmlCode;
} else {
	print "";
}
exit;