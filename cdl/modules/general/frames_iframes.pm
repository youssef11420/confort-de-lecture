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

# File: frames_iframes.pm
#	Module de gestion du code HTML et de nettoyage des frames/iframes

# Function: parseFrameSrc
#	Transformer l'attribut src d'une balise frame ou iframe et passer par le script CDL
#
# Param�tres:
#	$htmlCode - code html o� changer l'attribut src
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site pars�
sub parseFrameSrc #($htmlCode, $pagePath, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code html o� changer l'attribut src
	# - chemin vers la page en cours de traitement
	# - identifiant du site pars�
	my ($htmlCode, $pagePath, $siteId) = @_;
	
	# Transformation de l'attribut src pour rester sur CDL
	$htmlCode =~ s/(\s(src))\s*=\s*(\'|\")(.*?)\3/$1."=".$3.getUriFromUrl($4, $pagePath, $siteId).$3/segi;
	
	# Retourner la valeur de l'attrinut src
	return $htmlCode;
}

# Function: parseAllFramesSrc
#	Transformer les attributs src des balises frame et iframe pour rester sur CDL
#
# Param�tres:
#	$htmlCode - code html o� seront transform�es les balises frame et iframe
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site pars�
sub parseAllFramesSrc #($htmlCode, $pagePath, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code html o� seront transform�es les balises frame et iframe
	# - chemin vers la page en cours de traitement
	# - identifiant du site pars�
	my ($htmlCode, $pagePath, $siteId) = @_;

	# Transformation de l'attribut src dans la balise farme 
	$htmlCode =~ s/(<frame)(\s[^<]*?)?(\s\/>)/$1.parseFrameSrc($2, $pagePath, $siteId).$3/segi;
	
	# Transformation de l'attribut src dans la balise ifrmae
	$htmlCode =~ s/(<iframe)(\s[^<]*?)?(>)/$1.parseFrameSrc($2, $pagePath, $siteId).$3/segi;
	
	# Retourner le code html apr�s modification des URL de destinations des frames/iframes
	return $htmlCode;
}

# Function: replaceFramesWithAlternativeHtml
#	Supprimer les balises frame, frameset, iframe, et afficher le contenu alternatif � la place
#
# Param�tres:
#	$htmlCode - code html contenant les balises � enlever
sub replaceFramesWithAlternativeHtml #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code html contenant les balises � enlever
	my ($htmlCode) = @_;

	# Suppression des balises frame
	$htmlCode =~ s/<frame(\s[^<]*?)?\/>//sgi;

	# Suppression des balises ouvrantes frameset
	$htmlCode =~ s/<frameset(\s[^<]*?)?>//sgi;

	# Suppression des balises fermantes frameset
	$htmlCode =~ s/<\/frameset>//sgi;

	# Suppression des balises noframe et r�cup�ration de leurs contenus
	$htmlCode =~ s/<noframe(\s[^<]*?)?>(.*?)<\/noframe>/$2/sgi;
	
	# Suppression des balises iframe et r�cup�ration de leurs contenus
	$htmlCode =~ s/<iframe(\s[^<]*?)?>(.*?)<\/iframe>/$2/sgi;
	
	# Retourner le r�sultat apr�s suppression des frames/iframes
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;