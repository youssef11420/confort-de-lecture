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

if (isset($_REQUEST["plusDeCouleursTexte"])) {
	$typ = "CC";
}
if (isset($_REQUEST["plusDeCouleurs"])) {
	$typ = "F";
}

	$hexa = array();
	array_push($hexa, "000000");
	array_push($hexa, "333333");
	array_push($hexa, "666666");
	array_push($hexa, "999999");
	array_push($hexa, "CCCCCC");
	array_push($hexa, "FFFFFF");
	array_push($hexa, "00CC00");
	array_push($hexa, "00CC33");
	array_push($hexa, "33CC00");
	array_push($hexa, "33CC33");
	array_push($hexa, "66CC00");
	array_push($hexa, "66CC33");
	array_push($hexa, "00CC66");
	array_push($hexa, "33CC66");
	array_push($hexa, "00FF00");
	array_push($hexa, "00FF33");
	array_push($hexa, "00FF66");
	array_push($hexa, "33FF00");
	array_push($hexa, "66FF00");
	array_push($hexa, "33FF33");
	array_push($hexa, "33FF66");
	array_push($hexa, "66FF33");
	array_push($hexa, "66FF66");
	array_push($hexa, "99FF00");
	array_push($hexa, "99FF33");
	array_push($hexa, "99FF66");
	array_push($hexa, "99FF99");
	array_push($hexa, "CCFF66");
	array_push($hexa, "99CC00");
	array_push($hexa, "CCFF99");
	array_push($hexa, "99CC66");
	array_push($hexa, "669933");
	array_push($hexa, "339933");
	array_push($hexa, "009933");
	array_push($hexa, "339900");
	array_push($hexa, "007326");
	array_push($hexa, "336600");
	array_push($hexa, "336633");
	array_push($hexa, "003300");
	array_push($hexa, "006633");
	array_push($hexa, "009966");
	array_push($hexa, "339966");
	array_push($hexa, "669966");
	array_push($hexa, "66CC66");
	array_push($hexa, "66CC99");
	array_push($hexa, "33CC99");
	array_push($hexa, "99CC99");
	array_push($hexa, "00FF99");
	array_push($hexa, "33FF99");
	array_push($hexa, "CCFFCC");
	array_push($hexa, "99FFCC");
	array_push($hexa, "66FFCC");
	array_push($hexa, "99FFFF");
	array_push($hexa, "66FFFF");
	array_push($hexa, "00FFFF");
	array_push($hexa, "33FFFF");
	array_push($hexa, "33FFCC");
	array_push($hexa, "00FFCC");
	array_push($hexa, "33CCCC");
	array_push($hexa, "00CCCC");
	array_push($hexa, "66CCCC");
	array_push($hexa, "00CC99");
	array_push($hexa, "339999");
	array_push($hexa, "009999");
	array_push($hexa, "006666");
	array_push($hexa, "FFFF66");
	array_push($hexa, "FFFF33");
	array_push($hexa, "FFFF00");
	array_push($hexa, "FFFF99");
	array_push($hexa, "FF9966");
	array_push($hexa, "FFCC00");
	array_push($hexa, "CCCC66");
	array_push($hexa, "CCCC33");
	array_push($hexa, "CCCC00");
	array_push($hexa, "999933");
	array_push($hexa, "999900");
	array_push($hexa, "999966");
	array_push($hexa, "666633");
	array_push($hexa, "666600");
	array_push($hexa, "333300");
	array_push($hexa, "663300");
	array_push($hexa, "996633");
	array_push($hexa, "996600");
	array_push($hexa, "CC9933");
	array_push($hexa, "FFCC66");
	array_push($hexa, "FFCC99");
	array_push($hexa, "FF9933");
	array_push($hexa, "FF9900");
	array_push($hexa, "FF6600");
	array_push($hexa, "CC9966");
	array_push($hexa, "000033");
	array_push($hexa, "000066");
	array_push($hexa, "003366");
	array_push($hexa, "333366");
	array_push($hexa, "003399");
	array_push($hexa, "333399");
	array_push($hexa, "3300CC");
	array_push($hexa, "0033CC");
	array_push($hexa, "006699");
	array_push($hexa, "0000FF");
	array_push($hexa, "3300FF");
	array_push($hexa, "3333FF");
	array_push($hexa, "0033FF");
	array_push($hexa, "0066FF");
	array_push($hexa, "3366FF");
	array_push($hexa, "0066CC");
	array_push($hexa, "666699");
	array_push($hexa, "3366CC");
	array_push($hexa, "6666FF");
	array_push($hexa, "336699");
	array_push($hexa, "0099CC");
	array_push($hexa, "6699CC");
	array_push($hexa, "3399CC");
	array_push($hexa, "0099FF");
	array_push($hexa, "6699FF");
	array_push($hexa, "3399FF");
	array_push($hexa, "00CCFF");
	array_push($hexa, "33CCFF");
	array_push($hexa, "66CCFF");
	array_push($hexa, "99CCFF");
	array_push($hexa, "CCFFFF");
	array_push($hexa, "99CCCC");
	array_push($hexa, "669999");
	array_push($hexa, "336666");
	array_push($hexa, "003333");
	array_push($hexa, "330066");
	array_push($hexa, "330099");
	array_push($hexa, "6600CC");
	array_push($hexa, "6600FF");
	array_push($hexa, "6633CC");
	array_push($hexa, "6633FF");
	array_push($hexa, "CCCCFF");
	array_push($hexa, "660099");
	array_push($hexa, "660066");
	array_push($hexa, "663399");
	array_push($hexa, "9900CC");
	array_push($hexa, "993399");
	array_push($hexa, "9933CC");
	array_push($hexa, "9900FF");
	array_push($hexa, "9933FF");
	array_push($hexa, "996699");
	array_push($hexa, "9966CC");
	array_push($hexa, "9966FF");
	array_push($hexa, "663366");
	array_push($hexa, "CC00FF");
	array_push($hexa, "CC66CC");
	array_push($hexa, "CC99FF");
	array_push($hexa, "CC33FF");
	array_push($hexa, "CC66FF");
	array_push($hexa, "FF99FF");
	array_push($hexa, "330033");
	array_push($hexa, "660033");
	array_push($hexa, "990066");
	array_push($hexa, "CC0099");
	array_push($hexa, "CC3399");
	array_push($hexa, "CC6699");
	array_push($hexa, "FF0099");
	array_push($hexa, "FF3399");
	array_push($hexa, "FF33CC");
	array_push($hexa, "FF00CC");
	array_push($hexa, "FF33FF");
	array_push($hexa, "FF00FF");
	array_push($hexa, "FF66CC");
	array_push($hexa, "FF99CC");
	array_push($hexa, "FFCCFF");
	array_push($hexa, "660000");
	array_push($hexa, "990033");
	array_push($hexa, "990000");
	array_push($hexa, "993333");
	array_push($hexa, "CC3333");
	array_push($hexa, "CC6666");
	array_push($hexa, "CC6633");
	array_push($hexa, "CC6600");
	array_push($hexa, "CC3300");
	array_push($hexa, "993300");
	array_push($hexa, "663333");
	array_push($hexa, "FF0066");
	array_push($hexa, "FF3366");
	array_push($hexa, "FF6666");
	array_push($hexa, "FF6699");
	array_push($hexa, "FF9999");
	array_push($hexa, "FFCCCC");
	array_push($hexa, "330000");
	array_push($hexa, "CC9999");
	array_push($hexa, "FF6633");
	array_push($hexa, "FF3300");
	array_push($hexa, "FF0033");
	array_push($hexa, "FF3333");
	array_push($hexa, "FF0000");
	array_push($hexa, "CC3366");
	array_push($hexa, "CC0066");
	array_push($hexa, "CC0033");

$idSite = $_REQUEST["id"];

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

		preg_match("/siteLabel\s*=\s*(.*?)(\n|$)/", $siteConfig, $matches);
		$siteLabel = $matches[1];
	}
} else {
	print "<h1>Aucun site ne correspond !</h1>";
	exit;
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="fr" xml:lang="fr">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<link rel="stylesheet" type="text/css" href="/style_personalization/styles/styles.css" media="screen" />
		<title><?=$dico['_DICO_TITLE_PALETTE']?></title>
		<link href="/favicon.png" rel="shortcut icon" />
		<script type="text/javascript">
		//<!--
			function truc(leLi) {
				var leUl = leLi.parentNode.parentNode;

				for (i=0;i<leUl.childNodes.length;i++) {
					leUl.childNodes[i].className='';
				}
				leLi.parentNode.className='selected';
			}
		//-->
		</script>
	</head>
<body<?if ($_REQUEST['style'] == "bn") {?> class="body"<?}?>>
	<div class="header">
		<h1 class="titreLogoSite"><a href="http://<?=$urlsSite[0]?>"><img src="<?=$logoSite?>" alt="<?=$siteLabel?>" /></a></h1>
		<img src="images/logo-cdl.png" alt="Confort de lecture" />
		<div class="clearBoth"></div>
	</div>
	<hr class="cache" />
	<form action="parametrage.php" method="get" class="group" id="formPalette">
		<div>
			<div class="cache">
			<input type="hidden" name="typ" value="<?=$typ?>" />
			<input type="hidden" name="b" value="<?=strtoupper($_REQUEST["b"])?>" />
			<input type="hidden" name="t" value="<?=$_REQUEST["s"]?>" />
			<input type="hidden" name="f" value="<?=strtoupper($_REQUEST["f"])?>" />
			<input type="hidden" name="id" value="<?=$_REQUEST["id"]?>" />
			<input type="hidden" name="p" value="<?=$_REQUEST["p"]?>" />
			<input type="hidden" name="js" value="<?=$_SESSION["activateJs"] ? $_SESSION["activateJs"] : $_REQUEST['cdlJs'] ?>" />
			<input type="hidden" name="frame" value="<?=$_SESSION["activateFrames"] ? $_SESSION["activateFrames"] : $_REQUEST['cdlFrames'] ?>" />
			<input type="hidden" name="img" value="<?=$_SESSION["displayImages"] ? $_SESSION["displayImages"] : $_REQUEST['cdlImg'] ?>" />
			<input type="hidden" name="object" value="<?=$_SESSION["displayObjects"] ? $_SESSION["displayObjects"] : $_REQUEST['cdlObj'] ?>" />
			<input type="hidden" name="applet" value="<?=$_SESSION["displayApplets"] ? $_SESSION["displayApplets"] : $_REQUEST['cdlApplet'] ?>" />
			<input type="hidden" name="table" value="<?=$_SESSION["parseTables"] ? $_SESSION["parseTables"] : $_REQUEST['cdlTables'] ?>" />
			<input type="hidden" name="style" value="<?=$_REQUEST["style"]?>" />
			<input type="hidden" name="pal" value="1" />
			</div>
			<h2><?=$dico['_DICO_INTRO_PALETTE']?></h2>
			<div class="encadrementImage" id="encadrementImagePalette">
				<p class="pIntro"><?=$dico['_DICO_EXPLICATION_PALETTE']?><br /></p>
			</div>
			<div id="divCouleurs">
				<ul>
<?
					foreach ($hexa as $i) {
?>
					<li>
						<label for="couleur-<?=$i?>" ondblclick="document.forms[0].submit();" onkeypress="if (event.keyCode == 13 || event.witch == 13) {document.forms[0].submit();return false;}" style="background-color: #<?=$i?>;color: #<?=$i?>;"><span class="cache"><?=$dico['_DICO_LABEL_COULEUR']?> #<?=$i?>&nbsp;:&nbsp;</span><img src="images/trans_pix.png" alt="" /></label><input type="radio" value="<?=$i?>" name="c" id="couleur-<?=$i?>" onfocus="truc(this);" />
					</li>
<?
					}
?>
				</ul>
				<div class="clearBoth"></div>
			</div>
			<br /><br />
			<div style="text-align: center;"><div class="inputSubmit2"><input class="submit" type="submit" name="valider" value="<?=$dico['_DICO_BOUTON_VALIDER']?>" title="<?=$dico['_DICO_TITLE_BOUTON_VALIDER']?>" id="enregistrerAccederAuSite2" /></div></div>
		</div>
	</form>
</body>
</html>