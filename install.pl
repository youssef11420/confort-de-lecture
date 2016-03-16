#!/usr/bin/perl

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

# File: install.pl
#	Script d'installation de CDL : A ne lancer qu'une seule fois

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);

use Cwd;

use lib 'core/modules/utils';
use constants;

# Récupération de l'URL réécrite pour en extraire les informations nécessaires
my $thisCdlUrl = $ENV{'REQUEST_URI'};
$thisCdlUrl =~ s/%20/+/sgi;

$embeddedMode = "";
$thisCdlUrl =~ s/^(\/cdl)/$embeddedMode = $1; ""/segi;

$cdlRootPath = cwd();

# Création de l'objet CGI
my $cgi = CGI->new();

if (not -e $cdlRootPath."/install_ok") {
	if (param('valider')) {
		if (!param('loginAdmin') or !param('passwdAdmin')) {
			print $cgi->redirect($embeddedMode."/install?m=1");
			exit;
		}
		if (param('loginAdmin') =~ m/[^a-z\d\-_\.]/si) {
			print $cgi->redirect($embeddedMode."/install?m=2");
			exit;
		}
		if (length(param('passwdAdmin')) < 6) {
			print $cgi->redirect($embeddedMode."/install?m=3");
			exit;
		}

		my $encryptedIdentLine = param('loginAdmin').":".crypt(param('passwdAdmin'), param('passwdAdmin'));

		unless(-e $cdlRootPath."/configuration/.htpasswd") {
			open(FC, ">", $cdlRootPath."/configuration/.htpasswd");
			close(FC);
		}

		open(WRITER, '>', $cdlRootPath."/configuration/.htpasswd");
		print WRITER $encryptedIdentLine."\n";
		close(WRITER);

		open(WRITER, '>', $cdlRootPath."/install_ok");
		print WRITER "OK\n";
		close(WRITER);

		print $cgi->redirect($embeddedMode."/install");
	} else {
		print "Content-type: text/html; charset=utf-8\n\n";
		print "<link href=\"".$embeddedMode."/design/css/config.css\" rel=\"stylesheet\">";
		print "<br>";

		if (param('m') eq "1") {
			print "<div class=\"center\"><div class=\"messageErr\">Veuillez renseigner l'identifiant et le mot de passe.</div><br></div>";
		}
		if (param('m') eq "2") {
			print "<div class=\"center\"><div class=\"messageErr\">L'identifiant que vous avez renseigné n'est pas au bon format.</div><br></div>";
		}
		if (param('m') eq "3") {
			print "<div class=\"center\"><div class=\"messageErr\">Le mot de passe doit contenir 6 caractères minimum.</div><br></div>";
		}

		print "<form action=\"".$embeddedMode."/install\" method=\"post\">";
		print "<div class=\"clearBoth\"></div><br>";
		print "<div class=\"formLine\">";
		print "<div class=\"leftForm\"><label for=\"loginAdmin\">Identifiant de l'administrateur :&nbsp;</label></div>";
		print "<div class=\"rightForm\"><input class=\"text\" type=\"text\" id=\"loginAdmin\" name=\"loginAdmin\"></div>";
		print "<div class=\"clearBoth\"></div>";
		print "</div>";
		print "<div class=\"formLine\">";
		print "<div class=\"leftForm\"><label for=\"passwdAdmin\">Mot de passe de l'administrateur :&nbsp;</label></div>";
		print "<div class=\"rightForm\"><input class=\"text\" type=\"password\" id=\"passwdAdmin\" name=\"passwdAdmin\"></div>";
		print "<div class=\"clearBoth\"></div>";
		print "</div>";
		print "<div class=\"center\">";
		print "<input type=\"submit\" name=\"valider\" value=\"Valider\" class=\"submit\">";
		print "</div>";
		print "</form>";
	}
} else {
	print "Content-type: text/html; charset=utf-8\n\n";
	print "<div class=\"center\"><div class=\"messageOk\">Installation terminée.</div><br></div>";
}