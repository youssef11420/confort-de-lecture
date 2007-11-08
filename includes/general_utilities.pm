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

# File: general_utilities.pm
#	Module de fonction utilitaires de manipulation et nettoyage XHTML, et de gestion des �changes HTTP

# Function: htmlSpecialChars
#	Encodage HTML des caract�res sp�ciaux ('<' et '>')
#
# Param�tres:
#	$string - cha�ne � encoder
sub htmlSpecialChars #($string)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne � encoder
	my ($string) = @_;

	# Enceodage de la cha�ne
	# La fonction remplace tout caract�re sp�cial par son code entit� valide
	$string =~ s/</&lt;/sgi;
	$string =~ s/>/&gt;/sgi;

	# On retourne la cha�ne encod�e
	return $string;
}

# Function: urlEncode
#	Encodage d'une cha�ne � passer dans une URL
#
# Param�tres:
#	$string - cha�ne � encoder
sub urlEncode #($string)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne � encoder
	my ($string) = @_;

	# Enceodage de l'URL
	# La fonction remplace tout caract�re non alphanum�rique
	# par son code constitu� de "%" puis le code hexad�cimal sur 2 caract�res
	$string =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/segi;

	# On retourne l'URL encod�e
	return $string;
}

# Function: urlDecode
#	D�codage d'une cha�ne r�cup�r�e en param�tre
#
# Param�tres:
#	$string - cha�ne � d�coder
sub urlDecode #($string)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne � d�coder
	my ($string) = @_;

	# D�ceodage de l'URL
	# La fonction remplace toute sous-cha�ne sous la forme "%XX" (XX sont 2 alphanup�riques)
	# par le caract�re correspondant qui a cette valeur h�xadecimale
	$string =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/segi;

	# on retourne l'URL d�cod�e
	return $string;
}

# Function: linearizeHtmlCode
#	Supprimer tous les retours � la ligne et les tabulations dans le code HTML
#
# Param�tres:
#	$htmlCode - cha�ne correspondant au code HTML � traiter
sub linearizeHtmlCode #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne correspondant au code HTML � traiter
	my ($htmlCode) = @_;

	# On remplace les retours � la ligne et les tabulations par un espace, tout en supprimant le surplus de caract�res d'espacement
	$htmlCode =~ s/\s+/ /sgi;

	# On supprime les retours � la ligne html (balise br) en trop
	$htmlCode =~ s/<(p|div)(\s[^<]*?)?>\s*<br[^<]*?>\s*<\/\1>/<p$2><\/p>/sgi;

	# On retourne le r�sultat final apr�s le traitement
	return $htmlCode;
}

# Function: cleanIllegalChars
#	Remplacer les caract�res illegaux par leurs entit�s valides equivalentes
#
# Param�tres:
#	$htmlCode - cha�ne correspondant au code HTML � traiter
sub cleanIllegalChars #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne correspondant au code HTML � traiter
	my ($htmlCode) = @_;

	# On prot�ge les caract�res < > qui sont d�j� en entit� valide en les rempla�ant le temps du traitement par un code temporaire
	$htmlCode =~ s/&(lt|gt|quot);/_cdl_carac_temp_$1_/sgi;

	# On remplace toutes les entit�s valides qui sont les valeurs du tableau associatif $illegalCharacters par leurs caract�res �quivalents
	foreach my $key (keys(%illegalCharacters)) {
		$htmlCode =~ s/$illegalCharacters{$key}/$key/segi;
		$specialCharacters .= $key;
	}
	$specialCharacters .= "&";

	# On d�code et r�encode les caract�res sp�ciaux pour remplacer les caract�res non valides par leurs entit�s valides correspondantes
	$htmlCode = decode_entities($htmlCode, $specialCharacters);

	# On encode le & en premier
	$htmlCode =~ s/&/&amp;/sgi;

	# Ensuite on encode les autrs caract�res ill�gaux
	foreach my $key (keys(%illegalCharacters)) {
		my $cleanKey = "\\".$key;
		$htmlCode =~ s/$cleanKey/my @illegalCharEntity = split(\/\|\/, $illegalCharacters{$key}); $illegalCharEntity[0]/segi;
	}

	# On remet les caract�res < > en entit� valide en rempla�ant le code temporaire par les bonnes entit�s valides
	$htmlCode =~ s/_cdl_carac_temp_(lt|gt|quot)_/&$1;/sgi;

	# On retourne le r�sultat final apr�s le traitement
	return $htmlCode;
}

# Function: cleanDeprecatedHtmlTags
#	Supprimer le code html non valide XHTML (Balises et attributs)
#
# Param�tres:
#	$htmlCode - cha�ne correspondant au code HTML � traiter
sub cleanDeprecatedHtmlTags #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne correspondant au code HTML � traiter
	my ($htmlCode) = @_;

	# Mettre toujours un espace avant la fin d'une balise auto-fermante
	$htmlCode =~ s/<([^<]*?\S)\/>/<$1 \/>/sgi;

	# On supprime les balises d�pr�ci�es
	foreach my $tag (%deprecatedHTMLTags) {
		$htmlCode =~ s/<\/?$tag(\s[^<]*?)?>//sgi;
	}

	# On met en miniscule tous les noms de balises
	# On prot�ge les commentaires en les rempla�ant par un code temporaire qu'on annule apr�s
	$htmlCode =~ s/<!--(.*?)-->/___CDL_COMMENT___$1___CDL_COMMENT___/sgi;
	$htmlCode =~ s/(<\/?)((\w|\d)+?)(\s|>)/$1.lc($2).$4/segi;
	$htmlCode =~ s/___CDL_COMMENT___(.*?)___CDL_COMMENT___/<!--$1-->/sgi;

	# On retourne le r�sultat final apr�s le traitement
	return $htmlCode;
}

# Function: cleanAttributesValues
#	Encoder les caract�res '<' et '>' dans le contenu des attributs
#
# Param�tres:
#	$tagAttributes - code html correspondant aux attributs d'une balise quelconque
sub cleanAttributesValues #($tagAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code html correspondant aux attributs d'une balise quelconque
	my ($tagAttributes) = @_;

	$tagAttributes =~ s/\s(\S+)\s*=\s*(\"|\')(.*?)\2/" ".$1."=".$2.htmlSpecialChars($3).$2/segi;

	# On retourne le r�sultat final apr�s le traitement
	return $tagAttributes;
}

# Function: cleanDeprecatedHtmlAttributes
#	Supprimer les attributs non valide XHTML + fermeture des balises autofermantes qui ne sont pas bien ferm�es
#
# Param�tres:
#	$htmlCode - cha�ne correspondant au code HTML � traiter
sub cleanDeprecatedHtmlAttributes #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne correspondant au code HTML � traiter
	my ($htmlCode) = @_;

	# On met en miniscule tous les noms d'attributs et on encode les caract�res '<' et '>' dans le contenu des attributs
	$htmlCode =~ s/(<(\w|\d)+)(\s.*?(<|>).*?)>/$1.cleanAttributesValues($3).">"/segi;
	$htmlCode =~ s/(\s\S*?)\s*=\s*(\"|\')(.*?)\2/lc($1)."=".$2.$3.$2/segi;

	# On ferme les balises autofermantes qui ne sont pas ferm�es pour les rendre XHTML
	# Ce traitement est fait ici pour b�n�ficier du nettoyage des attributs avant
	foreach my $selfClosingTag (%selfClosingTags) {
		if ($selfClosingTag) {
			$htmlCode =~ s/(<$selfClosingTag(\s[^>]*?[^\/])?)\s*>/$1 \/>/sgi;
		}
	}

	# On �tudie le cas des balises o� certains attributs pr�sents dans %deprecatedHTMLAttributes sont valides.
	# Dans ce cas on remplace l'attribut XXXX par un code temporaire sous la form _cdl_XXXX
	$htmlCode =~ s/(<(script|input|link|style|a|object|param|button)\s)(([^<]*?\s)?(type)\s*=\s*(.*?(\s|>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(input|param|button|option)\s)(([^<]*?\s)?(value)\s*=\s*(.*?(\s|>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(img|object)\s)(([^<]*?\s)?(height)\s*=\s*(.*?(\s|>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(img|object|table|colgroup|col)\s)(([^<]*?\s)?(width)\s*=\s*(.*?(\s|>)))/$1$4_cdl_$5=$6/sgi;

	# On supprime tous les attributs d�pr�ci�s
	foreach my $attribute (%deprecatedHTMLAttributes) {
		$htmlCode =~ s/\s$attribute\s*=\s*(\"|\')(.*?)\1(\s|>)/$3/sgi;
		# Si l'attribut est d�clar� sans valeur (par exemple : nowrap)
		$htmlCode =~ s/\s$attribute(\s|>)/$1/sgi;
	}

	# On supprime le code temporaire _cdl_ (_cdl_XXXX ==> XXXX)
	$htmlCode =~ s/_cdl_(type|value|height|width)\s*=\s*(.*?)(\s|>)/$1=$2$3/sgi;

	# On retourne le r�sultat final apr�s le traitement
	return $htmlCode;
}

# Function: cleanUselessHTML
#	Supprimer les balises vides
#
# Param�tres:
#	$htmlCode - cha�ne correspondant au code HTML � traiter
sub cleanUselessHTML #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne correspondant au code HTML � traiter
	my ($htmlCode) = @_;

	# On remplie le contenu des balises vides � ne pas supprimer avec un contenu temporaire __CDL_EMPTY_TAG_NOT_TO_DELETE___
	foreach my $emptyTag (%emptyTagsToKeep) {
		$htmlCode =~ s/(<$emptyTag(\s[^<]*?)?>)\s*(<\/$emptyTag>)/$1."__CDL_EMPTY_TAG_NOT_TO_DELETE___".$3/segi;
	}

	# On supprime les balises vides inutiles
	while ($htmlCode =~ m/<((\w|\d)+?)(\s+[^>]*?)?(>\s*)(<\/\1>)/si) {
		$htmlCode =~ s/<((\w|\d)+?)(\s+[^>]*?)?(>\s*)(<\/\1>)//sgi;
	}

	# On supprime le code temporaire __CDL_EMPTY_TAG_NOT_TO_DELETE___ (<balise>__CDL_EMPTY_TAG_NOT_TO_DELETE___</balise> ==> <balise></balise>)
	foreach my $emptyTag (%emptyTagsToKeep) {
		$htmlCode =~ s/(<$emptyTag(.*?)>)__CDL_EMPTY_TAG_NOT_TO_DELETE___(<\/$emptyTag>)/$1$3/sgi;
	}

	# Supprimer les spans, ils servent plus � rien
	$htmlCode =~ s/<\/?span(\s[^<]*?)?>//sgi;

	# On retourne le r�sultat final apr�s le traitement
	return $htmlCode;
}

# Function: cleanAllHtml
#	Fonction g�n�rale de nettoyage et am�lioration XHTML
#
# Param�tres:
#	$htmlCode - cha�ne correspondant au code HTML � traiter
sub cleanAllHtml #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne correspondant au code HTML � traiter
	my ($htmlCode) = @_;

	# Pour ne pas traiter les cha�nes sp�ciales (qui sont dans les balises script). On les stocke pour les remettre apr�s les traitements qui suivent apr�s
	my $i = 0;
	my @scriptsContents;
	$htmlCode =~ s/(<script(\s[^<]*?)?>)(.*?)(<\/script>)/
		$scriptsContents[$i] = $3;
		$1."___CDL_SCRIPT".$i++."___".$4/segi;

	$htmlCode = linearizeHtmlCode($htmlCode);

	$htmlCode = cleanIllegalChars($htmlCode);

	$htmlCode = cleanDeprecatedHtmlTags($htmlCode);

	$htmlCode = cleanDeprecatedHtmlAttributes($htmlCode);

	$htmlCode = cleanUselessHTML($htmlCode);

	# On remet les contenus des balises script en les rep�rant avec la chaine sp�cial ___CDL_SCRIPT(un nombre)___
	$htmlCode =~ s/___CDL_SCRIPT(\d*)___/$scriptsContents[$1]/segi;

	# On retourne le r�sultat final apr�s le traitement
	return $htmlCode;
}

# Function: initHTTPAgent
#	Initialisation de l'agent HTTP
#
# Param�tres:
#	
sub initHTTPAgent
{
	# Initialisation de l'agent HTTP
	my $userAgent = LWP::UserAgent->new(agent => $agentNameToSend);
	
	# Retourner l'objet cr��
	return $userAgent;
}

# Function: putParametersInUrl
#	Ajouter les param�tres pass�s en arguments � l'URL pass� aussi en argument
#
# Param�tres:
#	$url - URL � compl�ter avec les param�tres
#	%requestParameters - param�tres � coller � l'URL
sub putParametersInUrl #($url, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - URL � compl�ter avec les param�tres
	# - param�tres � coller � l'URL
	my ($url, %requestParameters) = @_;

	$url .= "?";

	# Coller les param�tres un � un dans l'URL
	foreach my $paramterKey (keys(%requestParameters)) {
		$url .= $paramterKey."=".urlEncode($requestParameters{$paramterKey})."&";
	}

	# On supprime le caract�re en trop (& commercial de la derni�re it�ration, ou ? qui reste s'il n'y avait aucun param�tre)
	$url =~ s/.$//sgi;

	# Retourner l'URL mise � jour
	return $url;
}

# Function: buildMultipartRequest
#	Ecriture des donn�es en post dans le cas de l'envoi de fichiers (multipart/form-data)
#
# Param�tres:
#	$request - objet requ�te � modifier
#	%requestParameters - table de hachage contenant les param�tres � envoyer
sub buildMultipartRequest #($request, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - objet requ�te � modifier
	# - table de hachage contenant les param�tres � envoyer
	my ($request, %requestParameters) = @_;

	# R�cup�ration de la valeur de boundary pour d�limiter les param�tres dans la requ�te
	my $contentType = $ENV{'CONTENT_TYPE'};
	my $boundary;
	$contentType =~ s/boundary=(-*)(.*)($|;)/$boundary = $2;/segi;

	my $requestContent = "";

	# G�n�ration de la cha�ne de param�tres
	my $requestParametersString = "";
	foreach my $paramKey (keys(%requestParameters)) {
		my $paramValue = $requestParameters{$paramKey};
		# On traite la valeur du param�tre dans une variable � part pour r�cup�rer le bon nom de fichier
		my $fileName = $paramValue;
		$fileName =~ s/.*[\/\\](.*)/$1/;

		# R�cup�ration du handler pour lire le contenu du fichier
		my $uploadFileHandler = upload($paramKey);

		# Variable pour savoir s'il y a eu un fichier envoy�
		my $fileIsUploaded = 0;
		# Variable o� stocker le contenu du fichier
		my $fileContent = "";

		# Remplissage de la cha�ne du contenu du fichier upload�
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
	# Fermer le contenu de la requ�te en d�limitant par le boundary
	$requestContent .= "--".$boundary."--";

	# Mise � jour du contenu de la requ�te
	$request->content($requestContent);

	# Retourner l'objet repr�sentant la requ�te HTTP rempli avec les bons param�tres valable pour un envoi en multipart/form-data
	return $request;
}

# Function: initParametersForRequest
#	Ecriture des donn�es en param�tre � envoyer dans l'objet requ�te
#
# Param�tres:
#	$request - objet requ�te � modifier
#	$methodKey - m�thode d'envoi de la requ�te (GET ou POST)
#	%requestParameters - table de hachage contenant les param�tres � envoyer
sub initParametersForRequest #($request, $methodKey, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - objet requ�te � modifier
	# - m�thode d'envoi de la requ�te (GET ou POST)
	# - table de hachage contenant les param�tres � envoyer
	my ($request, $methodKey, %requestParameters) = @_;
	
	if ($ENV{'CONTENT_TYPE'}) {
		my $contentType = $ENV{'CONTENT_TYPE'};
		$contentType =~ s/(boundary=)(-*)/$1/sgi;
		$request->content_type($contentType);
	}

	# G�n�ration de la cha�ne de param�tres
	my $requestParametersString = "";
	foreach my $paramKey (keys(%requestParameters)) {
		$requestParametersString .= $paramKey."=".$requestParameters{$paramKey}."&";
	}

	# Ecriture des param�tres dans la requ�te
	if ($methodKey eq 'POST') {
		if ($request->content_type =~ /multipart\/form-data/si) {
			$request = buildMultipartRequest($request, %requestParameters);
		} else {
			$request->content($requestParametersString);
		}
	} else {
		$request->uri($request->uri."?".$requestParametersString);
	}

	# Retourner l'objet repr�sentant la requ�te HTTP rempli avec les bons param�tres
	return $request;
}

# Function: initRequest
#	Cr�er et param�trer la requ�te HTTP
#
# Param�tres:
#	$method - m�thode d'envoi de la requ�te (GET ou POST)
#	$url - URL � appeler pour effectuer la requ�te
#	$typeAccept - types accept�s par la requ�te
#	$referer - referer de la page $url : la page de laquelle on est arriv�
#	%requestParameters - table de hachage contenant les param�tres � envoyer
sub initRequest #($method, $url, $typeAccept, $referer, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - m�thode d'envoi de la requ�te (GET ou POST)
	# - URL � appeler pour effectuer la requ�te
	# - types accept�s par la requ�te
	# - referer de la page $url : la page de laquelle on est arriv�
	# - table de hachage contenant les param�tres � envoyer
	my ($method, $url, $typeAccept, $referer, %requestParameters) = @_;

	my $request;
	my $methodKey;

	# Test et initialisation la m�thode d'envoi
	if (!($method =~ /^(get|post)$/si)) {
		# Erreur si c'est ni POST ni GET
		die "m�thode invalide d'envoi de la requ�te HTTP...";
	} else {
		if ($method =~ /^post$/si) {
			$methodKey = 'POST';
		} else {
			$methodKey = 'GET';
		}
	}

	# Cr�ation de l'objet requ�te
	$request = new HTTP::Request($methodKey => $url);
	initParametersForRequest($request, $methodKey, %requestParameters);

	# G�neration des headers selon les param�tres mentionn�s
	if ($typeAccept) {
		$request->header('Accept' => $typeAccept);
	}
	else {
		$request->header('Accept' => "*/*");
	}

	if ($referer) {
		$request->header('Referer' => $referer);
	}

	# Retourner l'objet requ�te
	return $request;
}

# Function: getResponse
#	Envoi de la requ�te HTTP la r�ception de la r�ponse correspondante
#
# Param�tres:
#	$userAgent - agent HTTP
#	$request - objet requ�te � envoyer
sub getResponse #($userAgent, $request)
{
	# Extraction des arguments dans une variable locale :
	# - agent HTTP
	# - objet requ�te � envoyer
	my ($userAgent, $request) = @_;

	# Envoi de la requ�te par l'agent HTTP et r�cup�ration de l'object r�ponse
	$response = $userAgent->request($request);

	# Retourner la r�ponse
	return $response;
}

# Function: getReferer
#	R�cup�rer l'URL de la version originale de la page pr�c�dente
#
# Param�tres:
#	$url - URL CDL de la page pr�c�dente
#	$siteRootUrl - URL racine du site
sub getReferer #($url, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - URL CDL de la page pr�c�dente
	# - URL racine du site
	my ($url, $siteRootUrl) = @_;

	# L'URL originale de la page pr�c�dente
	my $refererUrl = "";

	$url =~ s/\/le\-filtre\/(.*?)\/(.*)$/$refererUrl = makeUrlAbsolute(urlDecode($2), $siteRootUrl);/segi;

	# D�coder les caract�res '&'
	$refererUrl =~ s/&amp;/&/sgi;

	# Retourner l'URL originale de la page pr�c�dente
	return $refererUrl;
}

# Function: redirectDownload
#	Fonction de redirection : elle sera utilis�e pour t�l�charger des fichiers sur l'URL pass�e en argument
#
# Param�tres:
#	$action - action � effectuer sur le document (o = ouverture / d : t�l�chargement)
#	$requestMethod - m�thode avec laquelle appeler l'URL qui renvoit le document
#	$url - URL o� se trouve le document
#	$session - objet session utile pour la gestion des cookies
#	$siteId - identifiant du site en cours de traitement utile pour la gestion des cookies
#	%requestParameters - param�tres � envoyer au script qui renvoit le document
sub redirectDownload #($action, $requestMethod, $url, $session, $siteId, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - action � effectuer sur le document (o = ouverture / d : t�l�chargement)
	# - m�thode avec laquelle appeler l'URL qui renvoit le document
	# - URL o� se trouve le document
	# - objet session utile pour la gestion des cookies
	# - identifiant du site en cours de traitement utile pour la gestion des cookies
	# - param�tres � envoyer au script qui renvoit le document
	my ($action, $requestMethod, $url, $session, $siteId, %requestParameters) = @_;

	my ($siteConfiguration, $siteDomainNames) = ("", "");

	# Chargement des param�tres du site
	my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
	# R�cup�rer la liste de tous les noms de domaine du site
	@siteDomainNames = split(/\t/, getValueForKey($siteConfiguration, 'siteDomainNames'));

	# Construction de l'URL racine du site
	my $siteRootUrl = "http://".$siteDomainNames[0];

	# Cr�ation de l'agent HTTP
	my $userAgent = initHTTPAgent;

	# Initialisation de la requ�te HTTP
	my $request = initRequest($requestMethod, $siteRootUrl."/".$url, $cdlAccept, getReferer($ENV{'HTTP_REFERER'}, $siteRootUrl), %requestParameters);

	# Initialisation du cookie avant l'envoi de la requ�te
	$request = sendCookie($request, $session, $siteId);

	# Envoi de la requ�te HTTP et r�ception de la r�ponse dans l'objet $response
	my $response = getResponse($userAgent, $request);

	# R�cup�ration du cookie dans la r�ponse HTTP et sauvegarde dans la session
	getCookieInSession($response, $session, $siteId);

	my $contentDisposition = $response->header('Content-Disposition');
	# R�cup�ration du type d'encodage des caract�res re�us dans les ent�tes de la r�ponse HTTP
	my $documentContent = $response->content;

	# On r�cup�re plut�t le type mime � partir de son contenu (les premiers octets du fichier)
	# pour �viter les informations incompl�tes du Content-type du site distant
	$contentType = getDocumentContentType($documentContent, $session, $siteId, 1);

	# si on ne dispose pas du nom de fichier dans Content-Disposition (c'est � dire que c'est un lien direct vers le fichier),
	# on r�cup�re son nom � partir de l'URL
	if (!$contentDisposition or $contentDisposition !~ /^inline;/si) {
		$url =~ s/^(.*)\/([^\/\?\&]*?)$/$2/sgi;
	}

	# Gestion de l'ent�te qui permet de donner le bon nom de fichier � t�l�charger,
	# ainsi que la mani�re avec laquelle le pr�senter � l'internaute (ouverture directe ou t�l�chargement)
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

	# Ecriture des ent�tes
	print $session->header('Content-type' => $contentType, 'Content-Disposition' => $contentDisposition);

	# Ecriture du contenu du document dans le flux
	print $documentContent;
	exit;
}

# Function: connectProtectedSite
#	Connexion � un site prot�g�
#
# Param�tres:
#	$cgi - objet cgi pour faire la redirection � la fin
#	$requestMethod - m�thode avec laquelle appeler l'URL de la page prot�g�e
#	$url - URL o� se trouve la page prot�g�e
#	$userLogin - login de l'utilisateur
#	$passwd - mot de passe de l'utilisateur
#	$realm - param�tre realm indispensable pour l'authentification
#	$session - objet session utile pour la gestion des cookies
#	$siteId - identifiant du site en cours de traitement utile pour la gestion des cookies
#	%requestParameters - param�tres � envoyer au script qui renvoit le document
sub connectProtectedSite #($cgi, $requestMethod, $url, $userLogin, $passwd, $realm, $session, $siteId, %requestParameters)
{
	# Extraction des arguments dans une variable locale :
	# - objet cgi pour faire la redirection � la fin
	# - m�thode avec laquelle appeler l'URL de la page prot�g�e
	# - URL o� se trouve la page prot�g�e
	# - login de l'utilisateur
	# - mot de passe de l'utilisateur
	# - param�tre realm indispensable pour l'authentification
	# - objet session utile pour la gestion des cookies
	# - identifiant du site en cours de traitement utile pour la gestion des cookies
	# - param�tres � envoyer au script qui renvoit le document
	my ($cgi, $requestMethod, $url, $userLogin, $passwd, $realm, $session, $siteId, %requestParameters) = @_;

	my ($siteConfiguration, $siteDomainNames) = ("", "");

	# Chargement des param�tres du site
	my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
	# R�cup�rer la liste de tous les noms de domaine du site
	@siteDomainNames = split(/\t/, getValueForKey($siteConfiguration, 'siteDomainNames'));

	# Construction de l'URL racine du site
	my $siteRootUrl = "http://".$siteDomainNames[0];

	# Cr�ation de l'agent HTTP
	my $userAgent = initHTTPAgent;

	# Initialisation de la requ�te HTTP
	my $request = initRequest('get', $siteRootUrl."/".$url, $cdlAccept, getReferer($ENV{'HTTP_REFERER'}, $siteRootUrl), %requestParameters);

	# Initialisation du cookie avant l'envoi de la requ�te
	$request = sendCookie($request, $session, $siteId);

	# Initialisation de l'authentification au site distant

	my $uri = $request->uri;
	$userAgent->credentials($uri->host_port, $realm, $userLogin, $passwd);

	# Envoi de la requ�te HTTP et r�ception de la r�ponse dans l'objet $response
	my $response = getResponse($userAgent, $request);

	if ($response->code eq "401") {
		my $redirectUrl = $ENV{'REQUEST_URI'};

		# Nettoyer l'URL du param�tre cdlact qui est inutile
		$redirectUrl =~ s/(\?|&)cdlact=(.+?)(&|$)/$1/sgi;
		$redirectUrl =~ s/(\?|&)$//sgi;

		my $cookie = new CGI::Cookie(-name=>$session->name, -value=>$session->id);
		print $cgi->redirect(-status=>"302 Moved", -location=>$redirectUrl."&cdlloginerror=1", -cookie=>$cookie);
		exit;
	}

	# Sauvegarde des param�tres de connexion au site prot�g� en session.
	editInSession($session, 'cdl_'.$siteId.'_login', $userLogin);
	editInSession($session, 'cdl_'.$siteId.'_passwd', $passwd);
	editInSession($session, 'cdl_'.$siteId.'_realm', $realm);

	# Redirection vers le script principal pour traitement de la page
	$url =~ s/$siteRootUrl\///sgi;
	print $cgi->redirect("/le-filtre/".$siteId."/".putParametersInUrl($url, %requestParameters));
	exit;
}

# Function: connectDatabase
#	Connexion � la base de donn�es
#
# Param�tres:
#	$databaseHost - adresse du serveur o� se trouve la base de donn�es
#	$databaseName - nom de la base de donn�es
#	$databaseLogin - login pour se connecter � la base
#	$databasePassword - mot de passe pour se connecter � la base
sub connectDatabase #($databaseHost, $databaseName, $databaseLogin, $databasePassword)
{
	# Extraction des arguments dans une variable locale :
	# - adresse du serveur o� se trouve la base de donn�es
	# - nom de la base de donn�es
	# - login pour se connecter � la base
	# - mot de passe pour se connecter � la base
	my ($databaseHost, $databaseName, $databaseLogin, $databasePassword) = @_;

	# Connexion � la base avec les bons param�tres
	my $dbh = DBI->connect(
			"DBI:mysql:database=$databaseName;host=$databaseHost",
			"$databaseLogin",
			"$databasePassword",
			{'RaiseError' => 1})
			or die "Connexion �chou�e !!!";

	# Retourner l'object base de donn�es cr��
	return $dbh;
}

# Function: disconnectDatabase
#	D�connexion de la base de donn�es
#
# Param�tres:
#	$dbh - object base qui permet de se d�connecter
sub disconnectDatabase #($dbh)
{
	# Extraction des arguments dans une variable locale :
	# - object base qui permet de se d�connecter
	my ($dbh) = @_;

	# D�connexion de la base
	$dbh->disconnect;
}

# Function: selectFromDatabase
#	Effectuer une requ�te sur la base de donn�es
#
# Param�tres:
#	$dbh - object base qui identifie la base de donn�es
#	$select - cha�ne correcpondant au SELECT (les colonnes qu'on veut r�cup�rer avec la requ�te)
#	$from - cha�ne correcpondant au FROM (les tables concern�es par la requ�te)
#	$where - cha�ne correcpondant au WHERE (les condition de s�lection des donn�es)
sub selectFromDatabase #($dbh, $select, $from, $where)
{
	# Extraction des arguments dans une variable locale :
	# - object base qui identifie la base de donn�es
	# - cha�ne correcpondant au SELECT (les colonnes qu'on veut r�cup�rer avec la requ�te)
	# - cha�ne correcpondant au FROM (les tables concern�es par la requ�te)
	# - cha�ne correcpondant au WHERE (les condition de s�lection des donn�es)
	my ($dbh, $select, $from, $where) = @_;

	# Construction de la cha�ne correspondant � la requ�te
	my $statement = "select ";
	
	if ($select eq "") {
		$statement .= "*";
	} else {
		$statement .= "$select";
	}

	$statement .= " from $from";
	
	if ($where ne "") {
		$statement .= " where $where";
	}

	# Construction de l'objet permettant d'�xecuter la requ�te
	my $sth = $dbh->prepare($statement) or die "Impossible de pr�parer la requ�te : $dbh->errstr\n";

	# Ex�cution de la requ�te
	my $rv = $sth->execute or die "ne peut pas ex�cuter la requ�te : $sth->errstr";

	# R�cup�ration du r�sultat, et renvoi de la liste des donn�es trouv�es
	my $results = $sth->fetchall_arrayref({});

	return $results;
}

# Function: getCookieInSession
#	R�cup�ration du cookie de session du site distant et sauvegarde de ce cookie en session
#
# Param�tres:
#	$response - objet r�ponse HTTP d'o� extraire le cookie
#	$session - objet session o� stocker le cookie de la session distante
#	$siteId - identifiant du site o� on veut cr�er une session pour l'internaute
sub getCookieInSession #($response, $session, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - objet r�ponse HTTP d'o� extraire le cookie
	# - objet session o� stocker le cookie de la session distante
	# - identifiant du site o� on veut cr�er une session pour l'internaute
	my ($response, $session, $siteId) = @_;

	# Le cookie � sauvegarder en session
	my $cookieToSave = $response->header("Set-cookie");

	# Sauvegarder la veleur du cookie en session pour l'envoyer � chaque requ�te
	if ($cookieToSave) {
		editInSession($session, 'cookie_'.$siteId, $cookieToSave);
	}
}

# Function: sendCookie
#	Mettre en ent�te de la requ�te pass�e en argument le cookie qu'on a en session
#
# Param�tres:
#	$request - objet requ�te o� mettre le cookie en ent�te
#	$session - objet session o� est stock� le cookie de la session distante
#	$siteId - identifiant du site o� on a cr�� une session pour l'internaute
sub sendCookie #($request, $session, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - objet requ�te o� mettre le cookie en ent�te
	# - objet session o� est stock� le cookie de la session distante
	# - identifiant du site o� on a cr�� une session pour l'internaute
	my ($request, $session, $siteId) = @_;

	my $cookieToSend = loadFromSession($session, 'cookie_'.$siteId);

	if ($cookieToSend) {
		$request->header('Cookie' => $cookieToSend);
	}

	return $request;
}

# Function: getDocumentContentType
#	D�tecter le type d'un document � partir de son contenu et en ex�cutant dessus la commande syst�me file
#
# Param�tres:
#	$documentContent - url du document pour lequel on veut conna�tre le type
#	$session - objet session utile pour la gestion des cookies
#	$siteId - identifiant du site en cours de traitement utile pour la gestion des cookies
#	$needTypeMime - bool�en pour demander le type mime au lien d'une description
sub getDocumentContentType #($documentContent, $session, $siteId, $needTypeMime)
{
	# Extraction des arguments dans une variable locale :
	# - url du document pour lequel on veut conna�tre le type
	# - objet session
	# - identifiant du site en cours de traitement
	# - bool�en pour demander le type mime au lien d'une description
	my ($documentContent, $session, $siteId, $needTypeMime) = @_;

	my $contentType;

	open(WRITER, " > ".$cdlRootPath.$cdlDocumentsCachePath."doc_temp_".$session->id);
	print WRITER $documentContent;

	close(WRITER);

	# R�cup�ration du r�sultat de la commande file dans un handler
	if ($needTypeMime) {
		$needTypeMime = "i";
	} else {
		$needTypeMime = "";
	}
	open(FH, "file -b".$needTypeMime."z ".$cdlRootPath.$cdlDocumentsCachePath."doc_temp_".$session->id." | ");

	# R�cup�ration du type mime dans une variable locale
	while (<FH>) {
		$contentType = $_;
	}

	# Fermeture du handler
	close(FH);

	# Suppression du fichier temporaire
	unlink($cdlRootPath.$cdlDocumentsCachePath."doc_temp_".$session->id);

	# Suppression du retour � la ligne � la fin du r�sultat de la commande
	$contentType =~ s/\n$//sgi;

	# Gestion des documents Office qu'on ne peut pas diff�rencier avec la commande file (aucune diff�rence entre les diff�rents types de documents Office)
	if ($contentType =~ m/application\/msword/si) {
		if ($documentContent =~ m/Microsoft Excel[^\w\d\s]\@.*?h[^\w\d]/si) {
			$contentType = "application/vnd.ms-excel";
		} elsif ($documentContent =~ m/PowerPoint[^\w\d\s]\@[^\w\d]*?\@/si) {
			$contentType = "application/vnd.ms-powerpoint";
		}
	}
	if ($contentType eq "Microsoft Office Document") {
		if ($documentContent =~ m/Microsoft Excel[^\w\d\s]\@.*?h[^\w\d]/si) {
			$contentType = "Microsoft Excel Document";
		} elsif ($documentContent =~ m/PowerPoint[^\w\d\s]\@[^\w\d]*?\@/si) {
			$contentType = "Microsoft PowerPoint Document";
		} else {
			$contentType = "Microsoft Word Document";
		}
	}

	return $contentType;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;