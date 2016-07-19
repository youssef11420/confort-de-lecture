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

# File: position.pm
#	Module de gestion du bloc CDL de fil d'Ariane

# Function: positionTagExists
#	Tester si la balise CDL position existe
#
# Paramètres:
#	 - code HTML à parcourir
sub positionTagExists #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à parcourir
	my ($htmlCode) = @_;

	# Si la balise CDL position existe, on retourne vrai
	if ($htmlCode =~ m/<!--(cdlPosition)(\s[^>]*)?-->(.*?)<!--\/\1-->/s) {
		return 1;
	}

	# Sinon on retourne faux
	return 0;
}

# Function: parsePosition
#	Construire un fil d'Ariane
#
# Paramètres:
#	$htmlCode - code HTML à parcourir
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$positionLocation - option indiquant si on affiche le fil d'Ariane en haut ou bas de page
#	$activateJavascript - option indiquant si on garde le javascript du site parsé en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
#	$displayImages - option indiquant si on garde les images du site parsé en version CDL
#	$displayObjects - option indiquant si on garde les objects du site parsé en version CDL
#	$displayApplets - option indiquant si on garde les applets du site parsé en version CDL
#	$parseTablesToList - option indiquant si on transforme les tableaux en liste à puce en version CDL
#	$activateFrames - option indiquant si on garde les frames/iframes du site parsé en version CDL
#	$entirePageTemplateString - chaîne de la template générale de page où remplir le haut de page
#	$cadreTemplateString - chaîne template où remplir le fil d'Ariane en haut de page
#	$siteId - identifiant du site parsé
#	$pageUri - URI de la page en cours
sub parsePosition #($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $entirePageTemplateString, $cadreTemplateString, $siteId, $pageUri)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à parcourir
	# - URL racine du site
	# - chemin vers la page en cours de traitement
	# - option indiquant si on affiche le fil d'Ariane en haut ou bas de page
	# - option indiquant si on garde le javascript du site parsé en version CDL
	# - option permettant de dire si on doit parser le javascript du site parsé
	# - option indiquant si on garde les images du site parsé en version CDL
	# - option indiquant si on garde les objects du site parsé en version CDL
	# - option indiquant si on garde les applets du site parsé en version CDL
	# - option indiquant si on transforme les tableaux en liste à puce en version CDL
	# - option indiquant si on garde les frames/iframes du site parsé en version CDL
	# - chaîne de la template générale de page où remplir le haut de page
	# - chaîne template où remplir le fil d'Ariane en haut de page
	# - identifiant du site parsé
	# - URI de la page en cours
	my ($htmlCode, $siteRootUrl, $pagePath, $positionLocation, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $entirePageTemplateString, $cadreTemplateString, $siteId, $pageUri) = @_;

	# Chaîne de caractères où sera stockée le contenu du fil d'Ariane
	my $positionContent = "";

	# Tableau des informations sur les occurrences de la balise CDL
	my @cdlTagsInfos;

	# Récupération de toutes les occurrences de la balise cdlPosition triées par partie
	($htmlCode, @cdlTagsInfos) = getCdlTagInnerHtmlAndInfos($htmlCode, 'cdlPosition', ('partie'));

	# Remplir la première partie par défaut
	if (@cdlTagsInfos > 0) {
		# Récupération du contenu HTML nettoyé de la balise exclure
		$positionContent .= parseAllHtml($cdlTagsInfos[0]->{'content'}, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri);

		# Remplir le reste des parties de cdlPosition
		for (my $j = 1; $j < @cdlTagsInfos; $j++) {
			$positionContent .= "&nbsp;&gt;&nbsp;".parseAllHtml($cdlTagsInfos[$j]->{'content'}, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri);
		}
	}

	if ($positionContent and $positionContent !~ m/^\s*$/sgi) {
		# Utilisation de la template de cadre pour entourer le fil d'Ariane
		$cadreTemplateString = setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', $positionContent)."\n";

		# Insertion du fil d'Ariane dans la template générale de la page
		$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'PAGE_'.($positionLocation eq "2" or $positionLocation eq "3" ? 'BOTTOM' : 'TOP'), $cadreTemplateString);
		if ($positionLocation eq "3") {
			$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'PAGE_TOP', $cadreTemplateString);
		} else {
			$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'PAGE_'.($positionLocation eq "2" ? 'TOP' : 'BOTTOM'), "");
		}
	} else {
		$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'PAGE_TOP', "");
		$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, 'PAGE_BOTTOM', "");
	}

	# Retourner le code HTML restant à parser ainsi que la template générale mise à jour
	return ($htmlCode, $entirePageTemplateString);
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;