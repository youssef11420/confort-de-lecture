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

# File: misc_audio.pm
#	Module de fonction utilitaires de manipulation et nettoyage pour la vocalisation

# Function: htmlToTts
#	Transformation de HTML en texte à vocaliser
#
# Paramètres:
#	$pageContent - contenu HTML à transformer en texte à vocaliser
#	$deleteOptionTitle - booléen indiquant si les options sélectionnées des listes déroulantes doivent être préfixée par "Option de liste sélectionnée : "
sub htmlToTts #($pageContent, $deleteOptionTitle)
{
	my ($pageContent, $deleteOptionTitle) = @_;

	# Récupération de tous les labels de la page
	my %labelsTexts = getLabelsForId($pageContent);
	# Suppression de tous les labels puisqu'ils sont déjé récupérés ci-dessus, et seront donc utilisés directement lors de la lecture des différents champs qui leur sont associés
	$pageContent =~ s/<label( [^>]*)?>.*?<\/label>//sgi;

	# Espacement des lettres dans un acronyme
	$pageContent =~ s/(<abbr( [^>]*)?>)(([A-Z]\.)+)(<\/abbr>)/$1.addSpaceToAcronym($3).$5/segi;

	# Transformation des liens images par le texte "Lien : {alt de l'image ou alt du lien ou title de l'image ou title du lien}". C'est le plus long de ces 4 attributs qui est mis
	my %linkAttributes;
	my %imgAttributes;
	$pageContent =~ s/<a( [^>]*)?>\s*<img( [^>]*)?>\s*<\/a>/
		%linkAttributes = getTagAttributes($1);
		%imgAttributes = getTagAttributes($2);
		defined $linkAttributes{'href'} and $imgAttributes{'alt'} ? " Lien : ".(length($imgAttributes{'title'}) > length($imgAttributes{'alt'}) ? (length($linkAttributes{'title'}) > length($imgAttributes{'title'}) ? $linkAttributes{'title'} : $imgAttributes{'title'}) : (length($linkAttributes{'title'}) > length($imgAttributes{'alt'}) ? $linkAttributes{'title'} : $imgAttributes{'alt'})).".__cdl_brk500__" : ""
		/segi;

	# Transformation des liens par le texte "Lien : {intitulé du lien (son contenu) ou son title}". C'est le plus long de ces 2 attributs qui est mis
	$pageContent =~ s/<img( [^>]*)?>/
		%imgAttributes = getTagAttributes($1);
		$imgAttributes{'alt'} or $imgAttributes{'title'} ? " ".(length($imgAttributes{'title'}) > length($imgAttributes{'alt'}) ? $imgAttributes{'title'} : $imgAttributes{'alt'}) : ""
		/segi;

	# Transformation des liens par le texte "Lien : {intitulé du lien (son contenu) ou son title}". C'est le plus long de ces 2 attributs qui est mis
	$pageContent =~ s/<a( [^>]*)?>(.*?)<\/a>/
		%linkAttributes = getTagAttributes($1);
		defined $linkAttributes{'href'} ? " Lien : ".(length($linkAttributes{'title'}) > length(HTML::TreeBuilder->new_from_content($2)->as_text) ? $linkAttributes{'title'} : $2).".__cdl_brk500__" : ""
		/segi;

	# Transformation des liens dans les images map par le texte "Lien : {alt ou title du lien}". C'est le plus long de ces 2 attributs qui est mis
	$pageContent =~ s/<area( [^>]*)?>/
		my %areaAttributes = getTagAttributes($1);
		defined $areaAttributes{'href'} and $areaAttributes{'alt'} ? " Lien : ".(length($areaAttributes{'title'}) > length($areaAttributes{'alt'}) ? $areaAttributes{'title'} : $areaAttributes{'alt'}).".__cdl_brk500__" : ""
		/segi;

	# Transformation des boutons (normal, de validation et de réinitialisation) par le texte "Bouton (validation, réinitialisation) : {intitulé du bouton (son contenu) ou son title}". C'est le plus long de ces 2 attributs qui est mis
	$pageContent =~ s/<button( [^>]*)?>(.*?)<\/button>/
		my %buttonAttributes = getTagAttributes($1);
		" Bouton".($buttonAttributes{'type'} eq "reset" ? " réinitialisation" : (!$buttonAttributes{'type'} or $buttonAttributes{'type'} eq "submit" ? " validation" : ""))." : ".(length($buttonAttributes{'title'}) > length(HTML::TreeBuilder->new_from_content($2)->as_text) ? $buttonAttributes{'title'} : $2).".__cdl_brk500__"
		/segi;

	# Transformation des boutons (normal, de validation et de réinitialisation) et champs de formulaire par leurs textes appropriés
	$pageContent =~ s/<input( [^>]*)?>/
		my %inputAttributes = getTagAttributes($1);
		# Transformation des boutons (normal, de validation et de réinitialisation) par le texte "Bouton (validation, réinitialisation) : {intitulé du bouton (son contenu)}"
		if ($inputAttributes{'type'} eq "button") {" Bouton : ".(length($inputAttributes{'title'}) > length($inputAttributes{'value'}) ? $inputAttributes{'title'} : $inputAttributes{'value'}).".__cdl_brk500__"}
		elsif ($inputAttributes{'type'} eq "reset") {" Bouton réinitialisation : ".(length($inputAttributes{'title'}) > length($inputAttributes{'value'}) ? $inputAttributes{'title'} : $inputAttributes{'value'}).".__cdl_brk500__"}
		elsif ($inputAttributes{'type'} eq "submit") {" Bouton validation : ".(length($inputAttributes{'title'}) > length($inputAttributes{'value'}) ? $inputAttributes{'title'} : $inputAttributes{'value'}).".__cdl_brk500__"}
		elsif ($inputAttributes{'type'} eq "image") {" Bouton validation : ".(length($inputAttributes{'title'}) > length($inputAttributes{'alt'}) ? $inputAttributes{'title'} : $inputAttributes{'alt'}).".__cdl_brk500__"}
		# Transformation des cases é cocher par le texte "Case à cocher : {intitulé récupéré dans le label}, {en indiquant si la case est précochée}"
		elsif ($inputAttributes{'type'} eq "checkbox") {" Case à cocher : ".$labelsTexts{$inputAttributes{'id'}}.", ".($inputAttributes{'checked'} eq "checked" ? "cochée" : "").".__cdl_brk500__"}
		# Transformation des boutons radio par le texte "Bouton radio : {intitulé récupéré dans le label}, {en indiquant si le bouton radio est précoché}"
		elsif ($inputAttributes{'type'} eq "radio") {" Bouton radio : ".$labelsTexts{$inputAttributes{'id'}}.", ".($inputAttributes{'checked'} eq "checked" ? "coché" : "").".__cdl_brk500__"}
		# Transformation des champs d'upload de fichiers par le texte "Champ fichier : {intitulé récupéré dans le label}"
		elsif ($inputAttributes{'type'} eq "file") {" Champ fichier : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk500__"}
		# Transformation des champs cryptés (masqués avec des *) par le texte "Champ crypté : {intitulé récupéré dans le label}"
		elsif ($inputAttributes{'type'} eq "password") {" Champ crypté : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "color") {" Champ couleur : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "date") {" Champ date : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "datetime") {" Champ date et heure : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "datetime-local") {" Champ date et heure locale : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "email") {" Champ email : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "month") {" Champ mois : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "number") {" Champ nombre : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "range") {" Champ intervalle : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "search") {" Champ de recherche : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "tel") {" Champ téléphone : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "time") {" Champ heure : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "url") {" Champ lien : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		elsif ($inputAttributes{'type'} eq "week") {" Champ semaine : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		# Transformation des champs texte par le texte "Champ texte : {intitulé récupéré dans le label}, {en indiquant la valeur du champ s'il est prérempli}"
		elsif (!$inputAttributes{'type'} or $inputAttributes{'type'} ne "hidden") {" Champ d'édition : ".$labelsTexts{$inputAttributes{'id'}}.($inputAttributes{'value'} ? " : ".$inputAttributes{'value'} : "").".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."}
		/segi;

	# Transformation des listes déroulantes par le texte "Liste déroulante : {intitulé récupéré dans le label}"
	$pageContent =~ s/<select( [^>]*)?>(.*?)<\/select>/
		my %selectAttributes = getTagAttributes($1);
		" Liste déroulante : ".$labelsTexts{$selectAttributes{'id'}}.":\n".$2."."
		/segi;

	# Transformation des options de liste déroulante par le texte "Option de liste {en indiquant si l'option est préselectionnée} : {intitulé de l'option (son contenu), en précisant si l'option est vide}"
	$pageContent =~ s/<option( [^>]*)?>(.*?)<\/option>/
		my %optionAttributes = getTagAttributes($1);
		$optionAttributes{'selected'} eq "selected" ? ($deleteOptionTitle ne 1 ? " Option de liste sélectionnée : " : "").($2 ? (length($optionAttributes{'title'}) > length($2) ? $optionAttributes{'title'} : $2) : "vide") : ""
		/segi;

	# Transformation des zones de saisie multiligne par le texte "Zone de saisie multiligne {intitulé récupéré dans le label}, {en indiquant la valeur de la zone si elle est préremplie}"
	$pageContent =~ s/<textarea( [^>]*)?>(.*?)<\/textarea>/
		my %textareaAttributes = getTagAttributes($1);
		" Champ d'édition multiligne : ".$labelsTexts{$textareaAttributes{'id'}}.($2 ? " : ".$2 : "").".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échappe."
		/segi;

	# Transformation des légendes des fieldset dans les formulaires par le texte "Légende : {intitulé de la légende (son contenu)}"
	$pageContent =~ s/<legend( [^>]*)?>(.*?)<\/legend>/ " Légende : ".$2.".\n"/segi;

	# Marquage d'un temps d'arrét aprés chaque item
	$pageContent =~ s/(<li( [^>]*)?>(.*?)<\/li>)/$1." "/segi;
	# Transformation des termes définis dans des listes de définitions par le texte "Terme défini : {intitulé du terme (son contenu)}"
	$pageContent =~ s/(<dt( [^>]*)?>(.*?)<\/dt>)/ " Terme défini : ".$1.".__cdl_brk200__"/segi;
	# Transformation des définitions dans des listes de définitions par le texte "Définition terme : {définition du terme (contenu de la définition)}"
	$pageContent =~ s/(<dd( [^>]*)?>(.*?)<\/dd>)/ " Définition terme : ".$1.".__cdl_brk200__"/segi;
	# Ajout d'un point aprés chaque élément "bloc" pour s'assurer qu'il y aura une pause de lecture é la fin d'un paragraphe ou d'un div
	$pageContent =~ s/(<\/(p|div|address|pre|blockquote|ins|del)>)/ ".".$1/segi;
	# Remplacement des retours é la ligne HTML (balises br) par des points pour marquer un pause.
	$pageContent =~ s/<br( [^>]*)?>/ ".\n"/segi;
	# Transformation des zones de codes par le texte "Zone de code : {contenu de la zone code}"
	$pageContent =~ s/<code( [^>]*)?>(.*?)<\/code>/" Zone de code :\n".$2.".__cdl_brk200__"/segi;
	# Transformation des citations par le texte "Citation : {contenu de la citation}"
	$pageContent =~ s/<cite( [^>]*)?>(.*?)<\/cite>/" Citation :\n".$2.".__cdl_brk200__"/segi;
	# Transformation des cellules de tableaux par le texte "Cellule : {contenu de la cellule}"
	$pageContent =~ s/<td( [^>]*)?>(.*?)<\/td>/" Cellule :\n".$2."__cdl_brk200__"/segi;
	# Transformation des entétes de cellules de tableaux par le texte "Entéte de cellule : {contenu de l'entéte de cellule}"
	$pageContent =~ s/<th( [^>]*)?>(.*?)<\/th>/" Entête de cellule :\n".$2."__cdl_brk200__"/segi;

	$pageContent =~ s/&nbsp;/ /sgi;

	# On retourne l'URL encodée
	return $pageContent;
}

# Function: prepareAudioTemplates
#	Préparation des templates utilisées par la synthèse vocale
#
# Paramètres:
#	$htmlRoot - objet contenant l'arborescence HTML
#	$siteId - identifiant su site parsé
#	$enableGlossary - booléen indiquant si le glossaire est activé sur ce site
#	$audioTemplateString - template contenant le contenu HTML à vocaliser
#	$audioTextTemplateString - template contenant le texte à vocaliser
#	$isDownload - booléen indiquant si le contenu audio est à télécharger
sub prepareAudioTemplates #($pageContent, $siteId, $enableGlossary, $audioTemplateString, $audioTextTemplateString, $isDownload)
{
	my ($htmlRoot, $siteId, $enableGlossary, $audioTemplateString, $audioTextTemplateString, $isDownload) = @_;

	my $pageHeader = $htmlRoot->content->[1]->content->[1]->content->[0]->content->[0]->content->[0]->as_text;
	my $pageContentBloc = $htmlRoot->content->[1]->content->[1]->content->[0]->content->[0]->content->[1]->as_text;
	my $pageNav = $htmlRoot->content->[1]->content->[1]->content->[0]->content->[0]->content->[2]->as_text;
	my $pageFooter = $htmlRoot->content->[1]->content->[1]->content->[0]->content->[0]->content->[3]->as_text;
	my $backToHomeLink = $htmlRoot->content->[1]->content->[1]->content->[0]->content->[0]->content->[4]->as_text;

	$pageHeader =~ s/>|</,/sgi;

	if ($enableGlossary ne "0") {
		$pageHeader = glossaryMain($pageHeader, $siteId);
		$pageContentBloc = glossaryMain($pageContentBloc, $siteId);
		$pageNav = glossaryMain($pageNav, $siteId);
		$pageFooter = glossaryMain($pageFooter, $siteId);
		$backToHomeLink = glossaryMain($backToHomeLink, $siteId);
	}

	if ($pageHeader =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si and $isDownload ne "1") {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_TOP_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'PAGE_TOP_CONTAINER'), "PAGE_TOP", $pageHeader));
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_TOP_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'PAGE_TOP_CONTAINER'), "PAGE_TOP", $pageHeader));
	} else {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_TOP_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_TOP_CONTAINER', "");
	}
	if ($pageContentBloc =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si) {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BLOCS_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'BLOCS_CONTAINER'), 'BLOCS', $pageContentBloc));
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BLOCS_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'BLOCS_CONTAINER'), 'BLOCS', $pageContentBloc));
	} else {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BLOCS_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BLOCS_CONTAINER', "");
	}
	if ($pageNav =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si and $isDownload ne "1") {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'NAVS_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'NAVS_CONTAINER'), 'NAVS', $pageNav));
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'NAVS_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'NAVS_CONTAINER'), 'NAVS', $pageNav));
	} else {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'NAVS_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'NAVS_CONTAINER', "");
	}
	if ($pageFooter =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si and $isDownload ne "1") {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_BOTTOM_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'PAGE_BOTTOM_CONTAINER'), "PAGE_BOTTOM", $pageFooter));
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_BOTTOM_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'PAGE_BOTTOM_CONTAINER'), "PAGE_BOTTOM", $pageFooter));
	} else {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_BOTTOM_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_BOTTOM_CONTAINER', "");
	}
	if ($backToHomeLink =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si and $isDownload ne "1") {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BACK_HOME_LINK_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'BACK_HOME_LINK_CONTAINER'), 'BACK_HOME_LINK', $backToHomeLink));
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BACK_HOME_LINK_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'BACK_HOME_LINK_CONTAINER'), 'BACK_HOME_LINK', $backToHomeLink));
	} else {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BACK_HOME_LINK_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BACK_HOME_LINK_CONTAINER', "");
	}

	$audioTemplateString = setValueInTemplateString($audioTemplateString, 'TEXT_CONTENT', "");
	$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'TEXT_CONTENT', "");

	# On retourne l'URL encodée
	return ($audioTemplateString, $audioTextTemplateString);
}

# Function: vocalize
#	Vocalisation du texte selon la configuration et les choix de l'internaute
#
# Paramètres:
#	$fileName - nom du fichier contenant le texte à vocaliser
#	$siteId - identifiant su site parsé
#	$defaultConfiguration - booléen indiquant si le glossaire est activé sur ce site
#	$voice - la voix sélectionnée par l'internaute
#	$speed - la vitesse de lecture sélectionnée par l'internaute
#	$audioTextTemplateString - template contenant le texte à vocaliser
sub vocalize #($fileName, $siteId, $defaultConfiguration, $voice, $speed, $audioTextTemplateString)
{
	my ($fileName, $siteId, $defaultConfiguration, $voice, $speed, $audioTextTemplateString) = @_;

	my $audioContent = "";

	my ($ttsMode, $ttsServerName, $ttsPort, $ttsUri, $ttsDefaultQueryString, $ttsVoiceParamName, $ttsTextParamName, $ttsRateParamName, $enableGlossary, $utf8DecodeContent) = ("", "", "", "", "", "", "", "", "", "");
	if ($siteId ne "") {
		my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
		$ttsMode = getConfig($siteConfiguration, 'ttsMode');
		$ttsServerName = getConfig($siteConfiguration, 'ttsServerName');
		$ttsPort = getConfig($siteConfiguration, 'ttsPort');
		$ttsUri = getConfig($siteConfiguration, 'ttsUri');
		$ttsDefaultQueryString = getConfig($siteConfiguration, 'ttsDefaultQueryString');
		$ttsVoiceParamName = getConfig($siteConfiguration, 'ttsVoiceParamName');
		$ttsTextParamName = getConfig($siteConfiguration, 'ttsTextParamName');
		$ttsRateParamName = getConfig($siteConfiguration, 'ttsRateParamName');

		$enableGlossary = getConfig($siteConfiguration, 'enableGlossary');
		$utf8DecodeContent = getConfig($siteConfiguration, 'utf8DecodeContent');
	}
	if ($ttsMode eq "") {
		$ttsMode = getConfig($defaultConfiguration, 'ttsMode');
	}
	if ($ttsServerName eq "") {
		$ttsServerName = getConfig($defaultConfiguration, 'ttsServerName');
	}
	if ($ttsPort eq "") {
		$ttsPort = getConfig($defaultConfiguration, 'ttsPort');
	}
	if ($ttsUri eq "") {
		$ttsUri = getConfig($defaultConfiguration, 'ttsUri');
	}
	if ($ttsDefaultQueryString eq "") {
		$ttsDefaultQueryString = getConfig($defaultConfiguration, 'ttsDefaultQueryString');
	}
	if ($ttsVoiceParamName eq "") {
		$ttsVoiceParamName = getConfig($defaultConfiguration, 'ttsVoiceParamName');
	}
	if ($ttsTextParamName eq "") {
		$ttsTextParamName = getConfig($defaultConfiguration, 'ttsTextParamName');
	}
	if ($ttsRateParamName eq "") {
		$ttsRateParamName = getConfig($defaultConfiguration, 'ttsRateParamName');
	}


	# Création du fichier texte, contenant toutes les informations nécessaires à la synthèse vocale :
	# - serveur de synthèse vocale, où seront traités les textes et où le son audio sera généré
	# - la voix avec laquelle lire le contenu (soit choisi par l'utilisateur soit la voix définir par défaut dans : <constants.pm>
	# - Contenu SSML à lire
	my $fileAudio = $cdlAudioCachePath."sound_".$fileName."_".($voice ? $voice : $defaultVoice)."_".(($speed ne "" ? $speed : $defaultSpeed)*2).".mp3";
	my $fileSize = -s $fileAudio;
	if (-e $fileAudio and $fileSize > 626) {
		$audioContent = readpipe("cat ".$fileAudio);
	} else {
		if ($ttsMode eq "vaas") {
			my $audioParametersTextString = $ttsDefaultQueryString.($ttsVoiceParamName ? "&".$ttsVoiceParamName."=".($voice ? $voice : $defaultVoice) : "").($ttsRateParamName ? "&".$ttsRateParamName."=".($speed ? $speed : $defaultSpeed) : "")."&".$ttsTextParamName."=".urlEncode($audioTextTemplateString);

			my $ua = LWP::UserAgent->new;
			$ua->agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.89 Safari/537.36');

			my $req = HTTP::Request->new(POST => $ttsServerName.":".$ttsPort.$ttsUri);
			$req->header('Content-Type' => 'application/x-www-form-urlencoded');
			$req->header('Content-Length' => length($audioParametersTextString));
			$req->header('Transfer-Encoding' => 'chunked');

			$req->content($audioParametersTextString);

			my $resp = $ua->request($req);

			if ($resp->is_success) {
				$audioContent = $resp->decoded_content;
			} else {
				$audioContent = get("http://".$ttsServerName.$ttsUri."?".$audioParametersTextString);
			}

			open(WRITER, ">", $fileAudio) || die "Erreur d'ouverture du fichier : ".$fileAudio.".\n";
			print WRITER ($audioContent);
			close(WRITER);
		} elsif ($ttsMode eq "sdk") {
			open(WRITER, ">", $cdlAudioCachePath."infos_".$fileName.".txt") || die "Erreur d'ouverture du fichier : infos_".$fileName.".txt.\n";
			print WRITER ($audioTextTemplateString);
			close(WRITER);

			my $ttsPath = $ttsUri;
			$ttsPath =~ s/^(.*\/)([^\/]*)/$1/sgi;
			$| = 1;
			use IO::Handle;
			STDOUT->autoflush(1);

			my $command = "export LD_LIBRARY_PATH=".$ttsPath." ; ".$ttsUri." ".$ttsDefaultQueryString.($ttsVoiceParamName ? " -".$ttsVoiceParamName." ".($voice ? $voice : $defaultVoice) : "").($ttsRateParamName ? " -".$ttsRateParamName." ".(($speed ne "" ? $speed : $defaultSpeed)*2) : "")." -".$ttsTextParamName." ".$cdlAudioCachePath."infos_".$fileName.".txt -o stdout | lame --quiet -r -h -b 64 -m m -s 22 - - | tee ".$fileAudio;

			$audioContent = readpipe($command);
		}
	}

	return $audioContent;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;
