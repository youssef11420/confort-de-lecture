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

# File: exclure.pm
#	Module de gestion des balises CDL qui permettent d'exclure du contenu de la version filtr�e

# Function: parseExclure
#	Supprimer les balises cdlExclure et leurs contenus
#
# Param�tres:
#	$htmlCode - code HTML � traiter
sub parseExclure #
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � traiter
	my ($htmlCode) = @_;

	# Suppression des balises cdlExclure et leurs contenus
	$htmlCode =~ s/<!--cdlExclure(\s[^<]*?)?-->(.*?)<!--\/cdlExclure-->//sg;

	# Retourner le code HTML nettoy�
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;