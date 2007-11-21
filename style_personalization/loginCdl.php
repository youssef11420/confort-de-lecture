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

// Recupération des différents paramètres
$idSite			= $_REQUEST["id"];
$pageOriginale	= $_REQUEST["p"];
$pseudoCdl		= $_REQUEST["pseudoLogin"];
$mdpCdl			= $_REQUEST["mdpLogin"];

// Vérification des paramètres
$codeErrId = "";
$codeErrMdp = "";
$codeErreur = "";
if ($pseudoCdl=="" || $pseudoCdl=="Identifiant") {
	$codeErrId = "1";
}
if ($mdpCdl=="") {
	$codeErrMdp = "1";
}


if ($codeErreur!="" || $codeErrId!="" || $codeErrMdp!="") {
	header("Location:parametrage.php?id=".$idSite."&p=".$pageOriginale."&errLog=1&pseudoLogin=".$pseudoCdl."&style=".$_REQUEST['style']."#erreurLog");
	exit(0);
}

// Status du login $logStatus
$logStatus = "0";

// Récupération de l'utilisateur
$sqlQuery	= "SELECT * FROM users WHERE LOGIN_USER = ".quote_smart($pseudoCdl)." AND PASSWORD_USER = ".quote_smart(md5($mdpCdl));

$res = $DB->execute($sqlQuery);
if($DB->sqlErrNo()) {
	echo $DB->sqlError();
} else {
	if($row = $DB->fetchArray($res)) {
		$idUtilisateur	= $row['ID_USER'];
		$loginUtilisateur	= $row['LOGIN_USER'];
		$coulEcran		= $row['BACKGROUND_COLOR'];
		$coulTexte		= $row['FONT_COLOR'];
		$tailleTexte	= $row['FONT_SIZE'];
		$_cdlJs	= $row['ACTIVATE_JS'];
		$_cdlFrames	= $row['ACTIVATE_FRAMES'];
		$_cdlImg	= $row['DISPLAY_IMAGES'];
		$_cdlObj	= $row['DISPLAY_OBJECTS'];
		$_cdlApplet	= $row['DISPLAY_APPLETS'];
		$_cdlTables	= $row['PARSE_TABLES'];
		$logStatus		= "1";
		$_SESSION['userCDL']	= $idUtilisateur;
		$_SESSION["loginUserCDL"] = $loginUtilisateur;
	} else {
		header("Location:parametrage.php?id=".$idSite."&p=".$pageOriginale."&errLog=2&pseudoLogin=".$pseudoCdl."&style=".$_REQUEST['style']."#erreurLog");
		exit(0);
	}
}
$DB->freeResult($res);


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

// Redirection vers la page de paramètrage
header("Location: $parserUrl?cdlid=$idSite&cdlurl=".urlencode($pageOriginale)."&cdlfirst=1&cdlbc=$coulEcran&cdlfc=$coulTexte&cdlfs=$tailleTexte&cdljs=".$_cdlJs."&cdlframes=".$_cdlFrames."&cdlimg=".$_cdlImg."&cdlobject=".$_cdlObj."&cdlapplet=".$_cdlApplet."&cdtable=".$_cdlTables."&cdlstyle=".$_REQUEST['style']);



?>