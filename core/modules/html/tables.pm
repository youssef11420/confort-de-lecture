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

# File: tables.pm
#	Module de gestion et de transformation des tableaux HTML (nettoyage ou transformation en listes à puce selon la configuration spécifiée)

# Function: getTableTagId
#	Récupérer l'attribut ID de la balise à parser
#
# Paramètres:
#	$tagAttributes - attributs de la balise
sub getTableTagId #($tagAttributes)
{
	my ($tagAttributes) = @_;

	$tagAttributes =~ s/ (id)=(\"|\')(.*?)\2/return " id=\"".$3."\""/segi;
	$tagAttributes =~ s/ (id)=(.*?)/return " id=\"".$2."\""/segi;

	return "";
}

# Function: getTableCellHeaders
#	Récupérer les valeurs des entêtes de la colonne
#
# Paramètres:
#	$tdAttributes - code HTML du contenu de la balise td
#	$tdNumber - numéro de la celulle courante
#	%theadersHash - tableau des entêtes
sub getTableCellHeaders #($tdAttributes, $tdNumber, %theadersHash)
{
	my ($tdAttributes, $tdNumber, %theadersHash) = @_;

	my ($tdHeadersContent, $nextTdNumber) = ("", 0);

	my @headers = ($tdNumber);

	if ($tdAttributes =~ m/ (headers)=(\"|\')(.*?)\2/si) {
		@headers = split(/\s/, $3);
	}

	# Remplissage du contenu des entêtes de la cellule en fonction leurs disponibilités
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
	$tdHeadersContent =~ s/&nbsp;//sgi;
	$tdHeadersContent =~ s/(<\/?([\w\d]+))( [^>]*?)?>//sgi;

	# Récupérer le colspan du td
	$tdAttributes =~ s/ (colspan)=(\"|\')(.*?)\2/$nextTdNumber = $3;/segi;

	# S'il y a pas de colspan, on incrémente de 1,
	# sinon on incrémente de la valeur du colspan
	if (!$nextTdNumber) {
		$nextTdNumber = $tdNumber + 1;
	} else {
		$nextTdNumber = $tdNumber + $nextTdNumber;
	}

	# Retourner le contenu des entêtes correspondantes à la cellule
	return $tdHeadersContent;
}

# Function: parseTableCellsToSubItems
#	Transformer les cellules une à une une item de la sous-liste
#
# Paramètres:
#	$trHtmlCode - code HTML du contenu de la balise tr
#	%theadersHash - tableau des entêtes (th)
sub parseTableCellsToSubItems #($trHtmlCode, %theadersHash)
{
	my ($trHtmlCode, %theadersHash) = @_;

	my $numCell = 0;

	# Détection des balises td et traitement pour afficher les entêtes correspondantes et le contenu
	my $tdHeadersContent = "";
	$trHtmlCode =~ s/<td( [^>]*?)?>(.*?)(?=(<t(r|h|d)( [^>]*?)?>|$))/
		$tdHeadersContent = getTableCellHeaders($1, $numCell++, %theadersHash);
		"<li class=\"cdlTableCell\"".getTableTagId($1).">".($tdHeadersContent ? "<div><strong>".$tdHeadersContent."&nbsp;:<\/strong><\/div> " : "").$2."<\/li>";/segi;

	$trHtmlCode =~ s/(.*)<hr>(.*?)$/$1$2/sgi;

	# Retourner l'identifiant du header (ou son numéro) ainsi que le numéro du prochain header
	return $trHtmlCode;
}

# Function: getThisThIdAndNextThNumber
#	Récupération de l'identifiant du header, sinon son numéro. On récupére aussi le numéro du prochain th compte tenu de celui du courant et des colspan
#
# Paramètres:
#	$thAttributes - code HTML des attributs de la balise th
#	$thNumber - numéro du td
sub getThisThIdAndNextThNumber #($thAttributes, $thNumber)
{
	my ($thAttributes, $thNumber) = @_;

	my ($thId, $nextThNumber) = ("", 0);

	# On recherche l'id du th
	$thAttributes =~ s/ (id)=(\"|\')(.*?)\2/$thId = $3;/segi;

	# S'il y a pas d'attribut id, on met le numéro du th courant
	if (!$thId) {
		$thId = $thNumber;
	}

	# Récupérer le colspan du th
	$thAttributes =~ s/ (colspan)=(\"|\')(.*?)\2/$nextThNumber = $3;/segi;

	# S'il y a pas de colspan, on incrémente de 1,
	# sinon on incrémente de la valeur du colspan
	if (!$nextThNumber) {
		$nextThNumber = $thNumber + 1;
	} else {
		$nextThNumber = $thNumber + $nextThNumber;
	}

	# Retourner l'identifiant du header (ou son numéro) ainsi que le numéro du prochain header
	return ($thId, $nextThNumber);
}

# Function: parseTableRowsToItems
#	Transformation du contenu d'un tableaux en items
#
# Paramètres:
#	$tableHtmlCode - code HTML où transformer les tableaux en liste à puce
#	$tableAttributes - attributs de la balise table à transformer
sub parseTableRowsToItems #($tableHtmlCode, $tableAttributes)
{
	my ($tableHtmlCode, $tableAttributes) = @_;

	my $footerHtmlCode = "";
	$tableHtmlCode =~ s/<tfoot( [^>]*?)?>(.*?)(?=(<t(head|body)( [^>]*?)?>|$))/
		$footerHtmlCode = $2; ""/segi;

	# Nettoyage des autres balises (thead, tbody, ..)
	$tableHtmlCode =~ s/<thead( [^>]*?)?>//sgi;
	$tableHtmlCode =~ s/<tbody( [^>]*?)?>//sgi;
	$tableHtmlCode =~ s/<colgroup( [^>]*?)?>//sgi;
	$tableHtmlCode =~ s/<col( [^>]*?)?>//sgi;

	my $tableCaption = "";
	$tableHtmlCode =~ s/<caption( [^>]*?)?>(.*?)<\/caption>/$tableCaption = $2;""/segi;

	# Récupération de la table de hachage des entêtes
	my %theadersHash;
	my %tfootHeadersHash;
	my $thNumber = 0;
	my $theaderId = "";

	# On construit la table de hachage des entêtes, et on les supprime du code HTML de la table
	$footerHtmlCode =~ s/<th( [^>]*?)?>(.*?)(?=(<t(r|h|d|body)( [^>]*?)?>|$))/
		($theaderId, $thNumber) = getThisThIdAndNextThNumber($1, $thNumber); $tfootHeadersHash{$theaderId} = $2; ""/segi;
	$thNumber = 0;
	$tableHtmlCode =~ s/<th( [^>]*?)?>(.*?)(?=(<t(r|h|d|body)( [^>]*?)?>|$))/
		($theaderId, $thNumber) = getThisThIdAndNextThNumber($1, $thNumber); $theadersHash{$theaderId} = $2; ""/segi;

	# Transformation du contenu de chaque ligne du footer du tableau
	my $nbRows = 0;

	# Transformation du contenu de chaque ligne du tableau

	# Suppression de la première ligne qui concerne les entêtes
	$footerHtmlCode =~ s/<tr( [^>]*?)?>(.*?)(?=(<tr( [^>]*?)?>|$))/$nbRows++; "<li".getTableTagId($1)."><ul class=\"cdlTableRowContent\">".parseTableCellsToSubItems($2, %tfootHeadersHash)."<\/ul><hr><br class=\"cdlHidden\">";/segi;

	# Suppression de la première ligne qui concerne les entêtes
	$tableHtmlCode =~ s/<tr( [^>]*?)?>(.*?)(?=(<tr( [^>]*?)?>|$))/$nbRows++; "<li".getTableTagId($1)."><ul class=\"cdlTableRowContent\">".parseTableCellsToSubItems($2, %theadersHash)."<\/ul><hr><br class=\"cdlHidden\">";/segi;

	$tableHtmlCode .= $footerHtmlCode ne "" ? "<br><hr><br class=\"cdlHidden\">".$footerHtmlCode : "";

	# Gestion des cas limite :
	# - s'il n'y a qu'un seul li, on enlève le séparateur hr
	if ($nbRows == 1) {
		$tableHtmlCode =~ s/<hr>(<br class=\"cdlHidden\">)$/$1/sgi;
	}
	# - s'il y a au moins un li, on entoure par un ul
	if ($nbRows > 0) {
		$tableHtmlCode = "<ul>".$tableHtmlCode."</ul>";
	}

	# Ajout du titre du tableau s'il y en a un
	if ($tableCaption) {
		$tableHtmlCode = "<div class=\"cdlTableCaption\"><strong>".$tableCaption."</strong><\/div>".$tableHtmlCode
	}

	$tableHtmlCode = "<div class=\"cdlTable\"".getTableTagId($tableAttributes).">".$tableHtmlCode."</div>";

	# Retourner le code HTML du contenu de la balise table transformé
	return $tableHtmlCode;
}


# Function: parseTablesToLists
#	Transformation des tableaux en listes à puce
#
# Paramètres:
#	$htmlCode - code HTML où transformer les tableaux en liste à puce
sub parseTablesToLists #($htmlCode)
{
	my ($htmlCode) = @_;

	while ($htmlCode =~ m/<table( [^>]*?)?>/) {
		$htmlCode =~ s/(.*)<table( [^>]*?)?>(.*?)<\/table>(.*)/
			my $firstPart = "".$1;
			my $attributes = "".$2;
			my $secondPart = "".$3;
			my $thirdPart = "".$4;
			$firstPart.parseTableRowsToItems($secondPart, $attributes).$thirdPart
		/segi;
	}

	# Retourner le code HTML avec des listes à puce à la place des tableaux
	return $htmlCode;
}

# Function: cleanTables
#	Traitement des tableaux
#
# Paramètres:
#	$htmlCode - code HTML où nettoyer les tableaux
sub cleanTables #($htmlCode)
{
	my ($htmlCode) = @_;

	# Suppression des attributs de base de la balise table (pour les réinitialiser après)
	$htmlCode =~ s/(<table( [^>]*?)?)( cellspacing=(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;
	$htmlCode =~ s/(<table( [^>]*?)?)( cellpadding=(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;
	$htmlCode =~ s/(<table( [^>]*?)?)( border=(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;
	$htmlCode =~ s/(<table( [^>]*?)?)( width=(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;
	$htmlCode =~ s/(<table( [^>]*?)?)( height=(\"|\')(.*?)\4)(.*?>)/$1$6/sgi;

	# Ajout des 3 attributs avec des valeurs assez génériques et qui rendent le tableau clair à lire en version sans style
	$htmlCode =~ s/(<table( [^>]*?)?)>/$1 cellspacing=\"0\" cellpadding=\"3\" border=\"1\" width=\"100%\">/sgi;

	# Remplir chaque cellule (balise td) vide avec un espace inseccable
	$htmlCode =~ s/<td( [^>]*?)?>\s*(?=(<(t(head|body|r|h|d)( [^>]*?)?|\/table)>|$))/<td$1>&nbsp;/sgi;

	# Retourner le code HTML avec les tables nettoyées
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;