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

# File: images_maps.pm
#	Module de gestion du code HTML des images/maps/areas

# Function: replaceImageWithAlt
#	Remplacer les images par leur contenu alternatif
#
# Paramètres:
#	$htmlCode - code HTML à traiter
sub replaceImageWithAlt #($htmlCode)
{
	my ($htmlCode) = @_;

	# Traitement du code et remplacement des images par leurs textes alternatifs
	$htmlCode =~ s/<img( [^>]*?)? (alt)=(\"|\')(.*?)\3.*?>/($4 eq "") ? "" : " ".$4." "/segi;
	$htmlCode =~ s/<img( [^>]*?)?>//sgi;

	# Retourner le code html après le traitement
	return $htmlCode;
}

# Function: parseImageAttributes
#	Traitement des attributs de la balise img : transformer la valeur de l'attribut src pour que ça soit toujours une url absolue + suppression des hauteurs et largeurs des images + ajout d'un attribut alt s'il y en a pas
#
# Paramètres:
#	$tagAttributes - code HTML des attributs à traiter
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page
sub parseImageAttributes #($tagAttributes, $siteRootUrl, $pagePath)
{
	my ($tagAttributes, $siteRootUrl, $pagePath) = @_;

	# Mettre en absolue l'URL dans l'attribut src
	$tagAttributes =~ s/( (src))=(\"|\')(.*?)\3/$1."=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3/segi;

	# Supprimer les attributs de tailles (hauteur, largeur) pour afficher l'image en pleines dimensions (sans dégradation)
	$tagAttributes =~ s/( (width))=(\"|\')(.*?)\3//sgi;
	$tagAttributes =~ s/( (height))=(\"|\')(.*?)\3//sgi;

	# Ajout d'un attribut alt s'il y en a pas
	if ($tagAttributes !~ m/( (alt))=(\"|\')(.*?)\3/si) {
		$tagAttributes .= " alt=\"\"";
	}

	# Retourner le code HTML des attributs parsés
	return $tagAttributes;
}

# Function: parseImages
#	Traitement des attributs des balises img pour s'afficher dans la version filtrée correctement et sans erreur XHTML
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page
sub parseImages #($htmlCode, $siteRootUrl, $pagePath)
{
	my ($htmlCode, $siteRootUrl, $pagePath) = @_;

	# Traitement des attributs dans les balises img
	$htmlCode =~ s/(<img)( [^>]*?)(>)/$1.parseImageAttributes($2, $siteRootUrl, $pagePath).$3/segi;

	# Retourner le code HTML avec les balise img parsées (url mises en absolues)
	return $htmlCode;
}

# Function: parseMapAreaAttributes
#	Transformer la valeur de l'attribut href dans une balise area pour que ça passe par le script CDL principal
#
# Paramètres:
#	$tagAttributes - code HTML des attibuts à traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - URL racine du site
sub parseMapAreaAttributes #($tagAttributes, $pagePath, $siteId, $siteRootUrl)
{
	my ($tagAttributes, $pagePath, $siteId, $siteRootUrl) = @_;

	# Transformer l'URL pour passer par le script CDL principal
	$tagAttributes =~ s/( (href))=(\"|\')(.*?)\3/$1."=".$3.getUriFromUrl($4, $pagePath, $siteId, $siteRootUrl).$3/segi;

	# Retourner les attributs du area en parsant l'URL dans le href
	return $tagAttributes;
}

# Function: parseMapAreas
#	Transformer les map/area selon la fait qu'on veuille ou non afficher les images
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$displayImages - booléen indiquant si l'affichage des images est activé
#	$siteId - identifiant du site parsé
#	$siteRootUrl - URL racine du site
sub parseMapAreas #($htmlCode, $pagePath, $displayImages, $siteId, $siteRootUrl)
{
	my ($htmlCode, $pagePath, $displayImages, $siteId, $siteRootUrl) = @_;

	# Si l'affichage des images est activé, on traite les URLs dans les attributs href des balises area pour passer par le script CDL principal, sinon, en remplace les maps par des listes à puce : en mettant comme intutilé du lien la valaur de l'attribut alt du area et comme lien le script CDL avec les paramètres id du site et url de la page à parser
	if ($displayImages) {
		$htmlCode =~ s/(<area)( [^>]*?)(>)/$1.parseMapAreaAttributes($2, $pagePath, $siteId).$3/segi;
	} else {
		# Remplacer les balises map par des balises ul
		$htmlCode =~ s/(<map( [^>]*?)?>)/<ul>/sgi;
		$htmlCode =~ s/(<\/map>)/<\/ul>/sgi;

		# Remplacer la balise area par la balise li contenant un lien vers la destination du area
		# Traitement des 3 cas, où l'attribut href est avant alt, et inversement, puis le cas où il n'y a pas de alt
		$htmlCode =~ s/<area( [^>]*?)? (href)=(\"|\')(.*?)\3( [^>]*?)? (alt)=(\"|\')(.*?)\7.*?>/
			"<li><a href=".$3.getUriFromUrl($4, $pagePath, $siteId, $siteRootUrl).$3.">".$8."<\/a><\/li>"/segi;
		$htmlCode =~ s/<area( [^>]*?)? (alt)=(\"|\')(.*?)\3( [^>]*?)? (href)=(\"|\')(.*?)\7.*?>/
			"<li><a href=".$7.getUriFromUrl($8, $pagePath, $siteId, $siteRootUrl).$7.">".$4."<\/a><\/li>"/segi;
		$htmlCode =~ s/<area( [^>]*?)? (href)=(\"|\')(.*?)\3.*?>/
			"<li><a href=".$3.getUriFromUrl($4, $pagePath, $siteId, $siteRootUrl).$3.">".(length($4) > 100 ? substr($4, 0, 97)."..." : $4)."<\/a><\/li>"/segi;
	}

	# Retourner le code HTML avec les balise map/area parsées
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;