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

# File: applets.pm
#	Module de transformation/nettoyage des applets

# Function: parseAppletAttributes
#	Ajouter l'attribut codebase dans la balise applet s'il n'existe pas
#
# Param�tres:
#	$tagAttributes - code html � l'int�rieur de la balise applet
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseAppletAttributes #($tagAttributes, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - code html � l'int�rieur de la balise applet
	# - url racine du site
	# - chemin vers la page en cours de traitement
	my ($tagAttributes, $siteRootUrl, $pagePath) = @_;
	
	# V�rifier si l'attribut codebase existe, s'il n'existe pas il faut l'ajouter
	# Sinon il faut le mettre en absolu
	if($tagAttributes !~ m/\s(codebase)\s*=\s*(\"|\')(.*?)\2/si) {
		$tagAttributes .= " codebase=\"".$siteRootUrl.$pagePath."\"";
	} else{
		$tagAttributes =~ s/(\s(codebase))\s*=\s*(\"|\')(.*?)\3/$1."=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3/segi;
	}

	# Retourne le contenu de la balise applet apr�s modification du chemin
	return $tagAttributes;
}

# Function: parseAppletsSrc
#	Rendre les chemins des balises applet absolu 
#
# Param�tres:
#	$htmlCode - code html o� rendre les chemins des applets absolu
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseAppletsSrc #($htmlCode, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - code html o� rendre le chemin absolu
	# - url racine du site
	# - chemin vers la page en cours de traitement
	my ($htmlCode, $siteRootUrl, $pagePath) = @_;

	# Identification des balises applet
	$htmlCode =~ s/(<applet)(\s[^<]*?)?(>)/$1.parseAppletAttributes($2, $siteRootUrl, $pagePath).$3/segi;

	# Retourner le code HTML avec les balises applet modifi�es
	return $htmlCode;
}

# Function: cleanAppletParams
#	Supprimer les balises param tout en gardant le contenu alternatif
#
# Param�tres:
#	$htmlCode - code HTML � traiter
sub cleanAppletParams #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � traiter
	my ($htmlCode) = @_;

	# Suppression des balises param
	$htmlCode =~ s/<param(\s[^<]*?)?\s\/>//segi;

	# Retourner le code HTML sans les �l�ments param
	return $htmlCode;
}

# Function: replaceAppletsWithAlternativeHtml
#	Supprimer les balises applet et les remplacer par leurs contenus alternatifs
#
# Param�tres:
#	$htmlCode - code HTML � traiter
sub replaceAppletsWithAlternativeHtml #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � traiter
	my ($htmlCode) = @_;

	# Supprimer les applet ainsi que les balises param se trauvant � l'int�rieur et garder le contenu alternatif
	$htmlCode =~ s/<applet(\s[^<]*?)?>(.*?)<\/applet>/cleanAppletParams($2)/sgi;

	# Retourner le code html nettoy� de toutes les balises applet
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;