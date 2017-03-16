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

# File: misc_html.pm
#	Module de gestion globale du code HTML, et de manipulation des URLs

# Function: makeUrlAbsolute
#	Traiter une URL et la transformer en URL absolue
#
# Paramètres:
#	$url - URL à mettre en absolue
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub makeUrlAbsolute #($url, $siteRootUrl, $pagePath)
{
	my ($url, $siteRootUrl, $pagePath) = @_;

	if (!$pagePath) {
		$pagePath = "";
	}

	# Si l'URL commence par un protocole (http:// , ftp:// , etc ...), on ne fait rien : l'url est déjà absolue
	if($url =~ m/^([\w\d]+:)?\/\//si) {
		return $url;
	}

	# Si l'URL commence par un "mailto:", c'est un lien pour démarrer l'écriture d'un nouveau message électronique vers l'addresse indiquée après mailto:
	# Idem pour les liens javascript
	if ($url =~ m/^mailto:/si or $url =~ m/^javascript:/si) {
		return $url;
	}

	# Si l'URL commence par un / , cad qu'il faur chercher la ressource à partir de la racine
	# Sinon, la ressource est à chercher dans le même chemin que la page
	if ($url !~ m/^\//si) {
		$url = $pagePath."/".$url;
	}
	$url = $siteRootUrl.$url;

	$url =~ s/\/\.\//\//sgi;

	# Retourner l'URL absolue
	return $url;
}

# Function: makeUrlAbsoluteWithoutProtocol
#	Traiter une URL et la transformer en URL absolue sans le protocole (exemple : sans "http://")
#
# Paramètres:
#	$url - URL à mettre en absolue
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub makeUrlAbsoluteWithoutProtocol #($url, $siteRootUrl, $pagePath)
{
	my ($url, $siteRootUrl, $pagePath) = @_;

	# Mettre d'abord l'URL en absolue
	$url = makeUrlAbsolute($url, $siteRootUrl, $pagePath);

	# Récupérer l'information : http ou https
	my $isHttps = "";
	if ($url =~ m/^https:\/\//si) {
		$isHttps = "-https";
	}

	# Supprimer le protocole http(s)://
	$url =~ s/^https?:\/\///sgi;

	# Retourner l'URL absolue
	return ($isHttps, $url);
}

# Function: getUriFromUrl
#	Obtenir une URI avec les paramètres à partir d'une adresse donnée et d'un chemin absolu
#
# Paramètres:
#	$url - URL à mettre en URI avec les paramètres
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - URL racine du site
#	$method - Méthode d'appel de l'URL (dans le cas des formulaires)
#	$trustedDomainNames - noms de domaine configuré de confiance
sub getUriFromUrl #($url, $pagePath, $siteId, $siteRootUrl, $method, $trustedDomainNames)
{
	my ($url, $pagePath, $siteId, $siteRootUrl, $method, $trustedDomainNames) = @_;

	# Si l'URL est vide, on va vers la page d'accueil
	if ($url eq "") {
		$url = $siteRootUrl;
	}

	# Si l'URL ne commence pas par "protocole://", il faut rajouter l'URI du chemin $pagePath
	if ($url !~ m/^https?:\/\//si) {
		$url = $siteRootUrl.($url =~ m/^\//si ? "" : $pagePath."/").$url;
	}

	# Gestion des protocoles (http et https, puis les autres protocoles impossible à gérer)
	if ($url =~ m/^http(s)?:\/\/([^\/]+)\/*(.*)$/si) {
		my $secure = $1;
		my $domainName = $2;
		my $uri = $3;
		if ($siteRootUrl =~ m/^http(s)?:\/\/$domainName/si) {
			$url = ($embeddedMode ne "" ? "" : $domainName."/").$uri;
			$url = ($secure ? ($siteRootUrl =~ m/^http:\/\//si ? "https://".$ENV{'SERVER_NAME'}.($embeddedMode ne "" ? $embeddedMode."/fs" : "/le-filtre-https/".$siteId)."/" : "") : ($siteRootUrl =~ m/^http:\/\//si ? "" : "http://".$ENV{'SERVER_NAME'}.($embeddedMode ne "" ? $embeddedMode."/f" : "/le-filtre/".$siteId)."/")).$url;
		} elsif (!$trustedDomainNames or $url !~ m/^https?:\/\/($trustedDomainNames)/si) {
			$url =~ s/^http(s)?:\/\///sgi;
			$url = $embeddedMode."/sortie".($secure eq "s" ? "-https" : "")."/".$siteId."/".$defaultLanguage."/".$method."/".$url;
		}
	}

	# Suppression du nom de domaine de la page (qui se trouve déjà dans la balise base)
	$siteRootUrl =~ s/^https?:\/\///sgi;
	if ($url =~ m/^$siteRootUrl\/*/si) {
		$url =~ s/^$siteRootUrl\/*//sgi;
	} else {
		if ($embeddedMode eq "" and $url !~ m/^\/(le-filtre|sortie)(-https)?(\/$siteId)?/si and $url !~ m/^https?:\/\//si) {
			$url = "../".$url;
		}
	}

	# Retourner l'URI à partir de la racine
	return $url;
}

# Function: getCleanedPageContent
#	Récupération du contenu de la réponse HTTP
#
# Paramètres:
#	$response - objet réponse HTTP d'où extraire le contenu de la page
#	$contentType - type et encodage du contenu
#	$activateAudio - booléen indiquant si l'utilisateur a choisi de vocaliser les pages
sub getCleanedPageContent #($response, $contentType, $activateAudio)
{
	my ($response, $contentType, $activateAudio) = @_;

	# Récupération du contenu de la réponse
	my $htmlCode;
	if ($contentType =~ m/charset=utf\-?\d+/si) {
		$htmlCode = $response->decoded_content;
	} else {
		$htmlCode = $response->content;
	}

	my $tree = HTML::TreeBuilder->new;
	$tree->store_comments(1);
	$tree->parse($htmlCode);
	$tree->eof();
	$htmlCode = $tree->as_HTML;
	$tree = $tree->delete;

	# Gestion des balises CDL exclure
	$htmlCode = parseExclure($htmlCode);

	# Gestion des balises CDL contraste
	$htmlCode = parseContraste($htmlCode);

	# Gestion des balises CDL change/replace
	$htmlCode = parseChanges($htmlCode);
	# Gestion des balises CDL replace seules (raccourcis pour éviter les balises CDL change vides)
	$htmlCode = parseAloneReplaces($htmlCode, $activateAudio);

	# Encoder les caractères en UTF-8 dans une page qui est encodée comme tel
	if ($contentType =~ m/charset=utf\-?\d+/si) {
		$htmlCode =~ s/((<(script)( [^>]*?)?>)(.*?)(<\/\3>))/
			my $scriptContent = $5;
			utf8::encode($scriptContent);
			$2.$scriptContent.$6
			/segi;
	}

	return $htmlCode;
}

# Function: cleanAttributesValues
#	Nettoyage des attibuts HTML et leurs valeurs
#
# Paramètres:
#	$tagAttributes - code html correspondant aux attributs d'une balise
sub cleanAttributesValues #($tagAttributes)
{
	my ($tagAttributes) = @_;

	# On supprime tous les attributs dépréciés
	foreach my $attribute (@deprecatedHTMLAttributes) {
		$tagAttributes =~ s/ $attribute=(\"|\')(.*?)\1//sgi;
	}

	$tagAttributes =~ s/( (xml:space|shape|dir|frameborder|scrolling|compact|noshade|declare|valuetype|ismap|method|_cdl_type|checked|disabled|readonly|multiple|selected|frame|rules|scope|nowrap)=(\"|\'))(.*?)\3/$1.lc($4).$3/segi;

	# On supprime les attributs ID vides
	$tagAttributes =~ s/ id=(\"|\')\1//sgi;

	# On retourne le résultat final après le traitement
	return $tagAttributes;
}

# Function: addDotToAcronym
#	Ajout des points séparateurs dans les acronymes
#
# Paramètres:
#	$acronym - texte de l'acronyme
sub addDotToAcronym #($acronym)
{
	my ($acronym) = @_;

	$acronym =~ s/([A-Z])/$1./sg;

	# On retourne le résultat final après le traitement
	return $acronym;
}

# Function: cleanHtml
#	Nettoyage supplémentaire du code HTML
#
# Paramètres:
#	$htmlCode - chaîne correspondant au code HTML à traiter
sub cleanHtml #($htmlCode)
{
	my ($htmlCode) = @_;

	# On étudie le cas des balises où certains attributs présents dans @deprecatedHTMLAttributes sont valides.
	# Dans ce cas on remplace l'attribut XXXX par un code temporaire sous la form _cdl_XXXX
	$htmlCode =~ s/(<(script|input|link|style|a|object|embed|param|button) )(([^>]*? )?(type)=(.*?( |>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(input|param|button|option) )(([^>]*? )?(value)=(.*?( |>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(object|embed|iframe) )(([^>]*? )?(height)=(.*?( |>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(object|embed|iframe) )(([^>]*? )?(width)=(.*?( |>)))/$1$4_cdl_$5=$6/sgi;
	$htmlCode =~ s/(<(select|input) )(([^>]*? )?(size)=(.*?( |>)))/$1$4_cdl_$5=$6/sgi;

	# Suppression des attributs dépréciés
	$htmlCode =~ s/(<([\w\d]+))( [^>]*?)>/$1.cleanAttributesValues($3).">"/segi;

	# On supprime le code temporaire _cdl_ (_cdl_XXXX ==> XXXX)
	$htmlCode =~ s/_cdl_width=((\"|\')(.*?)\2)( |>)/my $endTag = $4;"width=".$1." style='width:".$3.($3 =~ m\/%\/si ? "" : "px")." !important'".$endTag/segi;
	$htmlCode =~ s/_cdl_(type|value|height|size)=(.*?)( |>)/$1=$2$3/sgi;

	# Ajout du commentaire javascript avant le code HTML au début des scripts
	$htmlCode =~ s/(<script( [^>]*?)?>\s*)(<!\-\-)/$1\/\/$2/sgi;

	# Suppression des éléments obsolètes
	$htmlCode =~ s/<(\/?)acronym( [^>]*?)?>/<$1abbr$2>/sgi;

	# Ajout des points séparateurs dans les acronymes
	$htmlCode =~ s/(<abbr( [^>]*?)?>)([A-Z]+)(<\/abbr>)/$1.addDotToAcronym($3).$4/seg;

	# Nettoyage des problèmes de guillemets en trop dans les attributs d'une balise et suppression des espaces au début et à la fin des liens
	$htmlCode =~ s/(<a[^>]*>)(\s*)(.*?)(\s*)(<\/a>)/$2$1$3$5$4/sgi;
	$htmlCode =~ s/<p( [^>]*)?><span class=\"cdlPartOfText\">(\s|&nbsp;)*<\/span><\/p>//sgi;
	$htmlCode =~ s/<p( [^>]*)?>(\s|&nbsp;)*<\/p>//sgi;

	$htmlCode =~ s/<span( [^>]*?)>\s*<\/span>//sgi;
	$htmlCode =~ s/<span( [^>]*?)>\s*<\/span>//sgi;

	# On retourne le résultat final après le traitement
	return $htmlCode;
}

# Function: parseAllHead
#	Fonction générale de parsing du head
#
# Paramètres:
#	$htmlCode - code HTML à parser
#	$entirePageTemplateString - chaîne correspondant à la template de la page (à remplir par les valeurs du head)
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$contentType - encodage transmis dans l'entête de la réponse HTTP
#	$activateJavascript - option indiquant si on garde le javascript du site parsé en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
#	$siteId - identifiant du site parsé
#	$trustedDomainNames - noms de domaine configuré de confiance
sub parseAllHead #($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $contentType, $activateJavascript, $parseJavascript, $siteId, $trustedDomainNames)
{
	my ($htmlCode, $entirePageTemplateString, $siteRootUrl, $pagePath, $contentType, $activateJavascript, $parseJavascript, $siteId, $trustedDomainNames) = @_;

	$htmlCode = cleanHtml($htmlCode);

	$htmlCode = cleanStyles($htmlCode);

	my $headHtmlCode = getHeadContent($htmlCode);

	my $allLinks;
	my $allMetas;

	($htmlCode, $allLinks) = parseLinks($htmlCode, $siteRootUrl, $pagePath);
	($htmlCode, $allMetas) = parseMetas($htmlCode, $pagePath, $siteId, $siteRootUrl, $contentType, $trustedDomainNames);

	if ($allLinks !~ m/rel=(\"|\')shortcut\s*icon\1/si) {
		$allLinks .= "<link href=\"".$siteRootUrl."/favicon.ico\" rel=\"shortcut icon\">\n"
	}

	my $documentTitle = getPageTitle($htmlCode);

	my $allScripts = "";
	if ($activateJavascript) {
		($headHtmlCode, $allScripts) = parseScripts($headHtmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript);
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
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$activateJavascript - option indiquant si on garde le javascript du site parsé en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
#	$displayImages - option indiquant si on garde les images du site parsé en version CDL ou si on ne garde que celle avec une alternative
#	$displayObjects - option indiquant si on garde les objects du site parsé en version CDL
#	$displayApplets - option indiquant si on garde les applets du site parsé en version CDL
#	$parseTablesToList - option indiquant si on transforme les tableaux en liste à puce en version CDL
#	$activateFrames - option indiquant si on garde les frames/iframes du site parsé en version CDL
#	$siteId - identifiant du site parsé
#	$pageUri - URI de la page en cours
#	$trustedDomainNames - noms de domaine configuré de confiance
sub parseAllHtml #($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $trustedDomainNames)
{
	my ($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $trustedDomainNames) = @_;

	$htmlCode = parseLinkHref($htmlCode, $pagePath, $siteId, $siteRootUrl, $pageUri, $trustedDomainNames);

	$htmlCode = parseForms($htmlCode, $pagePath, $siteId, $siteRootUrl, $pageUri, $trustedDomainNames);

	$htmlCode = prepareForHighlighting($htmlCode);

	$htmlCode = cleanHtml($htmlCode);

	my $allScripts = "";
	if ($activateJavascript) {
		($htmlCode, $allScripts) = parseScripts($htmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript);
	} else {
		$htmlCode = cleanEventListeners($htmlCode);
		$htmlCode = cleanScripts($htmlCode);
	}

	if ($displayImages) {
		$htmlCode = parseImages($htmlCode, $siteRootUrl, $pagePath, $displayImages);
	} else {
		$htmlCode = replaceImageWithAlt($htmlCode);
	}

	$htmlCode = parseMapAreas($htmlCode, $pagePath, $displayImages, $siteId, $siteRootUrl, $trustedDomainNames);

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

	# Retourner le code HTML traité
	return $htmlCode;
}

# Function: getDocumentLanguage
#	Récupération de la langue du document à partir de l'attribut lang de la balise html
#
# Paramètres:
#	$htmlCode - code HTML où chercher la langue
#	$siteDefaultLanguage - langue par défaut du site
sub getDocumentLanguage #($htmlCode, $siteDefaultLanguage)
{
	my ($htmlCode, $siteDefaultLanguage) = @_;

	# Variable où sera stockée la langue du document
	my $pageLanguage = "";

	# Récupération de la langue dans la balise html
	$htmlCode =~ s/<html( [^>]*)? (lang)=(\"|\')(.*?)\3/$pageLanguage = $4;/segi;

	$pageLanguage =~ s/(\-.+)$//sgi;

	# Si la langue n'a pas été spécifiée dans le document d'origine, on met celle par défaut du site, sinon celle par défaut de l'application
	if (!$pageLanguage) {
		return $siteDefaultLanguage;
	}

	# Retourner la langue trouvée dans la page d'origine
	return $pageLanguage;
}

# Function: getBodyOpenTag
#	Récupération des attributs de la balise body utiles en version filtrée dans une chaîne de caractères
#
# Paramètres:
#	$htmlCode - code HTML où chercher les attributs de la balise body
#	$siteId - identifiant su site parsé
#	$pagePath - chemin vers la page en cours de traitement
#	$siteRootUrl - URL racine du site
#	$trustedDomainNames - noms de domaine configuré de confiance
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
sub getBodyAttributesInHash #($tagAttributes, $siteId, $pagePath, $siteRootUrl, $trustedDomainNames, $parseJavascript)
{
	my ($tagAttributes, $siteId, $pagePath, $siteRootUrl, $trustedDomainNames, $parseJavascript) = @_;

	my $attributesString = "";

	# Construire la liste des attributs qu'on veut garder en chaîne
	my $attributesRegExpString = join("|", @eventListeners);

	# Récupérer les bons attributs javascript
	$tagAttributes =~ s/ ($attributesRegExpString)=((\"|\')(.*?)\3)/$attributesString .= " ".($parseJavascript ? parseJavascriptCode($1, $siteId, $pagePath, $siteRootUrl, $trustedDomainNames, 1) : $1)."=".$2;/segi;

	# Récupérer les attributs génériques
	$tagAttributes =~ s/ (id|class)=((\"|\')(.*?)\3)/$attributesString .= " ".$1."=".$2;/segi;

	# Retourner la chaîne des attributs à intégrer à la balise body finale
	return $attributesString;
}

# Function: getBodyAttributes
#	Récupération de la balise body et tri des attributs à reporter dans la version filtrée
#
# Paramètres:
#	$htmlCode - code HTML où chercher les attributs de la balise body
#	$siteId - identifiant su site parsé
#	$pagePath - chemin vers la page en cours de traitement
#	$siteRootUrl - URL racine du site
#	$trustedDomainNames - noms de domaine configuré de confiance
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
sub getBodyAttributes #($htmlCode, $siteId, $pagePath, $siteRootUrl, $trustedDomainNames, $parseJavascript)
{
	my ($htmlCode, $siteId, $pagePath, $siteRootUrl, $trustedDomainNames, $parseJavascript) = @_;

	my $attributesString = "";

	# Rechercher la balise body et appeler la fonction <getBodyAttributesInHash> qui récupère les bons attributs
	$htmlCode =~ s/<body( [^>]*?)>/$attributesString = getBodyAttributesInHash($1, $siteId, $pagePath, $siteRootUrl, $trustedDomainNames, $parseJavascript);/segi;

	# Retourner la chaîne des attributs à intégrer à la balise body finale
	return $attributesString;
}

# Function: existPartOfTextSpan
#	Recherche de la balise span de texte dans un code HTML
#
# Paramètres:
#	$htmlCode - code HTML où chercher le span de texte
sub existPartOfTextSpan #($htmlCode)
{
	my ($htmlCode) = @_;

	if ($htmlCode =~ m/<span class=cdlPartOfText>/si) {
		return 1;
	}

	return 0;
}

# Function: prepareForHighlighting
#	Transformation du HTML pour le surlignage
#
# Paramètres:
#	$htmlCode - code HTML où faire les traitements préparatifs au surlignage
sub prepareForHighlighting #($htmlCode)
{
	my ($htmlCode) = @_;

	my $tree = HTML::TreeBuilder->new;
	$tree->store_comments(0);
	$tree->parse($htmlCode);
	$tree->eof();
	$htmlCode = $tree->as_HTML;

	$htmlCode =~ s/^<html><head>//sgi;
	$htmlCode =~ s/<\/head><body>//sgi;
	$htmlCode =~ s/<\/body><\/html>\n$//sgi;

	$htmlCode = "<html><head></head><body><span class=cdlPartOfText>".$htmlCode."</span></body></html>";

	$htmlCode =~ s/(<(span|strong) class=\"(cdlInputText|cdlOtherInput|cdlButtons|cdlSelectInput)\">(.*?)<\/\2>)/<\/span><\/span>$1<span class=cdlPartOfText>/sgi;

	$htmlCode =~ s/(<\/?(div|p|h[1-6]|blockquote|ins|del|form|fieldset|noscript|a|address|b)( [^>]*?)?>)/<\/span><\/span>$1<span class=cdlPartOfText>/sgi;

	$htmlCode =~ s/(<(li|dt|dd|caption|th|td|button)( [^>]*?)?>)/$1<span class=cdlPartOfText>/sgi;
	$htmlCode =~ s/(<\/(ul|ol|menu|dl|table)>)/<\/span>$1/sgi;

	$htmlCode =~ s/(<\/(li|dt|dd|caption|th|td|button)>)/<\/span>$1/sgi;

	$htmlCode =~ s/(<(ul|ol|menu|dl|table|tfoot|tbody|thead|select|textarea|label|object|legend)( [^>]*?)?>)/<\/span><\/span>$1/sgi;

	$htmlCode =~ s/(<\/(ul|ol|menu|dl|table|select|textarea|label|object|legend)>)/$1<span class=cdlPartOfText>/sgi;


	$htmlCode =~ s/(<(br|hr|img)( [^>]*?)?>)/<\/span><\/span>$1<span class=cdlPartOfText>/sgi;
	$htmlCode =~ s/<span class=cdlPartOfText>\s*<\/span><\/span>//sgi;
	$htmlCode =~ s/<span class=cdlPartOfText>(<script( [^>]*?)?>(.*?)<\/script>)<\/span><\/span>/$1/sgi;
	$htmlCode =~ s/<span class=cdlPartOfText>(<\/?[^>]+>)<\/span>/$1/sgi;

	$htmlCode =~ s/((<([\w\d]+)( [^>]*)?>)\s*<span class=cdlPartOfText>(.*?)<\/span><\/span>\s*(<\/\3>))/
		if (!existPartOfTextSpan($5)) {
			$2.$5.$6
		} else {
			$1
		}
		/segi;
	$tree = HTML::TreeBuilder->new;
	$tree->store_comments(0);
	$tree->parse($htmlCode);
	$tree->eof();
	$htmlCode = $tree->as_HTML;

	$htmlCode =~ s/^<html><head>//sgi;
	$htmlCode =~ s/<\/head><body>//sgi;
	$htmlCode =~ s/<\/body><\/html>\n$//sgi;

	$htmlCode =~ s/<span class=\"cdlPartOfText\">\s*<\/span>//sgi;
	$htmlCode =~ s/<span class=\"cdlPartOfText\">(<script( [^>]*?)?>(.*?)<\/script>)<\/span>/$1/sgi;

	$htmlCode =~ s/<\/a><a /<\/a> <a /sgi;

	$htmlCode =~ s/<\/option>//sgi;

	if ($tree->as_text ne "" or $htmlCode =~ m/<(object|embed|img|input|map|area|iframe)( [^>]*?)?>/si) {
		$tree = $tree->delete;
		return $htmlCode;
	} else {
		$tree = $tree->delete;
		return "";
	}
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;
