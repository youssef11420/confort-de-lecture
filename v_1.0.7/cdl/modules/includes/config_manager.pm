#########################################################################
# BEGIN COPYRIGHT, LICENSE AND WARRANTY NOTICE
# SOFTWARE NAME: Confort de lecture
# SOFTWARE RELEASE: 2.0.0
# COPYRIGHT NOTICE: Copyright (C) 2000-2007 GIE Confort de lecture (SQLI & HandicapZ�ro)
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

# File: config_manager.pm
#	Module de gestion de la configuration et des templates

# Function: createSiteConfig
#	Cr�er les fichiers n�cessaires � la configuration d'un site et initialisation de ces fichiers par des valeurs de d�part
#
# Param�tres:
#	$siteId - identifiant du site � cr�er
sub createSiteConfig #($siteId)
{
	# Extraction des arguments dans une variable locale :
	# - identifiant du site � cr�er
	my ($siteId) = @_;

	# Cr�ation du r�pertoire avec comme nom l'identifiant du site
	mkdir($cdlRootPath.$cdlSitesConfigPath.$siteId);

	# Cr�ation et ouverture du fichier de configuration .ini
	open(SITE_INI, ">:encoding(utf-8)", $cdlRootPath.$cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Initialisation de la cha�ne des param�tres de configuration
	my $configString = "";

	$configString .= "[UrlsAndUris]\n";
	$configString .= "siteDomainNames = \n";
	$configString .= "homePageUris = \n";
	$configString .= "\n";
	$configString .= "[Javascript]\n";
	$configString .= "activateJavascript = 0\n";
	$configString .= "parseJavascript = 0\n";
	$configString .= "\n";
	$configString .= "[Frames]\n";
	$configString .= "activateFrames = 1\n";
	$configString .= "\n";
	$configString .= "[Medias]\n";
	$configString .= "displayImages = 0\n";
	$configString .= "displayObjects = 0\n";
	$configString .= "displayApplets = 0\n";
	$configString .= "\n";
	$configString .= "[Tables]\n";
	$configString .= "parseTablesToList = 1\n";
	$configString .= "\n";
	$configString .= "[TitlesAndDefaultStrings]\n";
	$configString .= "siteLabel = \n";
	$configString .= "defaultLanguage = \n";
	$configString .= "logo = \n";

	# Ecriture de la cha�ne iniale de configuration dans le fichier
	print SITE_INI $configString;

	# Fermeture du fichier de configuration
	close(SITE_INI);

	# Cr�ation et ouverture du fichier perl du module sp�cifique au site
	open(SITE_PM, " > ", $cdlRootPath.$cdlSitesConfigPath.$siteId."/".$siteId.".pm");

	# Initialisation de la cha�ne contenant le code perl sp�cifique au site � cr�er
	my $pmString = "\n\n# pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)\n1;";

	# Ecriture de la cha�ne iniale de code sp�cifique dans le fichier
	print SITE_PM $pmString;

	# Fermeture du fichier du module sp�cifique
	close(SITE_PM);
}

# Function: loadConfig
#	R�cup�rer le contenu d'un fichier de configuration (.ini ou template)
#
# Param�tres:
#	$configFile - nom du fichier de configuration (ini, html ou css) o� r�cup�rer le contenu
sub loadConfig #($configFile)
{
	# Extraction des arguments dans une variable locale :
	# - nom du fichier de configuration (ini, html ou css) o� r�cup�rer le contenu
	my ($configFile) = @_;

	# Ouverture du fichier de configuration et r�cup�ration du flux o� lire
	open(CONFIG_FILE, "<:encoding(utf-8)", $cdlRootPath.$configFile) || die "Erreur d'ouverture du fichier : $configFile";

	# Remplissage de la cha�ne de caract�res correspondant au contenu du fichier de configuration
	$contentString = "";
	while (<CONFIG_FILE>) {
		$contentString .= $_;
	}

	# Fermeture du fichier de configuration
	close(CONFIG_FILE);

	return $contentString;
}

# Function: saveConfig
#	Sauvegarder la configuration pass�e en argument dans le fichier de configuration donn� (.ini ou template)
#
# Param�tres:
#	$configFile - nom du fichier de configuration (ini, html ou css) o� r�cup�rer le contenu
#	$configString - configuration � �crire dans le fichier
sub saveConfig #($configFile, $configString)
{
	# Extraction des arguments dans une variable locale :
	# - nom du fichier de configuration (ini, html ou css) o� r�cup�rer le contenu
	# - configuration � �crire dans le fichier
	my ($configFile, $configString) = @_;

	# Ouverture du fichier de configuration et r�cup�ration du flux o� lire
	open(CONFIG_FILE_WRITER, ">:encoding(utf-8)", $cdlRootPath.$configFile) || die "Erreur d'ouverture du fichier : ".$configFile;

	# Remplissage du fichier de configuration avec la cha�ne de caract�res correspondant � la configuration � sauvegarder
	print CONFIG_FILE_WRITER $configString;

	# Fermeture du fichier de configuration
	close(CONFIG_FILE_WRITER);
}

# Function: setValueInTemplateString
#	Remplir dans une cha�ne template, du contenu � la place le marqueur en argument
#
# Param�tres:
#	$templateString - cha�ne repr�sentant le contenu de la template
#	$marker - marqueur � remplacer
#	$replacementString - cha�ne correspondant au contenu de remplacement
sub setValueInTemplateString #($templateString, $marker, $replacementString)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne repr�sentant le contenu de la template
	# - marqueur � remplacer
	# - cha�ne correspondant au contenu de remplacement
	my ($templateString, $marker, $replacementString) = @_;

	# On remplace dans la cha�ne template le marqueur (ainsi que son contenu au cas d'un marqueur commentaire) par le contenu de remplacement.
	$templateString =~ s/<!--(\#\#\#$marker\#\#\#)-->.*?<!--\/\1-->/$replacementString/segi;
	$templateString =~ s/\#\#\#$marker\#\#\#/$replacementString/segi;

	# Retourner la valeur ainsi modifi�e
	return $templateString;
}

# Function: getPartOfTemplateString
#	Retourner la sous-cha�ne template qui est entour�e par le marqueur en argument
#
# Param�tres:
#	$templateString - cha�ne repr�sentant le contenu de la template
#	$marker - marqueur entourant la partie de la template � r�cup�rer
sub getPartOfTemplateString #($templateString, $marker)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne repr�sentant le contenu de la template
	# - marqueur entourant la partie de la template � r�cup�rer
	my ($templateString, $marker) = @_;

	my $innerMarkerString = "";

	# Si le marqueur est sous forme de commentaire, on ne garde que la cha�ne dans le marqueur, et on retourne cette cha�ne
	$templateString =~ s/<!--(\#\#\#$marker\#\#\#)-->(.*?)<!--\/\1-->/$innerMarkerString = $2;/segi;

	# Retourner la cha�ne vide si le marqueur n'a pas �t� ferm�
	return $innerMarkerString;
}

# Function: getValueForKey
#	R�cup�rer la valeur d'un �l�ment de la configuration pass�e en argument en tant que cha�ne
#
# Param�tres:
#	$configString - cha�ne repr�sentant le contenu de la configuration
#	$configKey - cl� de l'information de configuration qu'on veut r�cup�rer
sub getValueForKey #($configString, $configKey)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne repr�sentant le contenu de la configuration
	# - cl� de l'information de configuration qu'on veut r�cup�rer
	my ($configString, $configKey) = @_;

	my $configValue = "";

	$configString =~ s/(^|\n)$configKey *= *(.*?)(\n|$)/$configValue = $2;/segi;

	return $configValue;
}

# Function: setValueForKey
#	Mettre � jour un �l�ment de la configuration avec la nouvelle valeur pass�e en argument en tant que cha�ne
#
# Param�tres:
#	$configString - cha�ne repr�sentant le contenu de la configuration
#	$configKey - cl� de l'information de configuration qu'on veut mettre � jour
#	$configValue - valeur de la configuration � mettre
sub setValueForKey #($configString, $configKey, $configValue)
{
	# Extraction des arguments dans une variable locale :
	# - cha�ne repr�sentant le contenu de la configuration
	# - cl� de l'information de configuration qu'on veut mettre � jour
	# - valeur de la configuration � mettre
	my ($configString, $configKey, $configValue) = @_;

	$configValue =~ s/&/&amp;/sgi;
	$configValue =~ s/>/&gt;/sgi;
	$configValue =~ s/</&lt;/sgi;
	$configValue =~ s/\"/&quot;/sgi;

	$configString =~ s/((^|\n)$configKey *= *)(.*?)(\n|$)/$1.$configValue.$4/segi;

	return $configString;
}

# Function: getSitesIds
#	R�cup�rer la liste des identifiants des sites g�r�s
#
# Param�tres:
#	
sub getSitesIds
{
	# Remplissage du tableau correspondant � la liste des sites
	my @sitesDirectories = glob($cdlRootPath.$cdlSitesConfigPath."*");

	my $i = 0;
	my @sites;
	foreach my $site (@sitesDirectories) {
		if (-d $site) {
			$site =~ s/(.*)\/(.*?)/$2/sgi;
			$sites[$i++] = $site;
		}
	}

	return @sites;
}

# Function: getSiteFromDomain
#	Lecture dans les r�pertoires de config des sites, et qui cherche l'identifiant du site corespondant au domaine pass� en argument
#
# Param�tres:
#	$siteDomain - domaine du site � chercher
sub getSiteFromDomain #($siteDomain)
{
	# Extraction des arguments dans une variable locale :
	# - domaine du site � chercher
	my ($siteDomain) = @_;

	# R�cup�rer la liste des r�pertoires correspondant aux sites
	my @sitesDirectories = glob($cdlRootPath.$cdlSitesConfigPath."*");

	# Parcourir les configuration de tous les sites pour chercher le nom de domaine $siteDomain.
	foreach my $siteDirectory (@sitesDirectories) {
		# On ne regarde que les r�pertoires et non les fichiers normaux
		if (-d $siteDirectory) {
			# On extrait l'identifiant du site courant
			my $siteId;
			$siteDirectory =~ s/((.*)\/(.*))/$siteId = $3;$1/segi;

			# On charge la config su site courant pour extraire la liste des noms de domaine
			my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
			my @siteDomainNames = split(/\t/, getValueForKey($siteConfig, 'siteDomainNames'));

			# Si on trouve le nom de domaine pass� en argument $siteDomain, cela veut dire que c'est le site qu'on recherche, on retourne son id.
			foreach my $siteDomainName (@siteDomainNames) {
				if ($siteDomainName eq $siteDomain) {
					# Si on a trouv� une correspondance de nom de domaine, on retourne le nom du r�pertoire qui correspond � l'identifiant du site
					return $siteId;
				}
			}
		}
	}

	# On retourne vide si aucun site n'est accessible par ce nom de domaine
	return "";
}

# Function: existConfigDirectory
#	Tester l'existence d'un r�pertoire
#
# Param�tres:
#	$directoryName - nom du r�pertoire dont tester l'existance
sub existConfigDirectory #($directoryName)
{
	# Extraction des arguments dans une variable locale :
	# - nom du r�pertoire dont tester l'existance
	my ($directoryName) = @_;

	# Si le r�pertoire existe, on retourne vrai (donc 1)
	if (-e $cdlRootPath.$cdlSitesConfigPath.$directoryName) {
		return 1;
	}

	# Si on a pas retourn� vrai, c'est � dire que le fichier n'existe pas, on retourne faux (donc 0)
	return 0;
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;