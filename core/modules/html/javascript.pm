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

# File: javascript.pm
#	Module de transformation et de nettoyage du code javascript et du code HTML relatif aux comportements javascript

# Function: parseEventListenersAttributes
#	Transformer les URL dans les att
#
# Paramètres:
#	$tagAttributes - code HTML des attributs listeners javascript où transformer le javascript : onXXXX
#	$siteId - identifiant du site en cours de traitement
sub parseEventListenersAttributes  #($tagAttributes)
{
	my ($tagAttributes, $siteId, $pagePath, $siteRootUrl) = @_;

	# Génération de la chaîne des choix pour l'expression régulière :
	# onclick|onunload|onload|onmouseover|onmouseout|onfocus|onblur|onchange|onselect|onsubmit ...
	$eventListenersRegExpString = join("|", @eventListeners);

	$tagAttributes =~ s/ ($eventListenersRegExpString)=(\"|\')(.*?)\2/" ".$1."=".$2.parseJavascriptCode($3, $siteId, $pagePath, $siteRootUrl).$2/segi;

	return $tagAttributes;
}

# Function: parseScripts
#	Transformer les URL dans les attributs src des balises script et parser le code javascript si c'est demandé
#
# Paramètres:
#	$htmlCode - code HTML où parser les src des scripts
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site en cours de traitement
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé (en passant par <javascript.pl> ou le garder tel quel
sub parseScripts #($htmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript)
{
	my ($htmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript) = @_;

	# Si on a choisit de parser le javascript dans la configuration, on passe par le script <javascript.pl>
	# Sinon on traite l'URL pour la transformer en absolue
	if ($parseJavascript) {
		$htmlCode =~ s/(<script( [^>]*)? )src=(\"|\')(.*?)\3([^>]*?>)/
			my ($isHttps, $jsUrl) = makeUrlAbsoluteWithoutProtocol($4, $siteRootUrl, $pagePath);
			$1."src=".$3."\/javascript".$isHttps."\/".$siteId."\/".makeUrlAbsoluteWithoutProtocol($4, $siteRootUrl, $pagePath).$3.$5/segi;
	} else {
		$htmlCode =~ s/(<script( [^>]*)? )src=(\"|\')(.*?)\3(.*?>)/
			$1."src=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3.$5/segi;
	}

	# Chaîne qui contiendra tous les scripts
	my $allScripts = "";

	if ($parseJavascript) {
		# Transformation du javascript dans les balises script
		$htmlCode =~ s/((<(script)( [^>]*)?>)(.*?)(<\/\3>))/$allScripts .= $2."\n\/\/<!--\n".parseJavascriptCode($5, $siteId, $pagePath, $siteRootUrl)."\n\/\/-->\n".$6."\n"; $2."\n\/\/<!--\n".parseJavascriptCode($5, $siteId, $pagePath, $siteRootUrl)."\n\/\/-->\n".$6/segi;
		# Transformation du javascript dans les attributs 
		$htmlCode =~ s/(<([\w\d]+))( [^>]*)?>/$1.parseEventListenersAttributes($3, $siteId, $pagePath, $siteRootUrl).">"/segi;
	} else {
		# Récupération de tous les scripts du code HTML
		$htmlCode =~ s/((<(script)( [^>]*)?>)(.*?)(<\/\3>))/$allScripts .= $1."\n"; $1/segi;
	}

	# Retourner le code HTML avec les src des scripts traités
	return ($htmlCode, $allScripts);
}

# Function: cleanEventListenersAttributes
#	Supprimer tous les attributs javascript d'une balise
#
# Paramètres:
#	$tagAttributes - code HTML des attributs à nettoyer de listeners javascript : onXXXX
sub cleanEventListenersAttributes #($tagAttributes)
{
	my ($tagAttributes) = @_;

	# Génération de la chaîne des choix pour l'expression régulière :
	# onclick|onunload|onload|onmouseover|onmouseout|onfocus|onblur|onchange|onselect|onsubmit ...
	$eventListenersRegExpString = join("|", @eventListeners);

	# Suppression des attributs "event listeners" javascript
	$tagAttributes =~ s/ ($eventListenersRegExpString)=(\"|\')(.*?)\2//sgi;

	# Retourner la chaîne des attributs sans les attributs javascript
	return $tagAttributes;
}

# Function: cleanEventListeners
#	Supprimer tous les attributs javascript d'un code HTML passé en argument
#
# Paramètres:
#	$htmlCode - code HTML de la balise ouvrante où nettoyer les attributs listeners javascript : onXXXX
sub cleanEventListeners #($htmlCode)
{
	my ($htmlCode) = @_;

	# Détection des balises et traitement de la chaîne correspondant aux attributs
	$htmlCode =~ s/(<([\w\d]+))( [^>]*)?>/$1.cleanEventListenersAttributes($3).">"/segi;

	# Retourner le code HTML nettoyé d'attributs javascript
	return $htmlCode;
}

# Function: cleanScripts
#	Enlever les balises script et affichier le contenu des balises noscript (c'est à dire, forcer le fonction de la page sans javascript)
#
# Paramètres:
#	$htmlCode - code HTML où enlever les scripts
sub cleanScripts #($htmlCode)
{
	my ($htmlCode) = @_;

	# Suppression des balises script
	$htmlCode =~ s/<(script)( [^>]*)?>(.*?)<\/\1>//sgi;
	$htmlCode =~ s/<(noscript)( [^>]*)?>(.*?)<\/\1>/<div class=\"noscriptContent\">$3<\/div>/sgi;

	return $htmlCode;
}

# Function: cleanJavascriptRedirectUrl
#	Rendre l'URL dans la fonction Javascript absolue
#
# Paramètres:
#	$startUrl - début de l'URL composé de /le-filtre/$siteId/$currentServerName
#	$url - URL relative vers laquelle rediriger
sub cleanJavascriptRedirectUrl #($startUrl, $url)
{
	my ($startUrl, $url) = @_;

	# Si l'URL est déjà absolue (/le-filtre/ etc.), on ne mets pas le début de l'URL (ie /le-filtre/$siteId/$currentServerName)
	if ($url =~ m/$startUrl/si) {
		return $url;
	}

	return $startUrl."/".$url;
}

# Function: generateJavascriptForCompletingPageVariable
#	Ajouter un test en Javascript pour compléter la variable javascript trouvée
#
# Paramètres:
#	$startUrl - début de l'URL composé de /le-filtre/$siteId/$currentServerName
#	$currentServerName - nom de domaine en cours
#	$jsVariable - code Javascript correspondant à la variable
sub generateJavascriptForCompletingPageVariable #($startUrl, $jsVariable, $currentServerName)
{
	my ($startUrl, $currentServerName, $jsVariable) = @_;

	return "(".$jsVariable.".substring(0,1) == \"/\" ? \"".$startUrl.$currentServerName."/\"+".$jsVariable.".substring(1) : (".$jsVariable.".substring(0,7) == \"http://\" ? \"".$startUrl."\"+".$jsVariable.".substring(7) : \"".$startUrl.$currentServerName."/\"+".$jsVariable."))";
}

# Function: parseJavascriptCodeLine
#	Supprimer, dans une ligne de code javascript, les styles et transformer les URLs de redirection par l'URL vers le script CDL principal pour rester dans la version filtrée
#
# Paramètres:
#	$jsCode - code Javascript de la ligne où enlever les instructions de styles et où transformer les URLs de redirection
#	$siteId - identifiant su site parsé
#	$pagePath - chemin vers la page en cours de traitement
#	$siteRootUrl - URL racine du site
sub parseJavascriptCodeLine #($jsCode, $siteId, $pagePath, $siteRootUrl)
{
	my ($jsCode, $siteId, $pagePath, $siteRootUrl) = @_;

	# Suppression des instructions qui mettent à jour des styles
	$jsCode =~ s/\.style__CDL_DOT__(position|display|visibility|zIndex)\s*=\s*/._cdl_style__CDL_DOT__$1 = /sgi;
	$jsCode =~ s/^(.*)\.style__CDL_DOT__([\w\d]+)\s*=\s*(.*)$//sgi;
	$jsCode =~ s/\.css\s*(\(\s*[^,]*?\s*\))/._cdl_css$1/sgi;
	$jsCode =~ s/\.css\s*\(\s*(\"|\'|__CDL_QUOT__)(position|display|visibility|z\-index|)\1\s*,\s*(.*?)\s*\)/._cdl_css(\"$2\",$3)/sgi;
	$jsCode =~ s/\.css\s*\(\s*(.*?)\s*,\s*(.*?)\s*\)//sgi;
	$jsCode =~ s/_cdl_(css|style)/$1/sgi;

	# Le nom de domaine en cours
	my $currentServerName;
	$siteRootUrl =~ s/^(https?:\/\/(.*))$/$currentServerName = $2;$1/segi;

	# Transformer l'URL dans l'instruction de redirection pour passer par le script principal
	$jsCode =~ s/((\.location)(__CDL_DOT__href)?)\s*=\s*(\s*\"|\'|__CDL_QUOT__)(.*?)\4/$1."=".$4.cleanJavascriptRedirectUrl("\/le\-filtre\/".$siteId."\/".$currentServerName, getUriFromUrl($5, $pagePath, $siteId, $siteRootUrl)).$4/segi;
	s/((\.location)(__CDL_DOT__href)?)\s*=\s*(\s*[\w\d]*?)\s*/$1."=".generateJavascriptForCompletingPageVariable("\/le\-filtre\/".$siteId."\/", $currentServerName, $4)/segi;

	# Transformer l'URL dans l'instruction d'ouverture dans une nouvelle fenêtre pour passer par le script principal
	$jsCode =~ s/(window__CDL_DOT__open\s*\()\s*(\"|\'|__CDL_QUOT__)(.*?)\2(\s*(,|\)))/$1.$2.cleanJavascriptRedirectUrl("\/le\-filtre\/".$siteId."\/".$currentServerName, getUriFromUrl($3, $pagePath, $siteId, $siteRootUrl)).$2.$4/segi;
	$jsCode =~ s/(window__CDL_DOT__open\s*\()\s*([\w\d]+)(\s*(,|\)))/$1.generateJavascriptForCompletingPageVariable("\/le\-filtre\/".$siteId."\/", $currentServerName, $2).$3/segi;

	$jsCode =~ s/(\.autocomplete)\s*\(\s*(\"|\'|__CDL_QUOT__)(.*?)\2/$1."\(".$2.cleanJavascriptRedirectUrl("\/le\-filtre-pour-ajax\/".$siteId."\/".$currentServerName, getUriFromUrl($3, $pagePath, $siteId, $siteRootUrl)).$2/segi;

	$jsCode =~ s/(\{.*?url\s*:\s*)(\"|\'|__CDL_QUOT__)(.*?)\2/$1."\(".$2.cleanJavascriptRedirectUrl("\/le\-filtre-pour-ajax\/".$siteId."\/".$currentServerName, getUriFromUrl($3, $pagePath, $siteId, $siteRootUrl)).$2/segi;

	# Retourner le code javascript sans les instructions de styles et avec les URLs de redirection parsées
	return $jsCode;
}

# Function: protectJsSpecialCharsBeforeParse
#	Transformer les caractères propres au javascript qui se trouvent dans les déclarations de chaines avant de filter le code Javascript
#
# Paramètres:
#	$jsCode - code Javascript où protéger les points-virgules, acollades, ...
sub protectJsSpecialCharsBeforeParse #($jsCode)
{
	my ($jsCode) = @_;

	# Mettre un code temporaire à la place des caractères délimiteurs Javascript
	$jsCode =~ s/\./__CDL_DOT__/sgi;
	$jsCode =~ s/;/__CDL_DOT_COMMA__/sgi;
	$jsCode =~ s/,/__CDL_COMMA__/sgi;
	$jsCode =~ s/\(/__CDL_OPEN_BRACE__/sgi;
	$jsCode =~ s/\)/__CDL_CLOSE_BRACE__/sgi;
	$jsCode =~ s/\{/__CDL_OPEN_ACOLLADE__/sgi;
	$jsCode =~ s/\}/__CDL_CLOSE_ACOLLADE__/sgi;
	$jsCode =~ s/\/\*/__CDL_OPEN_COMMENT__/sgi;
	$jsCode =~ s/\*\//__CDL_CLOSE_COMMENT__/sgi;

	# Retourner le code javascript sans les instructions de styles et les Url sont parsés
	return $jsCode;
}

# Function: parseJavascriptCode
#	Transformer le javascript pour qu'il marche en version filtrée, et qu'il ne casse pas les styles CDL
#
# Paramètres:
#	$jsCode - code Javascript où enlever les instructions de styles et transformer les URLs de redirection
#	$siteId - identifiant su site parsé
sub parseJavascriptCode #($jsCode, $siteId)
{
	my ($jsCode, $siteId, $pagePath, $siteRootUrl) = @_;

	$jsCode =~ s/&\#39;/__CDL_QUOT__/sgi;
	$jsCode =~ s/(\"|\'|__CDL_QUOT__)(.*?[^\\])?\1/$1.protectJsSpecialCharsBeforeParse($2).$1/segi;
	$jsCode =~ s/\.location\.href/.location__CDL_DOT__href/sgi;
	$jsCode =~ s/window\.open/window__CDL_DOT__open/sgi;
	$jsCode =~ s/\.style\.([\w\d]+)/\.style__CDL_DOT__$1/sgi;

	# Enlever les commentaires
	$jsCode =~ s/\/\*(.*?)\*\///sgi;
	$jsCode =~ s/(\n|^)\s*\/\/(.*?)(\n|$)/$3/sgi;

	# Parser chaque ligne
	$dotPreceed = 0;
	$jsCode =~ s/([^;\{\}\.]*?)(\.|;|\{|\}|$)/
		my $dotPreceed2 = $dotPreceed ? 1 : 0;
		$dotPreceed = $2 eq "." ? 1 : 0;
		parseJavascriptCodeLine(($dotPreceed2 ? "." : "").$1, $siteId, $pagePath, $siteRootUrl).($dotPreceed ? "" : $2)
		/segi;

	# Remettre les caractères spéciaux Javascript dans les déclarations chaînes de caractères
	$jsCode =~ s/__CDL_DOT__/\./sgi;
	$jsCode =~ s/__CDL_QUOT__/&\#39;/sgi;
	$jsCode =~ s/__CDL_DOT_COMMA__/;/sgi;
	$jsCode =~ s/__CDL_COMMA__/,/sgi;
	$jsCode =~ s/__CDL_OPEN_BRACE__/\(/sgi;
	$jsCode =~ s/__CDL_CLOSE_BRACE__/\)/sgi;
	$jsCode =~ s/__CDL_OPEN_ACOLLADE__/\{/sgi;
	$jsCode =~ s/__CDL_CLOSE_ACOLLADE__/\}/sgi;
	$jsCode =~ s/__CDL_OPEN_COMMENT__/\/\*/sgi;
	$jsCode =~ s/__CDL_CLOSE_COMMENT__/\*\//sgi;

	# Retourner le code javascript sans les instructions de styles et les Url sont parsés
	return $jsCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;