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

# File: general_utilities.pm
#	Module de fonction utilitaires de manipulation et nettoyage XHTML, et de gestion des échanges HTTP

# Function: htmlSpecialChars
#	Encodage HTML des caractères spéciaux ('<' et '>')
#
# Paramètres:
#	$string - chaîne à encoder
sub htmlSpecialChars #($string)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne à encoder
	my ($string) = @_;

	# Enceodage de la chaîne
	# La fonction remplace tout caractère spécial par son code entité valide
	$string =~ s/</&lt;/sgi;
	$string =~ s/>/&gt;/sgi;

	# On retourne la chaîne encodée
	return $string;
}

# Function: urlEncode
#	Encodage d'une chaîne à passer dans une URL
#
# Paramètres:
#	$string - chaîne à encoder
sub urlEncode #($string)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne à encoder
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
	# Extraction des arguments dans une variable locale :
	# - chaîne à décoder
	my ($string) = @_;

	# Déceodage de l'URL
	# La fonction remplace toute sous-chaîne sous la forme "%XX" (XX sont 2 alphanupériques)
	# par le caractère correspondant qui a cette valeur héxadecimale
	$string =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/segi;

	# on retourne l'URL décodée
	return $string;
}

# Function: linearizeHtmlCode
#	Supprimer tous les retours à la ligne et les tabulations dans le code HTML
#
# Paramètres:
#	$htmlCode - chaîne correspondant au code HTML à traiter
sub linearizeHtmlCode #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne correspondant au code HTML à traiter
	my ($htmlCode) = @_;

	# On remplace les retours à la ligne et les tabulations par un espace, tout en supprimant le surplus de caractères d'espacement
	$htmlCode =~ s/\s+/ /sgi;

	# On supprime les retours à la ligne html (balise br) en trop
	$htmlCode =~ s/<(p|div)(\s[^>]*?)?>\s*<br[^>]*?>\s*<\/\1>/<p$2><\/p>/sgi;

	# On retourne le résultat final après le traitement
	return $htmlCode;
}

# Function: cleanIllegalChars
#	Remplacer les caractères illegaux par leurs entités valides equivalentes
#
# Paramètres:
#	$htmlCode - chaîne correspondant au code HTML à traiter
sub cleanIllegalChars #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne correspondant au code HTML à traiter
	my ($htmlCode) = @_;

	# On protège les caractères spéciaux qui sont déjà en entité valide en les remplaçant le temps du traitement par un code temporaire
	$regExp = "&(";
	foreach my $key (keys(%specialCharacters)) {
		$regExp .= $key."|";
	}
	$regExp .= "\\#\\d+?)";

	$htmlCode =~ s/$regExp;/"_cdl_carac_temp_".$1."_"/segi;
	# Le cas où l'erreur de ne pas mettre un ; à la fin est commise.
	$htmlCode =~ s/$regExp(\s|$)/"_cdl_carac_temp_".$1."_".$2/segi;

	# On encode les '&' qui ne le sont pas
	$htmlCode =~ s/&/&amp;/sgi;

	# On remet les caractères en entité valide en remplaçant le code temporaire par les bonnes entités valides
	$htmlCode =~ s/_cdl_carac_temp_((\w|\d)+?|\#\d+?)_/&$1;/sgi;

	# On retourne le résultat final après le traitement
	return $htmlCode;
}

# Function: cleanDeprecatedHtmlTags
#	Supprimer le code html non valide XHTML (Balises et attributs)
#
# Paramètres:
#	$htmlCode - chaîne correspondant au code HTML à traiter
sub cleanDeprecatedHtmlTags #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne correspondant au code HTML à traiter
	my ($htmlCode) = @_;

	# Mettre toujours un espace avant la fin d'une balise auto-fermante
	$htmlCode =~ s/<([^>]*?\S)\/>/<$1 \/>/sgi;

	# On supprime les balises dépréciées
	foreach my $tag (%deprecatedHTMLTags) {
		$htmlCode =~ s/<\/?$tag(\s[^>]*?)?>//sgi;
	}

	# On met en miniscule tous les noms de balises
	# On protège les commentaires en les remplaçant par un code temporaire qu'on annule après
	$htmlCode =~ s/<!--(.*?)-->/___CDL_COMMENT___$1___CDL_COMMENT___/sgi;
	$htmlCode =~ s/(<\/?)((\w|\d)+?)(\s|>)/$1.lc($2).$4/segi;
	$htmlCode =~ s/___CDL_COMMENT___(.*?)___CDL_COMMENT___/<!--$1-->/sgi;

	# On retourne le résultat final après le traitement
	return $htmlCode;
}

# Function: cleanAttributesValues
#	Nettoyage des attibuts HTML et leurs valeurs : encodage des caractères '<' et '>' dans les valeurs, suppression des attributs dépréciés et mise en miniscule des noms des attributs
#
# Paramètres:
#	$tagAttributes - code html correspondant aux attributs d'une balise quelconque
#	$removeDeprecatedAttributes - booléen pour indiquer si on procède à la suppression des attibuts dépréciés ou non. Utile pour faire 2 appels dans <cleanDeprecatedHtmlAttributes>)
sub cleanAttributesValues #($tagAttributes, $removeDeprecatedAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code html correspondant aux attributs d'une balise quelconque
	# - booléen pour indiquer si on procède à la suppression des attibuts dépréciés ou non. Utile pour faire 2 appels dans la fontion cleanDeprecatedHtmlAttributes)
	my ($tagAttributes, $removeDeprecatedAttributes) = @_;

	# On met en miniscule tous les noms d'attributs et on encode les caractères '<' et '>' dans le contenu des attributs
	if (not $removeDeprecatedAttributes) {
		$tagAttributes =~ s/\s(\S+)\s*=\s*(\"|\')(.*?)\2/" ".$1."=".$2.htmlSpecialChars($3).$2/segi;
		$tagAttributes =~ s/(\s\S*?)\s*=\s*(\"|\')(.*?)\2/lc($1)."=".$2.$3.$2/segi;
	}

	# On supprime tous les attributs dépréciés
	if ($removeDeprecatedAttributes) {
		foreach my $attribute (%deprecatedHTMLAttributes) {
			$tagAttributes =~ s/\s$attribute\s*=\s*(\"|\')(.*?)\1(\s|>)/$3/sgi;
			# Si l'attribut est déclaré sans valeur (par exemple : nowrap)
			$tagAttributes =~ s/\s$attribute(\s|>)/$1/sgi;
		}
	}

	# On retourne le résultat final après le traitement
	return $tagAttributes;
}

# Function: cleanDeprecatedHtmlAttributes
#	Supprimer les attributs non valides XHTML + fermeture des balises autofermantes qui ne sont pas bien fermées
#
# Paramètres:
#	$htmlCode - chaîne correspondant au code HTML à traiter
sub cleanDeprecatedHtmlAttributes #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne correspondant au code HTML à traiter
	my ($htmlCode) = @_;

	# On met en miniscule tous les noms d'attributs et on encode les caractères '<' et '>' dans le contenu des attributs
	$htmlCode =~ s/(<(\w|\d)+)(\s.*?(<|>).*?)>/$1.cleanAttributesValues($3, 0).">"/segi;

	# On ferme les balises autofermantes qui ne sont pas fermées pour les rendre XHTML
	# Ce traitement est fait ici pour bénéficier du nettoyage des attributs avant
	foreach my $selfClosingTag (%selfClosingTags) {
		if ($selfClosingTag) {
			$htmlCode =~ s/(<$selfClosingTag(\s[^>]*?[^\/])?)\s*>/$1 \/>/sgi;
		}
	}

	# On étudie le cas des balises où certains attributs présents dans %deprecatedHTMLAttributes sont valides.
	# Dans ce cas on remplace l'attribut XXXX par un code temporaire sous la form _cdl_XXXX
	$htmlCode =~ s/(<(script|input|link|style|a|object|param|button)\s)(([^>]*?\s)?(type)\s*=\s*(.*?(\s|>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(input|param|button|option)\s)(([^>]*?\s)?(value)\s*=\s*(.*?(\s|>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(img|object)\s)(([^>]*?\s)?(height)\s*=\s*(.*?(\s|>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(img|object|table|colgroup|col)\s)(([^>]*?\s)?(width)\s*=\s*(.*?(\s|>)))/$1$4_cdl_$5=$6/sgi;

	# Suppression des
	$htmlCode =~ s/(<(\w|\d)+)(\s[^>]*?(<|>).*?)>/$1.cleanAttributesValues($3, 1).">"/segi;

	# On supprime le code temporaire _cdl_ (_cdl_XXXX ==> XXXX)
	$htmlCode =~ s/_cdl_(type|value|height|width)\s*=\s*(.*?)(\s|>)/$1=$2$3/sgi;

	# On retourne le résultat final après le traitement
	return $htmlCode;
}

# Function: cleanUselessHTML
#	Supprimer tout le code HTML inutile (balises vides sans impact, commentaires informationnels, ...)
#
# Paramètres:
#	$htmlCode - chaîne correspondant au code HTML à traiter
sub cleanUselessHTML #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne correspondant au code HTML à traiter
	my ($htmlCode) = @_;

	# On remplie le contenu des balises vides à ne pas supprimer avec un contenu temporaire __CDL_EMPTY_TAG_NOT_TO_DELETE___
	foreach my $emptyTag (%emptyTagsToKeep) {
		$htmlCode =~ s/(<$emptyTag(\s[^>]*?)?>)\s*(<\/$emptyTag>)/$1."_CDL_EMPTY_TAG_NOT_TO_DELETE_".$3/segi;
	}

	# On supprime les balises vides inutiles
	while ($htmlCode =~ m/<((\w|\d)+?)(\s+[^>]*?)?(>\s*)(<\/\1>)/si) {
		$htmlCode =~ s/<((\w|\d)+?)(\s+[^>]*?)?(>\s*)(<\/\1>)//sgi;
	}

	# On supprime le code temporaire __CDL_EMPTY_TAG_NOT_TO_DELETE___ (<balise>__CDL_EMPTY_TAG_NOT_TO_DELETE___</balise> ==> <balise></balise>)
	foreach my $emptyTag (%emptyTagsToKeep) {
		$htmlCode =~ s/(<$emptyTag(.*?)>)_CDL_EMPTY_TAG_NOT_TO_DELETE_(<\/$emptyTag>)/$1$3/sgi;
	}

	# Supprimer les spans, ils servent plus à rien
	$htmlCode =~ s/<\/?span(\s[^>]*?)?>//sgi;

	# Supprimer les retours à la ligne (balise br) en trop.
	$htmlCode =~ s/<br(\s[^>]*?)?><br(\s[^>]*?)?>(<br(\s[^>]*?)?>)*/<br$1><br$2>/sgi;

	# Supprimer les paragraphes vides ou avec des espaces qui sont en trop
	$htmlCode =~ s/(<p(\s[^>]*?)?>(\s|&nbsp;)*<\/p>)(\s*<p(\s[^>]*?)?>(\s|&nbsp;)*<\/p>)*/$1/sgi;

	# On supprime des commentaires (hors CDL et commentaires conditionnels IE)

	# On mets des codes temporaires pour protéger les commentaires utiles
	$htmlCode =~ s/<!--cdlReplace(\s[^>]*?)?-->\s*<!--(.*?)-->\s*<!--\/cdlReplace-->/
		<!--cdlReplace$1-->_CDL_COMMENT_FOR_REPLACE_$2_CDL_COMMENT_FOR_REPLACE_<!--\/cdlReplace-->/sg;
	$htmlCode =~ s/<!--(\/?cdl.*?)-->/_CDL_COMMENT_$1_/sg;
	$htmlCode =~ s/<!--(\[if\s*.*?\]>(.*?)<!\[endif\])-->/_CDL_IE_COMMENT_$1_CDL_IE_COMMENT_/sgi;

	$htmlCode =~ s/<!--.*?-->//sgi;
	
	# Remmettre les balises CDL en enlevant le code temporaire
	$htmlCode =~ s/_CDL_IE_COMMENT_(.*?)_CDL_IE_COMMENT_/<!--$1_CDL_IE_COMMENT-->/sg;
	$htmlCode =~ s/<!--(\/?cdl.*?)-->/_CDL_COMMENT_$1_/sg;
	$htmlCode =~ s/_CDL_COMMENT_(\/?cdl.*?)_/<!--$1-->/sg;
	$htmlCode =~ s/_CDL_COMMENT_FOR_REPLACE_(.*?)_CDL_COMMENT_FOR_REPLACE_/<!--$1-->/sg;

	# On retourne le résultat final après le traitement
	return $htmlCode;
}

# Function: cleanAllHtml
#	Fonction générale de nettoyage et amélioration XHTML
#
# Paramètres:
#	$htmlCode - chaîne correspondant au code HTML à traiter
sub cleanAllHtml #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne correspondant au code HTML à traiter
	my ($htmlCode) = @_;

	# Pour ne pas traiter les chaînes spéciales (qui sont dans les balises script). On les stocke pour les remettre après les traitements qui suivent après
	my $i = 0;
	my @scriptsContents;
	$htmlCode =~ s/(<script(\s[^>]*?)?>)(.*?)(<\/script>)/
		$scriptsContents[$i] = $3;
		$1."___CDL_SCRIPT".$i++."___".$4/segi;

	$htmlCode = linearizeHtmlCode($htmlCode);

	$htmlCode = cleanIllegalChars($htmlCode);

	$htmlCode = cleanDeprecatedHtmlTags($htmlCode);

	$htmlCode = cleanDeprecatedHtmlAttributes($htmlCode);

	$htmlCode = cleanUselessHTML($htmlCode);

	# On remet les contenus des balises script en les repérant avec la chaine spécial ___CDL_SCRIPT(un nombre)___
	$htmlCode =~ s/___CDL_SCRIPT(\d*)___/$scriptsContents[$1]/segi;

	# On retourne le résultat final après le traitement
	return $htmlCode;
}

# Function: initHTTPAgent
#	Initialisation de l'agent HTTP
#
# Paramètres:
#	
sub initHTTPAgent
{
	# Initialisation de l'agent HTTP
	my $userAgent = LWP::UserAgent->new(agent => $agentNameToSend);
	
	# Retourner l'objet créé
	return $userAgent;
}

# Function: putParametersInUrl
#	Ajouter les paramètres passés en arguments à l'URL passé aussi en argument
#
# Paramètres:
#	$url - URL à compléter avec les paramètres
#	%requestParameters - paramètres à coller à l'URL
sub putParametersInUrl #($url, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - URL à compléter avec les paramètres
	# - paramètres à coller à l'URL
	my ($url, %requestParameters) = @_;

	$url .= "?";

	# Coller les paramètres un à un dans l'URL
	foreach my $paramterKey (keys(%requestParameters)) {
		my $refParamterValues = $requestParameters{$paramterKey};
		my @parameterValues = @$refParamterValues;
		foreach my $parameterValue (@parameterValues) {
			$url .= $paramterKey."=".urlEncode($parameterValue)."&";
		}
	}

	# On supprime le caractère en trop (& commercial de la dernière itération, ou ? qui reste s'il n'y avait aucun paramètre)
	$url =~ s/.$//sgi;

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
	# Extraction des arguments dans une variable locale :
	# - objet requête à modifier
	# - table de hachage contenant les paramètres à envoyer
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
#	$methodKey - méthode d'envoi de la requête (GET ou POST)
#	%requestParameters - table de hachage contenant les paramètres à envoyer
sub initParametersForRequest #($request, $methodKey, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - objet requête à modifier
	# - méthode d'envoi de la requête (GET ou POST)
	# - table de hachage contenant les paramètres à envoyer
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
		foreach my $paramValue (@paramValues) {
			$requestParametersString .= $paramKey."=".urlEncode($paramValue)."&";
		}
	}
	$requestParametersString =~ s/.$//sgi;

	# Ecriture des paramètres dans la requête
	if ($methodKey eq 'POST') {
		if ($request->content_type =~ /multipart\/form-data/si) {
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
#	$method - méthode d'envoi de la requête (GET ou POST)
#	$url - URL à appeler pour effectuer la requête
#	$typeAccept - types acceptés par la requête
#	$referer - referer de la page $url : la page de laquelle on est arrivé
#	%requestParameters - table de hachage contenant les paramètres à envoyer
sub initRequest #($method, $url, $typeAccept, $referer, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - méthode d'envoi de la requête (GET ou POST)
	# - URL à appeler pour effectuer la requête
	# - types acceptés par la requête
	# - referer de la page $url : la page de laquelle on est arrivé
	# - table de hachage contenant les paramètres à envoyer
	my ($method, $url, $typeAccept, $referer, %requestParameters) = @_;

	my $request;
	my $methodKey;

	# Test et initialisation la méthode d'envoi
	if (!($method =~ /^(get|post)$/si)) {
		# Erreur si c'est ni POST ni GET
		die "méthode invalide d'envoi de la requête HTTP...";
	} else {
		if ($method =~ /^post$/si) {
			$methodKey = 'POST';
		} else {
			$methodKey = 'GET';
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

# Function: getResponse
#	Envoi de la requête HTTP la réception de la réponse correspondante
#
# Paramètres:
#	$userAgent - agent HTTP
#	$request - objet requête à envoyer
sub getResponse #($userAgent, $request)
{
	# Extraction des arguments dans une variable locale :
	# - agent HTTP
	# - objet requête à envoyer
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
	# Extraction des arguments dans une variable locale :
	# - URL CDL de la page précédente
	# - URL racine du site
	my ($url, $siteRootUrl) = @_;

	# L'URL originale de la page précédente
	my $refererUrl = "";

	$siteRootUrl =~ s/^https?:\/\///sgi;

	$url =~ s/((\d|\w)+?:\/\/$ENV{'SERVER_NAME'})?\/le\-filtre(-http(s)?)?\/?$/$refererUrl = "http".$4.":\/\/".$siteRootUrl;/segi;
	$url =~ s/((\d|\w)+?:\/\/$ENV{'SERVER_NAME'})?\/le\-filtre(-http(s)?)?\/(.*?)\/(.*)$/$refererUrl = "http".$4.":\/\/".$6;/segi;

	# Décoder les caractères '&'
	$refererUrl =~ s/&amp;/&/sgi;

	# Retourner l'URL originale de la page précédente
	return $refererUrl;
}

# Function: redirectDownload
#	Fonction de redirection : elle sera utilisée pour télécharger des fichiers sur l'URL passée en argument
#
# Paramètres:
#	$action - action à effectuer sur le document (o = ouverture / d : téléchargement)
#	$requestMethod - méthode avec laquelle appeler l'URL qui renvoit le document
#	$url - URL où se trouve le document
#	$session - objet session utile pour la gestion des cookies
#	$siteId - identifiant du site en cours de traitement utile pour la gestion des cookies
#	%requestParameters - paramètres à envoyer au script qui renvoit le document
sub redirectDownload #($action, $requestMethod, $url, $session, $siteId, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - action à effectuer sur le document (o = ouverture / d : téléchargement)
	# - méthode avec laquelle appeler l'URL qui renvoit le document
	# - URL où se trouve le document
	# - objet session utile pour la gestion des cookies
	# - identifiant du site en cours de traitement utile pour la gestion des cookies
	# - paramètres à envoyer au script qui renvoit le document
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
	getCookieInSession($response, $session, $siteId);

	my $contentDisposition = $response->header('Content-Disposition');
	# Récupération du type d'encodage des caractères reçus dans les entêtes de la réponse HTTP
	my $documentContent = $response->content;

	# On récupère plutôt le type mime à partir de son contenu (les premiers octets du fichier)
	# pour éviter les informations incomplètes du Content-type du site distant
	$contentType = getDocumentContentType($documentContent, $session, $siteId, 1);

	# Si on ne dispose pas du nom de fichier dans Content-Disposition (c'est à dire que c'est un lien direct vers le fichier),
	# on récupère son nom à partir de l'URL
	if (!$contentDisposition or $contentDisposition !~ /^inline;?/si) {
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
#	$siteId - identifiant du site en cours de traitement utile pour la gestion des cookies
#	%requestParameters - paramètres à envoyer au script qui renvoit le document
sub connectProtectedSite #($cgi, $requestMethod, $url, $userLogin, $passwd, $realm, $session, $siteId, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - objet cgi pour faire la redirection à la fin
	# - méthode avec laquelle appeler l'URL de la page protégée
	# - URL où se trouve la page protégée
	# - login de l'utilisateur
	# - mot de passe de l'utilisateur
	# - paramètre realm indispensable pour l'authentification
	# - objet session utile pour la gestion des cookies
	# - identifiant du site en cours de traitement utile pour la gestion des cookies
	# - paramètres à envoyer au script qui renvoit le document
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

# Function: getCookieInSession
#	Récupération du cookie de session du site distant et sauvegarde de ce cookie en session
#
# Paramètres:
#	$response - objet réponse HTTP d'où extraire le cookie
#	$session - objet session où stocker le cookie de la session distante
#	$siteId - identifiant du site où on veut créer une session pour l'internaute
sub getCookieInSession #($response, $session, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - objet réponse HTTP d'où extraire le cookie
	# - objet session où stocker le cookie de la session distante
	# - identifiant du site où on veut créer une session pour l'internaute
	my ($response, $session, $siteId) = @_;

	# Le cookie à sauvegarder en session
	my $cookieToSave = $response->header("Set-cookie");

	# Sauvegarder la veleur du cookie en session pour l'envoyer à chaque requête
	if ($cookieToSave) {
		editInSession($session, 'cookie_'.$siteId, $cookieToSave);
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
	# Extraction des arguments dans une variable locale :
	# - objet requête où mettre le cookie en entête
	# - objet session où est stocké le cookie de la session distante
	# - identifiant du site où on a créé une session pour l'internaute
	my ($request, $session, $siteId) = @_;

	my $cookieToSend = loadFromSession($session, 'cookie_'.$siteId);

	if ($cookieToSend) {
		$cookieToSend =~ s/^(.*?);(.*)$/$1/sgi;
		$request->header('Cookie' => $cookieToSend);
	}

	return $request;
}

# Function: getDocumentContentType
#	Détecter le type d'un document à partir de son contenu et en exécutant dessus la commande système file
#
# Paramètres:
#	$documentContent - url du document pour lequel on veut connaître le type
#	$session - objet session utile pour la gestion des cookies
#	$siteId - identifiant du site en cours de traitement utile pour la gestion des cookies
#	$needTypeMime - booléen pour demander le type mime au lien d'une description
sub getDocumentContentType #($documentContent, $session, $siteId, $needTypeMime)
{
	# Extraction des arguments dans une variable locale :
	# - url du document pour lequel on veut connaître le type
	# - objet session
	# - identifiant du site en cours de traitement
	# - booléen pour demander le type mime au lien d'une description
	my ($documentContent, $session, $siteId, $needTypeMime) = @_;

	my $contentType;

	open(WRITER, " > ".$cdlRootPath.$cdlDocumentsCachePath."doc_temp_".$session->id);
	print WRITER $documentContent;

	close(WRITER);

	# Récupération du résultat de la commande file dans un handler
	if ($needTypeMime) {
		$needTypeMime = "i";
	} else {
		$needTypeMime = "";
	}
	open(FH, "file -b".$needTypeMime."z ".$cdlRootPath.$cdlDocumentsCachePath."doc_temp_".$session->id." | ");

	# Récupération du type mime dans une variable locale
	while (<FH>) {
		$contentType = $_;
	}

	# Nettoyage du type mime
	# Cas des fichiers compressés
	$contentType =~ s/(.*)\((.*?)\)/$2/sgi;
	$contentType =~ s/x-zip/zip/sgi;

	# Fermeture du handler
	close(FH);

	# Suppression du fichier temporaire
	unlink($cdlRootPath.$cdlDocumentsCachePath."doc_temp_".$session->id);

	# Suppression du retour à la ligne à la fin du résultat de la commande
	$contentType =~ s/\n$//sgi;
	$contentType =~ s/^\\\d*\- //sgi;

	# Gestion des documents Office qu'on ne peut pas différencier avec la commande file (aucune différence entre les différents types de documents Office)
	if ($contentType =~ m/application\/msword/si) {
		if ($documentContent =~ m/Microsoft Excel.*?\@/si) {
			$contentType = "application/vnd.ms-excel";
		} elsif ($documentContent =~ m/PowerPoint.*?\@/si) {
			$contentType = "application/vnd.ms-powerpoint";
		}
	}
	if ($contentType eq "Microsoft Office Document") {
		if ($documentContent =~ m/Microsoft Excel.*?\@/si) {
			$contentType = "Microsoft Excel Document";
		} elsif ($documentContent =~ m/PowerPoint.*?\@/si) {
			$contentType = "Microsoft PowerPoint Document";
		} else {
			$contentType = "Microsoft Word Document";
		}
	}

	if (!$contentType) {
		$contentType = "application/octet-stream";
	}

	return $contentType;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;