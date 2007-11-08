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

# File: utils.pm
#	Module de fonctions générale utiles pour récupérer toutes les informations relatives aux balises CDL

# Function: getAttributesInHash
#	Organiser les attributs CDL présents dans la chaîne des attributs en table de hachage.
#
# Paramètres:
#	$attributesString - chaîne correspondant aux attributs CDL d'une balise CDL
sub getAttributesInHash #($attributesString)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne correspondant aux attributs CDL d'une balise CDL
	my ($attributesString) = @_;

	my $cdlTagAttributes;

	# Remplir un hash avec les attributs CDL trouvés
	$attributesString =~ s/\s(\S+?)=(\"|\')(.*?)\2/$cdlTagAttributes->{$1} = $3;/segi;

	return $cdlTagAttributes;
}

# Function: existOpenedCdlTag
#	Tester s'il existe la balise CDL ouvrante passée en argument dans le code HTML donné
#
# Paramètres:
#	$htmlCode - code HTML à parcourir
#	$cdlTag - balise CDL concernée
sub existOpenedCdlTag #($htmlCode, $cdlTag)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à parcourir
	# - balise CDL concernée
	my ($htmlCode, $cdlTag) = @_;

	# Si la balise ouvrante existe, on retourne vrai
	if ($htmlCode =~ m/<!--$cdlTag/si) {
		return 1;
	}

	# Sinon on retourne faux
	return 0;
}

# Function: getCdlTagInnerHtmlAndInfos
#	Fonction pour retourner toutes les occurences de la balise CDL en argument dans le code HTML fourni ainsi que ses informations (attributs)
#
# Paramètres:
#	$htmlCode - code HTML à parcourir
#	$cdlTag - balise CDL concernée
#	@orderedSortAttributes - attributs sur lesquels trier avec ordre de préférence
sub getCdlTagInnerHtmlAndInfos #($htmlCode, $cdlTag, @orderedSortAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à parcourir
	# - balise CDL concernée
	# - attributs sur lesquels trier avec ordre de préférence
	my ($htmlCode, $cdlTag, @orderedSortAttributes) = @_;

	# Tableau où seront stockées toutes les occurrences de la balise CDL
	my @cdlTagsInfos;

	# Détection de toutes les occurrences de la balise CDL, et création de l'objet correspondant à insérer dans le tableau des occurrences
	$htmlCode =~ s/<!--$cdlTag(\s[^<]*?)?-->(.*?)(<!--\/$cdlTag-->)/
		my $cdlTagInfosHash;
		my ($innerHtmlCode, @innerCdlTagsInfos);
		# Cet appel récursif permet de prendre la balise ouvrante la plus éloignée pour ne garder que les informations de celle là en ignorant celles des parentes.
		if (existOpenedCdlTag($2, $cdlTag)) {
			($innerHtmlCode, @innerCdlTagsInfos) = getCdlTagInnerHtmlAndInfos($2.$3, $cdlTag, @orderedSortAttributes);
			$cdlTagInfosHash = $innerCdlTagsInfos[0];
		} else {
			$cdlTagInfosHash->{'content'} = $2;
			$cdlTagInfosHash->{'attributes'} = getAttributesInHash($1);
			$innerHtmlCode = $2;
		}
		# On met l'occurrence (contenu et attributs) ainsi que le tableau des attributs de tri dans une table de hachage pour les passer en paramètre à la fonction d'insertion de l'occurrence dans le tableau des occurrences.
		my $tmp;
		$tmp->{'cdlTagsInfosArray'} = \@cdlTagsInfos;
		$tmp->{'sortAttributes'} = \@orderedSortAttributes;
		@cdlTagsInfos = insertCdlTagOccurence($cdlTagInfosHash, $tmp);
		$innerHtmlCode/seg;

	# Retourner la reference du tableau final
	return ($htmlCode, @cdlTagsInfos);
}

# Function: insertCdlTagOccurence
#	Insérer dans le tableau trié des occurences de la balise CDL, les infos passées en argument, selon les attributs CDL passés en argument
#
# Paramètres:
#	$cdlTagInfosHash - informations de la nouvelle occurence à insérer
#	$tmp->{'cdlTagsInfosArray'} - tableau des occurences de la balise CDL
#	$tmp->{'sortAttributes'} - attributs sur lesquels trier. Ces attributs doivent être mis dans l'ordre d'importance
sub insertCdlTagOccurence #($cdlTagInfosHash, $tmp)
{
	# Extraction des arguments dans une variable locale :
	# - informations de la nouvelle occurence à insérer
	# - tableau des occurences de la balise CDL
	# - attributs sur lesquels trier. Ces attributs doivent être mis dans l'ordre d'importance
	my ($cdlTagInfosHash, $tmp) = @_;

	# Récupération la référence sur le tableau où insérer et la référence sur le tableau des attributs CDL sur lesquels trier
	my $refCdlTagsInfos = $tmp->{'cdlTagsInfosArray'};
	my $refOrderedSortAttributes = $tmp->{'sortAttributes'};

	# Récupération des tableaux correspondants
	my @cdlTagsInfos = @$refCdlTagsInfos;
	my @orderedSortAttributes = @$refOrderedSortAttributes;

	# Tailles des 2 tableaux
	my $sizeCdlTagsInfos = scalar(@cdlTagsInfos);
	my $sizeOrderedSortAttributes = scalar(@orderedSortAttributes);

	# Position à laquelle insérer la nouvelle occurrence pour avoir un tableau trié
	# Initialisation à la taille du tableau par défaut (pour insérer en fin si l'occurrence à insérer $cdlTagInfosHash est la plus grande
	my $indexWhereInsert = $sizeCdlTagsInfos;
	# indice de l'attribut CDL qui est pris comme critère de tri (il augmente si l'attribut courant donne une égalité)
	my $indexAttributeToTest = 0;

	for (my $i = 0; $i < $sizeCdlTagsInfos; $i++) {
		# Tant que les attributs spécifiés dans l'ordre donne des égalités on recherche l'attribut de test
		for (my $j = 0; $j < $sizeOrderedSortAttributes; $j++) {
			if ($cdlTagInfosHash->{'attributes'}->{$orderedSortAttributes[$j]} != $cdlTagsInfos[$i]->{'attributes'}->{$orderedSortAttributes[$j]}) {
				$indexAttributeToTest = $j;
				last;
			}
		}
		# Dés qu'on trouve une occurrence supérieure, en vue de l'atribut de tri $orderedSortAttributes[$indexAttributeToTest],
		# c'est à l'indice courant qu'il faut insérer
		if (($cdlTagInfosHash->{'attributes'}->{$orderedSortAttributes[$indexAttributeToTest]} < $cdlTagsInfos[$i]->{'attributes'}->{$orderedSortAttributes[$indexAttributeToTest]})) {
			$indexWhereInsert = $i;
			last;
		}
	}

	# On décale le tableau jusqu'à la case où insérer
	for (my $i = $sizeCdlTagsInfos; $i > $indexWhereInsert; $i--) {
		$cdlTagsInfos[$i] = $cdlTagsInfos[$i-1];
	}

	# On insère la nouvelle occurrence à l'endroit approprié
	$cdlTagsInfos[$indexWhereInsert] = $cdlTagInfosHash;

	# Retourner le tableau mis à jour
	return @cdlTagsInfos;
}

# Function: parseAllNavsBlocs
#	Récupérer le contenu des balises cdlNav/cdlBloc et de les insérer dans la template générale de la page
#
# Paramètres:
#	$htmlCode - code HTML à parcourir
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$activateJavascript - option indiquant si on garde le javascript du site parsé en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site parsé
#	$displayImages - option indiquant si on garde les images du site parsé en version CDL
#	$displayObjects - option indiquant si on garde les objects du site parsé en version CDL
#	$displayApplets - option indiquant si on garde les applets du site parsé en version CDL
#	$parseTablesToList - option indiquant si on transforme les tableaux en liste à puce en version CDL
#	$activateFrames - option indiquant si on garde les frames/iframes du site parsé en version CDL
#	$siteId - identifiant du site parsé
#	$entirePageTemplateString - chaîne de la template générale de page où remplir la zone des navs/blocs
#	$cadreTemplateString - chaîne template où remplir un bloc
#	$cdlTag - nom de la balise CDL à parser
#	$templateMarker - marqueur à remplir
#	%sortAttributes - attributs CDL sur lesquels trier (et pour chaque attribut, 1 pour dire qu'on scinde les occurences qui ont la même valeur de cet attribut)
sub parseAllNavsBlocs #($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $entirePageTemplateString, $cadreTemplateString, $cdlTag, $templateMarker, %sortAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à parcourir
	# - url racine du site
	# - chemin vers la page en cours de traitement
	# - option indiquant si on garde le javascript du site parsé en version CDL
	# - option permettant de dire si on doit parser le javascript du site parsé
	# - option indiquant si on garde les images du site parsé en version CDL
	# - option indiquant si on garde les objects du site parsé en version CDL
	# - option indiquant si on garde les applets du site parsé en version CDL
	# - option indiquant si on transforme les tableaux en liste à puce en version CDL
	# - option indiquant si on garde les frames/iframes du site parsé en version CDL
	# - identifiant du site parsé
	# - chaîne de la template générale de page où remplir la zone des navs/blocs
	# - chaîne template où remplir un bloc
	# - nom de la balise CDL à parser
	# - marqueur à remplir
	# - attributs CDL sur lesquels trier (et pour chaque attribut, 1 pour dire qu'on scinde les occurences qui ont la même valeur de cet attribut)
	my ($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $entirePageTemplateString, $cadreTemplateString, $cdlTag, $templateMarker, %sortAttributes) = @_;

	# Chaîne de caractères où sera stockée tous les navs/blocs
	my $contents = "";

	# Tableau des informations sur les occurrences de la balise CDL
	my @cdlTagsInfos;

	# Récupération de toutes les occurrences des balises cdlNav/cdlBloc triées par ordre et partie
	my ($htmlCode, @cdlTagsInfos) = getCdlTagInnerHtmlAndInfos($htmlCode, $cdlTag, keys(%sortAttributes));

	if (@cdlTagsInfos) {
		my $content = parseAllHtml($cdlTagsInfos[0]->{'content'}, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId);
		my $existEqualAttributes = 0;

		# Génération de la chaîne contenant tous les blocs
		for (my $j = 1; $j < @cdlTagsInfos; $j++) {
			foreach my $attributeKey (keys(%sortAttributes)) {
				if ($sortAttributes{$attributeKey}) {
					if ($cdlTagsInfos[$j-1]->{'attributes'}->{$attributeKey} eq $cdlTagsInfos[$j]->{'attributes'}->{$attributeKey}) {
						$content .= parseAllHtml($cdlTagsInfos[$j]->{'content'}, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId)."\n";
						$existEqualAttributes = 1;
						last;
					}
				}
			}

			if (!$existEqualAttributes) {
				# Gestion des balises CDL exclure
				$content = parseExclure($content);

				# Gestion des balises CDL change/replace
				$content = parseChanges($content);

				# Gestion des balises CDL replace seules (raccourcis pour éviter les balises CDL change vides)
				$content = parseAloneReplaces($content);

				if ($content and $content !~ m/^\s*$/sgi) {
					$contents .= setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', $content)."\n";
				}
				$content = parseAllHtml($cdlTagsInfos[$j]->{'content'}, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId);
			} else {
				$existEqualAttributes = 0;
			}
		}
		if ($content and $content !~ m/^\s*$/sgi) {
			# Gestion des balises CDL exclure
			$content = parseExclure($content);

			# Gestion des balises CDL change/replace
			$content = parseChanges($content);

			# Gestion des balises CDL replace seules (raccourcis pour éviter les balises CDL change vides)
			$content = parseAloneReplaces($content);

			if ($content and $content !~ m/^\s*$/sgi) {
				$contents .= setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', $content)."\n";
			}
		}
	}

	# Remplissage de la template générale avec les blocs
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, $templateMarker, $contents);

	# Retourner le code HTML restant à parser ainsi que la template générale mise à jour
	return ($htmlCode, $entirePageTemplateString);
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;