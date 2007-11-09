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

# File: forms.pm
#	Module de gestion du code HTML des formulaires

# Function: parseFormBooleanAttributes
#	Traitement des attributs relatives aux formulaires
#
# Paramètres:
#	$tagAttributes - code HTML des attributs d'une balise
sub parseFormBooleanAttributes #($tagAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs d'une balise
	my ($tagAttributes) = @_;

	# Génération de la chaîne des choix pour l'expression régulière : 
	# selected|disabled|readonly|checked|multiple
	$booleanFormAttributsRegExpString = "";
	foreach $booleanFormAttribut (%booleanFormAttributs) {
		if ($booleanFormAttribut) {
			$booleanFormAttributsRegExpString .= $booleanFormAttribut."|";
		}
	}

	$booleanFormAttributsRegExpString =~ s/\|$//sgi;

	# Correction des attributs booléens en mettant (attribute => attribute="attribute") pour rendre XHTML
	$tagAttributes =~ s/(\s)($booleanFormAttributsRegExpString)(\s|>)/$1.$2."=\"".$2."\"".$3/segi;

	# Retourner le code html aprés le traitement
	return $tagAttributes;
}

# Function: parseForms
#	Récupérer la table de hachage contenant les attributs d'une balise input de type image ainsi que leurs valeurs
#
# Paramètres:
#	$tagAttributes - code HTML des attributes à traiter
sub getInputImageAttributes #($tagAttributes)
{
	# Extraction des arguments dans une variable locale :
	# -le code HTML des attributes à traiter
	my ($tagAttributes) = @_;

	my %inputAttributes;

	$tagAttributes =~ s/\s(\S*?)\s*=\s*(\"|\')(.*?)\2/$inputAttributes{lc($1)} = $3;/segi;

	# S'il n'y a pas de alt ou qu'il est vide, on rajoute une valeur par défaut
	if (!$inputAttributes{'alt'}) {
		$inputAttributes{'alt'} = $defaultButtonText;
	}

	# Retourner la table de hachage des attributs et leurs valeurs
	return %inputAttributes;
}

# Function: parseForms
#	Traitement des formulaires (action et champs)
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
sub parseForms #($htmlCode, $pagePath, $siteId)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à traiter
	# - chemin vers la page en cours de traitement
	# - identifiant du site parsé
	my ($htmlCode, $pagePath, $siteId) = @_;

	# Traitement du code des formulaires :

	# Modification de la valeur de l'attribut action et rajout du champ caché pour passer l'action en paramétre au script CDL
	$htmlCode =~ s/<form(\s[^<]*?)?\s(action)\s*=\s*(\"|\')(.*?)\3((\s[^<]*?)?>)/"<form".$1." ".$2."=\"".getUriFromUrl($4, $pagePath, $siteId)."\"".$5/segi;

	# rajout d'un div autour du contenu de la balise form pour être sur que la page est valide XHTML strict
	$htmlCode =~ s/(<(form)(\s[^<]*?)?>)(.*?)(<\/\2>)/$1<div>$4<\/div>$5/sgi;

	# Supprimer l'attribut name de la balise form
	$htmlCode =~ s/(<form(\s[^<]*?)?\s)(name\s*=\s*(\"|\')(.*?)\4)/$tutu=1;$1;/segi;

	# Correction des attributs booléens concernant les champs de formulaire (selected, disabled, readonly, checked, multiple, ...
	# et d'autres on sait jamais) non conformes à la norme

	# Détection des balises et traitement de la chaîne correspondant aux attributs
	$htmlCode =~ s/(<(\w|\d)+)(\s.*?)>/$1.parseFormBooleanAttributes($3).">"/segi;

	# Mettre la classe cdlInputText aux champs textuels
	$htmlCode =~ s/(<input(\s[^<]*?)?\s(type)\s*=\s*(\"|\')(text|password|file)\4.*?)(\s\/>)/<span class=\"cdlInputText\">$1$6<\/span>/sgi;

	# Remplacer les boutons image (input type="image") par leur contenu alternatif. S'ils en ont pas, on met un texte par défaut ("Valider" par exemple)
	$htmlCode =~ s/<input(\s[^<]*?)?\s(type)\s*=\s*(\"|\')(image)\3(.*?)(\s\/>)/
		my %inputAttributes = getInputImageAttributes($1." ".$5);
		"<input type=\"submit\" name=\"".$inputAttributes{'name'}."\" value=\"".$inputAttributes{'alt'}."\" \/>"/segi;

	# Entourer les boutons de formulaire par un div
	$htmlCode =~ s/(<input(\s[^<]*?)?\s(type)\s*=\s*(\"|\')(submit|button|reset)\4.*?\/>)/<div class=\"cdlButtons\">$1<\/div>/sgi;
	$htmlCode =~ s/(<(button)(\s[^<]*?)?>.*?<\/\2>)/<div class=\"cdlButtons\">$1<\/div>/sgi;

	# Retourner le code html aprés le traitement
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;