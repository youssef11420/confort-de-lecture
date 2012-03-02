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

# File: constants.pm
#	Module des constantes générales de l'application

# Array: @deprecatedHTMLAttributes
# Attributs HTML dépréciées (non XHTML Strict)
@deprecatedHTMLAttributes = ('alink', 'align', 'valign', 'background', 'border', 'bgcolor', 'color', 'compact', 'face', 'height', 'language', 'link', 'noshade', 'nowrap', 'size', 'startm', 'textm', 'type', 'value', 'version', 'vlink', 'width', 'hspace', 'vspace', 'wrap', 'clear', 'complete', 'frameborder', 'marginheight', 'marginwidth', 'scrolling');

# Array: @eventListeners
# Attributs XHTML permettant d'éxécuter du javascript suite à des événements donnés
@eventListeners = ('onclick', 'onunload', 'onload', 'onmouseover', 'onmouseout', 'onfocus', 'onblur', 'onchange', 'onselect', 'onsubmit');

# String: $cdlAccept
# Les types mime acceptés par CDL dans une réponse HTTP
$cdlAccept = "*/*";

# String: $cdlRootPath
# Le chemin physique vers la racine du site
$cdlRootPath = $ENV{'DOCUMENT_ROOT'};

# String: $cdlTemplatesPath
# Le chemin à partir de la racine vers le répertoire contenant les templates XHTML et CSS
$cdlTemplatesPath = $cdlRootPath."/templates/";

# String: $cdlSitesConfigPath
# Le chemin à partir de la racine vers le répertoire contenant les sites pris en compte
$cdlSitesConfigPath = $cdlRootPath."/configuration/sites/";

# String: $cdlGlossaryConfigPath
# Le chemin à partir de la racine vers le répertoire contenant le fichier de corrections de prononciations
$cdlGlossaryConfigPath = $cdlRootPath."/configuration/glossary/";

# String: $cdlSessionCachePath
# Le chemin à partir de la racine vers le répertoire de cache pour la session
$cdlSessionCachePath = $cdlRootPath."/cache/session";

# String: $cdlDocumentsCachePath
# Le chemin à partir de la racine vers le répertoire utile pour la gestion des documents
$cdlDocumentsCachePath = $cdlRootPath."/cache/document/";

# String: $cdlContentCachePath
# Le chemin à partir de la racine vers le répertoire de cache des pages
$cdlContentCachePath = $cdlRootPath."/cache/html/";

# String: $cdlAudioCachePath
# Le chemin à partir de la racine vers le répertoire de cache pour la génération audio
$cdlAudioCachePath = $cdlRootPath."/cache/audio/";

# Array: @allColors
# La liste des couleurs pour la palette
@allColors = ("000000", "333333", "666666", "999999", "CCCCCC", "FFFFFF", "00CC00", "00CC33", "33CC00", "33CC33", "66CC00", "66CC33", "00CC66", "33CC66", "00FF00", "00FF33", "00FF66", "33FF00", "66FF00", "33FF33", "33FF66", "66FF33", "66FF66", "99FF00", "99FF33", "99FF66", "99FF99", "CCFF66", "99CC00", "CCFF99", "99CC66", "669933", "339933", "009933", "339900", "007326", "336600", "336633", "003300", "006633", "009966", "339966", "669966", "66CC66", "66CC99", "33CC99", "99CC99", "00FF99", "33FF99", "CCFFCC", "99FFCC", "66FFCC", "99FFFF", "66FFFF", "00FFFF", "33FFFF", "33FFCC", "00FFCC", "33CCCC", "00CCCC", "66CCCC", "00CC99", "339999", "009999", "006666", "FFFF66", "FFFF33", "FFFF00", "FFFF99", "FF9966", "FFCC00", "CCCC66", "CCCC33", "CCCC00", "999933", "999900", "999966", "666633", "666600", "333300", "663300", "996633", "996600", "CC9933", "FFCC66", "FFCC99", "FF9933", "FF9900", "FF6600", "CC9966", "000033", "000066", "003366", "333366", "003399", "333399", "3300CC", "0033CC", "006699", "0000FF", "3300FF", "3333FF", "0033FF", "0066FF", "3366FF", "0066CC", "666699", "3366CC", "6666FF", "336699", "0099CC", "6699CC", "3399CC", "0099FF", "6699FF", "3399FF", "00CCFF", "33CCFF", "66CCFF", "99CCFF", "CCFFFF", "99CCCC", "669999", "336666", "003333", "330066", "330099", "6600CC", "6600FF", "6633CC", "6633FF", "CCCCFF", "660099", "660066", "663399", "9900CC", "993399", "9933CC", "9900FF", "9933FF", "996699", "9966CC", "9966FF", "663366", "CC00FF", "CC66CC", "CC99FF", "CC33FF", "CC66FF", "FF99FF", "330033", "660033", "990066", "CC0099", "CC3399", "CC6699", "FF0099", "FF3399", "FF33CC", "FF00CC", "FF33FF", "FF00FF", "FF66CC", "FF99CC", "FFCCFF", "660000", "990033", "990000", "993333", "CC3333", "CC6666", "CC6633", "CC6600", "CC3300", "993300", "663333", "FF0066", "FF3366", "FF6666", "FF6699", "FF9999", "FFCCCC", "330000", "CC9999", "FF6633", "FF3300", "FF0033", "FF3333", "FF0000", "CC3366", "CC0066", "CC0033");

# Array: @speeds
# La liste des valeurs des 5 vitesses
@speeds = ('16', '20', '24', '32', '38');

# String: $defaultSpeed
# La vitesse par défaut utilisée pour lire les pages
$defaultSpeed = "32";

# String: $agentNameToSend
# Le nom de l'agent HTTP à envoyer dans les requêtes vers les sites distants parsés
$agentNameToSend = 'Confort de lecture [Lnet - aYaline]';

# Hash: %fontSizes
# La liste des tailles de police
%fontSizes = ('1' => '90', '2' => '115', '3' => '170', '4' => '220', '5' => '300');

# Hash: %cursorSizes
# La liste des tailles des curseurs
%cursorSizes = ('1' => '32', '2' => '47', '3' => '71', '4' => '93', '5' => '128');

# String: $defaultButtonText
# Valeur par défaut à mettre dans le texte d'un bouton de validation si aucun contenu alternatif n'a été donné au bouton de type image correspondant (cf. <parseForms> dans la partie de gestion des boutons images)
$defaultButtonText = "OK";

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;