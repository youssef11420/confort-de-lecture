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

# File: links.pm
#	Module de gestion des liens HTML

# Function: parseLinkHrefAttribute
#	Transformer les liens pour passer par le script général CDL et aussi pour gérer les liens ancres
#
# Paramètres:
#	$url - URL à traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - url racine du site
sub parseLinkHrefAttribute #($url, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - URL à traiter
	# - chemin vers la page en cours de traitement
	# - identifiant du site parsé
	# - url racine du site
	my ($url, $pagePath, $siteId, $siteRootUrl) = @_;

	# Si l'URL commence par un "mailto:", c'est un lien pour démarrer l'écriture d'un nouveau message électronique vers l'addresse indiquée après mailto. Idem pour les liens javascript
	if ($url =~ m/^mailto:/si or $url =~ m/^javascript:/si) {
		return $url;
	}

	# Si l'URL commence par un #, c'est un lien ancre : on y touche pas
	if ($url =~ m/^\#/si) {
		return $url;
	}

	# Si l'URL contient un # au milieu, c'est un lien vers une page, mais avec un ancre sur un emplacement dans la page destination : on traite l'URL et on rajoute l'ancre à la fin non encodée pour qu'elle soit prise en compte dans la version filtrée
	if ($url =~ m/(.*?)(\#.*)/si) {
		$url =~ s/(.*?)(\#.*)/return getUriFromUrl($1, $pagePath, $siteId, $siteRootUrl).$2;/segi;
	}

	# Sinon traiter l'URL en entier
	return getUriFromUrl($url, $pagePath, $siteId, $siteRootUrl);
}

# Function: parseLinkHref
#	Transformer les liens pour passer par le script CDL principal en lui passant en parametre l'URL d'origine
#
# Paramètres:
#	$htmlCode - code HTML où transformer les URL des liens
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - url racine du site
sub parseLinkHref #($htmlCode, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML où transformer les URL des liens
	# - chemin vers la page en cours de traitement
	# - identifiant du site parsé
	# - url racine du site
	my ($htmlCode, $pagePath, $siteId, $siteRootUrl) = @_;

	# Transformation du href en mettant le script CDL principal en intermédiaire
	$htmlCode =~ s/(<a(\s[^>]*?)?\s(href))\s*=\s*(\"|\')(.*?)\4/$1."=\"".parseLinkHrefAttribute($5, $pagePath, $siteId, $siteRootUrl)."\""/segi;

	# Retourner de code HTML parsé
	return $htmlCode;
}

# Function: cleanLink
#	Nettoyer les intitulés des liens
#
# Paramètres:
#	$htmlCode - code HTML à traiter
sub cleanLink #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à traiter
	my ($htmlCode) = @_;

	# Sortir les espaces à l'intérieur des liens (dans l'intitulé) pour les mettre à coté
	$htmlCode =~ s/(<(a)(\s[^>]*?)?>)(.*?)(\s|&nbsp;)*(<\/\2>)/$1.$4.$6.($5 ? " " : "")/segi;
	$htmlCode =~ s/(<(a)(\s[^>]*?)?>)(\s|&nbsp;)*(.*?)(<\/\2>)/($4 ? " " : "").$1.$5.$6/segi;

	# Retourner le code HTML traité
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;