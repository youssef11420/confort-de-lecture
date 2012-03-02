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

# File: tables.pm
#	Module de gestion et de transformation des tableaux HTML (nettoyage ou transformation en listes � puce selon la configuration sp�cifi�e)

# Function: getTableCellHeaders
#	R�cup�rer les valeurs des ent�tes de la colonne
#
# Param�tres:
#	$tdAttributes - code HTML du contenu de la balise td
#	$tdNumber - num�ro de la celulle courante
#	%theadersHash - tableau des ent�tes
sub getTableCellHeaders #($tdAttributes, $tdNumber, %theadersHash)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML du contenu de la balise td
	# - num�ro de la celulle courante
	# - tableau des ent�tes
	my ($tdAttributes, $tdNumber, %theadersHash) = @_;

	my ($tdHeadersContent, $nextTdNumber) = ("", 0);

	my @headers = ($tdNumber);

	$tdAttributes =~ s/\s(headers)\s*=\s*(\"|\')(.*?)\2/@headers = split(\/\s\/, $3);/segi;

	# Remplissage du contenu des ent�tes de la cellule en fonction leurs disponibilit�s
	foreach my $header (@headers) {
		my $headerKey = "";
		if ($theadersHash{$header}) {
			$headerKey = $header;
		} else {
			$headerKey = $tdNumber;
		}

		my $tdHeaderContent = $theadersHash{$headerKey};

		if ($tdHeaderContent) {
			$tdHeadersContent .= $tdHeaderContent." | ";
		}
	}

	$tdHeadersContent =~ s/ \| $//sgi;

	# R�cup�rer le colspan du td
	$tdAttributes =~ s/\s(colspan)\s*=\s*(\"|\')(.*?)\2/$nextTdNumber = $3;/segi;

	# S'il y a pas de colspan, on incr�mente de 1,
	# sinon on incr�mente de la valeur du colspan
	if (!$nextTdNumber) {
		$nextTdNumber = $tdNumber + 1;
	} else {
		$nextTdNumber = $tdNumber + $nextTdNumber;
	}

	# Retourner le contevu des ent�tes correspondantes � la cellule
	return $tdHeadersContent;
}

# Function: parseTableCellsToSubItems
#	Transformer les cellules une � une une item de la sous-liste
#
# Param�tres:
#	$trHtmlCode - code HTML du contenu de la balise tr
#	%theadersHash - tableau des ent�tes (th)
sub parseTableCellsToSubItems #($trHtmlCode, %theadersHash)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML du contenu de la balise tr
	# - tableau des ent�tes (th)
	my ($trHtmlCode, %theadersHash) = @_;

	my $numCell = 0;

	# D�tection des balises td et traitement pour afficher les ent�tes correspondantes et le contenu
	my ($tdHeadersContent, $tdNumber) = ("", 0);
	$trHtmlCode =~ s/<td(\s[^>]*?)?>(.*?)<\/td>/
		($tdHeadersContent, $tdNumber) = getTableCellHeaders($1, $numCell++, %theadersHash);
		"<div class=\"cdlTableCell\">".($tdHeadersContent ? $tdHeadersContent." : " : "").parseTablesToLists($2)."<\/div><hr \/>";/segi;

	$trHtmlCode =~ s/(.*)<hr \/>(.*?)$/$1$2/sgi;

	# Retourner l'identifiant du header (ou son num�ro) ainsi que le num�ro du prochain header
	return $trHtmlCode;
}

# Function: getThisThIdAndNextThNumber
#	R�cup�ration de l'identifiant du header, sinon son num�ro. On r�cup�re aussi le num�ro du prochain th compte tenu de celui du courant et des colspan
#
# Param�tres:
#	$thAttributes - code HTML des attributs de la balise th
#	$thNumber - num�ro du td
sub getThisThIdAndNextThNumber #($thAttributes, $thNumber)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs de la balise th
	# - num�ro du td
	my ($thAttributes, $thNumber) = @_;

	my ($thId, $nextThNumber) = ("", 0);

	# On recherche l'id du th
	$thAttributes =~ s/\s(id)\s*=\s*(\"|\')(.*?)\2/$thId = $3;/segi;

	# S'il y a pas d'attribut id, on met le num�ro du th courant
	if (!$thId) {
		$thId = $thNumber;
	}

	# R�cup�rer le colspan du th
	$thAttributes =~ s/\s(colspan)\s*=\s*(\"|\')(.*?)\2/$nextThNumber = $3;/segi;

	# S'il y a pas de colspan, on incr�mente de 1,
	# sinon on incr�mente de la valeur du colspan
	if (!$nextThNumber) {
		$nextThNumber = $thNumber + 1;
	} else {
		$nextThNumber = $thNumber + $nextThNumber;
	}

	# Retourner l'identifiant du header (ou son num�ro) ainsi que le num�ro du prochain header
	return ($thId, $nextThNumber);
}

# Function: parseTableRowsToItems
#	Transformation du contenu d'un tableaux en items
#
# Param�tres:
#	$tableHtmlCode - code HTML o� transformer les tableaux en liste � puce
sub parseTableRowsToItems #($tableHtmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML o� transformer les tableaux en liste � puce
	my ($tableHtmlCode) = @_;

	# Nettoyage des autres balises (thead, tbody, ..)
	$tableHtmlCode =~ s/<\/?thead(\s[^>]*?)?>//sgi;
	$tableHtmlCode =~ s/<\/?tbody(\s[^>]*?)?>//sgi;
	$tableHtmlCode =~ s/<\/?tfoot(\s[^>]*?)?>//sgi;
	$tableHtmlCode =~ s/<\/?colgroup(\s[^>]*?)?>//sgi;
	$tableHtmlCode =~ s/<\/?col(\s[^>]*?)?>//sgi;

	my $tableCaption = "";
	$tableHtmlCode =~ s/<caption(\s[^>]*?)?>(.*?)<\/caption>/$tableCaption = $2;""/segi;

	# R�cup�ration de la table de hachage des ent�tes
	my %theadersHash;
	my $thNumber = 0;
	my $theaderId = "";
	# On construit la table de hachage des ent�tes, eton les supprime du code HTML de la table
	$tableHtmlCode =~ s/<th(\s[^>]*?)?>(.*?)<\/th>/
		($theaderId, $thNumber) = getThisThIdAndNextThNumber($1, $thNumber); $theadersHash{$theaderId} = $2; ""/segi;

	

	# Transformation du contenu de chaque ligne du tableau
	my $nbRows = 0;
	# Suppression de la premi�re ligne qui concerne les ent�tes
	$tableHtmlCode =~ s/<tr(\s[^>]*?)?>\s*<\/tr>//sgi;
	$tableHtmlCode =~ s/<tr(\s[^>]*?)?>(.*?)<\/tr>/$nbRows++; "<li><div class=\"cdlTableRowContent\">".parseTableCellsToSubItems($2, %theadersHash)."<\/div><div class=\"cdlTableRowSep\"><\/div><br class=\"cdlCache\" \/><\/li>";/segi;

	# Suppression du dernier s�parateur
	$tableHtmlCode =~ s/(.*)<div class=\"cdlTableRowSep\"><\/div>(.*?)/$1$2/sgi;

	# Gestion des cas limite :
	# - s'il y a au moins un li, on entoure par un ul
	if ($nbRows > 0) {
		$tableHtmlCode = "<ul>".$tableHtmlCode."</ul>";
	}

	# Ajout du titre du tableau s'il y en a un
	if ($tableCaption) {
		$tableHtmlCode = "<div class=\"cdlTableCaption\"><strong>".$tableCaption."</strong><\/div>".$tableHtmlCode
	}

	$tableHtmlCode = "<div class=\"cdlTable\">".$tableHtmlCode."</div>";

	# Retourner le code HTML du contenu de la balise table transform�
	return $tableHtmlCode;
}

# Function: parseTablesToLists
#	Transformation des tableaux en listes � puce
#
# Param�tres:
#	$htmlCode - code HTML o� transformer les tableaux en liste � puce
sub parseTablesToLists #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML o� transformer les tableaux en liste � puce
	my ($htmlCode) = @_;

	$htmlCode =~ s/<table(\s[^>]*?)?>(.*?)<\/table>/parseTableRowsToItems($2)/segi;

	# Retourner le code HTML avec des listes � puce � la place des tableaux
	return $htmlCode;
}

# Function: cleanTables
#	Traitement des tableaux
#
# Param�tres:
#	$htmlCode - code HTML o� nettoyer les tableaux
sub cleanTables #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML o� nettoyer les tableaux
	my ($htmlCode) = @_;

	# Suppression des 3 attributs de base de la balise table (pour les r�initialiser apr�s
	$htmlCode =~ s/(<table(\s[^>]*?)?)(\scellspacing\s*=\s*(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;
	$htmlCode =~ s/(<table(\s[^>]*?)?)(\scellpadding\s*=\s*(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;
	$htmlCode =~ s/(<table(\s[^>]*?)?)(\sborder\s*=\s*(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;
	$htmlCode =~ s/(<table(\s[^>]*?)?)(\swidth\s*=\s*(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;
	$htmlCode =~ s/(<table(\s[^>]*?)?)(\sheight\s*=\s*(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;

	# Ajout des 3 attributs avec des valeurs assez g�n�riques et qui rendent le tableau clair � lire en version sans style
	$htmlCode =~ s/(<table(\s[^>]*?)?)>/$1 cellspacing=\"0\" cellpadding=\"3\" border=\"1\" width=\"100%\">/sgi;

	# Retourner le code HTML avec les tables nettoy�es
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;