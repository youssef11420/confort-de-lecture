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

	require ("../configuration/constantes.php");
	require ("inc/dbManager.class.php");
	require ("inc/cryptManager.class.php");
	require ("inc/errorManager.class.php");

	$parserUrl = "http://".$_SERVER['SERVER_NAME']."/filtre/index.pl";

	$ErrReport = new errorManager();
	$ErrReport->start();

	define("DB_HOST",$dbHost);
	define("DB_PORT","3306");
	define("DB_LOGIN",$dbLogin);
	define("DB_PASSWORD",$dbPassword);
	define("DB_NAME",$dbName);

	define("DEBUG_SQL",1);

	$DB = new dbManager();
	$DB->connect();

	$cryptMng = new cryptManager(CRYPT_KEY);

	/**
	 * Applique la fonction stripslashes recursivement
	 */
	function stripslashes_deep($value) {
	   $value = is_array($value) ? array_map('stripslashes_deep', $value) : stripslashes($value);
	   return $value;
	} 
	function protectSlashes($value) {
	   if (get_magic_quotes_gpc()) {
		   $value = stripslashes_deep($value);
	   }
	   return $value;
	}

	/**
	 * Protège la variable avant l'insertion
	 */
	function quote_smart($value) {
	   // Stripslashes si nécessaire
	   $value = protectSlashes($value);
	   // Protection si ce n'est pas un entier
	   if (!is_int($value)) {
		   $value = "'" . mysql_real_escape_string($value) . "'";
	   }
	   return $value;
	}
?>