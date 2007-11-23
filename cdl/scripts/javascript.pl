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

# File: javascript.pl
#	Script de traitement des fichiers javascript distants pour nettoyer et adapter le code javascript

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
use javascript;

# D�tection d'erreurs au niveau de l'identifiant du site
if (!param('cdlid')) {
	die "Aucun identifiant de site n'a �t� renseign�";
	exit;
}
if (!existConfigDirectory(param('cdlid'))) {
	die "Aucun site ne correspond � l'identifiant : ".param('cdlid');
	exit;
}

# R�cup�ration de l'URL racine du script et du chemin vers ce script  � partir de la racine
my $urlToParse = urlDecode(param('cdlurl'));
my ($siteRootUrl, $pagePath);
$urlToParse =~ s/^((https?:\/\/[^\/]+)(.*)(\/(.*?))?)/$siteRootUrl = $2; $pagePath = $3; $1/segi;

print "Content-type: text/javascript\n\n";

# Cr�ation de l'objet CGI
my $cgi = new CGI;

# Cr�ation de la session et r�cup�ration de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

# Cr�ation de l'agent HTTP
my $userAgent = initHTTPAgent;

# Initialisation de la requ�te HTTP
my $request = initRequest('get', $urlToParse, $cdlAccept, '', ());

# Initialisation du cookie avant l'envoi de la requ�te
$request = sendCookie($request, $session, param('cdlid'));

# Initialisation de l'authentification au site distant, s'il y a besoin (i.e. s'il y a des codes d'acc�s sont pr�sents en session)
my ($userLogin, $passwd, $realm) = (loadFromSession($session, 'cdl_'.param('cdlid').'_login'), loadFromSession($session, 'cdl_'.param('cdlid').'_passwd'), loadFromSession($session, 'cdl_'.param('cdlid').'_realm'));

if ($userLogin and $passwd) {
	my $uri = $request->uri;
	$userAgent->credentials($uri->host_port, $realm, $userLogin, $passwd);
}

# Envoi de la requ�te HTTP et r�ception de la r�ponse dans l'objet $response
my $response = getResponse($userAgent, $request);

# R�cup�ration du cookie dans la r�ponse HTTP et sauvegarde dans la session
getCookieInSession($response, $session, $siteId);

# R�cup�ration du type d'encodage des caract�res re�us dans la r�ponse HTTP
$contentType = $response->header('Content-type');

# Si le code retour est OK (200) on traite le code javascript
if ($response->code eq "200" and $contentType =~ m/javascript/si) {
	print parseJavascriptCode($response->content, param('cdlid'), param('cdlid'), $pagePath, $siteRootUrl);
}