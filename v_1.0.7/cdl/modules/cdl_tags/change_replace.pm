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

# File: change_replace.pm
#	Module de gestion des balises CDL de remplacement (change/replace)

# Function: parseAloneReplaces
#	D�commenter le contenu des balises CDL replace qui ne sont pas entour�es par un change
#
# Param�tres:
#	$htmlCode - contenu o� transformer les replace
sub parseAloneReplaces #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - contenu o� transformer les replace
	my ($htmlCode) = @_;

	# Supprimer les commentaires � l'int�rieur de la balise cdlReplace pour afficher son contenu dans la verion filtr�e
	$htmlCode =~ s/<!--cdlReplace(\s[^>]*?)?-->\s*<!--(.*?)-->\s*<!--\/cdlReplace-->/$2/sg;

	# Retourne le contenu HTML avec les balises CDL replace seules trait�es
	return $htmlCode;
}

# Function: parseReplaces
#	D�commenter le contenu de la balise CDL replace
#
# Param�tres:
#	$cdlTagContent - contenu de la balise cdlChange
sub parseReplaces #($cdlTagContent)
{
	# Extraction des arguments dans une variable locale :
	# - contenu de la balise cdlChange
	my ($cdlTagContent) = @_;

	# S'il n'y a pas de balise CDL replace, le remplacement est la cha�ne vide
	if ($cdlTagContent !~ m/<!--cdlReplace(\s[^>]*?)?-->\s*<!--(.*)-->\s*<!--\/cdlReplace-->/sg) {
		$cdlTagContent = "";
	}

	# Supprimer les commentaires � l'int�rieur de la balise cdlReplace
	$cdlTagContent =~ s/(.*)<!--cdlReplace(\s[^>]*?)?-->\s*<!--(.*)-->\s*<!--\/cdlReplace-->(.*)/$3/sg;

	# Retourne le contenu de la balise CDL replace d�comment�
	return $cdlTagContent;
}

# Function: parseChanges
#	Remplacer le contenu de la balise cdlChange par le contenu de la balise cdlReplace
#
# Param�tres:
#	$htmlCode - code HTML o� transformer les change/replace
sub parseChanges #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML o� transformer les change/replace
	my ($htmlCode) = @_;

	# D�tection de la balise cdlChange et r�cup�ration de son contenu
	$htmlCode =~ s/<!--cdlChange(\s[^>]*?)?-->(.*?)<!--\/cdlChange-->/parseReplaces($2)/seg;

	# Retourne le code html sans les balise change/replace et avec le contenu du replace d�comment�
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;