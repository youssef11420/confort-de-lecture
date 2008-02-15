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

# File: general_html_utils.pm
#	Module de gestion globale du code HTML, et de manipulation des URLs

# Function: makeUrlAbsolute
#	Traiter une URL et la transformer en URL absolue
#
# Param�tres:
#	$url - url � mettre en absolue
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub makeUrlAbsolute #($url, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - url � mettre en absolue
	# - url racine du site
	# - chemin vers la page en cours de traitement
	my ($url, $siteRootUrl, $pagePath) = @_;

	if (!$pagePath) {
		$pagePath = "/";
	}

	# Si l'URL commence par un protocole (http:// , ftp:// , etc ...), on ne fait rien : l'url est d�j� absolue
	if($url =~ m/^(\d|\w)*?:\/\//si) {
		return $url;
	}

	# Si l'URL commence par un "mailto:", c'est un lien pour d�marrer l'�criture d'un nouveau message �lectronique vers l'addresse indiqu�e apr�s mailto:
	# Idem pour les liens javascript
	if ($url =~ m/^mailto:/si or $url =~ m/^javascript:/si) {
		return $url;
	}

	# Si l'URL commence par un / , cad qu'il faur chercher la ressource � partir de la ressource
	# Sinon, la ressource est � chercher dans le m�me chemin que la page
	if ($url !~ m/^\//si) {
		$url = $pagePath.$url;
	}
	$url = $siteRootUrl.$url;

	# Retourner l'URL absolue
	return $url;
}

# Function: getUriFromUrl
#	Obtenir une URI avec les param�tres � partir d'une adresse donn�e et d'un chemin absolu
#
# Param�tres:
#	$url - url � mettre en URI avec les param�tres
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site pars�
#	$siteRootUrl - url racine du site
sub getUriFromUrl #($url, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - url � mettre en URI avec les param�tres
	# - chemin vers la page en cours de traitement
	# - identifiant du site pars�
	# - url racine du site
	my ($url, $pagePath, $siteId, $siteRootUrl) = @_;

	# Si l'URL est vide, on va vers la page d'accueil
	if ($url eq "") {
		$url = $siteRootUrl;
	}

	# Si l'URL ne commence pas par "protocole://", il faut rajouter l'URI du chemin $pagePath
	if ($url !~ m/^(\w|\d)+?:\/\//si) {
		$url = $siteRootUrl.($url =~ m/^\//si ? "" : $pagePath."/").$url;
	}

	# Gestion des protocoles (http et https, puis les autres protocoles impossible � g�rer)
	if ($url =~ m/^http(s?):\/\/(.*)$/si) {
		my $secure = $1;
		$url = $2;
		$url = ($secure ? ($siteRootUrl =~ /^http:\/\//si ? "https://".$ENV{'SERVER_NAME'}."/le-filtre-https/".$siteId."/" : "") : ($siteRootUrl =~ /^http:\/\//si ? "" : "http://".$ENV{'SERVER_NAME'}."/le-filtre/".$siteId."/")).$url;
	} elsif ($url =~ m/^(\d|\w)*?:\/\//si) {
		$url = "/sortie/".$defaultLanguage."/".$url;
	}

	# Suppression du nom de domaine de la page (qui se trouve d�j� dans la balise base)
	$siteRootUrl =~ s/^https?:\/\///sgi;
	if ($url =~ m/^$siteRootUrl\/*/si) {
		$url =~ s/^$siteRootUrl\/*//sgi;
	} else {
		if ($url !~ m/^\/le-filtre(-https)?\/$siteId/si and $url !~ m/^(\w|\d)+?:\/\//si) {
			$url = "../".$url;
		}
	}

	# Retourner l'URI � partir de la racine
	return $url;
}

# Function: parseAllHead
#	Fonction g�n�rale de parsing du head
#
# Param�tres:
#	$htmlCode - code HTML � parser
#	$entirePageTemplateString - cha�ne correspondant � la template de la page (� remplir par les valeurs du head)
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$activateJavascript - option indiquant si on garde le javascript du site pars� en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site pars�
#	$siteId - identifiant du site pars�
sub parseAllHead #($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � parser
	# - cha�ne correspondant � la template de la page (� remplir par les valeurs du head)
	# - url racine du site
	# - chemin vers la page en cours de traitement
	# - option indiquant si on garde le javascript du site pars� en version CDL
	# - option permettant de dire si on doit parser le javascript du site pars�
	# - identifiant du site pars�
	my ($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $siteId) = @_;

	$htmlCode = cleanStyles($htmlCode);

	$htmlCode = cleanAllHtml($htmlCode);

	$headHtmlCode = getHeadContent($htmlCode);

	my $allLinks;
	my $allMetas;

	($htmlCode, $allLinks) = parseLinks($htmlCode, $siteRootUrl, $pagePath);
	($htmlCode, $allMetas) = parseMetas($htmlCode, $pagePath, $siteId, $siteRootUrl);

	if ($allLinks !~ m/rel\s*=\s*(\"|\')shortcut\s*icon\1/si) {
		$allLinks .= "\t\t<link href=\"".$siteRootUrl."/favicon.ico\" rel=\"shortcut icon\" />\n"
	}

	my $documentTitle = getPageTitle($htmlCode);

	my $allScripts = "";
	if ($activateJavascript) {
		($headHtmlCode, $allScripts) = parseScripts($headHtmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript);
	} else {
		$headHtmlCode = cleanScripts($headHtmlCode, $siteRootUrl, $pagePath, $parseJavascript);
	}

	# Remplissage des diff�rentes valeurs du head dans la template g�n�rale de la page
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'DOCUMENT_TITLE', $documentTitle);
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'METAS', $allMetas);
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'LINKS', $allLinks);
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'SCRIPTS', $allScripts);

	# Retourner le code HTML restant � parser et la template g�n�rale de la page mise � jour
	return ($htmlCode, $entirePageTemplateString);
}

# Function: parseAllHtml
#	Fonction g�n�rale de parsing du HTML
#
# Param�tres:
#	$htmlCode - code HTML � parser
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$activateJavascript - option indiquant si on garde le javascript du site pars� en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site pars�
#	$displayImages - option indiquant si on garde les images du site pars� en version CDL
#	$displayObjects - option indiquant si on garde les objects du site pars� en version CDL
#	$displayApplets - option indiquant si on garde les applets du site pars� en version CDL
#	$parseTablesToList - option indiquant si on transforme les tableaux en liste � puce en version CDL
#	$activateFrames - option indiquant si on garde les frames/iframes du site pars� en version CDL
#	$siteId - identifiant du site pars�
sub parseAllHtml #($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � parser
	# - url racine du site
	# - chemin vers la page en cours de traitement
	# - option indiquant si on garde le javascript du site pars� en version CDL
	# - option permettant de dire si on doit parser le javascript du site pars�
	# - option indiquant si on garde les images du site pars� en version CDL
	# - option indiquant si on garde les objects du site pars� en version CDL
	# - option indiquant si on garde les applets du site pars� en version CDL
	# - option indiquant si on transforme les tableaux en liste � puce en version CDL
	# - option indiquant si on garde les frames/iframes du site pars� en version CDL
	# - identifiant du site pars�
	my ($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId) = @_;

	$htmlCode = cleanAllHtml($htmlCode);

	$htmlCode = parseLinkHref($htmlCode, $pagePath, $siteId, $siteRootUrl);

	$htmlCode = cleanLink($htmlCode);

	my $allScripts = "";
	if ($activateJavascript) {
		($htmlCode, $allScripts) = parseScripts($htmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript);
	} else {
		$htmlCode = cleanEventListeners($htmlCode);
		$htmlCode = cleanScripts($htmlCode);
	}

	$htmlCode = parseForms($htmlCode, $pagePath, $siteId, $siteRootUrl);

	if ($displayImages) {
		$htmlCode = parseImages($htmlCode, $siteRootUrl, $pagePath);
	} else {
		$htmlCode = replaceImageWithAlt($htmlCode);
	}

	$htmlCode = parseMapAreas($htmlCode, $pagePath, $displayImages, $siteId, $siteRootUrl);

	if ($displayObjects) {
		$htmlCode = parseObjects($htmlCode, $siteRootUrl, $pagePath);
	} else {
		$htmlCode = replaceObjectsWithAlternativeHtml($htmlCode);
	}

	if ($activateFrames) {
		$htmlCode = parseAllFramesSrc($htmlCode, $pagePath, $siteId, $siteRootUrl);
	} else {
		$htmlCode = replaceFramesWithAlternativeHtml($htmlCode);
	}

	if ($displayApplets) {
		$htmlCode = parseAppletsSrc($htmlCode, $siteRootUrl, $pagePath);
	} else {
		$htmlCode = replaceAppletsWithAlternativeHtml($htmlCode);
	}

	if ($parseTablesToList) {
		$htmlCode = parseTablesToLists($htmlCode);
	} else {
		$htmlCode = cleanTables($htmlCode);
	}

	# Retourner le code HTML trait�
	return $htmlCode;
}

# Function: getDocumentLanguage
#	R�cup�ration de la langue du document � partir de l'attribut lang de la balise html
#
# Param�tres:
#	$htmlCode - code HTML o� chercher la langue
#	$defaultLanguage - langue par d�faut si aucune n'est fournie dans la page
sub getDocumentLanguage #($htmlCode, $defaultLanguage)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML o� chercher la langue
	# - langue par d�faut si aucune n'est fournie dans la page
	my ($htmlCode, $defaultLanguage) = @_;

	# Variable o� sera stock�e la langue du document
	my $pageLanguage = "";

	# R�cup�ration de la langue dans la balise html
	$htmlCode =~ s/<html(\s[^<]*?)?\s(lang)\s*=\s*(\"|\')(.*?)\3/$pageLanguage = $4;/segi;

	# Si la langue n'a pas �t� sp�cifi�e dans le document d'origine, on met celle par d�faut du site, sinon celle par d�faut de l'application
	if (!$pageLanguage) {
		return $defaultLanguage;
	}

	# Retourner la langue trouv�e dans la page d'origine
	return $pageLanguage;
}

# Function: getBodyOpenTag
#	R�cup�ration des attributs de la balise body utiles en version filtr�e dans une cha�ne de caract�res
#
# Param�tres:
#	$htmlCode - code HTML o� chercher les attributs de la balise body
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site pars�
sub getBodyAttributesInHash {
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs de la balise body
	# - option permettant de dire si on doit parser le javascript du site pars�
	my ($tagAttributes, $parseJavascript) = @_;

	my $attributesString = "";

	# Construire la liste des attributs qu'on veut garder en cha�ne
	$attributesRegExpString = join("|", %eventListeners);

	# R�cup�rer les bons attributs javascript
	$tagAttributes =~ s/\s($attributesRegExpString)\s*=\s*((\"|\')(.*?)\3)/$attributesString .= " ".($parseJavascript ? parseJavascriptCode($1) : $1)."=".$2;/segi;

	# R�cup�rer les attributs g�n�riques
	$tagAttributes =~ s/\s(id|class)\s*=\s*((\"|\')(.*?)\3)/$attributesString .= " ".$1."=".$2;/segi;

	# Retourner la cha�ne des attributs � int�grer � la balise body finale
	return $attributesString;
}

# Function: getBodyAttributes
#	R�cup�ration de la balise body et tri des attributs � reporter dans la version filtr�e
#
# Param�tres:
#	$htmlCode - code HTML o� chercher les attributs de la balise body
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site pars�
sub getBodyAttributes {
	# Extraction des arguments dans une variable locale :
	# - code HTML o� chercher les attributs de la balise body
	# - option permettant de dire si on doit parser le javascript du site pars�
	my ($htmlCode, $parseJavascript) = @_;

	my $attributesString = "";

	# Rechercher la balise body et appeler la fonction <getBodyAttributesInHash> qui r�cup�re les bons attributs
	$htmlCode =~ s/<body(\s[^<]*?)>/$attributesString = getBodyAttributesInHash($1);/segi;

	# Retourner la cha�ne des attributs � int�grer � la balise body finale
	return $attributesString;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;