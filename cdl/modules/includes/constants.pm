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

# Hash: $specialCharacters
# Liste des caract�res sp�ciaux avec leurs entit�s valides correspondantes
%specialCharacters = (
	'amp' => '&',
	'lt' => '<',
	'gt' => '>',
	'quot' => '"',
	'AElig' => chr(198),
	'AElig' => chr(198),
	'Aacute' => chr(193),
	'Acirc' => chr(194),
	'Agrave' => chr(192),
	'Aring' => chr(197),
	'Atilde' => chr(195),
	'Auml' => chr(196),
	'Ccedil' => chr(199),
	'ETH' => chr(208),
	'Eacute' => chr(201),
	'Ecirc' => chr(202),
	'Egrave' => chr(200),
	'Euml' => chr(203),
	'Iacute' => chr(205),
	'Icirc' => chr(206),
	'Igrave' => chr(204),
	'Iuml' => chr(207),
	'Ntilde' => chr(209),
	'Oacute' => chr(211),
	'Ocirc' => chr(212),
	'Ograve' => chr(210),
	'Oslash' => chr(216),
	'Otilde' => chr(213),
	'Ouml' => chr(214),
	'THORN' => chr(222),
	'Uacute' => chr(218),
	'Ucirc' => chr(219),
	'Ugrave' => chr(217),
	'Uuml' => chr(220),
	'Yacute' => chr(221),
	'aacute' => chr(225),
	'acirc' => chr(226),
	'aelig' => chr(230),
	'agrave' => chr(224),
	'aring' => chr(229),
	'atilde' => chr(227),
	'auml' => chr(228),
	'ccedil' => chr(231),
	'eacute' => chr(233),
	'ecirc' => chr(234),
	'egrave' => chr(232),
	'eth' => chr(240),
	'euml' => chr(235),
	'iacute' => chr(237),
	'icirc' => chr(238),
	'igrave' => chr(236),
	'iuml' => chr(239),
	'ntilde' => chr(241),
	'oacute' => chr(243),
	'ocirc' => chr(244),
	'ograve' => chr(242),
	'oslash' => chr(248),
	'otilde' => chr(245),
	'ouml' => chr(246),
	'szlig' => chr(223),
	'thorn' => chr(254),
	'uacute' => chr(250),
	'ucirc' => chr(251),
	'ugrave' => chr(249),
	'uuml' => chr(252),
	'yacute' => chr(253),
	'yuml' => chr(255),
	'copy' => chr(169),
	'reg' => chr(174),
	'nbsp' => chr(160),
	'iexcl' => chr(161),
	'cent' => chr(162),
	'pound' => chr(163),
	'curren' => chr(164),
	'yen' => chr(165),
	'brvbar' => chr(166),
	'sect' => chr(167),
	'uml' => chr(168),
	'ordf' => chr(170),
	'laquo' => chr(171),
	'not' => chr(172),
	'shy' => chr(173),
	'macr' => chr(175),
	'deg' => chr(176),
	'plusmn' => chr(177),
	'sup1' => chr(185),
	'sup2' => chr(178),
	'sup3' => chr(179),
	'acute' => chr(180),
	'micro' => chr(181),
	'para' => chr(182),
	'middot' => chr(183),
	'cedil' => chr(184),
	'ordm' => chr(186),
	'raquo' => chr(187),
	'frac14' => chr(188),
	'frac12' => chr(189),
	'frac34' => chr(190),
	'iquest' => chr(191),
	'times' => chr(215),
	'divide' => chr(247),
	'OElig' => chr(338),
	'oelig' => chr(339),
	'Scaron' => chr(352),
	'scaron' => chr(353),
	'Yuml' => chr(376),
	'fnof' => chr(402),
	'circ' => chr(710),
	'tilde' => chr(732),
	'Alpha' => chr(913),
	'Beta' => chr(914),
	'Gamma' => chr(915),
	'Delta' => chr(916),
	'Epsilon' => chr(917),
	'Zeta' => chr(918),
	'Eta' => chr(919),
	'Theta' => chr(920),
	'Iota' => chr(921),
	'Kappa' => chr(922),
	'Lambda' => chr(923),
	'Mu' => chr(924),
	'Nu' => chr(925),
	'Xi' => chr(926),
	'Omicron' => chr(927),
	'Pi' => chr(928),
	'Rho' => chr(929),
	'Sigma' => chr(931),
	'Tau' => chr(932),
	'Upsilon' => chr(933),
	'Phi' => chr(934),
	'Chi' => chr(935),
	'Psi' => chr(936),
	'Omega' => chr(937),
	'alpha' => chr(945),
	'beta' => chr(946),
	'gamma' => chr(947),
	'delta' => chr(948),
	'epsilon' => chr(949),
	'zeta' => chr(950),
	'eta' => chr(951),
	'theta' => chr(952),
	'iota' => chr(953),
	'kappa' => chr(954),
	'lambda' => chr(955),
	'mu' => chr(956),
	'nu' => chr(957),
	'xi' => chr(958),
	'omicron' => chr(959),
	'pi' => chr(960),
	'rho' => chr(961),
	'sigmaf' => chr(962),
	'sigma' => chr(963),
	'tau' => chr(964),
	'upsilon' => chr(965),
	'phi' => chr(966),
	'chi' => chr(967),
	'psi' => chr(968),
	'omega' => chr(969),
	'thetasym' => chr(977),
	'upsih' => chr(978),
	'piv' => chr(982),
	'ensp' => chr(8194),
	'emsp' => chr(8195),
	'thinsp' => chr(8201),
	'zwnj' => chr(8204),
	'zwj' => chr(8205),
	'lrm' => chr(8206),
	'rlm' => chr(8207),
	'ndash' => chr(8211),
	'mdash' => chr(8212),
	'lsquo' => chr(8216),
	'rsquo' => chr(8217),
	'sbquo' => chr(8218),
	'ldquo' => chr(8220),
	'rdquo' => chr(8221),
	'bdquo' => chr(8222),
	'dagger' => chr(8224),
	'Dagger' => chr(8225),
	'bull' => chr(8226),
	'hellip' => chr(8230),
	'permil' => chr(8240),
	'prime' => chr(8242),
	'Prime' => chr(8243),
	'lsaquo' => chr(8249),
	'rsaquo' => chr(8250),
	'oline' => chr(8254),
	'frasl' => chr(8260),
	'euro' => chr(8364),
	'image' => chr(8465),
	'weierp' => chr(8472),
	'real' => chr(8476),
	'trade' => chr(8482),
	'alefsym' => chr(8501),
	'larr' => chr(8592),
	'uarr' => chr(8593),
	'rarr' => chr(8594),
	'darr' => chr(8595),
	'harr' => chr(8596),
	'crarr' => chr(8629),
	'lArr' => chr(8656),
	'uArr' => chr(8657),
	'rArr' => chr(8658),
	'dArr' => chr(8659),
	'hArr' => chr(8660),
	'forall' => chr(8704),
	'part' => chr(8706),
	'exist' => chr(8707),
	'empty' => chr(8709),
	'nabla' => chr(8711),
	'isin' => chr(8712),
	'notin' => chr(8713),
	'ni' => chr(8715),
	'prod' => chr(8719),
	'sum' => chr(8721),
	'minus' => chr(8722),
	'lowast' => chr(8727),
	'radic' => chr(8730),
	'prop' => chr(8733),
	'infin' => chr(8734),
	'ang' => chr(8736),
	'and' => chr(8743),
	'or' => chr(8744),
	'cap' => chr(8745),
	'cup' => chr(8746),
	'int' => chr(8747),
	'there4' => chr(8756),
	'sim' => chr(8764),
	'cong' => chr(8773),
	'asymp' => chr(8776),
	'ne' => chr(8800),
	'equiv' => chr(8801),
	'le' => chr(8804),
	'ge' => chr(8805),
	'sub' => chr(8834),
	'sup' => chr(8835),
	'nsub' => chr(8836),
	'sube' => chr(8838),
	'supe' => chr(8839),
	'oplus' => chr(8853),
	'otimes' => chr(8855),
	'perp' => chr(8869),
	'sdot' => chr(8901),
	'lceil' => chr(8968),
	'rceil' => chr(8969),
	'lfloor' => chr(8970),
	'rfloor' => chr(8971),
	'lang' => chr(9001),
	'rang' => chr(9002),
	'loz' => chr(9674),
	'spades' => chr(9824),
	'clubs' => chr(9827),
	'hearts' => chr(9829),
	'diams' => chr(9830),
);

# Hash: %illegalCharacters
# Table de hachage contenant les caract�res ill�gaux et en correspondance leurs entit�s valides
# Astuce : s'il y a plusieurs entit�s valides, les s�parer par un "pipe" : |
%illegalCharacters = (
	'�' => 'euro',
	'�' => 'sbquo',
	'�' => 'fnof',
	'�' => 'bdquo',
	'�' => 'hellip',
	'�' => 'dagger',
	'�' => 'Dagger',
	'^' => 'circ',
	'�' => 'permil',
	'�' => 'Scaron',
	'�' => 'lsaquo',
	'�' => 'OElig',
	'�' => '#381',
	'�' => 'lsquo',
	'�' => 'rsquo',
	'�' => 'ldquo',
	'�' => 'rdquo',
	'�' => 'bull',
	'�' => 'ndash',
	'�' => 'mdash',
	'�' => 'tilde',
	'�' => 'trade',
	'�' => 'scaron',
	'�' => 'rsaquo',
	'�' => 'oelig',
	'�' => '#382',
	'�' => 'Yuml',
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
$agentNameToSend = 'Confort de lecture [Lnet - SQLi]';

# String: $fontFamily
# La famille de polices de caract�res � utiliser pour afficher les pages filtr�es ainsi que la page de param�trage
$fontFamily = '"Lucida Sans","Lucida Sans Unicode",arial,sans-serif';

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