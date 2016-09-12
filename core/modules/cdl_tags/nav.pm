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

# File: nav.pm
#	Module de gestion des blocs CDL de navigation

# Function: parseAllNavs
#	Récupérer le contenu des balises cdlNav et de les insérer dans la template générale de la page
#
# Paramètres:
#	$htmlCode - code HTML à parcourir
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$activateJavascript - option indiquant si on garde le javascript du site parsé en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
#	$displayImages - option indiquant si on garde les images du site parsé en version CDL
#	$displayObjects - option indiquant si on garde les objects du site parsé en version CDL
#	$displayApplets - option indiquant si on garde les applets du site parsé en version CDL
#	$parseTablesToList - option indiquant si on transforme les tableaux en liste à puce en version CDL
#	$activateFrames - option indiquant si on garde les frames/iframes du site parsé en version CDL
#	$siteId - identifiant du site parsé
#	$pageUri - URI de la page en cours
#	$trustedDomainNames - noms de domaine configuré de confiance
#	$entirePageTemplateString - chaîne de la template générale de page où remplir la zone des navs
#	$cadreTemplateString - chaîne template où remplir un bloc de navigation
sub parseAllNavs #($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $trustedDomainNames, $entirePageTemplateString, $cadreTemplateString)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à parcourir
	# - URL racine du site
	# - chemin vers la page en cours de traitement
	# - option indiquant si on garde le javascript du site parsé en version CDL
	# - option permettant de dire si on doit parser le javascript du site parsé
	# - option indiquant si on garde les images du site parsé en version CDL
	# - option indiquant si on garde les objects du site parsé en version CDL
	# - option indiquant si on garde les applets du site parsé en version CDL
	# - option indiquant si on transforme les tableaux en liste à puce en version CDL
	# - option indiquant si on garde les frames/iframes du site parsé en version CDL
	# - identifiant du site parsé
	# - URI de la page en cours
	# - chaîne de la template générale de page où remplir la zone des navs
	# - chaîne template où remplir un bloc de navigation
	my ($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $trustedDomainNames, $entirePageTemplateString, $cadreTemplateString) = @_;

	# Retourner le code HTML restant à parser ainsi que la template générale mise à jour
	return parseAllNavsBlocs($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $pageUri, $trustedDomainNames, $entirePageTemplateString, $cadreTemplateString, 'cdlNav', 'NAVS', ('ordre' => 1, 'partie' => 0));
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;