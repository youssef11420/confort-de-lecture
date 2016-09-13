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

use LWP::Simple qw/get/;

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

use lib '../modules/audio';
use misc_audio;

# Création de l'objet CGI
my $cgi = CGI->new();

# Création de la session et récupération de l'objet de gestion de la session
my $session = createOrGetSession($cgi);

my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";

my $siteId = "";
$thisCdlUrl =~ s/^((\/cdl)?\/audio(\-[^\/]*)?\/([^\/\?]*)\/?(.*)?)$/$embeddedMode = $2;$siteId = urlDecode($4); $1/segi;

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

my ($enableGlossary, $utf8DecodeContent) = ("", "", "", "", "", "", "", "", "", "");

if ($siteId ne "") {
	my $siteConfiguration = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	$enableGlossary = getConfig($siteConfiguration, 'enableGlossary');
	$utf8DecodeContent = getConfig($siteConfiguration, 'utf8DecodeContent');
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
my $voice = param('cdlvoice');
if (!$voice) {
	$voice = loadFromSession($session, 'voice');
}
if ($voice and !exists($unordoredVoices{$voice})) {
	$voice = $defaultVoice;
	editInSession($session, 'voice', $voice);
}

my $speed = param('cdlspeed');
if (!$speed) {
	$speed = loadFromSession($session, 'speed');
}

my $parametersString = "";

my $deleteOptionTitle = 0;

if (param('cdltext') ne "") {
	$pageContent = param('cdltext');
	$fileName = sha1_hex(($siteId ne "" ? $siteId."\n" : "").$pageContent);

	if ($thisCdlUrl !~ m/^(\/cdl)?\/audio-text-letter/si) {
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
	}
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

my $root;
if ($thisCdlUrl !~ m/^(\/cdl)?\/audio-text-letter/si) {
	$pageContent = htmlToTts($pageContent, $deleteOptionTitle);

	# Génération d'un object qui contient l'arborescence HTML de la page é lire
	$root = HTML::TreeBuilder->new_from_content($pageContent);

	# Mettre dans la template la langue avec laquelle sera lu le contenu
	$audioTemplateString = setValueInTemplateString($audioTemplateString, 'LANGUAGE', $defaultLanguage);
	$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'LANGUAGE', $defaultLanguage);
	# Mettre dans la template la voix avec laquelle sera lu le contenu
	$audioTemplateString = setValueInTemplateString($audioTemplateString, 'VOICE', $voice ? $voice : $defaultVoice);
	$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'VOICE', $voice ? $voice : $defaultVoice);
	# Mettre dans la template la vitesse é laquelle sera lu le contenu
	$audioTemplateString = setValueInTemplateString($audioTemplateString, 'RATE', ($speed ne "" ? $speed : $defaultSpeed)*5);
	$audioTextTemplateString = setValueInTemplateString($audioTextTemplateString, 'RATE', ($speed ne "" ? $speed : $defaultSpeed)*5);
}

# Si on est en train de lire une page intermédiaire (téléchargement d'un document, accés é une page protégée ou sortie de CDL), on met dans la template juste le contenu centrale de la page
# Sinon on met dans la template toutes les parties de la page (entéte, contenu principal, éléments de navigation, lien retour é l'accueil, lien modifier votre parametrage, et enfin la mention copyright Confort de lecture
if (param('cdlpagetype') =~ m/document|exit|protected|error/si) {
	my $pageContentBloc = $root->content->[1]->content->[1]->content->[0]->as_text;

	if ($enableGlossary ne "0") {
		$pageContentBloc = glossaryMain($pageContentBloc, $siteId);
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
	if (param('cdltext') ne "") {
		my $textContent = $root ? $root->as_text : $pageContent;

		if ($textContent !~ m/[\w\dŠŒŽšœžŸ¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ²]/si) {
			$textContent = "";
		}
		$textContent =~ s/>|</,/sgi;

		if ($enableGlossary ne "0") {
			$textContent = glossaryMain($textContent, $siteId);
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
		($audioTemplateString, $audioTextTemplateString) = prepareAudioTemplates($root, $siteId, $enableGlossary, $audioTemplateString, $audioTextTemplateString, param('cdldownload'));
	}
}

# Transformation des codes temporaires pour les temporisations
$audioTemplateString =~ s/__cdl_brk(\d+)__//sgi;
$audioTextTemplateString =~ s/__cdl_brk(\d+)__//sgi;

$audioTemplateString =~ s/([\?!:\.,;])\s*\./$1/sgi;
$audioTextTemplateString =~ s/([\?!:\.,;])\s*\./$1/sgi;

# Appel du service audio, qui retourne le texte transformé en mp3

# Le type mime de sortie de ce script est audio/mpeg
#print "Content-type:text/plain; charset=utf-8\n\n";
#print $audioTextTemplateString;exit;
print "Content-type:audio/mpeg\n\n";

print vocalize($fileName, $siteId, $defaultConfiguration, $voice, $speed, $audioTextTemplateString);

exit;