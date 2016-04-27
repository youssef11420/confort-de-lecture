#!/usr/bin/perl

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

# File: audio.pl
#	Script pour générer en audio (mp3) le contenu de la page passée en paramétre (cette page étant préalablement sauvegardée sur le serveur dans le cache)

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use Cwd;

use Digest::SHA::PurePerl qw(sha1_hex);

use Encode;
use LWP::UserAgent;
use HTML::TreeBuilder;
%HTML::Tagset::optionalEndTag = map {; $_ => 1} qw();
%HTML::Tagset::boolean_attr = ();
%HTML::Tagset::isPhraseMarkup = map {; $_ => 1} qw(
	span abbr acronym q sub sup
	cite code em kbd samp strong var dfn strike
	b i u s tt
	a img br
	bdo
);
%HTML::Tagset::isHeadElement = map {; $_ => 1}
	qw(title base link meta isindex script);
%HTML::Tagset::isBodyElement = map {; $_ => 1} qw(
	h1 h2 h3 h4 h5 h6
	p div pre address blockquote

	iframe

	hr
	ol ul dir menu li
	dl dt dd
	ins del

	fieldset legend

	map area
	applet param object
	isindex script noscript
	table
	form
),
keys %HTML::Tagset::isFormElement,
keys %HTML::Tagset::isPhraseMarkup,
keys %HTML::Tagset::isTableElement;
%HTML::Tagset::isHeadOrBodyElement = map {; $_ => 1}
	qw(script noscript isindex style object map area param);
use HTML::Entities;

use lib '../modules/utils';
use constants;
use misc_utils;
use session;
use config_manager;


# Création de l'objet CGI
my $cgi = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";

my $siteId = "";
$thisCdlUrl =~ s/^(\/cdl)?\/audio(\-[^\/]*)?\/([^\/\?]*)\/?(.*)?$/$embeddedMode = $1;$siteId = urlDecode($3);/segi;

if (!$siteId) {
	if ($embeddedMode ne "") {
		my $siteDomain = $ENV{'SERVER_NAME'};
		$siteId = getSiteFromDomain($siteDomain);
	} else {
		$siteId = param('cdlid');
		if (!$siteId) {
			die "Aucun identifiant de site n'a été renseigné dans l'URL.\n";
			exit;
		}
	}
}

if (!existConfigDirectory($siteId)) {
	$siteId = param('cdlid');
	if (!$siteId) {
		die "Aucun identifiant de site n'a été renseigné en paramètre.\n";
		exit;
	}
	if (!existConfigDirectory($siteId)) {
		$siteId = "";
	}
}

# Inclusion du module extension général à tous les sites
require($cdlSitesConfigPath."default_override.pm");

# Inclusion du module extension spécifique au site s'il y en a un
if ($siteId ne "") {
	if (-e $cdlSitesConfigPath.$siteId."/override/main.pm") {
		require($cdlSitesConfigPath.$siteId."/override/main.pm");
	}
}

# Gestion des langues
my $language = loadFromSession($session, "language");
if (-e "../modules/dictionary/".$language.".pm") {
	require("../modules/dictionary/".$language.".pm");
} else {
	require("../modules/dictionary/fr.pm");
}

# Chargement de la configuration par défaut
my $defaultConfiguration = loadConfig($cdlSitesConfigPath."default.ini");

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

if ($enableGlossary eq "") {
	$enableGlossary = getConfig($defaultConfiguration, 'enableGlossary');
}
if ($utf8DecodeContent eq "") {
	$utf8DecodeContent = getConfig($defaultConfiguration, 'utf8DecodeContent');
}

my $fileName;
my $pageContent = "";

# Chargement de la template XML (format SSML) réservée à l'audio
my $audioTemplateString = loadConfig($cdlTemplatesPath."xml/audio.xml");
my $audioTextTemplateString = loadConfig($cdlTemplatesPath."xml/audio.txt");

# Chargement des paramétres utilisateur
my $voice = loadFromSession($session, 'voice');
if ($voice and !exists($unordoredVoices{$voice})) {
	$voice = $defaultVoice;
	editInSession($session, 'voice', $voice);
}
my $speed = loadFromSession($session, 'speed');

my $parametersString = "";
my $pageTitle = "page-en-audio";

my $deleteOptionTitle = 0;

if (param('cdltext')) {
	$pageContent = param('cdltext');
	$fileName = sha1_hex(($siteId ne "" ? $siteId."\n" : "").$pageContent);

	$pageContent =~ s/(&nbsp;| )+/ /sgi;

	if ($utf8DecodeContent ne "0") {
		$pageContent = decode("utf8", $pageContent);
	}

	my $root = HTML::TreeBuilder->new_from_content($pageContent);
	$pageContent = $root->as_HTML('<>&');

	if ($pageContent =~ m/<select( [^>]*)? id=\"cdlGhostSelect\"><option( [^>]*)? class=\"cdlDemoVoice\-([^\"]*)\"[^>]*>/si) {
		$voice = $3;
	}
	if ($pageContent =~ m/<select( [^>]*)? id=\"cdlGhostSelect\"><option( [^>]*)? class=\"cdlDemoSpeed\-([^\"]*)\"[^>]*>/si) {
		$speed = $3;
	}

	if ($pageContent =~ m/<select( [^>]*)? id=\"cdlGhostSelect\"><option( [^>]*)? class=\"cdlDemo(Voice|Speed)\-([^\"]*)\"[^>]*>/si) {
		$deleteOptionTitle = 1;
	}
	$pageContent =~ s/^<html><head><\/head><body><select( [^>]*)? id=\"cdlGhostSelect\"[^>]*><option([^>]*)>(.*?)<\/option><\/select><\/body><\/html>$/
		my %optionAttributes = getTagAttributes($2);
		($deleteOptionTitle ne 1 ? " Option de liste".($optionAttributes{'selected'} eq "selected" ? " sélectionnée" : "")." : " : "").($3 ? (length($optionAttributes{'title'}) > length($3) ? $optionAttributes{'title'} : $3) : "vide")."\n"
		/segi;
} else {
	# Récupérer le nom du fichier encrypté passé en paramétre
	$fileName = param('cdlcontent');
	if (!$fileName) {
		die "Aucun nom de fichier n'a été renseigné.\n";
		exit;
	}

	$parametersString = "_".loadFromSession($session, 'positionLocation')."_".loadFromSession($session, 'activateJavascript')."_".loadFromSession($session, 'activateFrames')."_".loadFromSession($session, 'displayImages')."_".loadFromSession($session, 'displayObjects')."_".loadFromSession($session, 'displayApplets')."_".loadFromSession($session, 'parseTablesToList');

	# Récupération du fichier correspondant à la page dans le cache
	my @files = glob($cdlContentCachePath.$fileName.$parametersString.".html");
	if (!@files) {
		die "Aucun nom de fichier ".$fileName." n'a été trouvé.\n";
		exit;
	}

	# lecture du contenu de la page dans le fichier de cache
	open(READER, "<", $files[0]) or die "Erreur récupération du cache : ".$fileName.".\n";
	while (<READER>) {
		$pageContent .= $_;
	}
	close(READER);
}

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
	elsif ($inputAttributes{'type'} eq "password") {" Champ crypté : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "color") {" Champ couleur : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "date") {" Champ date : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "datetime") {" Champ date et heure : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "datetime-local") {" Champ date et heure locale : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "email") {" Champ email : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "month") {" Champ mois : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "number") {" Champ nombre : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "range") {" Champ intervalle : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "search") {" Champ de recherche : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "tel") {" Champ téléphone : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "time") {" Champ heure : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "url") {" Champ lien : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	elsif ($inputAttributes{'type'} eq "week") {" Champ semaine : ".$labelsTexts{$inputAttributes{'id'}}.".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
	# Transformation des champs texte par le texte "Champ texte : {intitulé récupéré dans le label}, {en indiquant la valeur du champ s'il est prérempli}"
	elsif (!$inputAttributes{'type'} or $inputAttributes{'type'} ne "hidden") {" Champ d'édition : ".$labelsTexts{$inputAttributes{'id'}}.($inputAttributes{'value'} ? " : ".$inputAttributes{'value'} : "").".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."}
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
	" Champ d'édition multiligne : ".$labelsTexts{$textareaAttributes{'id'}}.($2 ? " : ".$2 : "").".__cdl_brk3000__ Pour sortir de ce champ, utilisez la touche échap."
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

# Si on est en train de lire une page intermédiaire (téléchargement d'un document, accés é une page protégée ou sortie de CDL), on supprime la balise object correspondant au lecteur mp3 puisqu'on ne veut pas le prendre en compte lors de la lecture
if (param('cdlpagetype') =~ m/document|exit|protected|error/si) {
	$pageContent =~ s/<object( [^>]*)?>(.*?)<\/object>//sgi;
}

$pageContent =~ s/&nbsp;/ /sgi;

# Génération d'un object qui contient l'arborescence HTML de la page é lire
my $root = HTML::TreeBuilder->new_from_content($pageContent);

# Mettre dans la template la langue avec laquelle sera lu le contenu
$audioTemplateString = setValueInTemplateString($audioTemplateString, 'LANGUAGE', $defaultLanguage);
$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'LANGUAGE', $defaultLanguage);
# Mettre dans la template la voix avec laquelle sera lu le contenu
$audioTemplateString = setValueInTemplateString($audioTemplateString, 'VOICE', $voice ? $voice : $defaultVoice);
$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'VOICE', $voice ? $voice : $defaultVoice);
# Mettre dans la template la vitesse é laquelle sera lu le contenu
$audioTemplateString = setValueInTemplateString($audioTemplateString, 'RATE', ($speed ne "" ? $speed : $defaultSpeed)*5);
$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'RATE', ($speed ne "" ? $speed : $defaultSpeed)*5);

# Si on est en train de lire une page intermédiaire (téléchargement d'un document, accés é une page protégée ou sortie de CDL), on met dans la template juste le contenu centrale de la page
# Sinon on met dans la template toutes les parties de la page (entéte, contenu principal, éléments de navigation, lien retour é l'accueil, lien modifier votre parametrage, et enfin la mention copyright Confort de lecture
if (param('cdlpagetype') =~ m/document|exit|protected|error/si) {
	my $pageContentBloc = $root->content->[1]->content->[1]->content->[0]->as_text;

	if ($enableGlossary ne "0") {
		$pageContentBloc = glossaryMain($pageContentBloc);
	}

	if ($pageContentBloc =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si) {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BLOCS_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'BLOCS_CONTAINER'), 'BLOCS', $pageContentBloc));
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BLOCS_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'BLOCS_CONTAINER'), 'BLOCS', $pageContentBloc));
	} else {
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BLOCS_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BLOCS_CONTAINER', "");
	}
	$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_TOP_CONTAINER', "");
	$audioTemplateString = setValueInTemplateString($audioTemplateString, 'NAVS_CONTAINER', "");
	$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_BOTTOM_CONTAINER', "");
	$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BACK_HOME_LINK_CONTAINER', "");
	$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_TOP_CONTAINER', "");
	$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'NAVS_CONTAINER', "");
	$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_BOTTOM_CONTAINER', "");
	$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BACK_HOME_LINK_CONTAINER', "");
} else {
	if (param('cdltext')) {
		my $textContent = $root->as_text;

		if ($textContent !~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si) {
			$textContent = "";
		}
		$textContent =~ s/>|</,/sgi;

		if ($enableGlossary ne "0") {
			$textContent = glossaryMain($textContent);
		}

		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_TOP_CONTAINER', "");
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BLOCS_CONTAINER', "");
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'NAVS_CONTAINER', "");
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_BOTTOM_CONTAINER', "");
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BACK_HOME_LINK_CONTAINER', "");
		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'TEXT_CONTENT', $textContent);
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_TOP_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BLOCS_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'NAVS_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_BOTTOM_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BACK_HOME_LINK_CONTAINER', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'TEXT_CONTENT', $textContent);
	} else {
		$pageTitle = $root->content->[0]->as_text;
		my $pageHeader = $root->content->[1]->content->[1]->content->[0]->content->[0]->content->[0]->as_text;
		my $pageContentBloc = $root->content->[1]->content->[1]->content->[0]->content->[0]->content->[1]->as_text;
		my $pageNav = $root->content->[1]->content->[1]->content->[0]->content->[0]->content->[2]->as_text;
		my $pageFooter = $root->content->[1]->content->[1]->content->[0]->content->[0]->content->[3]->as_text;
		my $backToHomeLink = $root->content->[1]->content->[1]->content->[0]->content->[0]->content->[4]->as_text;

		$pageTitle =~ s/>|</,/sgi;
		$pageTitle =~ tr/ŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ/SOZsozYYuAAAAAAACEEEEIIIIDNOOOOOOUUUUYsaaaaaaaceeeeiiiionoooooouuuuyy/;
		$pageTitle = lc($pageTitle);
		$pageTitle =~ s/[^\w\d_]/_/sgi;
		$pageTitle =~ s/_+/_/sgi;
		$pageTitle =~ s/(^_|_$)//sgi;
		$pageTitle =~ s/_confort_de_lecture$//sgi;

		$pageHeader =~ s/>|</,/sgi;

		if ($enableGlossary ne "0") {
			$pageHeader = glossaryMain($pageHeader);
			$pageContentBloc = glossaryMain($pageContentBloc);
			$pageNav = glossaryMain($pageNav);
			$pageFooter = glossaryMain($pageFooter);
			$backToHomeLink = glossaryMain($backToHomeLink);
		}

		if ($pageHeader =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si and param('cdldownload') ne "1") {
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
		if ($pageNav =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si and param('cdldownload') ne "1") {
			$audioTemplateString = setValueInTemplateString($audioTemplateString, 'NAVS_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'NAVS_CONTAINER'), 'NAVS', $pageNav));
			$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'NAVS_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'NAVS_CONTAINER'), 'NAVS', $pageNav));
		} else {
			$audioTemplateString = setValueInTemplateString($audioTemplateString, 'NAVS_CONTAINER', "");
			$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'NAVS_CONTAINER', "");
		}
		if ($pageFooter =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si and param('cdldownload') ne "1") {
			$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_BOTTOM_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'PAGE_BOTTOM_CONTAINER'), "PAGE_BOTTOM", $pageFooter));
			$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_BOTTOM_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'PAGE_BOTTOM_CONTAINER'), "PAGE_BOTTOM", $pageFooter));
		} else {
			$audioTemplateString = setValueInTemplateString($audioTemplateString, 'PAGE_BOTTOM_CONTAINER', "");
			$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'PAGE_BOTTOM_CONTAINER', "");
		}
		if ($backToHomeLink =~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ]/si and param('cdldownload') ne "1") {
			$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BACK_HOME_LINK_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTemplateString, 'BACK_HOME_LINK_CONTAINER'), 'BACK_HOME_LINK', $backToHomeLink));
			$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BACK_HOME_LINK_CONTAINER', setValueInTemplateString(getPartOfTemplateString($audioTextTemplateString, 'BACK_HOME_LINK_CONTAINER'), 'BACK_HOME_LINK', $backToHomeLink));
		} else {
			$audioTemplateString = setValueInTemplateString($audioTemplateString, 'BACK_HOME_LINK_CONTAINER', "");
			$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'BACK_HOME_LINK_CONTAINER', "");
		}

		$audioTemplateString = setValueInTemplateString($audioTemplateString, 'TEXT_CONTENT', "");
		$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'TEXT_CONTENT', "");
	}
}

# Transformation des codes temporaires pour les temporisations
$audioTemplateString =~ s/__cdl_brk(\d+)__//sgi;
$audioTextTemplateString =~ s/__cdl_brk(\d+)__//sgi;
# Alléger les pauses

# Appel du service audio, qui retourne le texte transformé en mp3

# Le type mime de sortie de ce script est audio/mpeg
#print "Content-type:text/plain; charset=utf-8\n\n";
print "Content-type:audio/mpeg\n";
print "Content-disposition:attachment;filename=".$pageTitle.".mp3\n\n";

if ($ttsMode eq "vaas" or $embeddedMode ne "") {
	if ($ttsMode eq "sdk" && $embeddedMode ne "") {
		$ttsServerName = "recette.cdl.lnet.fr";
		$ttsPort = "80";
		$ttsUri = "/audio-text/".($siteId ne "" ? $siteId : "default")."/";
		$ttsDefaultQueryString = "";
		$ttsTextParamName = "cdltext";
		$ttsVoiceParamName = "";
	}

	use Socket;

	socket(SOCK, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
	my $sin = sockaddr_in($ttsPort, inet_aton($ttsServerName));
	connect(SOCK, $sin) or die "Connect failed: $!\n";

	my $oldFh = select(SOCK);
	$| = 1;
	select($oldFh);

	my $audioParametersTextString = $ttsDefaultQueryString.($ttsVoiceParamName ? "&".$ttsVoiceParamName."=".($voice ? $voice : $defaultVoice) : "")."&".$ttsTextParamName."=".urlEncode($audioTextTemplateString);

	print SOCK "POST ".$ttsUri." HTTP/1.0\nHost: $ttsServerName:$ttsPort\nUser-Agent: Mozilla/5.0 (Windows NT 5.1) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.122 Safari/534.30\nContent-Length: ".length($audioParametersTextString)."\nContent-Type: application/x-www-form-urlencoded\nTransfer-Encoding: chunked\n\n".$audioParametersTextString."\n";
	my $header = <SOCK>;

	if ($header !~ m/200|OK/) {
		use LWP::Simple;
		print get("http://".$ttsServerName.$ttsUri."?".$audioParametersTextString);
	} else {
		while($header = <SOCK>) {
			chomp;
			last unless(m/\S/);
		}

		my $content;
		while(read(SOCK, $content, 512)) {
			print $content;
		}
	}
	close SOCK;
} elsif ($ttsMode eq "sdk") {
	# Création du fichier texte, contenant toutes les informations nécessaires à la synthèse vocale :
	# - serveur de synthèse vocale, où seront traités les textes et où le son audio sera généré
	# - la voix avec laquelle lire le contenu (soit choisi par l'utilisateur soit la voix définir par défaut dans : <constants.pm>
	# - Contenu SSML à lire
	my $fileSize = -s $cdlAudioCachePath."infos_".$fileName."_".($voice ? $voice : $defaultVoice)."_".(($speed ne "" ? $speed : $defaultSpeed)*2).".mp3";
	if (-e $cdlAudioCachePath."infos_".$fileName.".mp3" and $fileSize > 626) {
		system("cat ".$cdlAudioCachePath."infos_".$fileName."_".($voice ? $voice : $defaultVoice)."_".(($speed ne "" ? $speed : $defaultSpeed)*2).".mp3");
	} else {
		open(WRITER, ">", $cdlAudioCachePath."infos_".$fileName.".txt") || die "Erreur d'ouverture du fichier : infos_".$fileName.".txt.\n";
		print WRITER $audioTextTemplateString;
		close(WRITER);

		my $ttsPath = $ttsUri;
		$ttsPath =~ s/^(.*\/)([^\/]*)/$1/sgi;
		$| = 1;
		use IO::Handle;
		STDOUT->autoflush(1);

		my $command = "export LD_LIBRARY_PATH=".$ttsPath." ; ".$ttsUri." ".$ttsDefaultQueryString.($ttsVoiceParamName ? " -".$ttsVoiceParamName." ".($voice ? $voice : $defaultVoice) : "").($ttsRateParamName ? " -".$ttsRateParamName." ".(($speed ne "" ? $speed : $defaultSpeed)*2) : "")." -".$ttsTextParamName." ".$cdlAudioCachePath."infos_".$fileName.".txt -o stdout | lame --quiet -r -h -b 64 -m m -s 22 - - | tee ".$cdlAudioCachePath."infos_".$fileName."_".($voice ? $voice : $defaultVoice)."_".(($speed ne "" ? $speed : $defaultSpeed)*2).".mp3";

		system($command);
	}
}

exit;