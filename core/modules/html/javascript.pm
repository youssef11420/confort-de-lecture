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
#	$pagePath - chemin vers la page en cours de traitement
#	$siteRootUrl - URL racine du site
sub parseEventListenersAttributes  #($tagAttributes, $siteId, $pagePath, $siteRootUrl)
{
	my ($tagAttributes, $siteId, $pagePath, $siteRootUrl) = @_;

	# Génération de la chaîne des choix pour l'expression régulière :
	# onclick|onunload|onload|onmouseover|onmouseout|onfocus|onblur|onchange|onselect|onsubmit ...
	my $eventListenersRegExpString = join("|", @eventListeners);

	$tagAttributes =~ s/ ($eventListenersRegExpString)=(\"|\')(.*?)\2/" ".$1."=".$2.parseJavascriptCode($3, $siteId, $pagePath, $siteRootUrl, 1).$2/segi;

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
			$1."src=".$3.$embeddedMode."\/javascript".$isHttps."\/".$siteId."\/".$jsUrl.$3.$5/segi;
	} else {
		$htmlCode =~ s/(<script( [^>]*)? )src=(\"|\')(.*?)\3(.*?>)/
			$1."src=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3.$5/segi;
	}

	# Chaîne qui contiendra tous les scripts
	my $allScripts = "";

	if ($parseJavascript) {
		# Transformation du javascript dans les balises script
		$htmlCode =~ s/((<(script)( [^>]*)?>)(.*?)(<\/\3>))/$allScripts .= $2."\n\/\/<!--\n".parseJavascriptCode($5, $siteId, $pagePath, $siteRootUrl, 0)."\n\/\/-->\n".$6."\n"; $2."\n\/\/<!--\n".parseJavascriptCode($5, $siteId, $pagePath, $siteRootUrl, 0)."\n\/\/-->\n".$6/segi;
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
	my $eventListenersRegExpString = join("|", @eventListeners);

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
#	$isInAttribute - booléen indiquant si le code se trouve dans un attribut listener
sub generateJavascriptForCompletingPageVariable #($startUrl, $jsVariable, $currentServerName, $isInAttribute)
{
	my ($startUrl, $currentServerName, $jsVariable, $isInAttribute) = @_;

	my $res = "(".$jsVariable.".substring(0,1) == \"/\" ? \"".$startUrl.$currentServerName."/\"+".$jsVariable.".substring(1) : (".$jsVariable.".substring(0,7) == \"http://\" ? \"".$startUrl."\"+".$jsVariable.".substring(7) : \"".$startUrl.$currentServerName."/\"+".$jsVariable."))";

	if ($isInAttribute) {
		$res =~ s/\"/&quot;/sgi;
	}

	return $res;
}

# Function: parseJavascriptCodeLine
#	Supprimer, dans une ligne de code javascript, les styles et transformer les URLs de redirection par l'URL vers le script CDL principal pour rester dans la version filtrée
#
# Paramètres:
#	$jsCode - code Javascript de la ligne où enlever les instructions de styles et où transformer les URLs de redirection
#	$siteId - identifiant su site parsé
#	$pagePath - chemin vers la page en cours de traitement
#	$siteRootUrl - URL racine du site
#	$isInAttribute - booléen indiquant si le code se trouve dans un attribut listener
sub parseJavascriptCodeLine #($jsCode, $siteId, $pagePath, $siteRootUrl, $isInAttribute)
{
	my ($jsCode, $siteId, $pagePath, $siteRootUrl, $isInAttribute) = @_;

	# Suppression des instructions qui mettent à jour des styles
	$jsCode =~ s/\.style\.(position|display|visibility|zIndex)\s*=\s*/._cdl_style.$1=/sgi;
	$jsCode =~ s/(\.style\.)[\w\d]+(\s*=\s*)/$1cdlFakeStyle$2/sgi;
	$jsCode =~ s/\.css\s*(\(\s*[^,]*?\s*\))/._cdl_css$1/sgi;
	$jsCode =~ s/\.css\s*\(\s*(\"|\'|&\#39;)(position|display|visibility|z\-index)\1\s*,\s*(.*?)\s*\)/._cdl_css($1$2$1,$3)/sgi;
	$jsCode =~ s/(\.css\s*\(\s*)(.*?)(\s*,\s*.*?\s*\))/$1cdl-fake-style$2/sgi;
	$jsCode =~ s/_cdl_(css|style)/$1/sgi;

	# Le nom de domaine en cours
	my $currentServerName = "";
	if ($embeddedMode eq "") {
		$siteRootUrl =~ s/^(https?:\/\/(.*))$/$currentServerName = "\/".$2;$1/segi;
	}

	# Transformer l'URL dans l'instruction de redirection pour passer par le script principal
	$jsCode =~ s/((\.location)(\.href)?)\s*=\s*(\"|\'|&\#39;)(.*?)\4/$1."=".$4.cleanJavascriptRedirectUrl(($embeddedMode ne $embeddedMode."\/f" ? "" : "\/le\-filtre".$siteId.$currentServerName), getUriFromUrl($5, $pagePath, $siteId, $siteRootUrl, 'get')).$4/segi;
	$jsCode =~ s/((\.location)(\.href)?)\s*=\s*([\w\d_]+)\s*/$1."=".generateJavascriptForCompletingPageVariable(($embeddedMode ne $embeddedMode."\/f" ? "" : "\/le\-filtre".$siteId), $currentServerName, $4, $isInAttribute)/segi;

	# Transformer l'URL dans l'instruction d'ouverture dans une nouvelle fenêtre pour passer par le script principal
	$jsCode =~ s/(window\.open\s*\()\s*(\"|\'|&\#39;)(.*?)\2(\s*(,|\)))/$1.$2.cleanJavascriptRedirectUrl(($embeddedMode ne $embeddedMode."\/f" ? "" : "\/le\-filtre".$siteId.$currentServerName), getUriFromUrl($3, $pagePath, $siteId, $siteRootUrl, 'get')).$2.$4/segi;
	$jsCode =~ s/(window\.open\s*\()\s*([\w\d_]+)(\s*(,|\)))/$1.generateJavascriptForCompletingPageVariable(($embeddedMode ne $embeddedMode."\/f" ? "" : "\/le\-filtre".$siteId), $currentServerName, $2, $isInAttribute).$3/segi;

	$jsCode =~ s/(\.autocomplete)\s*\(\s*(\"|\'|&\#39;)(.*?)\2/$1."\(".$2.cleanJavascriptRedirectUrl($embeddedMode."\/le\-filtre-pour-ajax"."\/".$siteId.$currentServerName, getUriFromUrl($3, $pagePath, $siteId, $siteRootUrl, 'get')).$2/segi;

	$jsCode =~ s/((^|\s)(url|progress|review|saveMethod|failure)\s*:\s*)(\"|\'|&\#39;)(.*?)\4/$1.$4.cleanJavascriptRedirectUrl($embeddedMode."\/le\-filtre-pour-ajax"."\/".$siteId.$currentServerName, getUriFromUrl($5, $pagePath, $siteId, $siteRootUrl, 'get')).$4/segi;

	# Retourner le code javascript sans les instructions de styles et avec les URLs de redirection parsées
	return $jsCode;
}

# Function: parseJavascriptCode
#	Transformer le javascript pour qu'il marche en version filtrée, et qu'il ne casse pas les styles CDL
#
# Paramètres:
#	$jsCode - code Javascript où enlever les instructions de styles et transformer les URLs de redirection
#	$siteId - identifiant su site parsé
#	$pagePath - chemin vers la page en cours de traitement
#	$siteRootUrl - URL racine du site
#	$isInAttribute - booléen indiquant si le code se trouve dans un attribut listener
sub parseJavascriptCode #($jsCode, $siteId, $pagePath, $siteRootUrl, $isInAttribute)
{
	my ($jsCode, $siteId, $pagePath, $siteRootUrl, $isInAttribute) = @_;

	# Parser chaque ligne
	$jsCode = parseJavascriptCodeLine($jsCode, $siteId, $pagePath, $siteRootUrl, $isInAttribute);

	# Retourner le code javascript sans les instructions de styles et les Url sont parsés
	return $jsCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;