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

# File: forms.pm
#	Module de gestion du code HTML des formulaires

# Function: getInputImageAttributes
#	Récupérer la table de hachage contenant les attributs d'une balise input de type image ainsi que leurs valeurs
#
# Paramètres:
#	$tagAttributes - code HTML des attributes à traiter
sub getInputImageAttributes #($tagAttributes)
{
	my ($tagAttributes) = @_;

	my %inputAttributes;

	$tagAttributes =~ s/ (\S*?)=(\"|\')(.*?)\2/$inputAttributes{$1} = $2.$3.$2;/segi;

	# S'il n'y a pas de alt ou qu'il est vide, on rajoute une valeur par défaut
	if (!$inputAttributes{'alt'} or $inputAttributes{'alt'} eq "\"\"" or $inputAttributes{'alt'} eq "''") {
		$inputAttributes{'alt'} = $defaultButtonText;
	}

	# Retourner la table de hachage des attributs et leurs valeurs
	return %inputAttributes;
}

# Function: addBorderForTextInputWithoutTypeAttribute
#	Entourer d'un span pour ajouter une bordure aux balises input qui n'ont pas d'attribut type (et donc de type texte par défaut)
#
# Paramètres:
#	$tagHtmlCode - code HTML de la balise input à traiter
sub addBorderForTextInputWithoutTypeAttribute #($tagHtmlCode)
{
	my ($tagHtmlCode) = @_;

	# S'il n'y a pas d'attribut type, on entoure d'un span pour rajouter la bordure
	if ($tagHtmlCode !~ m/ (type=(\"|\')(.*?)\2)/si) {
		return "<span class=cdlInputText>".$tagHtmlCode."</span>";
	}

	return $tagHtmlCode;
}

# Function: parseForms
#	Traitement des formulaires (action et champs)
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - URL racine du site
#	$pageUri - URI de la page en cours
#	$trustedDomainNames - noms de domaine configurés de confiance
sub parseForms #($htmlCode, $pagePath, $siteId, $siteRootUrl, $pageUri, $trustedDomainNames)
{
	my ($htmlCode, $pagePath, $siteId, $siteRootUrl, $pageUri, $trustedDomainNames) = @_;

	# Traitement du code des formulaires :

	my $method = 'get';

	$htmlCode =~ s/(<form( [^>]*)? method=(\"|\'))(.*?)(\3([^>]*)>)/$method = $4; $1.$4.$5/segi;

	# Modification de la valeur de l'attribut action pour rester sur CDL
	$htmlCode =~ s/(<form( [^>]*)? action=(\"|\'))(.*?)(\3([^>]*)>)/$1.parseLinkHrefAttribute($4, $pagePath, $siteId, $siteRootUrl, $pageUri, $method, $trustedDomainNames).$5/segi;

	# Entourer les champs textuels de formulaire par un span de classe cdlInputText
	$htmlCode =~ s/(<input( [^>]*)? type=(\"|\')(text|password|file|color|date|datetime|datetime-local|email|month|number|range|search|tel|time|url|week)\3[^>]*>)/<span class=cdlInputText>$1<\/span>/sgi;
	# Entourer les autres textuels de formulaire par un span de classe cdlOtherInput
	$htmlCode =~ s/(<input( [^>]*)? type=(\"|\')(radio|checkbox)\3[^>]*>)/<span class=cdlOtherInput>$1<strong class=cdlInput_$4><\/strong><\/span>/sgi;
	# Gestion des balises input sans attribut type (donc par défaut de type texte)
	$htmlCode =~ s/(<input( [^>]*)?>)/addBorderForTextInputWithoutTypeAttribute($1)/segi;

	$htmlCode =~ s/(<select( [^>]*)?>.*?<\/select>)/<strong class=cdlSelectInput>$1<span><\/span><\/strong>/sgi;

	# Remplacer les boutons image (input type="image") par leur contenu alternatif. S'ils en ont pas, on met un texte par défaut ("Valider" par exemple)
	$htmlCode =~ s/<input( [^>]*)? type=(\"|\')image\2([^>]*)>/
		my %inputAttributes = getInputImageAttributes($1." ".$3);
		"<span class=cdlButtons><input type=\"submit\" name=".$inputAttributes{'name'}." value=".$inputAttributes{'alt'}."><\/span>"/segi;

	# Entourer les boutons de formulaire par un span de classe cdlButtons
	$htmlCode =~ s/(<input( [^>]*)? type=(\"|\')(submit|button|reset)\3[^>]*>)/<span class=cdlButtons>$1<\/span>/sgi;
	$htmlCode =~ s/(<button( [^>]*)?>.*?<\/button>)/<span class=cdlButtons>$1<\/span>/sgi;

	# Retourner le code html aprés le traitement
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;