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

# File: page_head.pm
#	Module de gestion et de manipulation des entêtes HTML (contenu de la balise head)

# Function: getHeadContent
#	Récuperer le contenu de la balise head
#
# Paramètres:
#	$htmlCode - code HTML où récupérer le contenu de la balise head
sub getHeadContent #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML où récupérer le contenu de la balise head
	my ($htmlCode) = @_;

	# S'il y a pas de head on retourne la chaîne vide
	if ($htmlCode !~ m/<head(\s[^<]*?)?>(.*?)<\/head>/si) {
		return "";
	}

	# Récupération du contenu de head
	$htmlCode =~ s/(.*)<head(\s[^<]*?)?>(.*?)<\/head>(.*)/$3/sgi;

	# Retourner le contenu du head
	return $htmlCode;
}

# Function: getPageTitle
#	Récupérer le titre de la page
#
# Paramètres:
#	$htmlCode - code HTML du head où récupérer le titre de la page (contenu de la balise title)
sub getPageTitle #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML du head où récupérer le titre de la page (contenu de la balise title)
	my ($htmlCode) = @_;

	# S'il y a pas de title on retourne la chaîne vide
	if ($htmlCode !~ m/<title(\s[^<]*?)?>(.*?)<\/title>/si) {
		return "";
	}

	# Récupération du contenu de head
	$htmlCode =~ s/(.*)<title(\s[^<]*?)?>(.*?)<\/title>(.*)/$3/segi;

	# Retourner le contenu de la balise title
	return $htmlCode;
}

# Function: getBaseHref
#	Récupérer la valeur href de la balise Base
#
# Paramètres:
#	$htmlCode - code HTML du head où récupérer l'URL de base de la page (attribut href de la balise base)
sub getBaseHref #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML du head où récupérer l'URL de base de la page (attribut href de la balise base)
	my ($htmlCode) = @_;

	my $baseHref = "";

	# Récupération de l'URL absolue dans le href de la balise base
	$htmlCode =~ s/<base(\s[^<]*?)?\s(href)\s*=\s*(\"|\')(.*?)\3(.*?)\s\/>/$baseHref = $4;/segi;

	# Si l'URL dans le href de la balise base n'est pas absolue, on retourne la chaîne vide
	if ($baseHref !~ m/^(\d|\w)*?:\/\//si) {
		return "/";
	}

	# Retourner l'URL de base de la pages
	return $baseHref;
}

# Function: cleanStyleAttributes
#	Suppression des attributs HTML style
#
# Paramètres:
#	$tagAttributes - code html correspondant aux attributs d'une balise HTML quelconque
sub cleanStyleAttributes #($tagAttributes)
{
	# Extraction des arguments dans une variable locale :
	# - code html correspondant aux attributs d'une balise HTML quelconque
	my ($tagAttributes) = @_;

	# Supprimer tous les attributs style
	$tagAttributes =~ s/\s(style)\s*=\s*(\"|\').*?\2//sgi;

	# Retouner les attributs de la balisemais sans l'attribut style
	return $tagAttributes;
}

# Function: cleanStyles
#	Suppression des styles (balises et attributs)
#
# Paramètres:
#	$htmlCode - code html à nettoyer de styles
sub cleanStyles #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code html à nettoyer de styles
	my ($htmlCode) = @_;

	# Suppression des balises style
	$htmlCode =~ s/<style(\s[^<]*?)?>(.*?)<\/style>//sgi;
	# Suppression des balises link permettant d'inclure un feuille de style : rel="stylesheet"
	$htmlCode =~ s/<link(\s[^<]*?)?\s(rel\s*=\s*((\"|\')?)stylesheet\3.*?)\s\/>//sgi;

	# Suppression des attributs HTML style
	$htmlCode =~ s/(<(\w|\d)+)(\s.*?)>/$1.cleanStyleAttributes($3).">"/segi;

	# Retourner le code HTML nettoyé de tous les styles
	return $htmlCode;
}

# Function: parseLinkAttributes
#	Traitement des attributs de la balise link : transformer la valeur de l'attribut href pour que ça soit toujours une url absolue
#
# Paramètres:
#	$tagAttributes - code HTML des attributs à traiter
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseLinkAttributes #($tagAttributes, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs à traiter
	# - url racine du site
	# - chemin vers la page en cours de traitement
	my ($tagAttributes, $siteRootUrl, $pagePath) = @_;

	# Mettre en absolue l'URL dans l'attribut href
	$tagAttributes =~ s/(\s(href))\s*=\s*(\"|\')(.*?)\3/$1."=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3/segi;

	# Retourner le code HTML des attributs parsés
	return $tagAttributes;
}

# Function: parseLinks
#	Transformer la valeur de l'attribut href pour que ça soit toujours une url absolue pour les balises link
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseLinks #($htmlCode, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à traiter
	# - url racine du site
	# - chemin vers la page en cours de traitement
	my ($htmlCode, $siteRootUrl, $pagePath) = @_;

	# Chaîne qui contiendra tous les links
	my $allLinks = "";

	# Transformation des URL de toutes les balises link et récupération de tous les links dans $allLinks
	$htmlCode =~ s/((<link)(\s.*?)(\s\/>))/$allLinks .= "\t\t".$2.parseLinkAttributes($3, $siteRootUrl, $pagePath).$4."\n"; ""/segi;

	# Retourner le code HTML avec les balises link parsées (url mises en absolues)
	return ($htmlCode, $allLinks);
}

# Function: cleanRedirectUrl
#	Transformer l'URL dans l'attribut content de la balise meta pour rester dans CDL et ne pas prendre en compte l'URL de base
#
# Paramètres:
#	$url - url dans la balise meta Refresh
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - url racine du site
sub cleanRedirectUrl #($url, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - url dans la balise meta Refresh
	# - chemin vers la page en cours de traitement
	# - identifiant du site parsé
	# - url racine du site
	my ($url, $pagePath, $siteId, $siteRootUrl) = @_;

	my $parsedUrl = getUriFromUrl($url, $pagePath, $siteId, $siteRootUrl);
	if ($parsedUrl !~ m/^\/le\-filtre/si) {
		$parsedUrl = "/le-filtre".($siteRootUrl =~ m/^https:\/\//si ? "-https/" : "")."/".$siteId."/".$parsedUrl;
	}

	# Retourner l'URL bien transformée dans tous les cas
	return $parsedUrl;
}

# Function: parseMetaAttributes
#	Transformer l'URL dans l'attribut content de la balise meta dont l'attribut http-equiv="Refresh"
#
# Paramètres:
#	$tagAttributes - code HTML des attributs à traiter de la balise meta
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - url racine du site
sub parseMetaAttributes #($tagAttributes, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs à traiter de la balise meta
	# - chemin vers la page en cours de traitement
	# - identifiant du site parsé
	# - url racine du site
	my ($tagAttributes, $pagePath, $siteId, $siteRootUrl) = @_;

	# Transformation de l'URL de redirection dans l'attribut content
	$tagAttributes =~ s/(\s(content))\s*=\s*(\"|\')(.*?)(\s|;)URL\s*=\s*(.*?)\s*\3/
		$1."=".$3.$4." URL=".cleanRedirectUrl($5, $pagePath, $siteId, $siteRootUrl).$3/segi;

	# Retourner les attributs avec la valeur de l'URL de redictection transformée
	return $tagAttributes;
}

# Function: parseMetas
#	Récupérer l'attribut Url de la balise meta dont l'attribut http-equiv="Refresh"
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - url racine du site
sub parseMetas #($htmlCode, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML à traiter
	# - chemin vers la page en cours de traitement
	# - identifiant du site parsé
	# - url racine du site
	my ($htmlCode, $pagePath, $siteId, $siteRootUrl) = @_;

	# Chaîne qui contiendra tous les métas
	my $allMetas = "";

	# Transformation des URL de redirection de toutes les balises meta dont l'attribut http-equiv="Refresh"
	$htmlCode =~ s/((<meta)(\s[^<]*?)?(\s(http-equiv)\s*=\s*(\"|\')?Refresh\5)(\s[^<]*?)?(\s\/>))/
		$2.parseMetaAttributes($3, $pagePath, $siteId, $siteRootUrl).$4.parseMetaAttributes($7, $pagePath, $siteId, $siteRootUrl).$8/segi;

	# Récupération de tous les métas
	$htmlCode =~ s/((<meta)(\s[^<]*?)?(\s\/>))/$allMetas .= "\t\t".$1."\n"; ""/segi;

	# Retourner le code html
	return ($htmlCode, $allMetas);
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;