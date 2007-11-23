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

# File: session.pm
#	Module de gestion de la session (création, ajout/modification/suppression/lecture d'une donnée)

# Function: createOrGetSession
#	Création de la session (ou récupération si elle existe déjà)
#
# Paramètres:
#	$cgi - ibjet CGI d'où extraire l'identifiant de session (s'il existe déjà)
sub createOrGetSession #($cgi)
{
	# Extraction des arguments dans une variable locale :
	# - ibjet CGI d'où extraire l'identifiant de session (s'il existe déjà)
	my ($cgi) = @_;

	my $sid = $cgi->cookie('CGISESSID');

	my $session = new CGI::Session("driver:File", $sid, {Directory=>$cdlRootPath.$cdlSessionCachePath});

	$session->expire('+'.$sessionExpireIn);

	return $session;
}

# Function: editInSession
#	Stockage d'une information (clé,valeur) en session
#
# Paramètres:
#	$session - objet session où mettre à jour les informations
#	$key - clé (nom) de l'information à éditer dans la session
#	$value - valeur d l'information à éditer dans la session
sub editInSession #($session, $key, $value)
{
	# Extraction des arguments dans une variable locale :
	# - objet session où mettre à jour les informations
	# - clé (nom) de l'information à éditer dans la session
	# - valeur d l'information à éditer dans la session
	my ($session, $key, $value) = @_;

	$session->param(-name=>$key, -value=>$value);
}

# Function: loadFromSession
#	Récupération de la valeur correspondant à la clé donnée en paramètre
#
# Paramètres:
#	$session - objet session contenant les informations
#	$key - clé (nom) de l'information à charger de la session
sub loadFromSession #($session, $key)
{
	# Extraction des arguments dans une variable locale :
	# - objet session contenant les informations
	# - clé (nom) de l'information à charger de la session
	my ($session, $key) = @_;

	my $value = $session->param(-name=>$key);

	return $value;
}

# Function: deleteFromSession
#	Suppression d'une information de la session
#
# Paramètres:
#	$session - objet session contenant les informations
#	$key - clé (nom) de l'information à supprimer de la session
sub deleteFromSession #($session, $key)
{
	# Extraction des arguments dans une variable locale :
	# - objet session contenant les informations
	# - clé (nom) de l'information à supprimer de la session
	my ($session, $key) = @_;

	# Suppression du couple (clé,valeur) de la session
	$session->clear([$key]);
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;