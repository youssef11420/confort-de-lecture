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

# File: page_head.pm
#	Module de gestion et de manipulation des ent�tes HTML (contenu de la balise head)

# Function: getHeadContent
#	R�cuperer le contenu de la balise head
#
# Param�tres:
#	$htmlCode - code HTML o� r�cup�rer le contenu de la balise head
sub getHeadContent #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML o� r�cup�rer le contenu de la balise head
	my ($htmlCode) = @_;

	# S'il y a pas de head on retourne la cha�ne vide
	if ($htmlCode !~ m/<head(\s[^<]*?)?>(.*?)<\/head>/si) {
		return "";
	}

	# R�cup�ration du contenu de head
	$htmlCode =~ s/(.*)<head(\s[^<]*?)?>(.*?)<\/head>(.*)/$3/sgi;

	# Retourner le contenu du head
	return $htmlCode;
}

# Function: getPageTitle
#	R�cup�rer le titre de la page
#
# Param�tres:
#	$htmlCode - code HTML du head o� r�cup�rer le titre de la page (contenu de la balise title)
sub getPageTitle #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML du head o� r�cup�rer le titre de la page (contenu de la balise title)
	my ($htmlCode) = @_;

	# S'il y a pas de title on retourne la cha�ne vide
	if ($htmlCode !~ m/<title(\s[^<]*?)?>(.*?)<\/title>/si) {
		return "";
	}

	# R�cup�ration du contenu de head
	$htmlCode =~ s/(.*)<title(\s[^<]*?)?>(.*?)<\/title>(.*)/$3/segi;

	# Retourner le contenu de la balise title
	return $htmlCode;
}

# Function: getBaseHref
#	R�cup�rer la valeur href de la balise Base
#
# Param�tres:
#	$htmlCode - code HTML du head o� r�cup�rer l'URL de base de la page (attribut href de la balise base)
sub getBaseHref #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML du head o� r�cup�rer l'URL de base de la page (attribut href de la balise base)
	my ($htmlCode) = @_;

	my $baseHref = "";

	# R�cup�ration de l'URL absolue dans le href de la balise base
	$htmlCode =~ s/<base(\s[^<]*?)?\s(href)\s*=\s*(\"|\')(.*?)\3(.*?)\s\/>/$baseHref = $4;/segi;

	# Si l'URL dans le href de la balise base n'est pas absolue, on retourne la cha�ne vide
	if ($baseHref !~ m/^(\d|\w)*?:\/\//si) {
		return "/";
	}

	# Retourner l'URL de base de la pages
	return $baseHref;
}

# Function: cleanStyleAttributes
#	Suppression des attributs HTML style
#
# Param�tres:
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
# Param�tres:
#	$htmlCode - code html � nettoyer de styles
sub cleanStyles #($htmlCode)
{
	# Extraction des arguments dans une variable locale :
	# - code html � nettoyer de styles
	my ($htmlCode) = @_;

	# Suppression des balises style
	$htmlCode =~ s/<style(\s[^<]*?)?>(.*?)<\/style>//sgi;
	# Suppression des balises link permettant d'inclure un feuille de style : rel="stylesheet"
	$htmlCode =~ s/<link(\s[^<]*?)?\s(rel\s*=\s*((\"|\')?)stylesheet\3.*?)\s\/>//sgi;

	# Suppression des attributs HTML style
	$htmlCode =~ s/(<(\w|\d)+)(\s.*?)>/$1.cleanStyleAttributes($3).">"/segi;

	# Retourner le code HTML nettoy� de tous les styles
	return $htmlCode;
}

# Function: parseLinkAttributes
#	Traitement des attributs de la balise link : transformer la valeur de l'attribut href pour que �a soit toujours une url absolue
#
# Param�tres:
#	$tagAttributes - code HTML des attributs � traiter
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseLinkAttributes #($tagAttributes, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs � traiter
	# - url racine du site
	# - chemin vers la page en cours de traitement
	my ($tagAttributes, $siteRootUrl, $pagePath) = @_;

	# Mettre en absolue l'URL dans l'attribut href
	$tagAttributes =~ s/(\s(href))\s*=\s*(\"|\')(.*?)\3/$1."=".$3.makeUrlAbsolute($4, $siteRootUrl, $pagePath).$3/segi;

	# Retourner le code HTML des attributs pars�s
	return $tagAttributes;
}

# Function: parseLinks
#	Transformer la valeur de l'attribut href pour que �a soit toujours une url absolue pour les balises link
#
# Param�tres:
#	$htmlCode - code HTML � traiter
#	$siteRootUrl - url racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseLinks #($htmlCode, $siteRootUrl, $pagePath)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � traiter
	# - url racine du site
	# - chemin vers la page en cours de traitement
	my ($htmlCode, $siteRootUrl, $pagePath) = @_;

	# Cha�ne qui contiendra tous les links
	my $allLinks = "";

	# Transformation des URL de toutes les balises link et r�cup�ration de tous les links dans $allLinks
	$htmlCode =~ s/((<link)(\s.*?)(\s\/>))/$allLinks .= "\t\t".$2.parseLinkAttributes($3, $siteRootUrl, $pagePath).$4."\n"; ""/segi;

	# Retourner le code HTML avec les balises link pars�es (url mises en absolues)
	return ($htmlCode, $allLinks);
}

# Function: cleanRedirectUrl
#	Transformer l'URL dans l'attribut content de la balise meta pour rester dans CDL et ne pas prendre en compte l'URL de base
#
# Param�tres:
#	$url - url dans la balise meta Refresh
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site pars�
#	$siteRootUrl - url racine du site
sub cleanRedirectUrl #($url, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - url dans la balise meta Refresh
	# - chemin vers la page en cours de traitement
	# - identifiant du site pars�
	# - url racine du site
	my ($url, $pagePath, $siteId, $siteRootUrl) = @_;

	my $parsedUrl = getUriFromUrl($url, $pagePath, $siteId, $siteRootUrl);
	if ($parsedUrl !~ m/^\/le\-filtre/si) {
		$parsedUrl = "/le-filtre".($siteRootUrl =~ m/^https:\/\//si ? "-https/" : "")."/".$siteId."/".$parsedUrl;
	}

	# Retourner l'URL bien transform�e dans tous les cas
	return $parsedUrl;
}

# Function: parseMetaAttributes
#	Transformer l'URL dans l'attribut content de la balise meta dont l'attribut http-equiv="Refresh"
#
# Param�tres:
#	$tagAttributes - code HTML des attributs � traiter de la balise meta
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site pars�
#	$siteRootUrl - url racine du site
sub parseMetaAttributes #($tagAttributes, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML des attributs � traiter de la balise meta
	# - chemin vers la page en cours de traitement
	# - identifiant du site pars�
	# - url racine du site
	my ($tagAttributes, $pagePath, $siteId, $siteRootUrl) = @_;

	# Transformation de l'URL de redirection dans l'attribut content
	$tagAttributes =~ s/(\s(content))\s*=\s*(\"|\')(.*?)(\s|;)URL\s*=\s*(.*?)\s*\3/
		$1."=".$3.$4." URL=".cleanRedirectUrl($5, $pagePath, $siteId, $siteRootUrl).$3/segi;

	# Retourner les attributs avec la valeur de l'URL de redictection transform�e
	return $tagAttributes;
}

# Function: parseMetas
#	R�cup�rer l'attribut Url de la balise meta dont l'attribut http-equiv="Refresh"
#
# Param�tres:
#	$htmlCode - code HTML � traiter
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site pars�
#	$siteRootUrl - url racine du site
sub parseMetas #($htmlCode, $pagePath, $siteId, $siteRootUrl)
{
	# Extraction des arguments dans une variable locale :
	# - code HTML � traiter
	# - chemin vers la page en cours de traitement
	# - identifiant du site pars�
	# - url racine du site
	my ($htmlCode, $pagePath, $siteId, $siteRootUrl) = @_;

	# Cha�ne qui contiendra tous les m�tas
	my $allMetas = "";

	# Transformation des URL de redirection de toutes les balises meta dont l'attribut http-equiv="Refresh"
	$htmlCode =~ s/((<meta)(\s[^<]*?)?(\s(http-equiv)\s*=\s*(\"|\')?Refresh\5)(\s[^<]*?)?(\s\/>))/
		$2.parseMetaAttributes($3, $pagePath, $siteId, $siteRootUrl).$4.parseMetaAttributes($7, $pagePath, $siteId, $siteRootUrl).$8/segi;

	# R�cup�ration de tous les m�tas
	$htmlCode =~ s/((<meta)(\s[^<]*?)?(\s\/>))/$allMetas .= "\t\t".$1."\n"; ""/segi;

	# Retourner le code html
	return ($htmlCode, $allMetas);
}

# Pour dire au pl que le pm s'est bien ex�cut�, il faut lui faire retourner vrai (donc 1 par ex)
1;