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

# File: general_html_utils.pm
#	Module de gestion globale du code HTML, et de manipulation des URLs

# Function: makeUrlAbsolute
#	Traiter une URL et la transformer en URL absolue
#
# Paramètres:
#	$url - url à mettre en absolue
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub makeUrlAbsolute #($url, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - url à mettre en absolue
	# - url racine du site
	# - chemin vers la page en cours de traitement
	my ($url, $siteRootUrl, $pagePath) = @_;

	if (!$pagePath) {
		$pagePath = "/";
	}

	# Si l'URL commence par un protocole (http:// , ftp:// , etc ...), on ne fait rien : l'url est déjà absolue
	if($url =~ m/^(\d|\w)*?:\/\//si) {
		return $url;
	}

	# Si l'URL commence par un "mailto:", c'est un lien pour démarrer l'écriture d'un nouveau message électronique vers l'addresse indiquée après mailto:
	# Idem pour les liens javascript
	if ($url =~ m/^mailto:/si or $url =~ m/^javascript:/si) {
		return $url;
	}

	# Si l'URL commence par un / , cad qu'il faur chercher la ressource à partir de la ressource
	# Sinon, la ressource est à chercher dans le même chemin que la page
	if ($url !~ m/^\//si) {
		$url = $pagePath.$url;
	}

	$url = $siteRootUrl.$url;

	# Retourner l'URL absolue
	return $url;
}

# Function: getUriFromUrl
#	Obtenir une URI avec les paramètres à partir d'une adresse donnée et d'un chemin absolu
#
# Paramètres:
#	$url - url à mettre en URI avec les paramètres
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site en cours de traitement
sub getUriFromUrl #($url, $pagePath, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - url à mettre en URI avec les paramètres
	# - chemin vers la page en cours de traitement
	# - identifiant du site en cours de traitement
	my ($url, $pagePath, $siteId) = @_;

	if (!$pagePath) {
		$pagePath = "/";
	}

	my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Récupérer la liste de tous les noms de domaine du site
	my @siteDomainNames = split(/\t/, getValueForKey($siteConfig, 'siteDomainNames'));

	foreach my $siteDomainName (@siteDomainNames) {
		if ($url =~ m/^http:\/\/$siteDomainName/si) {
			$url =~ s/^http:\/\/$siteDomainName//sgi;
			last;
		}
	}

	# Si l'URL ne commence ni par un / et ni par "protocole://", il faut rajouter l'URI du chemin $pagePath
	if ($url !~ m/^\//si and $url !~ m/^(\d|\w)*?:\/\//si and $url ne "") {
		$url = $pagePath.$url;
	}

	# Suppression du premier /
	$url =~ s/^\///sgi;

	if ($url =~ m/^(\d|\w)*?:\/\//si) {
		$url = "/le-filtre/".$siteId."/".$url;
	}

	# Retourner l'URI à partir de la racine
	return $url;
}

# Function: parseAllHead
#	Fonction générale de parsing du head
#
# Paramètres:
#	$htmlCode - code HTML à parser
#	$entirePageTemplateString - chaîne correspondant à la template de la page (à remplir par les valeurs du head)
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$activateJavascript - option indiquant si on garde le javascript du site parsé en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
#	$siteId - identifiant du site parsé
sub parseAllHead #($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à parser
	# - chaîne correspondant à la template de la page (à remplir par les valeurs du head)
	# - url racine du site
	# - chemin vers la page en cours de traitement
	# - option indiquant si on garde le javascript du site parsé en version CDL
	# - option permettant de dire si on doit parser le javascript du site parsé
	# - identifiant du site parsé
	my ($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $siteId) = @_;

	$htmlCode = cleanStyles($htmlCode);

	$htmlCode = cleanAllHtml($htmlCode);

	$headHtmlCode = getHeadContent($htmlCode);

	my $allLinks;
	my $allMetas;

	($htmlCode, $allLinks) = parseLinks($htmlCode, $siteRootUrl, $pagePath);
	($htmlCode, $allMetas) = parseMetas($htmlCode, $pagePath, $siteId);

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

	# Remplissage des différentes valeurs du head dans la template générale de la page
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'DOCUMENT_TITLE', $documentTitle);
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'METAS', $allMetas);
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'LINKS', $allLinks);
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'SCRIPTS', $allScripts);

	# Retourner le code HTML restant à parser et la template générale de la page mise à jour
	return ($htmlCode, $entirePageTemplateString);
}

# Function: parseAllHtml
#	Fonction générale de parsing du HTML
#
# Paramètres:
#	$htmlCode - code HTML à parser
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$activateJavascript - option indiquant si on garde le javascript du site parsé en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
#	$displayImages - option indiquant si on garde les images du site parsé en version CDL
#	$displayObjects - option indiquant si on garde les objects du site parsé en version CDL
#	$displayApplets - option indiquant si on garde les applets du site parsé en version CDL
#	$parseTablesToList - option indiquant si on transforme les tableaux en liste à puce en version CDL
#	$activateFrames - option indiquant si on garde les frames/iframes du site parsé en version CDL
#	$siteId - identifiant du site parsé
sub parseAllHtml #($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à parser
	# - url racine du site
	# - chemin vers la page en cours de traitement
	# - option indiquant si on garde le javascript du site parsé en version CDL
	# - option permettant de dire si on doit parser le javascript du site parsé
	# - option indiquant si on garde les images du site parsé en version CDL
	# - option indiquant si on garde les objects du site parsé en version CDL
	# - option indiquant si on garde les applets du site parsé en version CDL
	# - option indiquant si on transforme les tableaux en liste à puce en version CDL
	# - option indiquant si on garde les frames/iframes du site parsé en version CDL
	# - identifiant du site parsé
	my ($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId) = @_;

	$htmlCode = cleanAllHtml($htmlCode);

	$htmlCode = parseLinkHref($htmlCode, $pagePath, $siteId);

	$htmlCode = cleanLink($htmlCode);

	my $allScripts = "";
	if ($activateJavascript) {
		($htmlCode, $allScripts) = parseScripts($htmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript);
	} else {
		$htmlCode = cleanEventListeners($htmlCode, $siteRootUrl, $pagePath);
		$htmlCode = cleanScripts($htmlCode, $siteRootUrl, $pagePath);
	}

	$htmlCode = parseForms($htmlCode, $pagePath, $siteId);

	if ($displayImages) {
		$htmlCode = parseImagesSrc($htmlCode, $siteRootUrl, $pagePath);
	} else {
		$htmlCode = replaceImageWithAlt($htmlCode, $siteRootUrl, $pagePath);
	}

	$htmlCode = parseMapAreas($htmlCode, $pagePath, $displayImages, $siteId);

	if ($displayObjects) {
		$htmlCode = parseObjects($htmlCode, $siteRootUrl, $pagePath);
	} else {
		$htmlCode = replaceObjectsWithAlternativeHtml($htmlCode);
	}

	if ($activateFrames) {
		$htmlCode = parseAllFramesSrc($htmlCode, $pagePath, $siteId);
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

	# Retourner le code HTML traité
	return $htmlCode;
}

# Function: getDocumentLanguage
#	Récupération de la langue du document à partir de l'attribut lang de la balise html
#
# Paramètres:
#	$htmlCode - code HTML où chercher la langue
#	$defaultLanguage - langue par défaut si aucune n'est fournie dans la page
sub getDocumentLanguage #($htmlCode, $defaultLanguage)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML où chercher la langue
	# - langue par défaut si aucune n'est fournie dans la page
	my ($htmlCode, $defaultLanguage) = @_;

	# Variable où sera stockée la langue du document
	my $pageLanguage = "";

	# Récupération de la langue dans la balise html
	$htmlCode =~ s/<html(\s[^<]*?)?\s(lang)\s*=\s*(\"|\')(.*?)\3/$pageLanguage = $4;/segi;

	# Si la langue n'a pas été spécifiée dans le document d'origine, on met celle par défaut du site, sinon celle par défaut de l'application
	if (!$pageLanguage) {
		return $defaultLanguage;
	}

	# Retourner la langue trouvée dans la page d'origine
	return $pageLanguage;
}

# Function: getBodyOpenTag
#	Récupération des attributs de la balise body utiles en version filtrée dans une chaîne de caractères
#
# Paramètres:
#	$htmlCode - code HTML où chercher les attributs de la balise body
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
sub getBodyAttributesInHash {
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs de la balise body
	# - option permettant de dire si on doit parser le javascript du site parsé
	my ($tagAttributes, $parseJavascript) = @_;

	my $attributesString = "";

	# Construire la liste des attributs qu'on veut garder en chaîne
	$attributesRegExpString = join("|", %eventListeners);

	# Récupérer les bons attributs javascript
	$tagAttributes =~ s/\s($attributesRegExpString)\s*=\s*((\"|\')(.*?)\3)/$attributesString .= " ".($parseJavascript ? parseJavascriptCode($1) : $1)."=".$2;/segi;

	# Récupérer les attributs génériques
	$tagAttributes =~ s/\s(id|class)\s*=\s*((\"|\')(.*?)\3)/$attributesString .= " ".$1."=".$2;/segi;

	# Retourner la chaîne des attributs à intégrer à la balise body finale
	return $attributesString;
}

# Function: getBodyAttributes
#	Récupération de la balise body et tri des attributs à reporter dans la version filtrée
#
# Paramètres:
#	$htmlCode - code HTML où chercher les attributs de la balise body
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
sub getBodyAttributes {
	# Extraction des arguments dans une variable locale :
	# - code HTML où chercher les attributs de la balise body
	# - option permettant de dire si on doit parser le javascript du site parsé
	my ($htmlCode, $parseJavascript) = @_;

	my $attributesString = "";

	# Rechercher la balise body et appeler la fonction <getBodyAttributesInHash> qui récupère les bons attributs
	$htmlCode =~ s/<body(\s[^<]*?)>/$attributesString = getBodyAttributesInHash($1);/segi;

	# Retourner la chaîne des attributs à intégrer à la balise body finale
	return $attributesString;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;