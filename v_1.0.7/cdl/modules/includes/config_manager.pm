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

# File: config_manager.pm
#	Module de gestion de la configuration et des templates

# Function: createSiteConfig
#	Créer les fichiers nécessaires à la configuration d'un site et initialisation de ces fichiers par des valeurs de départ
#
# Paramètres:
#	$siteId - identifiant du site à créer
sub createSiteConfig #($siteId)
{
	# Extraction des arguments dans une variable locale :
	# - identifiant du site à créer
	my ($siteId) = @_;

	# Création du répertoire avec comme nom l'identifiant du site
	mkdir($cdlRootPath.$cdlSitesConfigPath.$siteId);

	# Création et ouverture du fichier de configuration .ini
	open(SITE_INI, ">:encoding(utf-8)", $cdlRootPath.$cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Initialisation de la chaîne des paramètres de configuration
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

	# Ecriture de la chaîne iniale de configuration dans le fichier
	print SITE_INI $configString;

	# Fermeture du fichier de configuration
	close(SITE_INI);

	# Création et ouverture du fichier perl du module spécifique au site
	open(SITE_PM, " > ", $cdlRootPath.$cdlSitesConfigPath.$siteId."/".$siteId.".pm");

	# Initialisation de la chaîne contenant le code perl spécifique au site à créer
	my $pmString = "\n\n# pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)\n1;";

	# Ecriture de la chaîne iniale de code spécifique dans le fichier
	print SITE_PM $pmString;

	# Fermeture du fichier du module spécifique
	close(SITE_PM);
}

# Function: loadConfig
#	Récupérer le contenu d'un fichier de configuration (.ini ou template)
#
# Paramètres:
#	$configFile - nom du fichier de configuration (ini, html ou css) où récupérer le contenu
sub loadConfig #($configFile)
{
	# Extraction des arguments dans une variable locale :
	# - nom du fichier de configuration (ini, html ou css) où récupérer le contenu
	my ($configFile) = @_;

	# Ouverture du fichier de configuration et récupération du flux où lire
	open(CONFIG_FILE, "<:encoding(utf-8)", $cdlRootPath.$configFile) || die "Erreur d'ouverture du fichier : $configFile";

	# Remplissage de la chaîne de caractères correspondant au contenu du fichier de configuration
	$contentString = "";
	while (<CONFIG_FILE>) {
		$contentString .= $_;
	}

	# Fermeture du fichier de configuration
	close(CONFIG_FILE);

	return $contentString;
}

# Function: saveConfig
#	Sauvegarder la configuration passée en argument dans le fichier de configuration donné (.ini ou template)
#
# Paramètres:
#	$configFile - nom du fichier de configuration (ini, html ou css) où récupérer le contenu
#	$configString - configuration à écrire dans le fichier
sub saveConfig #($configFile, $configString)
{
	# Extraction des arguments dans une variable locale :
	# - nom du fichier de configuration (ini, html ou css) où récupérer le contenu
	# - configuration à écrire dans le fichier
	my ($configFile, $configString) = @_;

	# Ouverture du fichier de configuration et récupération du flux où lire
	open(CONFIG_FILE_WRITER, ">:encoding(utf-8)", $cdlRootPath.$configFile) || die "Erreur d'ouverture du fichier : ".$configFile;

	# Remplissage du fichier de configuration avec la chaîne de caractères correspondant à la configuration à sauvegarder
	print CONFIG_FILE_WRITER $configString;

	# Fermeture du fichier de configuration
	close(CONFIG_FILE_WRITER);
}

# Function: setValueInTemplateString
#	Remplir dans une chaîne template, du contenu à la place le marqueur en argument
#
# Paramètres:
#	$templateString - chaîne représentant le contenu de la template
#	$marker - marqueur à remplacer
#	$replacementString - chaîne correspondant au contenu de remplacement
sub setValueInTemplateString #($templateString, $marker, $replacementString)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne représentant le contenu de la template
	# - marqueur à remplacer
	# - chaîne correspondant au contenu de remplacement
	my ($templateString, $marker, $replacementString) = @_;

	# On remplace dans la chaîne template le marqueur (ainsi que son contenu au cas d'un marqueur commentaire) par le contenu de remplacement.
	$templateString =~ s/<!--(\#\#\#$marker\#\#\#)-->.*?<!--\/\1-->/$replacementString/segi;
	$templateString =~ s/\#\#\#$marker\#\#\#/$replacementString/segi;

	# Retourner la valeur ainsi modifiée
	return $templateString;
}

# Function: getPartOfTemplateString
#	Retourner la sous-chaîne template qui est entourée par le marqueur en argument
#
# Paramètres:
#	$templateString - chaîne représentant le contenu de la template
#	$marker - marqueur entourant la partie de la template à récupérer
sub getPartOfTemplateString #($templateString, $marker)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne représentant le contenu de la template
	# - marqueur entourant la partie de la template à récupérer
	my ($templateString, $marker) = @_;

	my $innerMarkerString = "";

	# Si le marqueur est sous forme de commentaire, on ne garde que la chaîne dans le marqueur, et on retourne cette chaîne
	$templateString =~ s/<!--(\#\#\#$marker\#\#\#)-->(.*?)<!--\/\1-->/$innerMarkerString = $2;/segi;

	# Retourner la chaîne vide si le marqueur n'a pas été fermé
	return $innerMarkerString;
}

# Function: getValueForKey
#	Récupérer la valeur d'un élément de la configuration passée en argument en tant que chaîne
#
# Paramètres:
#	$configString - chaîne représentant le contenu de la configuration
#	$configKey - clé de l'information de configuration qu'on veut récupérer
sub getValueForKey #($configString, $configKey)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne représentant le contenu de la configuration
	# - clé de l'information de configuration qu'on veut récupérer
	my ($configString, $configKey) = @_;

	my $configValue = "";

	$configString =~ s/(^|\n)$configKey *= *(.*?)(\n|$)/$configValue = $2;/segi;

	return $configValue;
}

# Function: setValueForKey
#	Mettre à jour un élément de la configuration avec la nouvelle valeur passée en argument en tant que chaîne
#
# Paramètres:
#	$configString - chaîne représentant le contenu de la configuration
#	$configKey - clé de l'information de configuration qu'on veut mettre à jour
#	$configValue - valeur de la configuration à mettre
sub setValueForKey #($configString, $configKey, $configValue)
{
	# Extraction des arguments dans une variable locale :
	# - chaîne représentant le contenu de la configuration
	# - clé de l'information de configuration qu'on veut mettre à jour
	# - valeur de la configuration à mettre
	my ($configString, $configKey, $configValue) = @_;

	$configValue =~ s/&/&amp;/sgi;
	$configValue =~ s/>/&gt;/sgi;
	$configValue =~ s/</&lt;/sgi;
	$configValue =~ s/\"/&quot;/sgi;

	$configString =~ s/((^|\n)$configKey *= *)(.*?)(\n|$)/$1.$configValue.$4/segi;

	return $configString;
}

# Function: getSitesIds
#	Récupérer la liste des identifiants des sites gérés
#
# Paramètres:
#	
sub getSitesIds
{
	# Remplissage du tableau correspondant à la liste des sites
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
#	Lecture dans les répertoires de config des sites, et qui cherche l'identifiant du site corespondant au domaine passé en argument
#
# Paramètres:
#	$siteDomain - domaine du site à chercher
sub getSiteFromDomain #($siteDomain)
{
	# Extraction des arguments dans une variable locale :
	# - domaine du site à chercher
	my ($siteDomain) = @_;

	# Récupérer la liste des répertoires correspondant aux sites
	my @sitesDirectories = glob($cdlRootPath.$cdlSitesConfigPath."*");

	# Parcourir les configuration de tous les sites pour chercher le nom de domaine $siteDomain.
	foreach my $siteDirectory (@sitesDirectories) {
		# On ne regarde que les répertoires et non les fichiers normaux
		if (-d $siteDirectory) {
			# On extrait l'identifiant du site courant
			my $siteId;
			$siteDirectory =~ s/((.*)\/(.*))/$siteId = $3;$1/segi;

			# On charge la config su site courant pour extraire la liste des noms de domaine
			my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
			my @siteDomainNames = split(/\t/, getValueForKey($siteConfig, 'siteDomainNames'));

			# Si on trouve le nom de domaine passé en argument $siteDomain, cela veut dire que c'est le site qu'on recherche, on retourne son id.
			foreach my $siteDomainName (@siteDomainNames) {
				if ($siteDomainName eq $siteDomain) {
					# Si on a trouvé une correspondance de nom de domaine, on retourne le nom du répertoire qui correspond à l'identifiant du site
					return $siteId;
				}
			}
		}
	}

	# On retourne vide si aucun site n'est accessible par ce nom de domaine
	return "";
}

# Function: existConfigDirectory
#	Tester l'existence d'un répertoire
#
# Paramètres:
#	$directoryName - nom du répertoire dont tester l'existance
sub existConfigDirectory #($directoryName)
{
	# Extraction des arguments dans une variable locale :
	# - nom du répertoire dont tester l'existance
	my ($directoryName) = @_;

	# Si le répertoire existe, on retourne vrai (donc 1)
	if (-e $cdlRootPath.$cdlSitesConfigPath.$directoryName) {
		return 1;
	}

	# Si on a pas retourné vrai, c'est à dire que le fichier n'existe pas, on retourne faux (donc 0)
	return 0;
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;