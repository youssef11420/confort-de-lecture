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

# File: frames_iframes.pm
#	Module de gestion du code HTML et de nettoyage des frames/iframes

# Function: parseFrameSrc
#	Transformer l'attribut src d'une balise frame ou iframe et passer par le script CDL
#
# Paramètres:
#	$htmlCode - code html où changer l'attribut src
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - URL racine du site
sub parseFrameSrc #($htmlCode, $pagePath, $siteId, $siteRootUrl)
{
	my ($htmlCode, $pagePath, $siteId, $siteRootUrl) = @_;
	
	# Transformation de l'attribut src pour rester sur CDL
	$htmlCode =~ s/( (src))=(\"|\')(.*?)\3/$1."=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3/segi;
	
	# Retourner la valeur de l'attrinut src
	return $htmlCode;
}

# Function: parseAllFramesSrc
#	Transformer les attributs src des balises frame et iframe pour rester sur CDL
#
# Paramètres:
#	$htmlCode - code html où seront transformées les balises frame et iframe
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - URL racine du site
sub parseAllFramesSrc #($htmlCode, $pagePath, $siteId)
{
	my ($htmlCode, $pagePath, $siteId, $siteRootUrl) = @_;

	# Transformation de l'attribut src dans la balise farme 
	$htmlCode =~ s/(<frame)( [^>]*?)?(>)/$1.parseFrameSrc($2, $pagePath, $siteId, $siteRootUrl).$3/segi;
	
	# Transformation de l'attribut src dans la balise ifrmae
	$htmlCode =~ s/(<iframe)( [^>]*?)?(>)/$1.parseFrameSrc($2, $pagePath, $siteId, $siteRootUrl).$3/segi;
	
	# Retourner le code html après modification des URL de destinations des frames/iframes
	return $htmlCode;
}

# Function: replaceFramesWithAlternativeHtml
#	Supprimer les balises frame, frameset, iframe, et afficher le contenu alternatif à la place
#
# Paramètres:
#	$htmlCode - code html contenant les balises à enlever
sub replaceFramesWithAlternativeHtml #($htmlCode)
{
	my ($htmlCode) = @_;

	# Suppression des balises frame
	$htmlCode =~ s/<frame( [^>]*?)?>//sgi;

	# Suppression des balises ouvrantes frameset
	$htmlCode =~ s/<frameset( [^>]*?)?>//sgi;

	# Suppression des balises fermantes frameset
	$htmlCode =~ s/<\/frameset>//sgi;

	# Suppression des balises noframe et récupération de leurs contenus
	$htmlCode =~ s/<noframe( [^>]*?)?>(.*?)<\/noframe>/$2/sgi;
	
	# Suppression des balises iframe et récupération de leurs contenus
	$htmlCode =~ s/<iframe( [^>]*?)?>(.*?)<\/iframe>/$2/sgi;
	
	# Retourner le résultat après suppression des frames/iframes
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;