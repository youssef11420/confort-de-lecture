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

# File: constants.pm
#	Module des constantes générales de l'application

# String: $specialCharacters
# Chaîne contenant tous les caractères spéciaux ASCII utile pour le nettoyage XHTML des caractères illégaux
$specialCharacters = "¥µÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ";

# Hash: %illegalCharacters
# Table de hachage contenant les caractères illégaux et en correspondance leurs entités valides
# Astuce : s'il y a plusieurs entités valides, les séparer par un "pipe" : |
%illegalCharacters = (
	'€' => '&euro;',
	'‚' => '&sbquo;',
	'ƒ' => '&fnof;',
	'„' => '&bdquo;',
	'…' => '&hellip;|&#8230;',
	'†' => '&dagger;',
	'‡' => '&Dagger;',
	'^' => '&circ;',
	'‰' => '&permil;',
	'Š' => '&Scaron;',
	'‹' => '&lsaquo;',
	'Œ' => '&OElig;',
	'Ž' => '&#381;',
	'‘' => '&lsquo;',
	'’' => '&rsquo;|&#x2019;|&#8217;',
	'“' => '&ldquo;',
	'”' => '&rdquo;',
	'•' => '&bull;',
	'–' => '&ndash;',
	'—' => '&mdash;',
	'˜' => '&tilde;',
	'™' => '&trade;',
	'š' => '&scaron;',
	'›' => '&rsaquo;',
	'œ' => '&oelig;',
	'ž' => '&#382;',
	'Ÿ' => '&Yuml;',
);

# Hash: %deprecatedHTMLTags
# Balises HTML dépréciées (non XHTML Strict)
%deprecatedHTMLTags = (
	'basefont',
	'blackface',
	'center',
	'dir',
	'font',
	'isindex',
	'layer',
	'menu',
	's',
	'shadow',
	'strike',
	'u',
);

# Hash: %deprecatedHTMLAttributes
# Attributs HTML dépréciées (non XHTML Strict)
%deprecatedHTMLAttributes = (
	'alink',
	'align',
	'background',
	'border',
	'color',
	'compact',
	'face',
	'height',
	'language',
	'link',
	'noshade',
	'nowrap',
	'size',
	'startm',
	'textm',
	'type',
	'value',
	'version',
	'vlink',
	'width',
	'target',
	'hspace',
	'vspace',
	'wrap',
);

# Hash: %emptyTagsToKeep
# Balises XHTML qui sont utiles même vides
%emptyTagsToKeep = (
	'body',
	'a',
	'frameset',
	'iframe',
	'textarea',
	'option',
	'td',
	'head',
	'title',
	'script',
	'applet',
	'object',
);

# Hash: %selfClosingTags
# Balises XHTML autofermantes
%selfClosingTags = (
	'base',
	'meta',
	'link',
	'hr',
	'br',
	'param',
	'img',
	'area',
	'input',
	'col',
	'frame',
);

# Hash: %eventListeners
# Attributs XHTML permettant d'éxécuter du javascript suite à des événements donnés
%eventListeners = (
	'onclick',
	'onunload',
	'onload',
	'onmouseover',
	'onmouseout',
	'onfocus',
	'onblur',
	'onchange',
	'onselect',
	'onsubmit',
);

# Hash: %booleanFormAttributs
# Attributs XHTML booléens
%booleanFormAttributs = (
	'selected',
	'disabled',
	'readonly',
	'checked',
	'multiple',
);

# String: $sessionExpireIn
# La durée de vie de la session d'un internaute donné
# s : Seconde
# m : Minute
# h : Heure
# w : Semaine
# M : Mois
# y : Année
$sessionExpireIn = '24h';

# String: $cdlAccept
# Les types mime acceptés par CDL dans une réponse HTTP
$cdlAccept = "*/*";

# String: $cdlRootPath
# Le chemin physique vers la racine du site
$cdlRootPath = $ENV{'DOCUMENT_ROOT'};

# String: $cdlSessionCachePath
# Le chemin à partir de la racine vers le répertoire de cache pour la session
$cdlSessionCachePath = '/cache/session';

# String: $cdlDocumentsCachePath
# Le chemin à partir de la racine vers le répertoire utile pour la gestion des documents
$cdlDocumentsCachePath = "/cache/document/";

# String: $cdlTemplatesPath
# Le chemin à partir de la racine vers le répertoire contenant les templates XHTML et CSS
$cdlTemplatesPath = '/configuration/templates/';

# String: $cdlSitesConfigPath
# Le chemin à partir de la racine vers le répertoire contenant les sites pris en compte
$cdlSitesConfigPath = '/configuration/sites/';

# String: $agentNameToSend
# Le nom de l'agent HTTP à envoyer dans les requêtes vers les sites distants parsés
$agentNameToSend = 'Confort de lecture / 1.0 [Lnet - SQLi]';

# String: $fontFamily
# La famille de polices de caractères à utiliser pour afficher les pages filtrées ainsi que la page de paramétrage
$fontFamily = '"Lucida Sans", "Lucida Sans Unicode", arial, sans-serif';

# Hash: %fontSizes
# La liste des tailles de police
%fontSizes = (
	'1' => '100',
	'2' => '125',
	'3' => '170',
	'4' => '220',
	'5' => '300',
);

# String: $defaultLanguage
# La langue par défaut des pages si aucune n'est spécifiée dans la configuration
$defaultLanguage = "fr";

# String: $defaultButtonText
# Valeur par défaut à mettre dans le texte d'un bouton de validation si aucun contenu alternatif n'a été donné au bouton de type image correspondant (cf. <parseForms> dans la partie de gestion des boutons images)
$defaultButtonText = "Valider";

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;