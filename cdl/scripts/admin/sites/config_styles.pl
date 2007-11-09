#!/usr/bin/perl

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

# File: config_styles.pl
#	Script de génération du style de la configuration à partir d’une template CSS

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);

use CGI::Session;

use lib '../../../modules/includes';
use constants;
use config_manager;


# Affichage des entêtes pour la génération de flux CSS
print "Content-type: text/css\n";
print "Cache-Control: no-cache, must-revalidate\n\n";

# Chargement de la template de style de configuration
my $styleString = loadConfig($cdlTemplatesPath."config.css");

# Affichage du code CSS de configuration
print $styleString;