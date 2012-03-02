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

# File: images_maps.pm
#	Module de gestion du code HTML des images/maps/areas

# Function: replaceImageWithAlt
#	Remplacer les images par leur contenu alternatif
#
# Param�tres:
#	$htmlCode - code HTML � traiter
sub replaceImageWithAlt #($htmlCode)
{
	# extraction des arguments dans une variable locale :
	# - code HTML � traiter
	my ($htmlCode) = @_;

	# Traitement du code et remplacement des images par leurs textes alternatifs
	$htmlCode =~ s/<img(\s[^>]*?)?\s(alt)\s*=\s*(\"|\')(.*?)\3.*?\s\/>/($4 eq "") ? "" : "<span class=\"cdlImage\">".$4."<\/span>"/segi;
	$htmlCode =~ s/<img(\s[^>]*?)?\s\/>//sgi;

	# Retourner le code html apr�s le traitement
	return $htmlCode;
}

# Function: parseImageAttributes
#	Traitement des attributs de la balise img : transformer la valeur de l'attribut src pour que �a soit toujours une url absolue + suppression des hauteurs et largeurs des images + ajout d'un attribut alt s'il y en a pas
#
# Param�tres:
#	$tagAttributes - code HTML des attributs � traiter
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page
sub parseImageAttributes #($tagAttributes, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs � traiter
	# - url racine du site
	# - chemin vers la page
	my ($tagAttributes, $siteRootUrl, $pagePath) = @_;

	# Mettre en absolue l'URL dans l'attribut src
	$tagAttributes =~ s/(\s(src))\s*=\s*(\"|\')(.*?)\3/$1."=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3/segi;

	# Supprimer les attributs de tailles (hauteur, largeur) pour afficher l'image en pleines dimensions (sans d�gradation)
	$tagAttributes =~ s/(\s(width))\s*=\s*(\"|\')(.*?)\3//sgi;
	$tagAttributes =~ s/(\s(height))\s*=\s*(\"|\')(.*?)\3//sgi;

	# Ajout d'un attribut alt s'il y en a pas
	if ($tagAttributes !~ m/(\s(alt))\s*=\s*(\"|\')(.*?)\3/si) {
		$tagAttributes .= " alt=\"\"";
	}

	# Retourner le code HTML des attributs pars�s
	return $tagAttributes;
}

# Function: parseImages
#	Traitement des attributs des balises img pour s'afficher dans la version filtr�e correctement et sans erreur XHTML
#
# Param�tres:
#	$htmlCode - code HTML � traiter
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page
sub parseImages #($htmlCode, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � traiter
	# - url racine du site
	# - chemin vers la page
	my ($htmlCode, $siteRootUrl, $pagePath) = @_;

	# Traitement des attributs dans les balises img
	$htmlCode =~ s/(<img)(\s.*?)(\s\/>)/$1.parseImageAttributes($2, $siteRootUrl, $pagePath).$3/segi;

	# Retourner le code HTML avec les balise img pars�es (url mises en absolues)
	return $htmlCode;
}

# Function: parseMapAreaAttributes
#	Transformer la valeur de l'attribut href dans une balise area pour que �a passe par le script CDL principal
#
# Param�tres:
#	$tagAttributes - code HTML des attibuts � traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site pars�
#	$siteRootUrl - url racine du site
sub parseMapAreaAttributes #($tagAttributes, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attibuts � traiter
	# - chemin vers la page en cours de traitement
	# - identifiant du site pars�
	# - url racine du site
	my ($tagAttributes, $pagePath, $siteId, $siteRootUrl) = @_;

	# Transformer l'URL pour passer par le script CDL principal
	$tagAttributes =~ s/(\s(href))\s*=\s*(\"|\')(.*?)\3/$1."=".$3.getUriFromUrl($4, $pagePath, $siteId, $siteRootUrl).$3/segi;

	# Retourner les attributs du area en parsant l'URL dans le href
	return $tagAttributes;
}

# Function: parseMapAreas
#	Transformer les map/area selon la fait qu'on veuille ou non afficher les images
#
# Param�tres:
#	$htmlCode - code HTML � traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$displayImages - bool�en indiquant si l'affichage des images est activ�
#	$siteId - identifiant du site pars�
#	$siteRootUrl - url racine du site
sub parseMapAreas #($htmlCode, $pagePath, $displayImages, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � traiter
	# - chemin vers la page en cours de traitement
	# - bool�en indiquant si l'affichage des images est activ�
	# - identifiant du site pars�
	# - url racine du site
	my ($htmlCode, $pagePath, $displayImages, $siteId, $siteRootUrl) = @_;

	# Si l'affichage des images est activ�, on traite les URLs dans les attributs href des balises area pour passer par le script CDL principal, sinon, en remplace les maps par des listes � puce : en mettant comme intutil� du lien la valaur de l'attribut alt du area et comme lien le script CDL avec les param�tres id du site et url de la page � parser
	if ($displayImages) {
		$htmlCode =~ s/(<area)(\s.*?)(\s\/>)/$1.parseMapAreaAttributes($2, $pagePath, $siteId).$3/segi;
	} else {
		# Remplacer les balises map par des balises ul
		$htmlCode =~ s/(<map(\s[^>]*?)?>)/<ul>/sgi;
		$htmlCode =~ s/(<\/map>)/<\/ul>/sgi;

		# Remplacer la balise area par la balise li contenant un lien vers la destination du area
		# Traitement des 2 cas, o� l'attribut href est avant alt, et inversement
		$htmlCode =~ s/<area(\s[^>]*?)?\s(href)\s*=\s*(\"|\')(.*?)\3(\s[^>]*?)?\s(alt)\s*=\s*(\"|\')(.*?)\7.*?\s\/>/
			"<li><a href=".$3.getUriFromUrl($4, $pagePath, $siteId, $siteRootUrl).$3.">".$8."<\/a><\/li>"/segi;
		$htmlCode =~ s/<area(\s[^>]*?)?\s(alt)\s*=\s*(\"|\')(.*?)\3(\s[^>]*?)?\s(href)\s*=\s*(\"|\')(.*?)\7.*?\s\/>/
			"<li><a href=".$7.getUriFromUrl($8, $pagePath, $siteId, $siteRootUrl).$7.">".$4."<\/a><\/li>"/segi;
	}

	# Retourner le code HTML avec les balise map/area pars�es
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;