<?php
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


class dbManager {

	var $table_prefix = DB_PREFIX;
	var $debug;

	//----------------------------------------------------------------------------------------
	##### Appel du constructeur 
	//----------------------------------------------------------------------------------------
	function dbManager($prefix="") {
		if ($prefix!="")
			$this->table_prefix=$prefix;
		$this->debug = DEBUG_SQL;
	}

	//----------------------------------------------------------------------------------------
	##### Connexion à la base de données 
	//----------------------------------------------------------------------------------------
	function connect($host=DB_HOST, $port=DB_PORT, $login=DB_LOGIN, $pass=DB_PASSWORD, $db=DB_NAME) {
		if ($port > 0) $host = "$host:$port";
		@mysql_connect($host, $login, $pass);
		return @mysql_select_db($db);
	}

	//----------------------------------------------------------------------------------------
	##### Appel des requêtes SQL 
	//----------------------------------------------------------------------------------------
	function execute($query, $debug=-1) {
		static $tt = 0;

		switch ($debug) {
			case -1 :
				$this->debug = DEBUG_SQL;
			break;
			case 0 :
				$this->debug = 0;
			break;
			case 1 :
				$this->debug = 1;
			break;
		}

		$query = $this->formatQuery($query);

		if ($this->debug)
			$m1 = microtime();

		$result = mysql_query($query);

		if ($this->debug)
			echo '<span style="font-family: Arial; font-size: 11px; color: #000000; background-color: #FFFFFF; border: solid 1px #888888; width: 100%; padding-left: 2px; text-align: left;">';
		
		if ($this->debug) {
			$m2 = microtime();
			list($usec, $sec) = explode(" ", $m1);
			list($usec2, $sec2) = explode(" ", $m2);
			$dt = $sec2 + $usec2 - $sec - $usec;
			$tt += $dt;
			echo "<b>".htmlentities($query)."</b>";
			echo "<br><font color='blue'>Temps d'exécution de la requête&nbsp;: </font>".sprintf("%3f", $dt)." s<br><font color='green'>Cumulé&nbsp;: </font>$tt s\n";
			echo "<br><font color='darkorange'>Nombre de tuples affectés :</font> ".mysql_affected_rows();
		}

		if ($this->debug AND $s = mysql_error()) {
			echo "<p><font color='red' face='arial' style='font-size: 11px'>";
			echo "<b>Message d'erreur&nbsp;: </b>&laquo; ".htmlentities($s)." &raquo;</font>";
		}

		if ($this->debug)
			echo "</span><p>";

		return $result;
	}


	//----------------------------------------------------------------------------------------
	##### Passage d'une requête standardisée 
	//----------------------------------------------------------------------------------------
	function formatQuery($query) {

		$suite = '';

		// changer les noms des tables ($table_prefix)
		if (eregi('[[:space:]](VALUES|WHERE)[[:space:]].*$', $query, $regs)) {
			$suite = $regs[0];
			$query = substr($query, 0, -strlen($suite));
		}
		$query = eregi_replace(DB_PREFIX."_", $this->table_prefix."_", $query) . $suite;

		return $query;
	}


	//----------------------------------------------------------------------------------------
	##### Récupération, traitements et analyses de données
	//----------------------------------------------------------------------------------------
	function fetchArray($r) {
		if ($r)
			return mysql_fetch_array($r);
	}

	function fetchObject($r) {
		if ($r)
			return mysql_fetch_object($r);
	}

	function fetchRow($r) {
		if ($r)
			return mysql_fetch_row($r);
	}

	function fetchField($r) {
		if ($r)
			return mysql_fetch_field($r);
	}

	function fetchLengths($r) {
		if ($r)
			return mysql_fetch_lengths($r);
	}

	function fieldName($r, $offset) {
		if ($r)
			return mysql_field_name($r, $offset);
	}

	function fieldType($r, $offset) {
		if ($r)
			return mysql_field_type($r, $offset);
	}

	function fieldLen($r, $offset) {
		if ($r)
			return mysql_field_len($r, $offset);
	}

	function listFields($database=DATABASE, $table) {
		if ($table && $database)
			return mysql_list_fields($database, $table);
	}

	function listTables($database=DATABASE) {
		if ($database)
			return mysql_list_tables($database);
	}

	function numRows($r) {
		if ($r)
			return mysql_num_rows($r);
	}

	function numFields($r) {
		if ($r)
			return mysql_num_fields($r);
	}

	function dataSeek($r, $row_number=0) {
		if ($r)
			return mysql_data_seek($r, $row_number);
	}

	function freeResult($r) {
		if ($r)
			return mysql_free_result($r);
	}

	function optimize($table="") {
		if ($table) {
			$this->execute("OPTIMIZE TABLE `".$table."`");
		} else {
			$r = $this->listTables();
			while ($row = mysql_fetch_row($r)) {
				$this->execute("OPTIMIZE TABLE `".$row[0]."`");
			}
		}
	}

	function getMaxId($field,$table) {
		if ($table && $field) {
			$result = $this->execute("SELECT MAX(".$field.") as max_id FROM ".$table);
			if ($row = $this->fetchArray($result)) {
				$maxId = $row['max_id'];
			}
		}
		return $maxId;
	}

	function getId($field,$table) {
		if ($table && $field) {
			$id = $this->getMaxId($field,$table) + 1;
		}
		return $id;
	}

	function getRows($result) {
		$rows = array();
		if ($result) {
			while ($row = $this->fetchArray($result)) {
				$rows[] = $row;
			}
		}
		return $rows;
	}

	function insertId() {
		return mysql_insert_id();
	}

	function commit() {
		$this->execute("COMMIT");
	}

	function rollback() {
		$this->execute("ROLLBACK");
	}

	function begin() {
		$this->execute("BEGIN");
	}

	function lock($table) {
		if ($table) {
			$this->execute("LOCK TABLES ".$table." WRITE");
		}
	}

	function unlock() {
		$this->execute("UNLOCK TABLES");
	}

	function info() {
		return mysql_info();
	}

	function sqlError() {
		return mysql_error();
	}

	function sqlErrNo() {
		return mysql_errno();
	}

}
?>