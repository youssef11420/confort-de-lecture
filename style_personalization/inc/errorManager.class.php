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


class errorManager {

	var $_mailAlert;
	var $_DB;
	var $_logMsg = array();
	var $_errors = 0;

	var $_restoreErrorReporting;
	var $_restoreErrorHandler;

	var $_defaultErrorReporting;

	var $_errorType = array (
			E_ERROR				=>  "Error",
			E_WARNING			=>  "Warning",
			E_PARSE				=>  "Parsing Error",
			E_NOTICE			=>  "Notice",
			E_CORE_ERROR		=>  "Core Error",
			E_CORE_WARNING		=>  "Core Warning",
			E_COMPILE_ERROR		=>  "Compile Error",
			E_COMPILE_WARNING	=>  "Compile Warning",
			E_USER_ERROR		=>  "User Error",
			E_USER_WARNING		=>  "User Warning",
			E_USER_NOTICE		=>  "User Notice"
		);

	var $_notDisplayError = array (
			E_NOTICE
		);

	var $_errorsTrace = array (
			E_USER_ERROR,
			E_USER_WARNING,
			E_USER_NOTICE
		);

	function errorManager () {
		$this->_defaultErrorReporting = E_ALL ^ E_NOTICE;
	}

	function errorHandler ($errNo, $errMsg, $fileName, $lineNum, $vars) {

		$this->_errors++;
		$err = $this->_errors;
		$this->_logMsg[$err]["DATETIME"] = date("Y-m-d H:i:s");
		$this->_logMsg[$err]["ERRORNUM"] = $errNo;
		$this->_logMsg[$err]["ERRORTYPE"] = $this->_errorType[$errNo];
		$this->_logMsg[$err]["ERRORMSG"] = $errMsg;
		$this->_logMsg[$err]["FILE"] = $fileName;
		$this->_logMsg[$err]["LINE"] = $lineNum;
		$this->_logMsg[$err]["SESSIONID"] = session_id();
		$this->_logMsg[$err]["BROWSER"] = $_SERVER["HTTP_USER_AGENT"];

		if (in_array($errNo, $this->_errorsTrace))
			$this->_logMsg[$err]["VARS"] = wddx_serialize_value($vars, "Variables") ;
		else
			$this->_logMsg[$err]["VARS"] = "";

	}

	function start () {
		$this->_restoreErrorReporting = error_reporting($this->_defaultErrorReporting);
		$this->_restoreErrorHandler = set_error_handler(array(&$this,"errorHandler"));
	}

	function stop () {
		error_reporting($this->_restoreErrorReporting);
	}

	function setMailAlert($mail) {
		if (isset($mail))
			$this->_mailAlert = $mail;
	}

	function display () {
		$allErrors = "";

		foreach ($this->_logMsg as $errDisplay) {

			if (!in_array($errDisplay["ERRORNUM"],$this->_notDisplayError)) {
				$allErrors .= "<span style='font-family: Arial; font-size: 11px; color: #000000; background-color: #FFFFFF; border: solid 1px #888888; width: 100%; padding-left: 2px; text-align: left;'>";
				
				$allErrors .= "<font color='red' face='arial' style='font-size: 11px'><b>TYPE D'ERREUR : </b></font>" . $errDisplay["ERRORTYPE"] . "<br /><br />";
				$allErrors .= "<font color='darkblue' face='arial' style='font-size: 11px'><b>FICHIER : </b></font>" . $errDisplay["FILE"] . "<br />";
				$allErrors .= "<font color='#00AA00' face='arial' style='font-size: 11px'><b>LIGNE : </b></font>" . $errDisplay["LINE"] . "<br /><br />";
				$allErrors .= "<font color='darkorange' face='arial' style='font-size: 11px'><b>MESSAGE : </b></font>" . $errDisplay["ERRORMSG"] . "<br />";

				$allErrors .= "</span><p>";
			}
		}

		echo $allErrors;
	}

	function sendMailAlert() {

		if ($this->_mailAlert) {

			$subject = HEAD_TITLE." : Serveur : Erreurs";
			$from = MAIL_WEBMASTER;
			$replyTo = MAIL_WEBMASTER;
			$to = $this->_mailAlert;

			$errorCount = 0;

			foreach ($this->_logMsg as $errDisplay) {

				if (!in_array($errDisplay["ERRORNUM"],$this->_notDisplayError)) {
					
					$errorCount++;

					/*$allErrorsTxt .= "TYPE D'ERREUR : " . $errDisplay["ERRORTYPE"] . "\n";
					$allErrorsTxt .= "FICHIER : " . $errDisplay["FILE"] . "\n";
					$allErrorsTxt .= "LIGNE : " . $errDisplay["LINE"] . "\n";
					$allErrorsTxt .= "MESSAGE : " . $errDisplay["ERRORMSG"] . "\n";
					$allErrorsTxt .= "SESSION ID : " . $errDisplay["SESSIONID"] . "\n";
					$allErrorsTxt .= "NAVIGATEUR : " . $errDisplay["BROWSER"] . "\n\n";*/

					$allErrorsHtml .= "<span style='font-family: Arial; font-size: 11px; color: #000000; background-color: #FFFFFF; border: solid 1px #888888; width: 100%; padding-left: 2px; text-align: left;'>";
					$allErrorsHtml .= "<font color='red' face='arial' style='font-size: 11px'><b>TYPE D'ERREUR : </b></font>" . $errDisplay["ERRORTYPE"] . "<br /><br />";
					$allErrorsHtml .= "<font color='darkblue' face='arial' style='font-size: 11px'><b>FICHIER : </b></font>" . $errDisplay["FILE"] . "<br />";
					$allErrorsHtml .= "<font color='#00AA00' face='arial' style='font-size: 11px'><b>LIGNE : </b></font>" . $errDisplay["LINE"] . "<br /><br />";
					$allErrorsHtml .= "<font color='darkorange' face='arial' style='font-size: 11px'><b>MESSAGE : </b></font>" . $errDisplay["ERRORMSG"] . "<br /><br />";
					$allErrorsHtml .= "<font color='darkblue' face='arial' style='font-size: 11px'><b>SESSION ID : </b></font>" . $errDisplay["SESSIONID"] . "<br />";
					$allErrorsHtml .= "<font color='darkblue' face='arial' style='font-size: 11px'><b>NAVIGATEUR : </b></font>" . $errDisplay["BROWSER"] . "<br />";
					$allErrorsHtml .= "</span><p>";

				}
			}

			$limite = "_----------=_parties_".md5(uniqid (rand())); 

			$mailMime = "From: ".HEAD_TITLE." - Serveur <".$from.">\n";
		
			$mailMime .= "Date: ".date("r")."\n"; 
			$mailMime .= "MIME-Version: 1.0\n"; 
			$mailMime .= "Content-Type: multipart/alternative;boundary=\"".$limite."\""; 
  
			/*$message = "--".$limite."\n"; 
			$message .= "Content-Type: text/plain\n"; 
			$message .= "charset=\"UTF-8\"\n"; 
			$message .= "Content-Transfer-Encoding: 8bit\n\n";
			$message .= $allErrorsTxt; */

			$message .= "\n\n--".$limite."\n"; 
			$message .= "Content-Type: text/html\n"; 
			$message .= "charset=\"UTF-8\"\n"; 
			$message .= "Content-Transfer-Encoding: 8bit\n\n"; 
			$message .= $allErrorsHtml; 
  	
			if ($errorCount>0) {
				mail($to, $subject, $message, $mailMime);
			}
		}
	}
}

?>