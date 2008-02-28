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

# File: javascript.pm
#	Module de transformation et de nettoyage du code javascript et du code HTML relatif aux comportements javascript

# Function: parseScripts
#	Transformer les URL dans les att
#
# Param�tres:
#	$tagAttributes - code HTML des attributs listeners javascript o� transformer le javascript : onXXXX
#	$siteId - identifiant du site en cours de traitement
sub parseEventListenersAttributes  #($tagAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs listeners javascript o� transformer le javascript : onXXXX
	# - identifiant du site en cours de traitement
	my ($tagAttributes, $siteId, $pagePath, $siteRootUrl) = @_;

	# G�n�ration de la cha�ne des choix pour l'expression r�guli�re :
	# onclick|onunload|onload|onmouseover|onmouseout|onfocus|onblur|onchange|onselect|onsubmit ...
	$eventListenersRegExpString = join("|", %eventListeners);

	$tagAttributes =~ s/\s($eventListenersRegExpString)\s*=\s*(\"|\')(.*?)\2/" ".$1."=".$2.parseJavascriptCode($3, $siteId, $pagePath, $siteRootUrl).$2/segi;

	return $tagAttributes;
}

# Function: parseScripts
#	Transformer les URL dans les attributs src des balises script et parser le code javascript si c'est demand�
#
# Param�tres:
#	$htmlCode - code HTML o� parser les src des scripts
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site en cours de traitement
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site pars� (en passant par <javascript.pl> ou le garder tel quel
sub parseScripts #($htmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML o� parser les src des scripts
	# - url racine du site
	# - chemin vers la page en cours de traitement
	# - identifiant du site en cours de traitement
	# - option permettant de dire si on doit parser le javascript du site pars�
	my ($htmlCode, $siteRootUrl, $pagePath, $siteId, $parseJavascript) = @_;

	# Si on a choisit de parser le javascript dans la configuration, on passe par le script <javascript.pl>
	# Sinon on traite l'URL pour la transformer en absolue
	if ($parseJavascript) {
		$htmlCode =~ s/(<script(\s[^>]*?)?\s)src\s*=\s*(\"|\')(.*?)\3(.*?>)/
			$1."src=".$3."\/filtre\/javascript.pl?cdlid=".$siteId."&amp;cdlurl=".urlEncode(makeUrlAbsolute($4, $siteRootUrl, $pagePath)).$3.$5/segi;
	} else {
		$htmlCode =~ s/(<script(\s[^>]*?)?\s)src\s*=\s*(\"|\')(.*?)\3(.*?>)/
			$1."src=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3.$5/segi;
	}

	# Cha�ne qui contiendra tous les scripts
	my $allScripts = "";

	if ($parseJavascript) {
		# Transformation du javascript dans les balises script
		$htmlCode =~ s/((<(script)(\s[^>]*?)?>)(.*?)(<\/\3>))/$allScripts .= "\t\t".$2.parseJavascriptCode($5, $siteId, $pagePath, $siteRootUrl).$6."\n"; $1/segi;
		# Transformation du javascript dans les attributs 
		$htmlCode =~ s/(<(\w|\d)+)(\s.*?)>/$1.parseEventListenersAttributes($3, $siteId, $pagePath, $siteRootUrl).">"/segi;
	} else {
		# R�cup�ration de tous les scripts du code HTML
		$htmlCode =~ s/(<(script)(\s[^>]*?)?>(.*?)<\/\2>)/$allScripts .= "\t\t".$1."\n"; $1/segi;
	}

	# Retourner le code HTML avec les src des scripts trait�s
	return ($htmlCode, $allScripts);
}

# Function: cleanEventListenersAttributes
#	Supprimer tous les attributs javascript d'une balise
#
# Param�tres:
#	$tagAttributes - code HTML des attributs � nettoyer de listeners javascript : onXXXX
sub cleanEventListenersAttributes #($tagAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs � nettoyer de listeners javascript : onXXXX
	my ($tagAttributes) = @_;

	# G�n�ration de la cha�ne des choix pour l'expression r�guli�re :
	# onclick|onunload|onload|onmouseover|onmouseout|onfocus|onblur|onchange|onselect|onsubmit ...
	$eventListenersRegExpString = join("|", %eventListeners);

	# Suppression des attributs "event listeners" javascript
	$tagAttributes =~ s/\s($eventListenersRegExpString)\s*=\s*(\"|\')(.*?)\2//sgi;

	# Retourner la cha�ne des attributs sans les attributs javascript
	return $tagAttributes;
}

# Function: cleanEventListeners
#	Supprimer tous les attributs javascript d'un code HTML pass� en argument
#
# Param�tres:
#	$htmlCode - code HTML de la balise ouvrante o� nettoyer les attributs listeners javascript : onXXXX
sub cleanEventListeners #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML de la balise ouvrante o� nettoyer les attributs listeners javascript : onXXXX
	my ($htmlCode) = @_;

	# D�tection des balises et traitement de la cha�ne correspondant aux attributs
	$htmlCode =~ s/(<(\w|\d)+)(\s[^>]*?)>/$1.cleanEventListenersAttributes($3).">"/segi;

	# Retourner le code HTML nettoy� d'attributs javascript
	return $htmlCode;
}

# Function: cleanScripts
#	Enlever les balises script et affichier le contenu des balises noscript (c'est � dire, forcer le fonction de la page sans javascript)
#
# Param�tres:
#	$htmlCode - code HTML o� enlever les scripts
sub cleanScripts #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML o� enlever les scripts
	my ($htmlCode) = @_;

	# Suppression des balises script
	$htmlCode =~ s/<(script)(\s[^>]*?)?>(.*?)<\/\1>//sgi;
	$htmlCode =~ s/<(noscript)(\s[^>]*?)?>(.*?)<\/\1>/<div class=\"noscriptContent\">$1<\/div>/sgi;

	return $htmlCode;
}

# Function: parseJavascriptCodeLine
#	Supprimer, dans une ligne de code javascript, les styles et transformer les URLs de redirection par l'URL vers le script CDL principal pour rester dans la version filtr�e
#
# Param�tres:
#	$jsCode - code Javascript de la ligne o� enlever les instructions de styles et o� transformer les URLs de redirection
#	$siteId - identifiant su site pars�
sub parseJavascriptCodeLine #($jsCode, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code Javascript de la ligne o� enlever les instructions de styles et o� transformer les URLs de redirection
	# - identifiant su site pars�
	my ($jsCode, $siteId, $pagePath, $siteRootUrl) = @_;

	# Suppression des instructions qui mettent � jour des styles
	$jsCode =~ s/([^;\{\}]*?)\.style\.(\w+)\s*=\s*([^;\{\}]+)//sgi;

	# Le nom de domaine en cours
	my $currentServerName;
	$siteRootUrl =~ s/^(https?:\/\/(.*))$/$currentServerName = $2;$1/segi;

	# Transformer l'URL dans l'instruction de redirection pour passer par le script principal
	$jsCode =~ s/(([^;]*?)(\.location)(\.href)?)\s*=\s*(\"|\')(.*?)\5/$1."=".$5."\/le\-filtre\/".$siteId."\/".$currentServerName."\/".getUriFromUrl($6, $pagePath, $siteId, $siteRootUrl).$5/segi;

	# Transformer l'URL dans l'instruction d'ouverture dans une nouvelle fen�tre pour passer par le script principal
	$jsCode =~ s/(window\.open\()(\"|\')(.*?)\2((\s*,.*?)?\))/$1.$2."\/le\-filtre\/".$siteId."\/".$currentServerName."\/".getUriFromUrl($3, $pagePath, $siteId, $siteRootUrl).$2.$4/segi;

	# Retourner le code javascript sans les instructions de styles et avec les URLs de redirection pars�es
	return $jsCode;
}

# Function: parseJavascriptCode
#	Transformer le javascript pour qu'il marche en version filtr�e, et qu'il ne casse pas les styles CDL
#
# Param�tres:
#	$jsCode - code Javascript o� enlever les instructions de styles et transformer les URLs de redirection
#	$siteId - identifiant su site pars�
sub parseJavascriptCode #($jsCode, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code Javascript o� enlever les instructions de styles et transformer les URLs de redirection
	# - identifiant su site pars�
	my ($jsCode, $siteId, $pagePath, $siteRootUrl) = @_;

	# Parser chaque ligne
	$jsCode =~ s/(.*?)(\n|$)/parseJavascriptCodeLine($1, $siteId, $pagePath, $siteRootUrl).$2/segi;

	# Retourner le code javascript sans les instructions de styles et les Url sont pars�s
	return $jsCode;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;