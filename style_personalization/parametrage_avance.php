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

// Ce script sera activé très prochainement
exit;


require("inc/constantes_fonctions.php");
require("inc/session.php");

switch ($_SESSION['langue']) {
	case "fr" : require("dico/dico.fr.inc.php"); break;
	case "en" : require("dico/dico.en.inc.php"); break;
	case "de" : require("dico/dico.de.inc.php"); break;
	case "es" : require("dico/dico.es.inc.php"); break;
	case "it" : require("dico/dico.it.inc.php"); break;
	case "nl" : require("dico/dico.nl.inc.php"); break;
	case "pt" : require("dico/dico.pt.inc.php"); break;
	default : require("dico/dico.fr.inc.php");
}

$idSite = $_REQUEST["id"];

if ($idSite && is_dir("../configuration/sites/".$idSite)) {
	if (file_exists("../configuration/sites/".$idSite."/".$idSite.".ini")) {
		$siteConfig = file_get_contents("../configuration/sites/".$idSite."/".$idSite.".ini");

		preg_match("/logo\s*=\s*(.*?)(\n|$)/", $siteConfig, $matches);
		$logoSite = $matches[1];

		preg_match("/siteDomainNames\s*=\s*(.*?)(\n|$)/", $siteConfig, $matches);
		$urlsSite = split("\t", $matches[1]);

		foreach ($urlsSite as $urlSite) {
			$urlSite = "http://".$urlSite;
		}

		preg_match("/siteLabel\s*=\s*(.*?)(\n|$)/", $siteConfig, $matches);
		$siteLabel = $matches[1];
	}
} else {
	print "<h1>Aucun site ne correspond !</h1>";
	exit;
}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="fr" xml:lang="fr">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<link rel="stylesheet" type="text/css" href="/style_personalization/styles/styles.css" media="screen" />
		<title><?=$dico['_DICO_TITLE_MODIFIER_PREFERENCES']?></title>
		<link href="/favicon.png" rel="shortcut icon" />
	</head>
	<body<?if ($_REQUEST['style'] == "bn") {?> class="body"<?}?>>
		<div class="header">
			<h1 class="titreLogoSite"><a href="http://<?=$urlsSite[0]?>"><img src="<?=$logoSite?>" alt="<?=$siteLabel?>" /></a></h1>
			<img src="images/logo-cdl.png" alt="Confort de lecture" />
			<div class="clearBoth"></div>
		</div>
		<hr class="cache" />
		<form action="parametrage.php" method="get" class="group" id="formParametresAvances">
			<div class="cache">
				<input type="hidden" name="b" value="<?=strtoupper($_REQUEST["b"])?>" />
				<input type="hidden" name="t" value="<?=$_REQUEST["s"]?>" />
				<input type="hidden" name="f" value="<?=strtoupper($_REQUEST["f"])?>" />
				<input type="hidden" name="id" value="<?=$_REQUEST["id"]?>" />
				<input type="hidden" name="p" value="<?=$_REQUEST["p"]?>" />
				<input type="hidden" name="style" value="<?=$_REQUEST["style"]?>" />
				<input type="hidden" name="avances" value="1" />
				<input type="hidden" name="pal" value="1" />
			</div>
			<div>
				<fieldset class="autresParametres">
					<legend><?=$dico['_DICO_PARAMETRES_AVANCES_LEGENDE']?></legend>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_JS']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_JS_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><input type="radio" id="activateJavascript1" name="activateJavascript" value="1"<?=$_SESSION["activateJs"]=="1" ? " checked=\"checked\"" : "" ?> /><label for="activateJavascript1"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></script></label>&nbsp;&nbsp;&nbsp;<input type="radio" id="activateJavascript0" name="activateJavascript" value="0" <?=$_SESSION["activateJs"]=="0" ? " checked=\"checked\"" : "" ?> /><label for="activateJavascript0"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></label></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_FRAME']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_FRAME_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><input type="radio" id="activateFrames1" name="activateFrames" value="1"<?=$_SESSION["activateFrames"]=="1" ? " checked=\"checked\"" : "" ?> /><label for="activateFrames1"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></label>&nbsp;&nbsp;&nbsp;<input type="radio" id="activateFrames0" name="activateFrames" value="0"<?=$_SESSION["activateFrames"]=="0" ? " checked=\"checked\"" : "" ?> /><label for="activateFrames0"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></label></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_IMG']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_IMG_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><input type="radio" id="displayImages1" name="displayImages" value="1"<?=$_SESSION["displayImages"]=="1" ? " checked=\"checked\"" : "" ?> /><label for="displayImages1"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></label>&nbsp;&nbsp;&nbsp;<input type="radio" id="displayImages0" name="displayImages" value="0"<?=$_SESSION["displayImages"]=="0" ? " checked=\"checked\"" : "" ?> /><label for="displayImages0"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></label></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_OBJECT']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_OBJECT_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><input type="radio" id="displayObjects1" name="displayObjects" value="1"<?=$_SESSION["displayObjects"]=="1" ? " checked=\"checked\"" : "" ?> /><label for="displayObjects1"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></label>&nbsp;&nbsp;&nbsp;<input type="radio" id="displayObjects0" name="displayObjects" value="0"<?=$_SESSION["displayObjects"]=="0" ? " checked=\"checked\"" : "" ?> /><label for="displayObjects0"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></label></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_APPLET']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_APPLET_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><input type="radio" id="displayApplets1" name="displayApplets" value="1"<?=$_SESSION["displayApplets"]=="1" ? " checked=\"checked\"" : "" ?> /><label for="displayApplets1"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></label>&nbsp;&nbsp;&nbsp;<input type="radio" id="displayApplets0" name="displayApplets" value="0"<?=$_SESSION["displayApplets"]=="0" ? " checked=\"checked\"" : "" ?> /><label for="displayApplets0"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></label></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_TABLE']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_TABLE_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><input type="radio" id="parseTablesToList1" name="parseTablesToList" value="1"<?=$_SESSION["parseTables"]=="1" ? " checked=\"checked\"" : "" ?> /><label for="parseTablesToList1"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></label>&nbsp;&nbsp;&nbsp;<input type="radio" id="parseTablesToList0" name="parseTablesToList" value="0"<?=$_SESSION["parseTables"]=="0" ? " checked=\"checked\"" : "" ?> /><label for="parseTablesToList0"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></label></div></div>
						<div class="clearBothSep2"></div>
					</div>
				</fieldset>
				<br />
				<div style="text-align: center;"><div class="inputSubmit2"><input class="submit" type="submit" name="valider" value="<?=$dico['_DICO_BOUTON_VALIDER']?>" title="<?=$dico['_DICO_TITLE_BOUTON_VALIDER']?>" id="enregistrerAccederAuSite2" /></div></div>
			</div>
		</form>
	</body>
</html>