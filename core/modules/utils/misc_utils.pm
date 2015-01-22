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

# File: misc_utils.pm
#	Module de fonction utilitaires de manipulation et nettoyage XHTML, et de gestion des échanges HTTP

# Function: urlEncode
#	Encodage d'une chaîne à passer dans une URL
#
# Paramètres:
#	$string - chaîne à encoder
sub urlEncode #($string)
{
	my ($string) = @_;

	# Enceodage de l'URL
	# La fonction remplace tout caractère non alphanumérique
	# par son code constitué de "%" puis le code hexadécimal sur 2 caractères
	$string =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/segi;

	# On retourne l'URL encodée
	return $string;
}

# Function: urlDecode
#	Décodage d'une chaîne récupérée en paramètre
#
# Paramètres:
#	$string - chaîne à décoder
sub urlDecode #($string)
{
	my ($string) = @_;

	# Déceodage de l'URL
	# La fonction remplace toute sous-chaîne sous la forme "%XX" (XX sont 2 alphanupériques)
	# par le caractère correspondant qui a cette valeur héxadecimale
	$string =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/segi;

	# on retourne l'URL décodée
	return $string;
}

# Function: getTagAttributes
#	Récupérer la liste de tous les attributs (nom, valeur) d'une balise HTML
#
# Paramètres:
#	$openTagContent - contenu de la balise ouvrante
sub getTagAttributes #($openTagContent)
{
	my ($openTagContent) = @_;

	# Table de hashage où seront stockés les attributs de la balise
	my %tagAttributes = ();

	# Récupérer chaque attribut : comme clé le nom de l'attribut, et on associe à la valeur de la clé le contenu de cet attribut
	$openTagContent =~ s/ (\S*?)=(\"|\')(.*?)\2/$tagAttributes{$1} = $3;/segi;

	return %tagAttributes;
}

# Function: getLabelForId
#	Récupérer les libellés de tous les labels associés au différents champs de la page
#
# Paramètres:
#	$htmlCode - code HTML où chercher les labels
sub getLabelsForId #($htmlCode)
{
	my ($htmlCode) = @_;

	# Table de hashage où seront stockés les libellés des labels
	my %labelsTexts = ();

	# Récupérer chaque label : comme clé la valeur de l'attibut for (ID du champ correspondant), et on associe à la valeur de la clé le contenu de la balise label
	$htmlCode =~ s/<label( [^>]*)?for=(\"|\')(.*?)\2([^>]*)>\s*(.*?)\s*<\/label>/%labelTagAttributes = getTagAttributes($1." ".$4);$labelsTexts{$3} .= (length($labelTagAttributes{'title'}) > length(HTML::TreeBuilder->new_from_content($5)->as_text) ? $labelTagAttributes{'title'} : $5)." ";/segi;

	return %labelsTexts;
}

# Function: getRequestParameters
#	Récupération des paramètres de la requête dans une table de hashage
#
# Paramètres:
#	
sub getRequestParameters
{
	my %requestParameters;

	my @paramKeys = param;

	foreach my $paramKey (@paramKeys) {
		my @paramValuesArray = param($paramKey);
		$requestParameters{$paramKey} = \@paramValuesArray;
	}

	return %requestParameters;
}

# Function: getIndexUrlParameters
#	Récupération des paramètres du script index à partir de l'URL
#
# Paramètres:
#	
sub getIndexUrlParameters
{
	my ($siteId, $pageUri, $secure);

	# Récupération de l'URL réécrite pour en extraire les informations nécessaires
	my $thisCdlUrl = $ENV{'REQUEST_URI'};
	$thisCdlUrl =~ s/%20/+/sgi;

	$thisCdlUrl =~ s/^\/le\-filtre(\-https)?\/([^\/]*)(\/(([^\?]*?)(\?.*)?)?)?$/$siteId = urlDecode($2); $pageUri = urlDecode($4); $secure = $1 ? "s" : "";/segi;

	return ($siteId, $pageUri, $secure);
}

# Function: verifySiteId
#	Vérification l'identifiant du site passé dans l'URL
#
# Paramètres:
#	$siteId - Identifiant récupéré à partir de l'URL
sub verifySiteId #($siteId)
{
	my ($siteId) = @_;

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

	return $siteId;
}

# Function: getAllConfigs
#	Récupérer toute la configuration nécessaire
#
# Paramètres:
#	$session - objet session pour récupérer les préférences utilisateur
#	$siteId - Identifiant du site parsé
sub getAllConfigs #($session, $siteId)
{
	my ($session, $siteId) = @_;

	# Chargement de la configuration par défaut
	my $defaultConfiguration = loadConfig($cdlSitesConfigPath."default.ini");

	# Chargement de la configuration du site
	my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Récupérer la liste de tous les noms de domaine du site
	my $siteDomainNamesConfig = getConfig($siteConfiguration, 'siteDomainNames');
	my @homePageUrisConfig = split(/\t+/, getConfig($siteConfiguration, 'homePageUris'));

	# Chargement des paramètres utilisateur
	my $positionLocation = loadFromSession($session, 'positionLocation');
	my $activateJavascript = loadFromSession($session, 'activateJavascript');
	my $activateFrames = loadFromSession($session, 'activateFrames');
	my $displayImages = loadFromSession($session, 'displayImages');
	my $displayObjects = loadFromSession($session, 'displayObjects');
	my $displayApplets = loadFromSession($session, 'displayApplets');
	my $parseTablesToList = loadFromSession($session, 'parseTablesToList');

	# Si un paramètre n'est pas renseigné, on met celui par défaut du site
	$positionLocation = $positionLocation eq "" ? getConfig($siteConfiguration, 'positionLocation') : $positionLocation;
	$activateJavascript = $activateJavascript eq "" ? getConfig($siteConfiguration, 'activateJavascript') : $activateJavascript;
	$activateFrames = $activateFrames eq "" ? getConfig($siteConfiguration, 'activateFrames') : $activateFrames;
	$displayImages = $displayImages eq "" ? getConfig($siteConfiguration, 'displayImages') : $displayImages;
	$displayObjects = $displayObjects eq "" ? getConfig($siteConfiguration, 'displayObjects') : $displayObjects;
	$displayApplets = $displayApplets eq "" ? getConfig($siteConfiguration, 'displayApplets') : $displayApplets;
	$parseTablesToList = $parseTablesToList eq "" ? getConfig($siteConfiguration, 'parseTablesToList') : $parseTablesToList;

	my $parseJavascript = getConfig($siteConfiguration, 'parseJavascript');
	my $siteLabel = getConfig($siteConfiguration, 'siteLabel');
	my $siteDefaultLanguage = getConfig($siteConfiguration, 'defaultLanguage');
	my $enableAudio = getConfig($siteConfiguration, 'enableAudio');

	my $pagesNoCache = getConfig($siteConfiguration, 'pagesNoCache');
	$pagesNoCache =~ s/\t+/\t/sgi;
	$pagesNoCache =~ s/(^\t|\t$)//sgi;
	$pagesNoCache =~ s/\t/|/sgi;
	my $cacheExpiry = getConfig($siteConfiguration, 'cacheExpiry');

	# Si un paramètre n'est pas renseigné, on met celui par défaut
	$positionLocation = $positionLocation eq "" ? getConfig($defaultConfiguration, 'positionLocation') : $positionLocation;
	$activateJavascript = $activateJavascript eq "" ? getConfig($defaultConfiguration, 'activateJavascript') : $activateJavascript;
	$parseJavascript = $parseJavascript eq "" ? getConfig($defaultConfiguration, 'parseJavascript') : $parseJavascript;
	$activateFrames = $activateFrames eq "" ? getConfig($defaultConfiguration, 'activateFrames') : $activateFrames;
	$displayImages = $displayImages eq "" ? getConfig($defaultConfiguration, 'displayImages') : $displayImages;
	$displayObjects = $displayObjects eq "" ? getConfig($defaultConfiguration, 'displayObjects') : $displayObjects;
	$displayApplets = $displayApplets eq "" ? getConfig($defaultConfiguration, 'displayApplets') : $displayApplets;
	$parseTablesToList = $parseTablesToList eq "" ? getConfig($defaultConfiguration, 'parseTablesToList') : $parseTablesToList;
	$enableAudio = $enableAudio eq "" ? getConfig($defaultConfiguration, 'enableAudio') : $enableAudio;
	$siteDefaultLanguage = $siteDefaultLanguage eq "" ? getConfig($defaultConfiguration, 'defaultLanguage') : $siteDefaultLanguage;
	$cacheExpiry = $cacheExpiry eq "" ? getConfig($defaultConfiguration, 'cacheExpiry') : $cacheExpiry;
	$cacheExpiry = $cacheExpiry eq "" ? "3600*2" : $cacheExpiry;

	# Récupération de la session de la variable indiquant si l'audio est activé
	my $activateAudio = $enableAudio ? loadFromSession($session, 'activateAudio') : 0;

	# Récupérer la liste de tous les noms de domaine du site
	$siteDomainNames = getConfig($siteConfiguration, 'siteDomainNames');
	$siteDomainNames =~ s/\s+/\|/sgi;

	my $homePageUri = getConfig($siteConfiguration, 'homePageUris');
	$homePageUri =~ s/([^\s]*)\s+.*/$1/sgi;

	return ($siteLabel, $siteDefaultLanguage, $positionLocation, $activateJavascript, $parseJavascript, $activateFrames, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $enableAudio, $activateAudio, $siteDomainNames, $homePageUri, $pagesNoCache, $cacheExpiry);
}

# Function: buildUrlToParse
#	Construire l'URL de la page à parser (avec redirection éventuelle vers la page configurée par défaut si l'URL est vide)
#
# Paramètres:
#	$cgi - objet CGI pour la redirection éventuelle
#	$session - objet session utile pour la gestion des cookies
#	$pageUri - URI de la page en cours
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
#	$siteDomainNames - nom de domaine configuré par défaut
#	$homePageUri - URI de la page d'accueil configurée par défaut
sub buildUrlToParse #($cgi, $session, $pageUri, $secure, $siteDomainNames, $homePageUri)
{
	my ($cgi, $session, $pageUri, $secure, $siteDomainNames, $homePageUri) = @_;

	my $urlToParse = $pageUri;

	# Si l'URI est vide (ie. on arrive avec le lien raccorci /le-filtre/siteId/), on redirige vers le filtre avec une URI complète en rajoutant le nom de domaine par défaut du site
	if (!$urlToParse) {
		my $redirectUrl = $ENV{'REQUEST_URI'};
		# Ajout automatique du / à la fin
		$redirectUrl =~ s/([^\/])$/$1\//sgi;
		my @siteDomainNamesArray = split(/\|/, $siteDomainNames);
		$redirectUrl .= $siteDomainNamesArray[0].$homePageUri;
		my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
		print $cgi->header(-status=>"302 Found", -location=>$redirectUrl, -cookie=>$cookie);
		exit;
	}

	# Si l'URL n'est pas absolue on la met en absolue
	if ($urlToParse !~ m/^[\w\d]+:\/\//si) {
		$urlToParse = "http".$secure."://".$urlToParse;
	}

	# Initialisation du chemin vers la page depuis la racine et construction de l'URL racine du site
	my ($siteRootUrl, $pagePath);
	$urlToParse =~ s/^(https?:\/\/[^\/]+)$/$siteRootUrl = $1; $1/segi;
	$urlToParse =~ s/^((https?:\/\/[^\/]+)(.*)\/([^\/]*?))/$siteRootUrl = $2; $pagePath = $3; $1/segi;

	return ($urlToParse, $siteRootUrl, $pagePath);
}

# Function: accessAnotherSite
#	Accés à un nouveau site (géré ou non par CDL)
#
# Paramètres:
#	$cgi - objet CGI pour la redirection éventuelle
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$siteDefaultLanguage - Langue par défaut du site
#	$requestMethod - méthode HTTP pour sortir
#	$urlToParse - URL du nouveau site
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
#	%requestParameters - paramètres à coller à l'URL
sub accessAnotherSite #($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $urlToParse, $secure, %requestParameters)
{
	my ($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $urlToParse, $secure, %requestParameters) = @_;

	# On teste si le site est pris en compte par CDL
	my $siteDomain = "";
	my $pageUri = "";
	$urlToParse =~ s/^(https?:\/\/([^\/]*)(\/(.*)|$))/$siteDomain = $2; $pageUri = $4; $1/segi;

	my $newSiteId = "";
	if ($siteDomain) {
		$newSiteId = getSiteFromDomain($siteDomain);
	}

	$urlToParse =~ s/^https?:\/\///sgi;

	# Si le site existe, on redirige vers ce script mais avec le bon siteId et la bonne uri
	if ($newSiteId) {
		my $redirectUrl = "/le-filtre".($secure eq "s" ? "-https" : "")."/".$newSiteId."/".$urlToParse;

		if ($requestMethod =~ m/post/si) {
			$redirectUrl = putParametersInUrl($redirectUrl, %requestParameters);
		}

		my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
		print $cgi->header(-status=>"302 Found", -location=>$redirectUrl, -cookie=>$cookie);
		exit;
	}

	# On redirige vers la page de sortie de CDL vers un autre site
	my $redirectUrl = "/sortie".($secure eq "s" ? "-https" : "")."/".$siteId."/".$siteDefaultLanguage."/".$requestMethod."/".$urlToParse;

	if ($requestMethod =~ m/post/si) {
		editInSession($session, 'cdl_post_parameters_to_exit', encode_json(\%requestParameters));
	}

	my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
	print $cgi->header(-status=>"302 Found", -location=>$redirectUrl, -cookie=>$cookie);
}

# Function: redirectToAnotherPage
#	Rediriger vers une autre page en restant dans CDL si la réponse HTTP demande de rediriger
#
# Paramètres:
#	$cgi - objet CGI pour la redirection
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$siteRootUrl - URL racine du site
#	$response - objet réponse HTTP d'où l'URL de redirection
#	$pageUri - URI de la page en cours
#	$pagePath - chemin vers la page en cours de traitement
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
sub redirectToAnotherPage #($cgi, $session, $siteId, $response, $siteRootUrl, $pageUri, $pagePath, $secure)
{
	my ($cgi, $session, $siteId, $response, $siteRootUrl, $pageUri, $pagePath, $secure) = @_;

	# On récupère l'url vers laquelle on redirige dans l'entête Location
	my $redirectUrl = $response->header("Location");

	# Transformation de l'URL pour rester dans CDL
	$redirectUrl = parseLinkHrefAttribute($redirectUrl, $pagePath, $siteId, $siteRootUrl, $pageUri);

	$siteRootUrl =~ s/^https?:\/\///sgi;
	if ($redirectUrl !~ m/^\/le\-filtre(\-https)?\/$siteId\//si and $redirectUrl !~ m/^[\w\d]+:\/\//si) {
		$redirectUrl = "/le-filtre".($secure eq "s" ? "-https" : "")."/".$siteId."/".$siteRootUrl."/".$redirectUrl;
	}

	my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
	print $cgi->header(-status=>"302 Found", -location=>$redirectUrl, -cookie=>$cookie);
}

# Function: redirectToDocumentPage
#	Rediriger vers la page de gestion des documents à ouvrir/télécharger
#
# Paramètres:
#	$cgi - objet CGI pour la redirection
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$siteDefaultLanguage - Langue par défaut du site
#	$requestMethod - méthode d'envoi de la requête (GET, POST ou HEAD)
#	$response - objet réponse HTTP d'où l'URL de redirection
#	$urlToParse - URL du document non HTML
#	$siteRootUrl - URL racine du site
#	$pageUri - URI de la page en cours
#	$pagePath - chemin vers la page en cours de traitement
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
#	%requestParameters - paramètres à coller à l'URL
sub redirectToDocumentPage #($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $response, $urlToParse, $siteRootUrl, $pageUri, $pagePath, $secure, %requestParameters)
{
	my ($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $response, $urlToParse, $siteRootUrl, $pageUri, $pagePath, $secure, %requestParameters) = @_;

	# On récupère plutôt le type mime à partir de son contenu (les premiers octets du fichier)
	# pour éviter les informations incomplètes du Content-type du site distant.
	my $contentType = getDocumentContentType($response->content, $session, $siteId);

	$contentType =~ s/(.*?)(;|$)(.*)/$1/sgi;

	# Nettoyage du type mime
	# Cas des fichiers compressés
	$contentType =~ s/(.*)\((.*?)\)/$2/sgi;
	$contentType =~ s/\//\-/sgi;

	# Gestion directe des fichiers audio, lien direct sans passer par la page CDL intermédiaire
	if ($contentType =~ m/audio/si or $response->header('Content-Disposition') =~ m/\.(mp3|wav|wma|rm|au)$/si or $urlToParse =~ m/\.(mp3|wav|wma|rm|au)$/si) {
		# Récupération de l'entête qui permet de donner le bon nom de fichier à télécharger,
		# ainsi que la manière avec laquelle le présenter à l'internaute (ouverture directe ou téléchargement)
		my $contentDisposition = $response->header('Content-Disposition');

		# Si on ne dispose pas du nom de fichier dans Content-Disposition (c'est à dire que c'est un lien direct vers le fichier),
		# on récupère son nom à partir de l'URL
		if (!$contentDisposition or $contentDisposition !~ m/^inline;?/si) {
			$urlToParse =~ s/^(.*)\/([^\/\?\&]*?)$/$2/sgi;
			$contentDisposition =~ s/^(inline;?)(.*)$/$1." ".$urlToParse/segi;
			if (!$contentDisposition) {
				$contentDisposition = "inline; ".$urlToParse;
			}
		}

		# Ecriture des entêtes
		print $session->header('Content-type' => $contentType, 'Content-Disposition' => $contentDisposition);

		# Ecriture du contenu du document dans le flux
		print $response->content;
		exit;
	}

	$urlToParse =~ s/^https?:\/\///segi;

	# On redirige vers la page proposition de téléchargement du document
	$contentType =~ s/(\+)/_/segi;
	my $redirectUrl = "/document".($secure eq "s" ? "-https" : "")."/".$siteId."/".$contentType."/".lc($requestMethod)."/".$siteDefaultLanguage."/cdl-url/".$urlToParse;

	# Ajout des paramètres éventuels
	if ($requestMethod =~ m/post/si) {
		$redirectUrl = putParametersInUrl($redirectUrl, %requestParameters);
	}

	my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
	print $cgi->header(-status=>"302 Found", -location=>$redirectUrl, -cookie=>$cookie);
}

# Function: redirectToProtectedAccessLogin
#	Rediriger vers la page de login pour accéder une page distance protégée
#
# Paramètres:
#	$cgi - objet CGI pour la redirection
#	$session - objet session utile pour la gestion des cookies
#	$siteId - Identifiant du site parsé
#	$siteDefaultLanguage - Langue par défaut du site
#	$requestMethod - méthode d'envoi de la requête (GET, POST ou HEAD)
#	$response - objet réponse HTTP d'où l'URL de redirection
#	$urlToParse - URL de la page sécurisée
#	$secure - booléen indiquant si la page est sécurisée (en HTTPS)
#	%requestParameters - paramètres à coller à l'URL
sub redirectToProtectedAccessLogin #($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $response, $urlToParse, $secure, %requestParameters)
{
	my ($cgi, $session, $siteId, $siteDefaultLanguage, $requestMethod, $response, $urlToParse, $secure, %requestParameters) = @_;

	# On récupère dans les entêtes de la réponse le paramètre realm indispensable pour l'authentification
	my $wwwAthentificate = $response->header('WWW-Authenticate');
	my $realm;
	$wwwAthentificate =~ s/\s(realm)\s*=\s*\"(.*?)\"/$realm = $2;/segi;
	# Sauvegarde en session du paramètre realm
	editInSession($session, 'cdl_'.$siteId.'_realm', $realm);

	$urlToParse =~ s/^https?:\/\///segi;

	# On redirige vers la page d'authentification au site
	my $redirectUrl = "/acces-protege".($secure eq "s" ? "-https" : "")."/".$siteId."/".lc($requestMethod)."/".$siteDefaultLanguage."/cdl-url/".$urlToParse;

	# Ajout des paramètres éventuels
	if ($requestMethod =~ m/post/si) {
		$redirectUrl = putParametersInUrl($redirectUrl, %requestParameters);
	}

	my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
	print $cgi->header(-status=>"302 Found", -location=>$redirectUrl, -cookie=>$cookie);
}

# Function: initHTTPAgent
#	Initialisation de l'agent HTTP
#
# Paramètres:
#	
sub initHTTPAgent
{
	# Retourner l'agent HTTP créé
	return LWP::UserAgent->new(agent => $agentNameToSend);
}

# Function: putParametersInUrl
#	Ajouter les paramètres passés en arguments à l'URL passé aussi en argument
#
# Paramètres:
#	$url - URL à compléter avec les paramètres
#	%requestParameters - paramètres à coller à l'URL
sub putParametersInUrl #($url, %requestParameters)
{
	my ($url, %requestParameters) = @_;

	if ($url !~ m/\?/si) {
		$url .= "?";
	} else {
		$url .= "&";
	}

	# Coller les paramètres un à un dans l'URL
	foreach my $paramterKey (keys(%requestParameters)) {
		my $refParamterValues = $requestParameters{$paramterKey};
		my @parameterValues = @$refParamterValues;
		if (!@parameterValues) {
			$parameterValues[@parameterValues] = "";
		}
		foreach my $parameterValue (@parameterValues) {
			$url .= $paramterKey."=".urlEncode($parameterValue)."&";
		}
	}

	# On supprime le caractère en trop (& commercial de la dernière itération, ou ? qui reste s'il n'y avait aucun paramètre)
	$url =~ s/(\?|&)$//sgi;

	# Retourner l'URL mise à jour
	return $url;
}

# Function: putParametersInUrlForHtml
#	Ajouter les paramètres passés en arguments à l'URL passé aussi en argument, encoder les '&' en '&amp;' pour les afficher en HTML
#
# Paramètres:
#	$url - URL à compléter avec les paramètres
#	%requestParameters - paramètres à coller à l'URL
sub putParametersInUrlForHtml #($url, %requestParameters)
{
	my ($url, %requestParameters) = @_;

	if ($url !~ m/\?/si) {
		$url .= "?";
	} else {
		$url .= "&";
	}

	# Coller les paramètres un à un dans l'URL
	foreach my $paramterKey (keys(%requestParameters)) {
		my $refParamterValues = $requestParameters{$paramterKey};
		my @parameterValues = @$refParamterValues;
		if (!@parameterValues) {
			$parameterValues[@parameterValues] = "";
		}
		foreach my $parameterValue (@parameterValues) {
			$url .= $paramterKey."=".urlEncode($parameterValue)."&amp;";
		}
	}

	# On supprime le caractère en trop (& commercial de la dernière itération, ou ? qui reste s'il n'y avait aucun paramètre)
	$url =~ s/(\?|&amp;)$//sgi;

	# Retourner l'URL mise à jour
	return $url;
}

# Function: buildMultipartRequest
#	Ecriture des données en post dans le cas de l'envoi de fichiers (multipart/form-data)
#
# Paramètres:
#	$request - objet requête à modifier
#	%requestParameters - table de hachage contenant les paramètres à envoyer
sub buildMultipartRequest #($request, %requestParameters)
{
	my ($request, %requestParameters) = @_;

	# Récupération de la valeur de boundary pour délimiter les paramètres dans la requête
	my $contentType = $ENV{'CONTENT_TYPE'};
	my $boundary;
	$contentType =~ s/boundary=(-*)(.*)($|;)/$boundary = $2;/segi;

	my $requestContent = "";

	# Génération de la chaîne de paramètres
	foreach my $paramKey (keys(%requestParameters)) {
		my $refParamValues = $requestParameters{$paramKey};
		my @paramValues = @$refParamValues;
		if (!@paramValues) {
			$paramValues[@paramValues] = "";
		}
		foreach my $paramValue (@paramValues) {
			# On traite la valeur du paramètre dans une variable à part pour récupérer le bon nom de fichier
			my $fileName = $paramValue;
			$fileName =~ s/.*[\/\\](.*)/$1/;

			# Récupération du handler pour lire le contenu du fichier
			my $uploadFileHandler = upload($paramKey);

			# Variable pour savoir s'il y a eu un fichier envoyé
			my $fileIsUploaded = 0;
			# Variable où stocker le contenu du fichier
			my $fileContent = "";

			# Remplissage de la chaîne du contenu du fichier uploadé
			while (<$uploadFileHandler>) {
				$fileContent .= $_;
				$fileIsUploaded = 1;
			}

			$requestContent .= "--".$boundary."\n";
			$requestContent .= "Content-Disposition: form-data; name=\"".$paramKey."\"";
			if ($fileIsUploaded) {
				$requestContent .= "; filename=\"".$fileName."\"\n";
				$requestContent .= "Content-type: application/octet-stream\n\n";
				$requestContent .= $fileContent;
			} else {
				$requestContent .= "\n\n".$paramValue;
			}
			$requestContent .= "\n";
		}
	}
	# Fermer le contenu de la requête en délimitant par le boundary
	$requestContent .= "--".$boundary."--";

	# Mise à jour du contenu de la requête
	$request->content($requestContent);

	# Retourner l'objet représentant la requête HTTP rempli avec les bons paramètres valable pour un envoi en multipart/form-data
	return $request;
}

# Function: initParametersForRequest
#	Ecriture des données en paramètre à envoyer dans l'objet requête
#
# Paramètres:
#	$request - objet requête à modifier
#	$methodKey - méthode d'envoi de la requête (GET, POST ou HEAD)
#	%requestParameters - table de hachage contenant les paramètres à envoyer
sub initParametersForRequest #($request, $methodKey, %requestParameters)
{
	my ($request, $methodKey, %requestParameters) = @_;

	if ($ENV{'CONTENT_TYPE'}) {
		my $contentType = $ENV{'CONTENT_TYPE'};
		$contentType =~ s/(boundary=)(-*)/$1/sgi;
		$request->content_type($contentType);
	}
	# Génération de la chaîne de paramètres
	my $requestParametersString = "";
	foreach my $paramKey (keys(%requestParameters)) {
		my $refParamValues = $requestParameters{$paramKey};
		my @paramValues = @$refParamValues;
		if (!@paramValues) {
			$paramValues[@paramValues] = "";
		}
		foreach my $paramValue (@paramValues) {
			$requestParametersString .= $paramKey."=".urlEncode($paramValue)."&";
		}
	}
	$requestParametersString =~ s/.$//sgi;

	# Ecriture des paramètres dans la requête
	if ($methodKey eq 'POST') {
		if ($request->content_type =~ m/multipart\/form-data/si) {
			$request = buildMultipartRequest($request, %requestParameters);
		} else {
			$request->content($requestParametersString);
		}
	} else {
		$request->uri($request->uri.($requestParametersString ? "?".$requestParametersString : ""));
	}

	# Retourner l'objet représentant la requête HTTP rempli avec les bons paramètres
	return $request;
}

# Function: initRequest
#	Créer et paramètrer la requête HTTP
#
# Paramètres:
#	$method - méthode d'envoi de la requête (GET, POST ou HEAD)
#	$url - URL à appeler pour effectuer la requête
#	$typeAccept - types acceptés par la requête
#	$referer - referer de la page $url : la page de laquelle on est arrivé
#	%requestParameters - table de hachage contenant les paramètres à envoyer
sub initRequest #($method, $url, $typeAccept, $referer, %requestParameters)
{
	my ($method, $url, $typeAccept, $referer, %requestParameters) = @_;

	my $request;
	my $methodKey;

	$url =~ s/(\%)/urlEncode($1)/segi;

	# Test et initialisation la méthode d'envoi
	if (!($method =~ m/^(get|post|head)$/si)) {
		# Erreur si c'est ni POST ni GET ni HEAD
		die "méthode '".$method."' invalide d'envoi de la requête HTTP...\n";
	} else {
		if ($method =~ m/^post$/si) {
			$methodKey = 'POST';
		} elsif ($method =~ m/^get$/si) {
			$methodKey = 'GET';
		} else {
			$methodKey = 'HEAD';
		}
	}

	# Création de l'objet requête
	$request = new HTTP::Request($methodKey => $url);
	initParametersForRequest($request, $methodKey, %requestParameters);

	# Géneration des headers selon les paramètres mentionnés
	if ($typeAccept) {
		$request->header('Accept' => $typeAccept);
	}
	else {
		$request->header('Accept' => "*/*");
	}

	if ($referer) {
		$request->header('Referer' => $referer);
	}

	# Retourner l'objet requête
	return $request;
}

# Function: sendRequest
#	Fonction d'envoi de la requête HTTP complète et récupération de la bonne réponse HTTP
#
# Paramètres:
#	$requestMethod - méthode d'envoi de la requête (GET, POST ou HEAD)
#	$urlToParse - URL à appeler pour effectuer la requête
#	$siteId - identifiant du site en cours de traitement
#	$siteRootUrl - URL racine du site
#	$session - objet session utile pour la gestion des cookies
#	%requestParameters - table de hachage contenant les paramètres à envoyer
sub sendRequest #($requestMethod, $urlToParse, $siteId, $siteRootUrl, $session, %requestParameters)
{
	my ($requestMethod, $urlToParse, $siteId, $siteRootUrl, $session, %requestParameters) = @_;

	# Création de l'agent HTTP
	my $userAgent = initHTTPAgent;

	if ($requestMethod =~ m/get/si) {
		$urlToParse =~ s/\?.*$//sgi;
	}

	# Initialisation de la requête HTTP
	my $request = initRequest($requestMethod, $urlToParse, $cdlAccept, getReferer($ENV{'HTTP_REFERER'}, $siteRootUrl), %requestParameters);

	# Initialisation du cookie avant l'envoi de la requête
	$request = sendCookie($request, $session, $siteId);

	# Initialisation de l'authentification au site distant, s'il y a besoin (i.e. s'il y a des codes d'accès sont présents en session)
	my ($userLogin, $passwd, $realm) = (loadFromSession($session, 'cdl_'.$siteId.'_login'), loadFromSession($session, 'cdl_'.$siteId.'_passwd'), loadFromSession($session, 'cdl_'.$siteId.'_realm'));

	if ($userLogin) {
		my $uri = $request->uri;
		$userAgent->credentials($uri->host_port, $realm, $userLogin, $passwd);
	}

	# Envoi de la requête HTTP et réception de la réponse dans l'objet $response. On refait tant que la réponse n'est que informative
	my $response;
	do {$response = getResponse($userAgent, $request);} while ($response->is_info);
	# Récupérer la première réponse correcte de la chaîne de redirection pour refaire étape par étape l'enchaînement en restant dans CDL
	while ($response->previous ne undef and not $response->previous->is_error) {
		$response = $response->previous;
	}

	# Récupération du cookie dans la réponse HTTP et sauvegarde dans la session
	putCookieInSession($response, $session, $siteId);

	return $response;
}

# Function: getResponse
#	Envoi de la requête HTTP la réception de la réponse correspondante
#
# Paramètres:
#	$userAgent - agent HTTP
#	$request - objet requête à envoyer
sub getResponse #($userAgent, $request)
{
	my ($userAgent, $request) = @_;

	# Envoi de la requête par l'agent HTTP et récupération de l'object réponse
	$response = $userAgent->request($request);

	# Retourner la réponse
	return $response;
}

# Function: getReferer
#	Récupérer l'URL de la version originale de la page précédente
#
# Paramètres:
#	$url - URL CDL de la page précédente
#	$siteRootUrl - URL racine du site
sub getReferer #($url, $siteRootUrl)
{
	my ($url, $siteRootUrl) = @_;

	# L'URL originale de la page précédente
	my $refererUrl = "";

	$siteRootUrl =~ s/^https?:\/\///sgi;

	$url =~ s/(([\w\d]+):\/\/$ENV{'SERVER_NAME'})?\/le\-filtre(-http(s)?)?\/?$/$refererUrl = "http".$4.":\/\/".$siteRootUrl;/segi;
	$url =~ s/(([\w\d]+):\/\/$ENV{'SERVER_NAME'})?\/le\-filtre(-http(s)?)?\/(.*?)\/(.*)$/$refererUrl = "http".$4.":\/\/".$6;/segi;

	# Décoder les caractères '&'
	$refererUrl =~ s/&amp;/&/sgi;

	# Retourner l'URL originale de la page précédente
	return $refererUrl;
}

# Function: getContentTypeFromHttpResponseHeader
#	Récupérer le type de contenu et son encodage à partir de l'entête HTTP de la réponse
#
# Paramètres:
#	$response - objet réponse HTTP d'où extraire le type de contenu
sub getContentTypeFromHttpResponseHeader #($response)
{
	my ($response) = @_;

	# Récupération de l'entête HTTP contenant le type de contenu
	my $contentType = $response->header('Content-type');
	# Nettoyage de la chaîne récupérée
	$contentType =~ s/(.*,\s*)([^;,]+;.+)$/$2/sgi;
	# Remplacement du nom du type d'encodage ISO (ANSI)
	$contentType =~ s/iso\-8859\-\d+/windows-1252/sgi;

	return $contentType;
}

# Function: redirectDownload
#	Fonction de redirection : elle sera utilisée pour télécharger des fichiers sur l'URL passée en argument
#
# Paramètres:
#	$action - action à effectuer sur le document (o = ouverture / d : téléchargement)
#	$requestMethod - méthode avec laquelle appeler l'URL qui renvoit le document
#	$url - URL où se trouve le document
#	$session - objet session utile pour la gestion des cookies
#	$siteId - identifiant du site en cours de traitement
#	%requestParameters - paramètres à envoyer au script qui renvoit le document
sub redirectDownload #($action, $requestMethod, $url, $session, $siteId, %requestParameters)
{
	my ($action, $requestMethod, $url, $session, $siteId, %requestParameters) = @_;

	# Création de l'agent HTTP
	my $userAgent = initHTTPAgent;

	# Initialisation de la requête HTTP
	my $request = initRequest($requestMethod, $url, $cdlAccept, getReferer(param('cdlreferer'), $siteRootUrl), %requestParameters);

	if ($requestMethod =~ m/^post$/si) {
		$request->content_type("application/x-www-form-urlencoded");
	}

	# Initialisation du cookie avant l'envoi de la requête
	$request = sendCookie($request, $session, $siteId);

	# Envoi de la requête HTTP et réception de la réponse dans l'objet $response
	my $response = getResponse($userAgent, $request);

	# Récupération du cookie dans la réponse HTTP et sauvegarde dans la session
	putCookieInSession($response, $session, $siteId);

	my $contentDisposition = $response->header('Content-Disposition');
	# Récupération du type d'encodage des caractères reçus dans les entêtes de la réponse HTTP
	my $documentContent = $response->content;

	# On récupère plutôt le type mime à partir de son contenu (les premiers octets du fichier)
	# pour éviter les informations incomplètes du Content-type du site distant
	$contentType = getDocumentContentType($documentContent, $session, $siteId);

	# Si on ne dispose pas du nom de fichier dans Content-Disposition (c'est à dire que c'est un lien direct vers le fichier),
	# on récupère son nom à partir de l'URL
	if (!$contentDisposition or $contentDisposition !~ m/^inline;?/si) {
		$url =~ s/^(.*)\/([^\/\?\&]*?)$/$2/sgi;
	}

	# Gestion de l'entête qui permet de donner le bon nom de fichier à télécharger,
	# ainsi que la manière avec laquelle le présenter à l'internaute (ouverture directe ou téléchargement)
	if ($action eq "telecharger") {
		if ($contentDisposition !~ m/^attachment;/si) {
			if ($contentDisposition) {
				$contentDisposition =~ s/^(.*?);/attachment;/sgi;
			} else {
				$contentDisposition = "attachment; filename=".$url;
			}
		}
	} else {
		if ($contentDisposition =~ m/^attachment;/si) {
			$contentDisposition =~ s/^attachment;/inline;/sgi;
		} else {
			$contentDisposition = "inline; filename=".$url;
		}
	}

	# Ecriture des entêtes
	print $session->header('Content-type' => $contentType, 'Content-Disposition' => $contentDisposition);

	# Ecriture du contenu du document dans le flux
	print $documentContent;
	exit;
}

# Function: connectProtectedSite
#	Connexion à un site protégé
#
# Paramètres:
#	$cgi - objet cgi pour faire la redirection à la fin
#	$requestMethod - méthode avec laquelle appeler l'URL de la page protégée
#	$url - URL où se trouve la page protégée
#	$userLogin - login de l'utilisateur
#	$passwd - mot de passe de l'utilisateur
#	$realm - paramètre realm indispensable pour l'authentification
#	$session - objet session utile pour la gestion des cookies
#	$siteId - identifiant du site en cours de traitement
#	%requestParameters - paramètres à envoyer au script qui renvoit le document
sub connectProtectedSite #($cgi, $requestMethod, $url, $userLogin, $passwd, $realm, $session, $siteId, %requestParameters)
{
	my ($cgi, $requestMethod, $url, $userLogin, $passwd, $realm, $session, $siteId, %requestParameters) = @_;

	# Création de l'agent HTTP
	my $userAgent = initHTTPAgent;

	# Initialisation de la requête HTTP
	my $request = initRequest($requestMethod, $url, $cdlAccept, getReferer($ENV{'HTTP_REFERER'}, $siteRootUrl), %requestParameters);

	# Initialisation du cookie avant l'envoi de la requête
	$request = sendCookie($request, $session, $siteId);

	# Initialisation de l'authentification au site distant
	my $uri = $request->uri;
	$userAgent->credentials($uri->host_port, $realm, $userLogin, $passwd);

	# Envoi de la requête HTTP et réception de la réponse dans l'objet $response
	my $response = getResponse($userAgent, $request);

	if ($response->code eq "401") {
		my $redirectUrl = $ENV{'REQUEST_URI'};

		# Nettoyer l'URL du paramètre cdlact qui est inutile
		$redirectUrl =~ s/(\?|&)cdlact=(.+?)(&|$)/$1/sgi;
		$redirectUrl =~ s/(\?|&)$//sgi;

		my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
		print $cgi->redirect(-status=>"302 Moved", -location=>$redirectUrl."&cdlloginerror=1", -cookie=>$cookie);
		exit;
	}
	# Sauvegarde des paramètres de connexion au site protégé en session.
	editInSession($session, 'cdl_'.$siteId.'_login', $userLogin);
	editInSession($session, 'cdl_'.$siteId.'_passwd', $passwd);
	editInSession($session, 'cdl_'.$siteId.'_realm', $realm);

	# Redirection vers le script principal pour traitement de la page
	my $redirectUrl = "/le-filtre";
	if ($url =~ m/^https:\/\//si) {
		$redirectUrl .= "-https";
	}
	$url =~ s/^https?:\/\///sgi;
	$redirectUrl .= "/".$siteId."/".putParametersInUrl($url, %requestParameters);

	my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
	print $cgi->redirect(-status=>"302 Moved", -location=>$redirectUrl, -cookie=>$cookie);
	exit;
}

# Function: putCookieInSession
#	Récupération du cookie de session du site distant et sauvegarde de ce cookie en session
#
# Paramètres:
#	$response - objet réponse HTTP d'où extraire le cookie
#	$session - objet session où stocker le cookie de la session distante
#	$siteId - identifiant du site où on veut créer une session pour l'internaute
sub putCookieInSession #($response, $session, $siteId)
{
	my ($response, $session, $siteId) = @_;

	# Le cookie à sauvegarder en session
	my @cookieToSave = $response->header("Set-cookie");
	my $cookiesSaved = loadFromSession($session, 'cookie_'.$siteId);

	if ($cookiesSaved =~ m/\|\#cdl\#\|/si) {
		$cookiesSaved = "";
	}

	foreach my $cookie (@cookieToSave) {
		my $cookieName = $cookie;
		$cookieName =~ s/^([^=]+)\s*=.*$/$1/sgi;
		$cookiesSaved =~ s/(^|;\s*)$cookieName\s*=[^;]*(;\s*|$)/$1.$2/segi;
		
		$cookiesSaved =~ s/;\s*;\s*/; /sgi;
		$cookiesSaved =~ s/(^;\s*|;\s*$)//sgi;

		$cookie =~ s/(;(.*))?$//sgi;
		$cookiesSaved .= "; " . $cookie;
	}

	$cookiesSaved =~ s/(^;\s*|;\s*$)//sgi;

	# Sauvegarder la veleur du cookie en session pour l'envoyer à chaque requête
	if ($cookiesSaved) {
		editInSession($session, 'cookie_'.$siteId, $cookiesSaved);
	} else {
		editInSession($session, 'cookie_'.$siteId, "");
	}
}

# Function: sendCookie
#	Mettre en entête de la requête passée en argument le cookie qu'on a en session
#
# Paramètres:
#	$request - objet requête où mettre le cookie en entête
#	$session - objet session où est stocké le cookie de la session distante
#	$siteId - identifiant du site où on a créé une session pour l'internaute
sub sendCookie #($request, $session, $siteId)
{
	my ($request, $session, $siteId) = @_;

	my $cookieToSend = loadFromSession($session, 'cookie_'.$siteId);

	if ($cookieToSend) {
		if ($cookieToSend =~ m/\|\#cdl\#\|/si) {
			my @cookiesToSend = split(/\|\#cdl\#\|/, $cookieToSend);
			foreach my $cookie (@cookiesToSend) {
				$cookie =~ s/(;(.*))?$//sgi;
				$cookiesString .= $cookie . "; ";
			}
			$cookiesString =~ s/; $//sgi;
			$cookieToSend = $cookiesString;
		}

		$request->header('Cookie' => $cookieToSend);
	}

	return $request;
}

# Function: getDocumentContentType
#	Détecter le type d'un document à partir de son contenu et en exécutant dessus la commande système file
#
# Paramètres:
#	$documentContent - URL du document pour lequel on veut connaître le type
#	$session - objet session utile pour la gestion des cookies
#	$siteId - identifiant du site en cours de traitement
sub getDocumentContentType #($documentContent, $session, $siteId)
{
	my ($documentContent, $session, $siteId) = @_;

	my $contentType;

	open(WRITER, " > ".$cdlDocumentsCachePath."doc_temp_".$session->id) or die "Erreur d'ouverture du fichier : doc_temp_".$session->id.".\n";
	print WRITER $documentContent;

	close(WRITER);

	# Récupération du résultat de la commande file dans un handler
	open(FH, "file -biz ".$cdlDocumentsCachePath."doc_temp_".$session->id." | ");

	# Récupération du type mime dans une variable locale
	while (<FH>) {
		$contentType .= $_;
	}

	# Suppression du retour à la ligne à la fin du résultat de la commande
	$contentType =~ s/\n$//sgi;
	# Suppression des codes superflus
	$contentType =~ s/^\\\d*\- //sgi;
	# Nettoyage du type mime
	$contentType =~ s/(.*)\((.*?)\)/$2/sgi;
	$contentType =~ s/application\/msword application\/msword/application\/msword/sgi;

	# Fermeture du handler
	close(FH);

	# Suppression du fichier temporaire
	unlink($cdlDocumentsCachePath."doc_temp_".$session->id);

	# Gestion des documents Office qu'on ne peut pas différencier avec la commande file (aucune différence entre les différents types de documents Office)
	if ($contentType =~ m/application\/msword/si) {
		if ($documentContent =~ m/Microsoft Excel.*?\@/si) {
			$contentType = "application/vnd.ms-excel";
		} elsif ($documentContent =~ m/PowerPoint.*?\@/si) {
			$contentType = "application/vnd.ms-powerpoint";
		}
	}

	if (!$contentType) {
		if ($documentContent =~ m/^<\?xml[^>]*>\s*<rss/si) {
			$contentType = "application/rss+xml";
		} else {
			$contentType = "application/octet-stream";
		}
	}

	return $contentType;
}

# Function: savePageContentInCache
#	Sauvegarder le contenu passé en argument de la page générée dans un fichier de cache, et renvoyer le nom de ce fichier
#
# Paramètres:
#	$requestMethod - méthode HTTP avec laquelle la page a été appelée
#	$pageUrl - URL de la page avec ses paramètres
#	$pageContent - contenu de la page à sauvegarder
#	$displayParameters - chaine concaténant tous les paramètres d'affichage de l'utilisateur
sub savePageContentInCache #($requestMethod, $pageUrl, $pageContent, $displayParameters)
{
	my ($requestMethod, $pageUrl, $pageContent, $displayParameters) = @_;

	# Générer en md5 une clé à partir des informations de la page
	use Digest::SHA1  qw(sha1_hex);
	my $cryptedPartOfFileName = Digest::SHA1::sha1_hex($requestMethod."==>".$pageUrl);

	# Sauvegarde du contenu de la page
	open(WRITER, ">:encoding(iso-8859-1)", $cdlContentCachePath.$cryptedPartOfFileName."_".$displayParameters.".html") or die "Erreur d'ouverture du fichier : ".$cryptedPartOfFileName."_".$displayParameters.".html.\n";
	print WRITER $pageContent;
	close(WRITER);

	return $cryptedPartOfFileName;
}

# Function: getPageContentFromCache
#	Récupérer le contenu de la page passée en paramètre si elle existe un fichier de cache
#
# Paramètres:
#	$requestMethod - méthode HTTP avec laquelle la page a été appelée
#	$pageUrl - URL de la page avec ses paramètres
#	$displayParameters - chaine concaténant tous les paramètres d'affichage de l'utilisateur affectant le code HTML
#	$cacheExpiry - la durée de vie du cache configurée pour le site
sub getPageContentFromCache #($requestMethod, $pageUrl, $displayParameters, $cacheExpiry)
{
	my ($requestMethod, $pageUrl, $displayParameters, $cacheExpiry) = @_;

	# Générer en md5 une clé à partir des informations de la page
	use Digest::SHA1  qw(sha1_hex);
	my $cryptedPartOfFileName = Digest::SHA1::sha1_hex($requestMethod."==>".$pageUrl);

	my $pageContent = "";
	if (-e $cdlContentCachePath.$cryptedPartOfFileName."_".$displayParameters.".html") {
		$lastModified = (stat $cdlContentCachePath.$cryptedPartOfFileName."_".$displayParameters.".html")[9];
		my $lastModifiedExpire = $lastModified+eval($cacheExpiry);
		my $now = time;
		if ($lastModifiedExpire > $now) {
			# Récupération du contenu de la page
			open(FH, $cdlContentCachePath.$cryptedPartOfFileName."_".$displayParameters.".html") or die "Erreur d'ouverture du fichier : ".$cryptedPartOfFileName."_".$displayParameters.".html.\n";

			while (<FH>) {
				$pageContent .= $_;
			}
			close(FH);
		}
	}

	return ($cryptedPartOfFileName, $pageContent);
}

# Function: isNotAlphabetic
#	tester si c'est un caractère n'est pas un alphabétique
#
# Paramètres:
#	$string - chaine contenant le caractère à tester
sub isNotAlphabetic #($string)
{
	my ($string) = @_;

	if ($string =~ m/^[^a-zŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]$/si) {
		return 1;
	}

	return 0;
}

# Function: isNotAlphanumeric
#	tester si c'est un caractère n'est pas un alphanumérique
#
# Paramètres:
#	$string - chaine contenant le caractère à tester
sub isNotAlphanumeric #($string)
{
	my ($string) = @_;

	if ($string =~ m/^[^a-z0-9ŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]$/si) {
		return 1;
	}

	return 0;
}

# Function: glossaryMain
#	Remplacer les mots/séquences mal-prononcés
#
# Paramètres:
#	$string - chaine à traiter
sub glossaryMain #($string)
{
	my ($string) = @_;

	utf8::encode($string);

	# Transformation des caractéres '|' '-' pour ne pas géner la lecture, et juste marquer une pause
	$string =~ s/\|/./sgi;
	$string =~ s/\s+(–|\-)\s+/ , /sgi;

	$string =~ s/^\s*\.\s+/, /sgi;
	$string =~ s/\((.*?)\)/\[$1\]/sgi;

	#$string =~ s/(([a-zŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ])(\.[\wŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]\.?)+)/join(' ',split(\/\.\/,$1))/segi;

	# Ajout des éléments administrés du glossaire
	my @glossaryItems = getGlossaryItems();
	foreach my $glossaryItem (@glossaryItems) {
		my @glossaryItemParts = split(/\t/, $glossaryItem);
		$glossary{sprintf("%09d", $glossaryIndex++)} = {'iCase' => $glossaryItemParts[3], 'sepL' => $glossaryItemParts[4], 'sepR' => $glossaryItemParts[5], 'pattern' => $glossaryItemParts[1], 'replacement' => $glossaryItemParts[2]};
	}

	foreach my $term (sort keys(%glossary)) {
		my $regExpString = ($glossary{$term}->{'iCase'} ? "(?i)" : "").$glossary{$term}->{'pattern'};
		$regExpString =~ s/\\\.([^\?]|$)/\\s\*\\.\\s\*$1/sgi;
		$string =~ s/$regExpString/
			if (($` eq "" or $glossary{$term}->{'sepL'} eq 0 or ($glossary{$term}->{'sepL'} eq 1 and (isNotAlphanumeric(substr $`,-1,1))) or ($glossary{$term}->{'sepL'} eq 2 and isNotAlphabetic(substr $`,-1,1))) and ($' eq "" or $glossary{$term}->{'sepR'} eq 0 or ($glossary{$term}->{'sepR'} eq 1 and isNotAlphanumeric(substr $',0,1)) or ($glossary{$term}->{'sepR'} eq 2 and isNotAlphabetic(substr $',0,1)))) {
				eval $glossary{$term}->{'replacement'}
			} else {
				$&
			}
			/seg;
	}

	return $string;
}

# Function: isBigCursorNotAllowed
#	Tester si l'on est sur un navigateur qui ne gère pas les gros curseurs (supérieurs à 32x32 pixels)
#
# Paramètres:
#	
sub isBigCursorNotAllowed
{
	return $ENV{'HTTP_USER_AGENT'} !~ m/((firefox)\/(3\.[^6]|3\.6\.[7-9]|[^3].\d+)|chrome)/si;
}

# Function: getArrayWithParameterValues
#	Récupérer la liste des valeurs d'un paramètre de requête donné
#
# Paramètres:
#	$paramKey - paramètre dont on veut récupérer la liste des valeurs
#	%requestParameters - table de hachage contenant les paramètres de la requête et leurs valeurs
sub getArrayWithParameterValues #($paramKey, %requestParameters)
{
	my ($paramKey, %requestParameters) = @_;

	my $refParamterValues = $requestParameters{$paramKey};

	return @$refParamterValues;
}

# Function: getGlossaryItems
#	Récupérer la liste items du glossaire dans un tableau
#
# Paramètres:
#	
sub getGlossaryItems
{
	# Chargement du fichier texte de glossaire
	my $glossaryContent = loadConfig($cdlGlossaryConfigPath."/pronunciation_corrections.txt");

	$glossaryContent =~ s/\n$//sgi;

	return split(/\n+/, $glossaryContent);
}

# Function: addSpaceToAcronym
#	Ajout des espaces séparateurs dans les acronymes
#
# Paramètres:
#	$acronym - texte de l'acronyme
sub addSpaceToAcronym #($acronym)
{
	my ($acronym) = @_;

	$acronym =~ s/([A-Z])\./$1 /sg;

	# On retourne le résultat final après le traitement
	return $acronym;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;
