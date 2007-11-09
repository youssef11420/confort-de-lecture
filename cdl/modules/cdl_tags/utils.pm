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

# File: utils.pm
#	Module de fonctions g�n�rale utiles pour r�cup�rer toutes les informations relatives aux balises CDL

# Function: getAttributesInHash
#	Organiser les attributs CDL pr�sents dans la cha�ne des attributs en table de hachage.
#
# Param�tres:
#	$attributesString - cha�ne correspondant aux attributs CDL d'une balise CDL
sub getAttributesInHash #($attributesString)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne correspondant aux attributs CDL d'une balise CDL
	my ($attributesString) = @_;

	my $cdlTagAttributes;

	# Remplir un hash avec les attributs CDL trouv�s
	$attributesString =~ s/\s(\S+?)=(\"|\')(.*?)\2/$cdlTagAttributes->{$1} = $3;/segi;

	return $cdlTagAttributes;
}

# Function: existOpenedCdlTag
#	Tester s'il existe la balise CDL ouvrante pass�e en argument dans le code HTML donn�
#
# Param�tres:
#	$htmlCode - code HTML � parcourir
#	$cdlTag - balise CDL concern�e
sub existOpenedCdlTag #($htmlCode, $cdlTag)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � parcourir
	# - balise CDL concern�e
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
# Param�tres:
#	$htmlCode - code HTML � parcourir
#	$cdlTag - balise CDL concern�e
#	@orderedSortAttributes - attributs sur lesquels trier avec ordre de pr�f�rence
sub getCdlTagInnerHtmlAndInfos #($htmlCode, $cdlTag, @orderedSortAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � parcourir
	# - balise CDL concern�e
	# - attributs sur lesquels trier avec ordre de pr�f�rence
	my ($htmlCode, $cdlTag, @orderedSortAttributes) = @_;

	# Tableau o� seront stock�es toutes les occurrences de la balise CDL
	my @cdlTagsInfos;

	# D�tection de toutes les occurrences de la balise CDL, et cr�ation de l'objet correspondant � ins�rer dans le tableau des occurrences
	$htmlCode =~ s/<!--$cdlTag(\s[^<]*?)?-->(.*?)(<!--\/$cdlTag-->)/
		my $cdlTagInfosHash;
		my ($innerHtmlCode, @innerCdlTagsInfos);
		# Cet appel r�cursif permet de prendre la balise ouvrante la plus �loign�e pour ne garder que les informations de celle l� en ignorant celles des parentes.
		if (existOpenedCdlTag($2, $cdlTag)) {
			($innerHtmlCode, @innerCdlTagsInfos) = getCdlTagInnerHtmlAndInfos($2.$3, $cdlTag, @orderedSortAttributes);
			$cdlTagInfosHash = $innerCdlTagsInfos[0];
		} else {
			$cdlTagInfosHash->{'content'} = $2;
			$cdlTagInfosHash->{'attributes'} = getAttributesInHash($1);
			$innerHtmlCode = $2;
		}
		# On met l'occurrence (contenu et attributs) ainsi que le tableau des attributs de tri dans une table de hachage pour les passer en param�tre � la fonction d'insertion de l'occurrence dans le tableau des occurrences.
		my $tmp;
		$tmp->{'cdlTagsInfosArray'} = \@cdlTagsInfos;
		$tmp->{'sortAttributes'} = \@orderedSortAttributes;
		@cdlTagsInfos = insertCdlTagOccurence($cdlTagInfosHash, $tmp);
		$innerHtmlCode/seg;

	# Retourner la reference du tableau final
	return ($htmlCode, @cdlTagsInfos);
}

# Function: insertCdlTagOccurence
#	Ins�rer dans le tableau tri� des occurences de la balise CDL, les infos pass�es en argument, selon les attributs CDL pass�s en argument
#
# Param�tres:
#	$cdlTagInfosHash - informations de la nouvelle occurence � ins�rer
#	$tmp->{'cdlTagsInfosArray'} - tableau des occurences de la balise CDL
#	$tmp->{'sortAttributes'} - attributs sur lesquels trier. Ces attributs doivent �tre mis dans l'ordre d'importance
sub insertCdlTagOccurence #($cdlTagInfosHash, $tmp)
{
	# Extraction des arguments dans une variable locale :
	# - informations de la nouvelle occurence � ins�rer
	# - tableau des occurences de la balise CDL
	# - attributs sur lesquels trier. Ces attributs doivent �tre mis dans l'ordre d'importance
	my ($cdlTagInfosHash, $tmp) = @_;

	# R�cup�ration la r�f�rence sur le tableau o� ins�rer et la r�f�rence sur le tableau des attributs CDL sur lesquels trier
	my $refCdlTagsInfos = $tmp->{'cdlTagsInfosArray'};
	my $refOrderedSortAttributes = $tmp->{'sortAttributes'};

	# R�cup�ration des tableaux correspondants
	my @cdlTagsInfos = @$refCdlTagsInfos;
	my @orderedSortAttributes = @$refOrderedSortAttributes;

	# Tailles des 2 tableaux
	my $sizeCdlTagsInfos = scalar(@cdlTagsInfos);
	my $sizeOrderedSortAttributes = scalar(@orderedSortAttributes);

	# Position � laquelle ins�rer la nouvelle occurrence pour avoir un tableau tri�
	# Initialisation � la taille du tableau par d�faut (pour ins�rer en fin si l'occurrence � ins�rer $cdlTagInfosHash est la plus grande
	my $indexWhereInsert = $sizeCdlTagsInfos;
	# indice de l'attribut CDL qui est pris comme crit�re de tri (il augmente si l'attribut courant donne une �galit�)
	my $indexAttributeToTest = 0;

	for (my $i = 0; $i < $sizeCdlTagsInfos; $i++) {
		# Tant que les attributs sp�cifi�s dans l'ordre donne des �galit�s on recherche l'attribut de test
		for (my $j = 0; $j < $sizeOrderedSortAttributes; $j++) {
			if ($cdlTagInfosHash->{'attributes'}->{$orderedSortAttributes[$j]} != $cdlTagsInfos[$i]->{'attributes'}->{$orderedSortAttributes[$j]}) {
				$indexAttributeToTest = $j;
				last;
			}
		}
		# D�s qu'on trouve une occurrence sup�rieure, en vue de l'atribut de tri $orderedSortAttributes[$indexAttributeToTest],
		# c'est � l'indice courant qu'il faut ins�rer
		if (($cdlTagInfosHash->{'attributes'}->{$orderedSortAttributes[$indexAttributeToTest]} < $cdlTagsInfos[$i]->{'attributes'}->{$orderedSortAttributes[$indexAttributeToTest]})) {
			$indexWhereInsert = $i;
			last;
		}
	}

	# On d�cale le tableau jusqu'� la case o� ins�rer
	for (my $i = $sizeCdlTagsInfos; $i > $indexWhereInsert; $i--) {
		$cdlTagsInfos[$i] = $cdlTagsInfos[$i-1];
	}

	# On ins�re la nouvelle occurrence � l'endroit appropri�
	$cdlTagsInfos[$indexWhereInsert] = $cdlTagInfosHash;

	# Retourner le tableau mis � jour
	return @cdlTagsInfos;
}

# Function: parseAllNavsBlocs
#	R�cup�rer le contenu des balises cdlNav/cdlBloc et de les ins�rer dans la template g�n�rale de la page
#
# Param�tres:
#	$htmlCode - code HTML � parcourir
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
#	$activateJavascript - option indiquant si on garde le javascript du site pars� en version CDL
#	$parseJavascript - option permettant de dire si on doit parser le javascript du site pars�
#	$displayImages - option indiquant si on garde les images du site pars� en version CDL
#	$displayObjects - option indiquant si on garde les objects du site pars� en version CDL
#	$displayApplets - option indiquant si on garde les applets du site pars� en version CDL
#	$parseTablesToList - option indiquant si on transforme les tableaux en liste � puce en version CDL
#	$activateFrames - option indiquant si on garde les frames/iframes du site pars� en version CDL
#	$siteId - identifiant du site pars�
#	$entirePageTemplateString - cha�ne de la template g�n�rale de page o� remplir la zone des navs/blocs
#	$cadreTemplateString - cha�ne template o� remplir un bloc
#	$cdlTag - nom de la balise CDL � parser
#	$templateMarker - marqueur � remplir
#	%sortAttributes - attributs CDL sur lesquels trier (et pour chaque attribut, 1 pour dire qu'on scinde les occurences qui ont la m�me valeur de cet attribut)
sub parseAllNavsBlocs #($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $entirePageTemplateString, $cadreTemplateString, $cdlTag, $templateMarker, %sortAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � parcourir
	# - url racine du site
	# - chemin vers la page en cours de traitement
	# - option indiquant si on garde le javascript du site pars� en version CDL
	# - option permettant de dire si on doit parser le javascript du site pars�
	# - option indiquant si on garde les images du site pars� en version CDL
	# - option indiquant si on garde les objects du site pars� en version CDL
	# - option indiquant si on garde les applets du site pars� en version CDL
	# - option indiquant si on transforme les tableaux en liste � puce en version CDL
	# - option indiquant si on garde les frames/iframes du site pars� en version CDL
	# - identifiant du site pars�
	# - cha�ne de la template g�n�rale de page o� remplir la zone des navs/blocs
	# - cha�ne template o� remplir un bloc
	# - nom de la balise CDL � parser
	# - marqueur � remplir
	# - attributs CDL sur lesquels trier (et pour chaque attribut, 1 pour dire qu'on scinde les occurences qui ont la m�me valeur de cet attribut)
	my ($htmlCode, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId, $entirePageTemplateString, $cadreTemplateString, $cdlTag, $templateMarker, %sortAttributes) = @_;

	# Cha�ne de caract�res o� sera stock�e tous les navs/blocs
	my $contents = "";

	# Tableau des informations sur les occurrences de la balise CDL
	my @cdlTagsInfos;

	# R�cup�ration de toutes les occurrences des balises cdlNav/cdlBloc tri�es par ordre et partie
	my ($htmlCode, @cdlTagsInfos) = getCdlTagInnerHtmlAndInfos($htmlCode, $cdlTag, keys(%sortAttributes));

	if (@cdlTagsInfos) {
		my $content = parseAllHtml($cdlTagsInfos[0]->{'content'}, $siteRootUrl, $pagePath, $activateJavascript, $parseJavascript, $displayImages, $displayObjects, $displayApplets, $parseTablesToList, $activateFrames, $siteId);
		my $existEqualAttributes = 0;

		# G�n�ration de la cha�ne contenant tous les blocs
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

				# Gestion des balises CDL replace seules (raccourcis pour �viter les balises CDL change vides)
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

			# Gestion des balises CDL replace seules (raccourcis pour �viter les balises CDL change vides)
			$content = parseAloneReplaces($content);

			if ($content and $content !~ m/^\s*$/sgi) {
				$contents .= setValueInTemplateString($cadreTemplateString, 'CADRE_CONTENT', $content)."\n";
			}
		}
	}

	# Remplissage de la template g�n�rale avec les blocs
	$entirePageTemplateString = setValueInTemplateString($entirePageTemplateString, $templateMarker, $contents);

	# Retourner le code HTML restant � parser ainsi que la template g�n�rale mise � jour
	return ($htmlCode, $entirePageTemplateString);
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;