<?
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

	require("inc/constantes_fonctions.php");
	require("inc/session.php");

# ----------------------------------------------------------------------
# Vérifie si on est sur le site en ligne ou le site en développement
# ----------------------------------------------------------------------

// Recupération des différents paramètres
$idSite			= $_REQUEST['id'];
$pageOriginale	= $_REQUEST['p'];
$coulEcran		= $_REQUEST['b'];
$coulTexte		= $_REQUEST['f'];
$tailleTexte	= $_REQUEST['s'];

switch($tailleTexte) {
	case "100" : $tailleTexte = "1"; break;
	case "170" : $tailleTexte = "3"; break;
	case "220" : $tailleTexte = "4"; break;
	case "300" : $tailleTexte = "5"; break;
	default: $tailleTexte = "2"; break;
}

// Status du login $logStatus
$logStatus = "0";

if (is_dir("../configuration/sites/".$idSite)) {
	if (file_exists("../configuration/sites/".$idSite."/".$idSite.".ini")) {
		$siteConfig = file_get_contents("../configuration/sites/".$idSite."/".$idSite.".ini");

		preg_match("/logo\s*=\s*(.*?)(\n|$)/", $siteConfig, $matches);
		$logoSite = $matches[1];

		preg_match("/siteDomainNames\s*=\s*(.*?)(\n|$)/", $siteConfig, $matches);
		$urlsSite = split("\t", $matches[1]);

		foreach ($urlsSite as $urlSite) {
			$urlSite = "http://".$urlSite;
		}
	}
} else {
	print "Aucun site ne correspond !";
	exit;
}

foreach ($urlsSite as $urlSite) {
	$pageOriginale = preg_replace("{^$urlSite/}i", "", $pageOriginale);
}

// Redirection vers la page de paramètrage
header("Location: $parserUrl?cdlid=$idSite&cdlurl=".urlencode(preg_replace("{^/}", "", $pageOriginale))."&cdlfirst=1&cdlbc=$coulEcran&cdlfc=$coulTexte&cdlfs=$tailleTexte&cdljs=".$_REQUEST['cdlJs']."&cdlframes=".$_REQUEST['cdlFrames']."&cdlimg=".$_REQUEST['cdlImg']."&cdlobject=".$_REQUEST['cdlObj']."&cdlapplet=".$_REQUEST['cdlApplet']."&cdtable=".$_REQUEST['cdlTables']."&cdlstyle=".$_REQUEST['style']);
?>