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

# File: config_manager.pm
#	Module de gestion de la configuration et des templates

# Function: createSiteConfig
#	Créer les fichiers nécessaires à la configuration d'un site et initialisation de ces fichiers par des valeurs de départ
#
# Paramètres:
#	$siteId - identifiant du site à créer
sub createSiteConfig #($siteId)
{
	my ($siteId) = @_;

	# Création du répertoire avec comme nom l'identifiant du site
	mkdir($cdlSitesConfigPath.$siteId);
	chmod(0777, $cdlSitesConfigPath.$siteId);

	# Création et ouverture du fichier de configuration .ini
	open(SITE_INI, ">:encoding(utf-8)", $cdlSitesConfigPath.$siteId."/".$siteId.".ini") or die "Erreur d'ouverture du fichier : ".$siteId.".ini.\n";

	# Initialisation de la chaîne des paramètres de configuration
	my $configString = "";

	$configString .= "[UrlsAndUris]\n";
	$configString .= "siteDomainNames = \n";
	$configString .= "homePageUris = \n";
	$configString .= "\n";
	$configString .= "[Fil d'ariane]\n";
	$configString .= "positionLocation = 1\n";
	$configString .= "\n";
	$configString .= "[Javascript]\n";
	$configString .= "activateJavascript = 0\n";
	$configString .= "parseJavascript = 0\n";
	$configString .= "\n";
	$configString .= "[Frames]\n";
	$configString .= "activateFrames = 0\n";
	$configString .= "\n";
	$configString .= "[Medias]\n";
	$configString .= "displayImages = 1\n";
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
	$configString .= "\n";
	$configString .= "[Audio]\n";
	$configString .= "enableAudio = \n";
	$configString .= "voiceChoice = \n";
	$configString .= "ttsMode = \n";
	$configString .= "ttsServerName = \n";
	$configString .= "ttsPort = \n";
	$configString .= "ttsUri = \n";
	$configString .= "ttsDefaultQueryString = \n";
	$configString .= "ttsVoiceParamName = \n";
	$configString .= "ttsRateParamName = \n";
	$configString .= "ttsTextParamName = \n";
	$configString .= "enableGlossary = \n";
	$configString .= "utf8DecodeContent = \n";
	$configString .= "\n";
	$configString .= "[Cache]\n";
	$configString .= "cacheExpiry = \n";
	$configString .= "pagesNoCache = \n";

	# Ecriture de la chaîne iniale de configuration dans le fichier
	print SITE_INI $configString;

	# Fermeture du fichier de configuration
	close(SITE_INI);

	chmod(0777, $cdlSitesConfigPath.$siteId."/".$siteId.".ini");

	# Création d'un répertoire override pour la surcharge des modules du core
	mkdir($cdlSitesConfigPath.$siteId."/override");

	chmod(0777, $cdlSitesConfigPath.$siteId."/override");

	open(SITE_PM, ">", $cdlSitesConfigPath.$siteId."/override/main.pm") || die "Erreur d'ouverture du fichier : override/main.pm.\n";

	# Initialisation de la chaîne contenant le code perl spécifique au site à créer
	my $pmString = "# Override begin\n\n# Override end\n\n# pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)\n1;";

	# Ecriture de la chaîne iniale de code spécifique dans le fichier
	print SITE_PM $pmString;

	# Fermeture du fichier du module spécifique
	close(SITE_PM);

	chmod(0777, $cdlSitesConfigPath.$siteId."/override/main.pm");
}

# Function: loadConfig
#	Récupérer le contenu d'un fichier de configuration (.ini ou template)
#
# Paramètres:
#	$configFile - nom du fichier de configuration (ini, html ou css) où récupérer le contenu
sub loadConfig #($configFile)
{
	my ($configFile) = @_;

	# Ouverture du fichier de configuration et récupération du flux où lire
	open(CONFIG_FILE, "<", $configFile) or die "Erreur d'ouverture du fichier : ".$configFile.".\n";

	# Remplissage de la chaîne de caractères correspondant au contenu du fichier de configuration
	my $contentString = "";
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
	my ($configFile, $configString) = @_;

	# Ouverture du fichier de configuration et récupération du flux où lire
	open(CONFIG_FILE_WRITER, ">", $configFile) or die "Erreur d'ouverture du fichier : ".$configFile.".\n";

	# Remplissage du fichier de configuration avec la chaîne de caractères correspondant à la configuration à sauvegarder
	print CONFIG_FILE_WRITER $configString;

	# Fermeture du fichier de configuration
	close(CONFIG_FILE_WRITER);

	chmod(0777, $configFile);
}

# Function: getConfig
#	Récupérer la valeur d'un élément de la configuration passée en argument en tant que chaîne
#
# Paramètres:
#	$configString - chaîne représentant le contenu de la configuration
#	$configKey - clé de l'information de configuration qu'on veut récupérer
sub getConfig #($configString, $configKey)
{
	my ($configString, $configKey) = @_;

	my $configValue = "";

	$configString =~ s/(^|\n)$configKey *= *(.*?)(\n|$)/$configValue = $2;/segi;

	return $configValue;
}

# Function: setConfig
#	Mettre à jour un élément de la configuration avec la nouvelle valeur passée en argument en tant que chaîne
#
# Paramètres:
#	$configString - chaîne représentant le contenu de la configuration
#	$configKey - clé de l'information de configuration qu'on veut mettre à jour
#	$configValue - valeur de la configuration à mettre
sub setConfig #($configString, $configKey, $configValue)
{
	my ($configString, $configKey, $configValue) = @_;

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
	my @sitesDirectories = glob($cdlSitesConfigPath."*");

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
	my ($siteDomain) = @_;

	# Récupérer la liste des répertoires correspondant aux sites
	my @sitesDirectories = glob($cdlSitesConfigPath."*");

	# Parcourir les configuration de tous les sites pour chercher le nom de domaine $siteDomain.
	foreach my $siteDirectory (@sitesDirectories) {
		# On ne regarde que les répertoires et non les fichiers normaux
		if (-d $siteDirectory) {
			# On extrait l'identifiant du site courant
			my $siteId;
			$siteDirectory =~ s/((.*)\/(.*))/$siteId = $3;$1/segi;

			# On charge la config su site courant pour extraire la liste des noms de domaine
			my $siteConfig = loadConfig($cdlSitesConfigPath.$siteId."/".$siteId.".ini");
			my @siteDomainNames = split(/\t/, getConfig($siteConfig, 'siteDomainNames'));

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
	my ($directoryName) = @_;

	# Si le répertoire existe, on retourne vrai (donc 1)
	if (-e $cdlSitesConfigPath.$directoryName) {
		return 1;
	}

	# Si on a pas retourné vrai, c'est à dire que le fichier n'existe pas, on retourne faux (donc 0)
	return 0;
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

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;