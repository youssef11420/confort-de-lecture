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

# File: applets.pm
#	Module de transformation/nettoyage des applets

# Function: parseAppletAttributes
#	Ajouter l'attribut codebase dans la balise applet s'il n'existe pas
#
# Paramètres:
#	$tagAttributes - code html à l'intérieur de la balise applet
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseAppletAttributes #($tagAttributes, $siteRootUrl, $pagePath)
{
	my ($tagAttributes, $siteRootUrl, $pagePath) = @_;
	
	# Vérifier si l'attribut codebase existe, s'il n'existe pas il faut l'ajouter
	# Sinon il faut le mettre en absolu
	if($tagAttributes !~ m/ (codebase)=(\"|\')(.*?)\2/si) {
		$tagAttributes .= " codebase=\"".$siteRootUrl.$pagePath."\"";
	} else{
		$tagAttributes =~ s/( (codebase))=(\"|\')(.*?)\3/$1."=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3/segi;
	}

	# Retourne le contenu de la balise applet après modification du chemin
	return $tagAttributes;
}

# Function: parseAppletsSrc
#	Rendre les chemins des balises applet absolu 
#
# Paramètres:
#	$htmlCode - code html où rendre les chemins des applets absolu
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseAppletsSrc #($htmlCode, $siteRootUrl, $pagePath)
{
	my ($htmlCode, $siteRootUrl, $pagePath) = @_;

	# Identification des balises applet
	$htmlCode =~ s/(<applet)( [^>]*?)?(>)/$1.parseAppletAttributes($2, $siteRootUrl, $pagePath).$3/segi;

	# Retourner le code HTML avec les balises applet modifiées
	return $htmlCode;
}

# Function: cleanAppletParams
#	Supprimer les balises param tout en gardant le contenu alternatif
#
# Paramètres:
#	$htmlCode - code HTML à traiter
sub cleanAppletParams #($htmlCode)
{
	my ($htmlCode) = @_;

	# Suppression des balises param
	$htmlCode =~ s/<param( [^>]*?)?>//segi;

	# Retourner le code HTML sans les éléments param
	return $htmlCode;
}

# Function: replaceAppletsWithAlternativeHtml
#	Supprimer les balises applet et les remplacer par leurs contenus alternatifs
#
# Paramètres:
#	$htmlCode - code HTML à traiter
sub replaceAppletsWithAlternativeHtml #($htmlCode)
{
	my ($htmlCode) = @_;

	# Supprimer les applet ainsi que les balises param se trauvant à l'intérieur et garder le contenu alternatif
	$htmlCode =~ s/<applet( [^>]*?)?>(.*?)<\/applet>/cleanAppletParams($2)/sgi;

	# Retourner le code html nettoyé de toutes les balises applet
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;