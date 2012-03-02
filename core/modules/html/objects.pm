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

# File: objects.pm
#	Module de gestion des balises HTML object

# Function: parseParamMovieValue
#	Rendre absolue l'URL dans l'attribut value
#
# Paramètres:
#	$tagAttributes - code HTML des attributs à traiter
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseParamMovieValue #($tagAttributes, $siteRootUrl, $pagePath)
{
	my ($tagAttributes, $siteRootUrl, $pagePath) = @_;

	# Mise en absolue de l'URL dans l'attribut value
	$tagAttributes =~ s/( (value))=(\"|\')(.*?)\3/$1."=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3/segi;

	# Retourner le code HTML des attributs parsés
	return $tagAttributes;
}

# Function: parseObjects
#	Transformer la valeur de l'attribut data, ainsi que l'attribut value de la balise param dont le l'attribut name est movie, pour obtenir des URLs absolues
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseObjects #($htmlCode, $siteRootUrl, $pagePath)
{
	my ($htmlCode, $siteRootUrl, $pagePath) = @_;

	# Traiter l'URL dans l'attribut data pour la rendre absolue
	$htmlCode =~ s/(<object( [^>]*?)? (data))=(\"|\')(.*?)\4/$1."=".$4.makeUrlAbsolute($5, $siteRootUrl, $pagePath).$4/segi;

	# Surcharger la largeur par défaut pour mettre celle spécifiée pour l'objet
	$htmlCode =~ s/(<(object|embed)( [^>]*?)? (width)=(\"|\')(.*?)(px)?\5)/$1." style=\"width:".$6."px !important\""/segi;

	# Traiter l'URL dans l'attribut value de la balise param (name="movie") pour la rendre absolue
	$htmlCode =~ s/(<param)( [^>]*?)?( (name))=((\"|\')movie\6)( [^>]*?)?(>)/$1.parseParamMovieValue($2, $siteRootUrl, $pagePath).$3."=".$5.parseParamMovieValue($7, $siteRootUrl, $pagePath).$8/segi;

	# Retourner le code HTML avec les éléments object parsées
	return $htmlCode;
}

# Function: cleanObjectParams
#	Supprimer les balises param d'un object
#
# Paramètres:
#	$htmlCode - code HTML dans la balise object à traiter
sub cleanObjectParams #($htmlCode)
{
	my ($htmlCode) = @_;

	# Suppression des balises param
	$htmlCode =~ s/<param( [^>]*?)?>//segi;

	# Retourner le code HTML sans les éléments param
	return $htmlCode;
}

# Function: replaceObjectsWithAlternativeHtml
#	Supprimer les balises ouvrantes et fermantes object ainsi que les balises param pour laisser le contenu alternatif
#
# Paramètres:
#	$htmlCode - code HTML à traiter
sub replaceObjectsWithAlternativeHtml #($htmlCode)
{
	my ($htmlCode) = @_;

	# Suppression de la balise object et remplacement par le contenu alternatif
	$htmlCode =~ s/<object( [^>]*?)?>(.*?)<\/object>/cleanObjectParams($2)/segi;

	# Retourner le code HTML sans les éléments object
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;