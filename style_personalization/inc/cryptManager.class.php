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


class cryptManager {
	
	var $cle;

	function cryptManager($cle="") {
		$this->cle = $cle;
	}

	//
	// Fonction pour générer une clé de décryptage
	//
	function _genererCle($text) { 
		$cle = $this->cle;
		$cle = md5($cle); 
		$cpt = 0; 
		$temp = ""; 
		for ($i=0; $i<strlen($text); $i++) { 
			if ($cpt==strlen($cle))
				$cpt=0; 
			$temp.= substr($text,$i,1) ^ substr($cle,$cpt,1); 
			$Compteur++; 
		} 
		return $temp; 
	}

	//
	// Fonction pour crypter un mot
	//
	function crypter($text) {
		$cle = $this->cle;
		srand((double)microtime()*1000000); 
		$cleDecrypt = md5(rand(0,32000)); 
		$cpt = 0; 
		$temp = ""; 
		for ($i=0; $i<strlen($text); $i++) { 
			if ($cpt == strlen($cleDecrypt)) 
				$cpt = 0; 
			$temp.= substr($cleDecrypt,$cpt,1).(substr($text,$i,1) ^ substr($cleDecrypt,$cpt,1)); 
			$Compteur++;
		} 
		return base64_encode($this->_genererCle($temp));
	} 

	//
	// Fonction pour décrypter un mot
	//
	function decrypter($text) { 
		$cle = $this->cle;
		$text = $this->_genererCle(base64_decode($text));
		$temp = ""; 
		for ($i=0; $i<strlen($text); $i++) { 
			$md5 = substr($text,$i,1); 
			$i++; 
			$temp.= (substr($text,$i,1) ^ $md5); 
		} 
		return $temp; 
	}

	//
	// Fonction pour générer une chaine aléatoire
	//
	function key_generator($size){ 
		$key_g = ""; 
		$letter = "abcdefghijklmnopqrstuvwxyz"; 
		$letter .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; 
		$letter .= "0123456789"; 
	  
		srand((double)microtime()*date("YmdGis")); 
	  
		for($cnt = 0; $cnt < $size; $cnt++) 
		$key_g .= $letter[rand(0, 61)]; 
	     
		return $key_g; 
	}

}

?>