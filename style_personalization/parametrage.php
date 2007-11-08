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

switch ($_REQUEST['l']) {
	case "fr" : $_SESSION['langue'] = "fr"; break;
	case "en" : $_SESSION['langue'] = "en"; break;
	case "de" : $_SESSION['langue'] = "de"; break;
	case "es" : $_SESSION['langue'] = "es"; break;
	case "it" : $_SESSION['langue'] = "it"; break;
	case "nl" : $_SESSION['langue'] = "en"; break;
	case "pt" : $_SESSION['langue'] = "pt"; break;
	case "" : break;
	default : $_SESSION['langue'] = "fr";
}

switch ($_SESSION['langue']) {
	case "fr" : require("dico.fr.inc.php"); break;
	case "en" : require("dico.en.inc.php"); break;
	case "de" : require("dico.de.inc.php"); break;
	case "es" : require("dico.es.inc.php"); break;
	case "it" : require("dico.it.inc.php"); break;
	case "nl" : require("dico.nl.inc.php"); break;
	case "pt" : require("dico.pt.inc.php"); break;
	default : require("dico.fr.inc.php");
}

$typ	 = $_REQUEST["typ"];
$class	 = $_REQUEST["class"];
$couleur = $_REQUEST["c"];
$taille = $_REQUEST["t"];

// vient de la palette
$pal = $_REQUEST["pal"];

###########################################################################################
// CODE CONFORT DE LECTURE
###########################################################################################
$cdlId = $_REQUEST["id"];
$cdlB =strtoupper( $_REQUEST["b"]);
$cdlF = strtoupper($_REQUEST["f"]);
$cdlS = $_REQUEST["s"];
$cdlP = $_REQUEST["p"];

// Validation de paramètres par defaut
if ($cdlB == "") {if ($_REQUEST['style'] == "bn") $cdlB = "FFFFFF"; else $cdlB = "000000";}
if ($cdlF == "") {if ($_REQUEST['style'] == "bn") $cdlF = "000000"; else $cdlF = "FFFFFF";}
if ($cdlS == "") {$cdlS = "3";}


# ----------------------------------------------------------------------

// récupération des différents paramètres
$idSite			= $_REQUEST["id"];
$coulEcran		= $_REQUEST["b"];
$coulTexte		= $_REQUEST["f"];
$tailleTexte	= $_REQUEST["s"];
$pageOriginale	= $_REQUEST["p"];

$urlsSite		= "";

$finalUrlToGo	= "";

echo "<!-- urlSite : $urlSite  -->";

if ($idSite != "" && is_dir("../configuration/sites/".$idSite)) {
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

foreach ($urlsSite as $urlSite) {
	$pageOriginale = preg_replace("{^$urlSite/}i", "", $pageOriginale);
}
##########################################################################################

// Remplir les variables de session en fonction du typ
switch($typ) {
	case "F" :	$_SESSION["couleurFond"] = $couleur;
				$_SESSION["tailleLettre"] = $taille;
				$_SESSION["idF"] = $class;
				break;
	case "TC" :	$_SESSION["tailleLettre"] = $taille;
				$_SESSION["idTC"] = $class;
				break;
	case "CC" :	$_SESSION["couleurLettre"] = $couleur;
				$_SESSION["idCC"] = $class;
				break;
	case "js" :	$_SESSION["activateJs"] = $class;
				break;
	case "frame" :	$_SESSION["activateFrames"] = $class;
				break;
	case "img" :	$_SESSION["displayImages"] = $class;
				break;
	case "object" :	$_SESSION["displayObjects"] = $class;
				break;
	case "applet" :	$_SESSION["displayApplets"] = $class;
				break;
	case "table" :	$_SESSION["parseTables"] = $class;
				break;
	default	: break;
}

if ($_SESSION["activateJs"]=="1")
	$classSelectedJs1 = " class=\"advancedSelected\"";
elseif ($_SESSION["activateJs"]=="0")
	$classSelectedJs0 = " class=\"advancedSelected\"";
if ($_SESSION["activateFrames"]=="1")
	$classSelectedFrame1 = " class=\"advancedSelected\"";
elseif ($_SESSION["activateFrames"]=="0")
	$classSelectedFrame0 = " class=\"advancedSelected\"";
if ($_SESSION["displayImages"]=="1")
	$classSelectedImg1 = " class=\"advancedSelected\"";
elseif ($_SESSION["displayImages"]=="0")
	$classSelectedImg0 = " class=\"advancedSelected\"";
if ($_SESSION["displayObjects"]=="1")
	$classSelectedObject1 = " class=\"advancedSelected\"";
elseif ($_SESSION["displayObjects"]=="0")
	$classSelectedObject0 = " class=\"advancedSelected\"";
if ($_SESSION["displayApplets"]=="1")
	$classSelectedApplet1 = " class=\"advancedSelected\"";
elseif ($_SESSION["displayApplets"]=="0")
	$classSelectedApplet0 = " class=\"advancedSelected\"";
if ($_SESSION["parseTables"]=="1")
	$classSelectedTable1 = " class=\"advancedSelected\"";
elseif ($_SESSION["parseTables"]=="0")
	$classSelectedTable0 = " class=\"advancedSelected\"";

if ($pal==1 && $taille!="" && $_REQUEST["typ"]!="TC") {
	$_SESSION["tailleLettre"] = $taille;
	$s = $taille;
	switch($taille) {		
		case "100" : $_SESSION["idTC"] = "textSize1"; break;
		case "125" : $_SESSION["idTC"] = "textSize2"; break;
		case "220" : $_SESSION["idTC"] = "textSize4"; break;
		case "300" : $_SESSION["idTC"] = "textSize5"; break;
		default: $_SESSION["idTC"] = "textSize3"; break;
	}
}
if ($pal==1 && $_REQUEST["b"]!="" && $_REQUEST["typ"]!="F") {
	$_SESSION["couleurFond"] = strtoupper($_REQUEST["b"]);
	$_SESSION["idF"] = "backColor".strtoupper($_REQUEST["b"]);
}
if ($pal==1 && $_REQUEST["f"]!="" && $_REQUEST["typ"]!="CC") {
	$_SESSION["couleurLettre"] = strtoupper($_REQUEST["f"]);
	$_SESSION["idCC"] = "textColor".strtoupper($_REQUEST["f"]);
}

// On arrive
if ($cdlB!="" && $pal!=1 && $typ=="") {
	$_SESSION["couleurFond"] = $cdlB;
	$_SESSION["idF"] = "backColor".$cdlB;
}
if ($cdlF!="" && $pal!=1 && $typ=="") {
	$_SESSION["couleurLettre"] = $cdlF;
	$_SESSION["idCC"] = "textColor".$cdlF;
}

if ($cdlS!="" && $pal!=1 && $typ=="") {
	switch($cdlS) {
		case "1" : $_SESSION["tailleLettre"] = "100"; break;
		case "2" : $_SESSION["tailleLettre"] = "125"; break;
		case "4" : $_SESSION["tailleLettre"] = "220"; break;
		case "5" : $_SESSION["tailleLettre"] = "300"; break;
		default: $_SESSION["tailleLettre"] = "170"; break;
	}
	$_SESSION["idTC"] = "textSize".$cdlS;
}

// Pour sélectionner le bon carré
switch($_SESSION["idF"]) {
	// Couleur de Fond
	case "backColor000000"  : $selBackBlack = " class=\"selected\""; break;
	case "backColorFFFFFF"	: $selBackWhite = " class=\"selected\""; break;
	case "backColor009900"  : $selBackGreen = " class=\"selected\""; break;
	case "backColorFFFF00" : $selBackYellow = " class=\"selected\""; break;
	case "backColor0000FF"	: $selBackBlue = " class=\"selected\""; break;
	default	: $selBackBlack = " class=\"selected\""; break;
}
switch($_SESSION["idTC"]) {
	// Taille des caractères
	case "textSize1"	: $selTxtSizeVS = " class=\"selected\""; break;
	case "textSize2"	: $selTxtSizeS = " class=\"selected\""; break;
	case "textSize4"	: $selTxtSizeL = " class=\"selected\""; break;
	case "textSize5"	: $selTxtSizeVL = " class=\"selected\""; break;
	default	: $selTxtSizeM = " class=\"selected\""; break;
}
switch($_SESSION["idCC"]) {
	// Couleur des caractères
	case "textColor000000"	: $selTxtColorBlack = " class=\"selected\""; break;
	case "textColorFFFFFF"	: $selTxtColorWhite = " class=\"selected\""; break;
	case "textColor009900"	: $selTxtColorGreen = " class=\"selected\""; break;
	case "textColorFFFF00"	: $selTxtColorYellow = " class=\"selected\""; break;
	case "textColor0000FF"	: $selTxtColorBlue = " class=\"selected\""; break;

	default	: $selTxtColorWhite = " class=\"selected\""; break;
}

$apercu = "";
if ($_SESSION["couleurFond"]!="") {
	$apercu .= 'background:#'.$_SESSION["couleurFond"].';';
} else {
	if ($pal==1 && $typ=="F") {
		$apercu .= 'background:#'.$c.';';
	} else {
		$apercu .= 'background:#000000;';
	}
}
if ($_SESSION["couleurLettre"]!="") {
	$apercu .= 'color:#'.$_SESSION["couleurLettre"].';';
	$divApercu = 'style="border-color:#'.$_SESSION["couleurLettre"].';"';
} else {
	if ($pal==1 && $typ=="CC") {
		$apercu .= 'color:#'.$c.';border-color:#'.$c.';';
		$divApercu = 'style="border-color:#'.$c.';"';
	} else {
		$apercu .= 'color:#FFFFFF;border-color:#FFFFFF;';
		$divApercu = 'style="border-color:#FFFFFF;"';
	}
}
if ($_SESSION["tailleLettre"]!="") {
	$apercu .= 'font-size:'.$_SESSION["tailleLettre"].'%;';
} else {
	$apercu .= 'font-size:170%;';
}
if ($apercu!="") {
	$apercu = ' style="'.$apercu.'"';
}

// Par défaut
if ($_SESSION["idF"]=="") {
	$selBackBlack = " class=\"selected\"";
}
if ($_SESSION["idTC"]=="") {
	$selTxtSizeVL = " class=\"selected\"";
}
if ($_SESSION["idCC"]=="") {
	$selTxtColorWhite = " class=\"selected\"";
}

if ($_SESSION["couleurLettre"]!="000000" && $_SESSION["couleurLettre"]!="FFFFFF" && $_SESSION["couleurLettre"]!="009900" && $_SESSION["couleurLettre"]!="FFFF00" && $_SESSION["couleurLettre"]!="0000FF") {
	$_SESSION["idCC"] = "";
	$selTxtColorBlack = "";
	$selTxtColorWhite = "";
	$selTxtColorGreen = "";
	$selTxtColorYellow = "";
	$selTxtColorBlue = "";
}
if ($_SESSION["couleurFond"]!="000000" && $_SESSION["couleurFond"]!="FFFFFF" && $_SESSION["couleurFond"]!="009900" && $_SESSION["couleurFond"]!="FFFF00" && $_SESSION["couleurFond"]!="0000FF") {
	$_SESSION["idF"] = "";
	$selBackBlack = "";
	$selBackWhite = "";
	$selBackGreen = "";
	$selBackYellow = "";
	$selBackBlue = "";
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="fr" xml:lang="fr">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<link rel="stylesheet" type="text/css" href="/style_personalization/styles/styles.css" media="screen" />
		<title><?=$dico['_DICO_TITLE_MODIFIER_PREFERENCES']?></title>
		<link href="/favicon.png" rel="shortcut icon" />
		<script type="text/javascript">
		//<!--
			function getElementsByClassName(oElm, strTagName, strClassName){
				var arrElements = (strTagName == "*" && oElm.all)? oElm.all : oElm.getElementsByTagName(strTagName);
				var arrReturnElements = new Array();
				
				strClassName = strClassName.replace(/\-/g, "\\-");
				
				var oRegExp = new RegExp("(^|\\s)" + strClassName + "(\\s|$)");
				var oElement;
				
				for(var i=0; i<arrElements.length; i++) {
					oElement = arrElements[i];
					if(oRegExp.test(oElement.className)) {
						arrReturnElements.push(oElement);
					}
				}
				return (arrReturnElements)
			}

			function modifCouleurFond(leLi) {
				var leUl = leLi.parentNode.parentNode;

				for (i=0;i<leUl.childNodes.length;i++) {
					leUl.childNodes[i].className='';
				}
				leLi.parentNode.className='selected';
				document.getElementById('formEnregistrerProfil').cdlB_.value = leLi.value;
				document.getElementById('formPalette').b.value = leLi.value;
				document.getElementById('entrerDirect').b.value = leLi.value;
				document.getElementById('apercu').style.backgroundColor = "#"+leLi.value;
			}
			
			function modifTailleTxt(leLi) {
				var leUl = leLi.parentNode.parentNode;

				for (i=0;i<leUl.childNodes.length;i++) {
					leUl.childNodes[i].className='';
				}
				leLi.parentNode.className='selected';
				document.getElementById('apercu').style.color = "#"+leLi.value;
				document.getElementById('formEnregistrerProfil').cdlF_.value = leLi.value;
				document.getElementById('formPalette').f.value = leLi.value;
				document.getElementById('entrerDirect').f.value = leLi.value;
				document.getElementById('divApercu').style.borderColor = "#"+leLi.value;
			}

			function modifCouleurTxt(leLi) {
				var leUl = leLi.parentNode.parentNode;

				for (i=0;i<leUl.childNodes.length;i++) {
					leUl.childNodes[i].className='';
				}
				leLi.parentNode.className='selected';
				document.getElementById('formEnregistrerProfil').cdlS_.value = leLi.value;
				document.getElementById('formPalette').s.value = leLi.value;
				document.getElementById('entrerDirect').s.value = leLi.value;
				document.getElementById('apercu').style.fontSize = leLi.value+"%";
			}
		//-->
		</script>
	</head>
	<body<?if ($_REQUEST['style'] == "bn") {?> class="body"<?}?>>
		<div class="header">
			<h1 class="titreLogoSite"><a href="http://<?=$urlsSite[0]?>"><img src="<?=$logoSite?>" alt="<?=$siteLabel?>" /></a></h1>
			<img src="/style_personalization/images/logo-cdl.png" alt="Confort de lecture" />
			<div class="clearBoth"></div>
		</div>
		<hr class="cache" />
		<form action="loginCdl.php" method="get" class="group" id="formIdent">
<?
//Erreur côté serveur
if ($_REQUEST["errLog"]==1 || $_REQUEST["errLog"]==2) {
	if ($_REQUEST["errLog"]=="2") {
		$txtErreurLog = $dico['_DICO_ERREUR_BAD_PASSWORD']."<br />";
	} else {
		if ($_REQUEST["pseudoLogin"]=="" || $_REQUEST["pseudoLogin"]==$dico['_DICO_VALEUR_LOGIN_IDENT']) {
			$txtErreurLog .= $dico['_DICO_ERREUR_LOGIN_IDENT'] . "<br />";
		} else {
			$pseudoLogin = $_REQUEST["pseudoLogin"];
		}
		if ($_REQUEST["mdpLogin"]=="") {
			$txtErreurLog .= $dico['_DICO_ERREUR_PASSWORD_IDENT'] . "<br />";
		}
		
		if ($txtErreurLog!="") {
			$txtErreurLog = $dico['_DICO_ERREUR_IDENT'] . "<br />".$txtErreurLog;
		}
	}
} else {
	$pseudoLogin = $dico['_DICO_VALEUR_LOGIN_IDENT'];
}
?>
			<div class="cache">
				<input type="hidden" name="id" value="<?=$idSite?>" />
				<input type="hidden" name="p" value="<?=$pageOriginale?>" />
				<input type="hidden" name="style" value="<?=$_REQUEST['style']?>" />
			</div>
			<div class="encadrementImage" id="encadrementImageIdent">
				<h2><?=$dico['_DICO_INTRO_IDENT']?></h2>
			<?
			if ($txtErreurLog!="") {
			?>
				<a name="erreurLog"></a>
				<div class="txtErr"><p><?=$txtErreurLog?></p></div>
			<?
			}
			?>
				<div>
					<div class="divLigneForm"><label for="identify"><?=$dico['_DICO_LABEL_LOGIN_IDENT']?>&nbsp;</label><input id="identify" type="text" name="pseudoLogin" value="<?=$pseudoLogin?>" onfocus="if (this.value==this.defaultValue) this.value='';" onblur="if (this.value=='') this.value=this.defaultValue;" /></div>
					<div class="clearBothSep"></div>
					<div class="divLigneForm"><label for="password"><?=$dico['_DICO_LABEL_PASSWORD_IDENT']?>&nbsp;</label><input id="password" name="mdpLogin" type="password" /></div>
					<div class="clearBothSep"></div>
				</div>
			</div>
			<div id="boutonIdent">
				<div class="inputSubmit"><input class="submit" type="submit" value="<?=$dico['_DICO_BOUTON_VALIDER_IDENT']?>" /></div>
			</div>
		</form>
		<hr class="cache" />
		<div class="group">
			<form action="palette.php" method="post" id="formPalette">
				<div class="cache">
					<input type="hidden" name="b" value="<?=$_SESSION["couleurFond"]?>" />
					<input type="hidden" name="f" value="<?=$_SESSION["couleurLettre"]?>" />
					<input type="hidden" name="s" value="<?=$_SESSION["tailleLettre"]?>" />
					<input type="hidden" name="cdlJs" value="<?=$_SESSION["activateJs"] ? $_SESSION["activateJs"] : $_REQUEST['js'] ?>" />
					<input type="hidden" name="cdlFrames" value="<?=$_SESSION["activateFrames"] ? $_SESSION["activateFrames"] : $_REQUEST['frame'] ?>" />
					<input type="hidden" name="cdlImg" value="<?=$_SESSION["displayImages"] ? $_SESSION["displayImages"] : $_REQUEST['img'] ?>" />
					<input type="hidden" name="cdlObj" value="<?=$_SESSION["displayObjects"] ? $_SESSION["displayObjects"] : $_REQUEST['object'] ?>" />
					<input type="hidden" name="cdlApplet" value="<?=$_SESSION["displayApplets"] ? $_SESSION["displayApplets"] : $_REQUEST['applet'] ?>" />
					<input type="hidden" name="cdlTables" value="<?=$_SESSION["parseTables"] ? $_SESSION["parseTables"] : $_REQUEST['table'] ?>" />
					<input type="hidden" name="id" value="<?=$idSite?>" />
					<input type="hidden" name="p" value="<?=$_REQUEST["p"]?>" />
					<input type="hidden" name="style" value="<?=$_REQUEST["style"]?>" />
				</div>
				<div class="encadrementImage" id="encadrementImagePalette">
					<a name="formPalette"></a>
					<h2><?=$dico['_DICO_INTRO_CONFIG']?></h2>
					<p class="pIntro"><?=$dico['_DICO_EXPLICATION_CONFIG']?></p>
				</div>
				<div id="divContenuConfigsApercu">
					<div id="divConfigs">
						<div class="divConteneurConfig">
							<div class="contenuConfig">
								<a name="fond"></a>
								<fieldset class="encadrementImage">
									<legend><?=$dico['_DICO_LEGEND_COULEUR_FOND']?></legend>
									<ul class="palette" id="backColor">
										<li <?=$selBackBlack?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"backColor000000\" style=\"background-color: black;color: black;border: 1px solid white;height: 64px !important;height: 66px !important!;width: 64px !important;width: 66px !important!;\"><?=$dico['_DICO_LABEL_NOIR']?></label><input type=\"radio\" value=\"000000\" name=\"backcolor\" id=\"backColor000000\" onfocus=\"modifCouleurFond(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="backColor000000" style="background-color: black;color: black;border: 1px solid white;height: 64px !important;height: 66px !important!;width: 64px !important;width: 66px !important!;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=F&amp;class=backColor000000&amp;c=000000#fond" style="display:block;font-size:100%; width:66px;height:66px;color:#000000"><span style="display:none"><?=$dico['_DICO_LABEL_NOIR']?></span></a></label><input type="radio" value="000000" name="backcolor" id="backColor000000" onfocus="modifCouleurFond(this);" /></div></noscript>
										</li>
										<li <?=$selBackWhite?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"backColorFFFFFF\" style=\"background-color: white;color: white;border: 1px solid black;height: 64px !important;height: 66px !important!;width: 64px !important;width: 66px !important!;\"><?=$dico['_DICO_LABEL_BLANC']?></label><input type=\"radio\" value=\"FFFFFF\" name=\"backcolor\" id=\"backColorFFFFFF\" onfocus=\"modifCouleurFond(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="backColorFFFFFF" style="background-color: white;color: white;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=F&amp;class=backColorFFFFFF&amp;c=FFFFFF#fond" style="display:block;font-size:100%;border: 1px solid black;height: 64px !important;height: 66px !important!;width: 64px !important;width: 66px !important!;"><span style="display:none"><?=$dico['_DICO_LABEL_BLANC']?></span></a></label><input type="radio" value="FFFFFF" name="backcolor" id="backColorFFFFFF" onfocus="modifCouleurFond(this);" /></div></noscript>
										</li>
										<li <?=$selBackGreen?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"backColor009900\" style=\"background-color: #009900;color: #009900;\"><?=$dico['_DICO_LABEL_VERT']?></label><input type=\"radio\" value=\"009900\" name=\"backcolor\" id=\"backColor009900\" onfocus=\"modifCouleurFond(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="backColor009900" style="background-color: #009900;color: #009900;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=F&amp;class=backColor009900&amp;c=009900#fond" style="display:block;font-size:100%; width:66px;height:66px;color:#009900;"><span style="display:none"><?=$dico['_DICO_LABEL_VERT']?></span></a></label><input type="radio" value="009900" name="backcolor" id="backColor009900" onfocus="modifCouleurFond(this);" /></div></noscript>
										</li>
										<li <?=$selBackYellow?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"backColorFFFF00\" style=\"background-color: #FFFF00;color: #FFFF00;\"><?=$dico['_DICO_LABEL_JAUNE']?></label><input type=\"radio\" value=\"FFFF00\" name=\"backcolor\" id=\"backColorFFFF00\" onfocus=\"modifCouleurFond(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="backColorFFFF00" style="background-color: #FFFF00;color: #FFFF00;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=F&amp;class=backColorFFFF00&amp;c=FFFF00#fond" style="display:block;font-size:100%; width:66px;height:66px;color:#FFFF00;"><span style="display:none"><?=$dico['_DICO_LABEL_JAUNE']?></span></a></label><input type="radio" value="FFFF00" name="backcolor" id="backColorFFFF00" onfocus="modifCouleurFond(this);" /></div></noscript>
										</li>
										<li <?=$selBackBlue?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"backColor0000FF\" style=\"background-color: #0000FF;color: #0000FF;\"><?=$dico['_DICO_LABEL_BLEU']?></label><input type=\"radio\" value=\"0000FF\" name=\"backcolor\" id=\"backColor0000FF\" onfocus=\"modifCouleurFond(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="backColor0000FF" style="background-color: #0000FF;color: #0000FF;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=F&amp;class=backColor0000FF&amp;c=0000FF#fond" style="display:block;font-size:100%; width:66px;height:66px;color:#0000FF;"><span style="display:none"><?=$dico['_DICO_LABEL_BLEU']?></span></a></label><input type="radio" value="0000FF" name="backcolor" id="backColor0000FF" onfocus="modifCouleurFond(this);" /></div></noscript>
										</li>
									</ul>
									<div class="ligneFlecheVersApercu"><div class="inputSubmit"><input class="submit" type="submit" id="plusDeCouleurs" name="plusDeCouleurs" value="<?=$dico['_DICO_BOUTON_PLUS_DE_COULEURS']?>" title="<?=$dico['_DICO_TITLE_BOUTON_PLUS_DE_COULEURS_FOND']?>" /></div></div>
								</fieldset>
								<div class="clearBoth"></div>
							</div>
						</div>

						<div class="divConteneurConfig" id="divConteneurConfigTailleTexte">
							<div class="contenuConfig">
								<a name="taille"></a>
								<fieldset class="encadrementImage">
									<legend><?=$dico['_DICO_LEGEND_TAILLE_TEXTE']?></legend>
									<ul class="palette" id="textSize">
										<li <?=$selTxtSizeVS?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textSize1\" style=\"background: url(images/verysmall<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_TRES_PETITE']?></span></label><input type=\"radio\" value=\"100\" name=\"textsize\" id=\"textSize1\" onfocus=\"modifCouleurTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textSize1" style="background: url(images/verysmall<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=TC&amp;class=textSize1&amp;t=90#taille" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_TRES_PETITE']?></span></a></label><input type="radio" checked="checked" value="100" name="textsize" id="textSize1" onfocus="modifCouleurTxt(this);" /></div></noscript>				
										</li>
										<li <?=$selTxtSizeS?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textSize2\" style=\"background: url(images/small<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_PETITE']?></span></label><input type=\"radio\" value=\"125\" name=\"textsize\" id=\"textSize2\" onfocus=\"modifCouleurTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textSize2" style="background: url(images/small<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=TC&amp;class=textSize2&amp;t=120#taille" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_PETITE']?></span></a></label><input type="radio" checked="checked" value="125" name="textsize" id="textSize2" onfocus="modifCouleurTxt(this);" /></div></noscript>
										</li>
										<li <?=$selTxtSizeM?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textSize3\" style=\"background: url(images/medium<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_MOYENNE']?></span></label><input type=\"radio\" checked=\"checked\" value=\"170\" name=\"textsize\" id=\"textSize3\" onfocus=\"modifCouleurTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textSize3" style="background: url(images/medium<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=TC&amp;class=textSize3&amp;t=150#taille" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_MOYENNE']?></span></a></label><input type="radio" checked="checked" value="170" name="textsize" id="textSize3" onfocus="modifCouleurTxt(this);" /></div></noscript>
										</li>
										<li <?=$selTxtSizeL?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textSize4\" style=\"background: url(images/large<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_GRANDE']?></span></label><input type=\"radio\" value=\"220\" name=\"textsize\" id=\"textSize4\" onfocus=\"modifCouleurTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textSize4" style="background: url(images/large<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=TC&amp;class=textSize4&amp;t=200#taille" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_GRANDE']?></span></a></label><input type="radio" checked="checked" value="220" name="textsize" id="textSize4" onfocus="modifCouleurTxt(this);" /></div></noscript>
										</li>
										<li <?=$selTxtSizeVL?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textSize5\" style=\"background: url(images/verylarge<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_TRES_GRANDE']?></span></label><input type=\"radio\" value=\"300\" name=\"textsize\" id=\"textSize5\" onfocus=\"modifCouleurTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textSize5" style="background: url(images/verylarge<?= ($_REQUEST['style'] == 'bn') ? '_black' : '' ?>.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=TC&amp;class=textSize5&amp;t=300#taille" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_TRES_GRANDE']?></span></a></label><input type="radio" checked="checked" value="300" name="textsize" id="textSize5" onfocus="modifCouleurTxt(this);" /></div></noscript>
										</li>
									</ul>
								</fieldset>
								<div class="clearBoth"></div>
							</div>
						</div>
						<div class="divConteneurConfig" id="divConteneurConfigCouleurTexte">
							<div class="contenuConfig">
								<a name="couleur"></a>
								<fieldset class="encadrementImage">
									<legend><?=$dico['_DICO_LEGEND_COULEUR_TEXTE']?></legend>
									<ul class="palette" id="textColor">
										<li <?=$selTxtColorBlack?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textColor000000\" style=\"background: url(images/textblack.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_NOIR']?></span></label><input type=\"radio\" value=\"000000\" name=\"textColor\" id=\"textColor000000\" onfocus=\"modifTailleTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textColor000000" style="background: url(images/textblack.png) center no-repeat;"><a<?=$classSelectedJs?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=CC&amp;class=textColor000000&amp;c=000000#couleur" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_NOIR']?></span></a></label><input type="radio" value="000000" name="textColor" id="textColor000000" onfocus="modifTailleTxt(this);" /></div></noscript>								
										</li>
										<li <?=$selTxtColorWhite?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textColorFFFFFF\" style=\"background: url(images/textwhite.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_BLANC']?></span></label><input type=\"radio\" value=\"FFFFFF\" name=\"textColor\" id=\"textColorFFFFFF\" onfocus=\"modifTailleTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textColorFFFFFF" style="background: url(images/textwhite.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=CC&amp;class=textColorFFFFFF&amp;c=FFFFFF#couleur" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_BLANC']?></span></a></label><input type="radio" value="FFFFFF" name="textColor" id="textColorFFFFFF" onfocus="modifTailleTxt(this);" /></div></noscript>
										</li>
										<li <?=$selTxtColorGreen?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textColor009900\" style=\"background: url(images/textgreen.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_VERT']?></span></label><input type=\"radio\" value=\"009900\" name=\"textColor\" id=\"textColor009900\" onfocus=\"modifTailleTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textColor009900" style="background: url(images/textgreen.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=CC&amp;class=textColor009900&amp;c=009900#couleur" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_VERT']?></span></a></label><input type="radio" value="009900" name="textColor" id="textColor009900" onfocus="modifTailleTxt(this);" /></div></noscript>
										</li>
										<li <?=$selTxtColorYellow?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textColorFFFF00\" style=\"background: url(images/textyellow.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_JAUNE']?></span></label><input type=\"radio\" value=\"FFFF00\" name=\"textColor\" id=\"textColorFFFF00\" onfocus=\"modifTailleTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textColorFFFF00" style="background: url(images/textyellow.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=CC&amp;class=textColorFFFF00&amp;c=FFFF00#couleur" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_JAUNE']?></span></a></label><input type="radio" value="FFFF00" name="textColor" id="textColorFFFF00" onfocus="modifTailleTxt(this);" /></div></noscript>
										</li>
										<li <?=$selTxtColorBlue?>>
											<script type="text/javascript">
											//<!--
											document.write("<label for=\"textColor0000FF\" style=\"background: url(images/textblue.png) center no-repeat;\"><span><?=$dico['_DICO_LABEL_BLEU']?></span></label><input type=\"radio\" value=\"0000FF\" name=\"textColor\" id=\"textColor0000FF\" onfocus=\"modifTailleTxt(this);\" />");
											//--></script><noscript><div style="display:inline;"><label for="textColor0000FF" style="background: url(images/textblue.png) center no-repeat;"><a href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;p=<?=$_REQUEST["p"]?>&amp;id=<?=$idSite?>&amp;typ=CC&amp;class=textColor0000FF&amp;c=0000FF#couleur" style="display:block;font-size:10%; width:66px;height:66px;color:#000000;"><span style="display:none"><?=$dico['_DICO_LABEL_BLEU']?></span></a></label><input type="radio" value="0000FF" name="textColor" id="textColor0000FF" onfocus="modifTailleTxt(this);" /></div></noscript>
										</li>
									</ul>
									<div class="ligneFlecheVersApercu"><div class="inputSubmit"><input class="submit" type="submit" name="plusDeCouleursTexte" id="plusDeCouleursTexte" value="<?=$dico['_DICO_BOUTON_PLUS_DE_COULEURS']?>" title="<?=$dico['_DICO_TITLE_BOUTON_PLUS_DE_COULEURS_TEXTE']?>" /></div></div>
								</fieldset>
								<div class="clearBoth"></div>
							</div>
						</div>
					</div>
					<br class="cache" />
					<div id="divApercu" <?=$divApercu?>>
						<button type="button" name="apercu" id="apercu" title="<?=$dico['_DICO_TITLE_BOUTON_APERCU']?>" <?=$apercu?>><?=$dico['_DICO_BOUTON_APERCU']?></button>
					</div>
				</div>
			</form>
			<form action="entreeDirect.php" method="post" id="entrerDirect">
				<div class="cache">
					<input type="hidden" name="b" value="<?=$_SESSION["couleurFond"]?>" />
					<input type="hidden" name="f" value="<?=$_SESSION["couleurLettre"]?>" />
					<input type="hidden" name="s" value="<?=$_SESSION["tailleLettre"]?>" />
					<input type="hidden" name="cdlJs" value="<?=$_SESSION["activateJs"] ? $_SESSION["activateJs"] : $_REQUEST['js'] ?>" />
					<input type="hidden" name="cdlFrames" value="<?=$_SESSION["activateFrames"] ? $_SESSION["activateFrames"] : $_REQUEST['frame'] ?>" />
					<input type="hidden" name="cdlImg" value="<?=$_SESSION["displayImages"] ? $_SESSION["displayImages"] : $_REQUEST['img'] ?>" />
					<input type="hidden" name="cdlObj" value="<?=$_SESSION["displayObjects"] ? $_SESSION["displayObjects"] : $_REQUEST['object'] ?>" />
					<input type="hidden" name="cdlApplet" value="<?=$_SESSION["displayApplets"] ? $_SESSION["displayApplets"] : $_REQUEST['applet'] ?>" />
					<input type="hidden" name="cdlTables" value="<?=$_SESSION["parseTables"] ? $_SESSION["parseTables"] : $_REQUEST['table'] ?>" />
					<input type="hidden" name="id" value="<?=$idSite?>" />
					<input type="hidden" name="p" value="<?=$pageOriginale?>" />
					<input type="hidden" name="style" value="<?=$_REQUEST['style']?>" />
					<br class="cache" />
				</div>
<!-- Ces fonctionnalités seront activées très prochainement :
				<fieldset class="autresParametres">
					<a name="advanded"></a>
					<legend><?=$dico['_DICO_PARAMETRES_AVANCES_LEGENDE']?></legend>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_JS']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_JS_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="activateJavascript1" name="activateJavascript" value="1" onchange="document.getElementById(\'formEnregistrerProfil\').cdlJs.value = this.value;document.getElementById(\'entrerDirect\').cdlJs.value = this.value"<?=$_REQUEST['js']=="1" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="activateJavascript1"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedJs1?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=js&amp;class=1#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></a></div></noscript>&nbsp;&nbsp;&nbsp;<script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="activateJavascript0" name="activateJavascript" value="0" onchange="document.getElementById(\'formEnregistrerProfil\').cdlJs.value = this.value;document.getElementById(\'entrerDirect\').cdlJs.value = this.value"<?=$_REQUEST['js']=="0" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="activateJavascript0"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_NON']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedJs0?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=js&amp;class=0#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></a></div></noscript></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_FRAME']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_FRAME_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="activateFrames1" name="activateFrames" value="1" onchange="document.getElementById(\'formEnregistrerProfil\').cdlFrames.value = this.value;document.getElementById(\'entrerDirect\').cdlFrames.value = this.value"<?=$_REQUEST['frame']=="1" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="activateFrames1"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedFrame1?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=frame&amp;class=1#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></a></div></noscript>&nbsp;&nbsp;&nbsp;<script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="activateFrames0" name="activateFrames" value="0" onchange="document.getElementById(\'formEnregistrerProfil\').cdlFrames.value = this.value;document.getElementById(\'entrerDirect\').cdlFrames.value = this.value"<?=$_REQUEST['frame']=="0" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="activateFrames0"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_NON']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedFrame0?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=frame&amp;class=0#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></a></div></noscript></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_IMG']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_IMG_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="displayImages1" name="displayImages" value="1" onchange="document.getElementById(\'formEnregistrerProfil\').cdlImg.value = this.value;document.getElementById(\'entrerDirect\').cdlImg.value = this.value"<?=$_REQUEST['img']=="1" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="displayImages1"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedImg1?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=img&amp;class=1#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></a></div></noscript>&nbsp;&nbsp;&nbsp;<script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="displayImages0" name="displayImages" value="0" onchange="document.getElementById(\'formEnregistrerProfil\').cdlImg.value = this.value;document.getElementById(\'entrerDirect\').cdlImg.value = this.value"<?=$_REQUEST['img']=="0" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="displayImages0"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_NON']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedImg0?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=img&amp;class=0#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></a></div></noscript></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_OBJECT']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_OBJECT_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="displayObjects1" name="displayObjects" value="1" onchange="document.getElementById(\'formEnregistrerProfil\').cdlObj.value = this.value;document.getElementById(\'entrerDirect\').cdlObj.value = this.value"<?=$_REQUEST['object']=="1" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="displayObjects1"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedObject1?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=object&amp;class=1#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></a></div></noscript>&nbsp;&nbsp;&nbsp;<script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="displayObjects0" name="displayObjects" value="0" onchange="document.getElementById(\'formEnregistrerProfil\').cdlObj.value = this.value;document.getElementById(\'entrerDirect\').cdlObj.value = this.value"<?=$_REQUEST['object']=="0" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="displayObjects0"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_NON']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedObject0?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=object&amp;class=0#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></a></div></noscript></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_APPLET']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_APPLET_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="displayApplets1" name="displayApplets" value="1" onchange="document.getElementById(\'formEnregistrerProfil\').cdlApplet.value = this.value;document.getElementById(\'entrerDirect\').cdlApplet.value = this.value"<?=$_REQUEST['applet']=="1" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="displayApplets1"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedApplet1?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=applet&amp;class=1#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></a></div></noscript>&nbsp;&nbsp;&nbsp;<script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="displayApplets0" name="displayApplets" value="0" onchange="document.getElementById(\'formEnregistrerProfil\').cdlApplet.value = this.value;document.getElementById(\'entrerDirect\').cdlApplet.value = this.value"<?=$_REQUEST['applet']=="0" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="displayApplets0"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_NON']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedApplet0?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=applet&amp;class=0#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></a></div></noscript></div></div>
						<div class="clearBothSep2"></div>
					</div>
					<div class="divLigneForm">
						<div class="leftForm"><?=$dico['_DICO_PARAMETRES_AVANCES_TABLE']?> :&nbsp;<br /><span class="info"><?=$dico['_DICO_PARAMETRES_AVANCES_TABLE_INFO']?></span></div>
						<div class="rightForm"><div class="radio"><script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="parseTablesToList1" name="parseTablesToList" value="1" onchange="document.getElementById(\'formEnregistrerProfil\').cdlTables.value = this.value;document.getElementById(\'entrerDirect\').cdlTables.value = this.value"<?=$_REQUEST['table']=="1" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="parseTablesToList1"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedTable1?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=table&amp;class=1#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_OUI']?></a></div></noscript>&nbsp;&nbsp;&nbsp;<script type="text/javascript">//<![CDATA[
						document.write('<input type="radio" id="parseTablesToList0" name="parseTablesToList" value="0" onchange="document.getElementById(\'formEnregistrerProfil\').cdlTables.value = this.value;document.getElementById(\'entrerDirect\').cdlTables.value = this.value"<?=$_REQUEST['table']=="0" ? " checked=\"checked\"" : "" ?> />');
						//]]></script><label for="parseTablesToList0"><script type="text/javascript">document.write('<?=$dico['_DICO_PARAMETRES_AVANCES_NON']?>');</script></label><noscript><div style="display:inline"><a<?=$classSelectedTable0?> href="parametrage.php?style=<?=$_REQUEST['style']?>&amp;id=<?=$idSite?>&amp;p=<?=$cdlP?>&amp;typ=table&amp;class=0#advanded"><?=$dico['_DICO_PARAMETRES_AVANCES_NON']?></a></div></noscript></div></div>
						<div class="clearBothSep2"></div>
					</div>
				</fieldset>
-->
				<div class="clearBoth"><br /></div>
				<div id="divBoutons">
					<hr class="cache" />
					<div class="ligneFlecheVersApercu" id="divAccedezAuSite"><div class="inputSubmit"><input class="submit" type="submit" id="accedezAuSite" name="accedezAuSite" value="<?=$dico['_DICO_BOUTON_ACCEDER']?>" /></div></div>
					<div class="ou"><?=$dico['_DICO_OU']?></div>
					<div class="ligneFlecheVersApercu"><div class="inputSubmit"><a class="submit2" href="#formEnregistrer"><?=$dico['_DICO_LIEN_ENREGISTRER']?></a></div></div>
				</div>
			</form>
		</div>
		<hr class="cache" />
<?
//Erreur côté serveur
if ($_REQUEST["err"]==1) {
	if ($_REQUEST["pseudoCdl"]=="" || $_REQUEST["pseudoCdl"]==$dico['_DICO_VALEUR_LOGIN_ENREGISTRER']) {
		$txtErreur .= $dico['_DICO_ERREUR_LOGIN_ENREGISTRER'] . "<br />";
	} else {
		$pseudo = $_REQUEST["pseudoCdl"];
	}
	if ($_REQUEST["mdpCdl"]=="") {
		$txtErreur .= $dico['_DICO_ERREUR_PASSWORD_ENREGISTRER'] . "<br />";
	}
	if ($_REQUEST["confMdpCdl"]=="") {
		$txtErreur .= $dico['_DICO_ERREUR_CONFIRM_PASSWORD_ENREGISTRER'] . "<br />";
	}
	if ($_REQUEST["mdpCdl"]!="" && $_REQUEST["mdpCdl"]!=$_REQUEST["confMdpCdl"]) {
		$txtErreur .= $dico['_DICO_ERREUR_CONFIRM_PASSWORD_PASSWORD_ENREGISTRER'] . "<br />";
	}
	if ($txtErreur!="") {
		$txtErreur = $dico['_DICO_ERREUR_ENREGISTRER'] . "<br />".$txtErreur;
	}
} else if ($_REQUEST["err"]==2) {
	// l'utilisateur existe déjà
	$txtErreur .= $dico['_DICO_ERREUR_UTILISATEUR_EXISTE_DEJA'];
}

$pseudo = $_SESSION["loginUserCDL"] ? $_SESSION["loginUserCDL"] : ($_REQUEST["pseudoCdl"] ? $_REQUEST["pseudoCdl"] : $dico['_DICO_VALEUR_LOGIN_ENREGISTRER']);
?>
		<form action="saveParamCdl.php" method="get" class="group" id="formEnregistrerProfil">
			<div class="cache">
				<input type="hidden" name="id" value="<?=$idSite?>" />
				<input type="hidden" name="cdlB_" value="<?=$_SESSION["couleurFond"]?>" />
				<input type="hidden" name="cdlF_" value="<?=$_SESSION["couleurLettre"]?>" />
				<input type="hidden" name="cdlS_" value="<?=$_SESSION["tailleLettre"]?>" />
				<input type="hidden" name="cdlJs" value="<?=$_SESSION["activateJs"] ? $_SESSION["activateJs"] : $_REQUEST['js'] ?>" />
				<input type="hidden" name="cdlFrames" value="<?=$_SESSION["activateFrames"] ? $_SESSION["activateFrames"] : $_REQUEST['frame'] ?>" />
				<input type="hidden" name="cdlImg" value="<?=$_SESSION["displayImages"] ? $_SESSION["displayImages"] : $_REQUEST['img'] ?>" />
				<input type="hidden" name="cdlObj" value="<?=$_SESSION["displayObjects"] ? $_SESSION["displayObjects"] : $_REQUEST['object'] ?>" />
				<input type="hidden" name="cdlApplet" value="<?=$_SESSION["displayApplets"] ? $_SESSION["displayApplets"] : $_REQUEST['applet'] ?>" />
				<input type="hidden" name="cdlTables" value="<?=$_SESSION["parseTables"] ? $_SESSION["parseTables"] : $_REQUEST['table'] ?>" />
				<input type="hidden" name="p" value="<?=$pageOriginale?>" />
				<input type="hidden" name="style" value="<?=$_REQUEST['style']?>" />
			</div>
			<div class="encadrementImage" id="encadrementImageEnregistrer">
				<a name="erreur"></a><h2><a id="lienFormEnregistrer" name="formEnregistrer"><?=$dico['_DICO_ENREGISTRER_PROFIL']?></a></h2>
		
		<?
		if ($txtErreur!="") {
		?>
				<div class="txtErr"><p><?=$txtErreur?></p></div>
		<?
		}
		?>
				<div>
					<div class="divLigneForm"><label for="newIdentify"><?=$dico['_DICO_LABEL_LOGIN_ENREGISTRER']?>&nbsp;</label><input id="newIdentify" name="pseudoModif" type="text" value="<?=$pseudo?>" onfocus="if (this.value==this.defaultValue) this.value='';" onblur="if (this.value=='') this.value=this.defaultValue;" /></div>
					<div class="clearBothSep"></div>
					<div class="divLigneForm"><label for="newPassword"><?=$dico['_DICO_LABEL_PASSWORD_ENREGISTRER']?>&nbsp;</label><input id="newPassword" name="mdpModif" type="password" value="<?=$_REQUEST["mdpCdl"]?>" /></div>
					<div class="clearBothSep"></div>
					<div class="divLigneForm"><label for="cNewPassword"><?=$dico['_DICO_LABEL_CONFIRM_PASSWORD_ENREGISTRER']?>&nbsp;</label><input id="cNewPassword" name="confMdpModif" type="password" value="<?=$_REQUEST["confMdpCdl"]?>" /></div>
					<div class="clearBothSep"></div>
				</div>
				<div class="inputSubmit" id="divBoutonEnregistrer"><input class="submit" type="submit" value="<?=$dico['_DICO_BOUTON_VALIDER_ENREGISTRER']?>" id="enregistrerAccederAuSite" /></div>
			</div>
			<hr class="cache" />
		</form>
	</body>
</html>