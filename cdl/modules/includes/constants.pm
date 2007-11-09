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

# File: constants.pm
#	Module des constantes g�n�rales de l'application

# String: $specialCharacters
# Cha�ne contenant tous les caract�res sp�ciaux ASCII utile pour le nettoyage XHTML des caract�res ill�gaux
$specialCharacters = "��������������������������������������������������������������";

# Hash: %illegalCharacters
# Table de hachage contenant les caract�res ill�gaux et en correspondance leurs entit�s valides
# Astuce : s'il y a plusieurs entit�s valides, les s�parer par un "pipe" : |
%illegalCharacters = (
	'�' => '&euro;',
	'�' => '&sbquo;',
	'�' => '&fnof;',
	'�' => '&bdquo;',
	'�' => '&hellip;|&#8230;',
	'�' => '&dagger;',
	'�' => '&Dagger;',
	'^' => '&circ;',
	'�' => '&permil;',
	'�' => '&Scaron;',
	'�' => '&lsaquo;',
	'�' => '&OElig;',
	'�' => '&#381;',
	'�' => '&lsquo;',
	'�' => '&rsquo;|&#x2019;|&#8217;',
	'�' => '&ldquo;',
	'�' => '&rdquo;',
	'�' => '&bull;',
	'�' => '&ndash;',
	'�' => '&mdash;',
	'�' => '&tilde;',
	'�' => '&trade;',
	'�' => '&scaron;',
	'�' => '&rsaquo;',
	'�' => '&oelig;',
	'�' => '&#382;',
	'�' => '&Yuml;',
);

# Hash: %deprecatedHTMLTags
# Balises HTML d�pr�ci�es (non XHTML Strict)
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
# Attributs HTML d�pr�ci�es (non XHTML Strict)
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
# Balises XHTML qui sont utiles m�me vides
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
# Attributs XHTML permettant d'�x�cuter du javascript suite � des �v�nements donn�s
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
# Attributs XHTML bool�ens
%booleanFormAttributs = (
	'selected',
	'disabled',
	'readonly',
	'checked',
	'multiple',
);

# String: $sessionExpireIn
# La dur�e de vie de la session d'un internaute donn�
# s : Seconde
# m : Minute
# h : Heure
# w : Semaine
# M : Mois
# y : Ann�e
$sessionExpireIn = '24h';

# String: $cdlAccept
# Les types mime accept�s par CDL dans une r�ponse HTTP
$cdlAccept = "*/*";

# String: $cdlRootPath
# Le chemin physique vers la racine du site
$cdlRootPath = $ENV{'DOCUMENT_ROOT'};

# String: $cdlSessionCachePath
# Le chemin � partir de la racine vers le r�pertoire de cache pour la session
$cdlSessionCachePath = '/cache/session';

# String: $cdlDocumentsCachePath
# Le chemin � partir de la racine vers le r�pertoire utile pour la gestion des documents
$cdlDocumentsCachePath = "/cache/document/";

# String: $cdlTemplatesPath
# Le chemin � partir de la racine vers le r�pertoire contenant les templates XHTML et CSS
$cdlTemplatesPath = '/configuration/templates/';

# String: $cdlSitesConfigPath
# Le chemin � partir de la racine vers le r�pertoire contenant les sites pris en compte
$cdlSitesConfigPath = '/configuration/sites/';

# String: $agentNameToSend
# Le nom de l'agent HTTP � envoyer dans les requ�tes vers les sites distants pars�s
$agentNameToSend = 'Confort de lecture / 1.0 [Lnet - SQLi]';

# String: $fontFamily
# La famille de polices de caract�res � utiliser pour afficher les pages filtr�es ainsi que la page de param�trage
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
# La langue par d�faut des pages si aucune n'est sp�cifi�e dans la configuration
$defaultLanguage = "fr";

# String: $defaultButtonText
# Valeur par d�faut � mettre dans le texte d'un bouton de validation si aucun contenu alternatif n'a �t� donn� au bouton de type image correspondant (cf. <parseForms> dans la partie de gestion des boutons images)
$defaultButtonText = "Valider";

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;