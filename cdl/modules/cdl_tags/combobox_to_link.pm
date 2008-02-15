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

# File: combobox_to_link.pm
#	Module de gestion des balises CDL de transformation des menus déroulants en listes à puce avec liens

# Function: parseComboItemsToLinks
#	Transformer les items d'une combobox en des items d'une liste à puce
#
# Paramètres:
#	$selectInnerHtmlCode - code HTML à traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$comboItemToLinkTemplateString - template de rendu final de l'item combotolink
#	$siteId - identifiant du site parsé
#	$siteRootUrl - url racine du site
sub parseComboItemsToLinks #($selectInnerHtmlCode, $pagePath, $comboItemToLinkTemplateString, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à traiter
	# - chemin vers la page en cours de traitement
	# - template de rendu final de l'item combotolink
	# - identifiant du site parsé
	# - url racine du site
	my ($selectInnerHtmlCode, $pagePath, $comboItemToLinkTemplateString, $siteId, $siteRootUrl) = @_;

	# Chaîne qui contiendra tous les items transformés
	my $allItems = "";

	# Transformation de tous les items de combobox et génération de la chaîne contenants tous les items en liste à puce
	$selectInnerHtmlCode =~ s/<(option)(\s[^>]*?)?\s(value)\s*=\s*(\"|\')(.*?)\4(.*?)>(.*?)<\/\1>/
		$allItems .= setValueInTemplateString(setValueInTemplateString($comboItemToLinkTemplateString, 'ITEM_URL', getUriFromUrl($5, $pagePath, $siteId, $siteRootUrl)), 'ITEM_NAME', $7);/segi;

	# Retourner le code HTML transformé
	return $allItems;
}

# Function: parseAllComboToLinks
#	Transformer une combobox de navigation en une liste à puce
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$comboToLinkTemplateString - template de rendu final du combotolink
#	$siteId - identifiant du site parsé
#	$siteRootUrl - url racine du site
sub parseAllCombosToLinks #($htmlCode, $pagePath, $comboToLinkTemplateString, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à traiter
	# - chemin vers la page en cours de traitement
	# - template de rendu final du combotolink
	# - identifiant du site parsé
	# - url racine du site
	my ($htmlCode, $pagePath, $comboToLinkTemplateString, $siteId, $siteRootUrl) = @_;

	# Remplacement des combobox au sein de la balise CDL par des liste à puce
	$htmlCode =~ s/<!--cdlComboToLink(\s[^>]*?)?-->(.*?)(<select(\s[^>]*?)?>)(.*?)(<\/select>)(.*?)<!--\/cdlComboToLink-->/
		$2.setValueInTemplateString($comboToLinkTemplateString, 'LIST_ITEM', parseComboItemsToLinks($5, $pagePath, getPartOfTemplateString($comboToLinkTemplateString, 'LIST_ITEM'), $siteId, $siteRootUrl)).$7/seg;

	# Retourner le code HTML transformé
	return $htmlCode;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;