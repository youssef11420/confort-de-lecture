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

# File: page_head.pm
#	Module de gestion et de manipulation des entêtes HTML (contenu de la balise head)

# Function: getHeadContent
#	Récuperer le contenu de la balise head
#
# Paramètres:
#	$htmlCode - code HTML où récupérer le contenu de la balise head
sub getHeadContent #($htmlCode)
{
	my ($htmlCode) = @_;

	# S'il y a pas de head on retourne la chaîne vide
	if ($htmlCode !~ m/<head( [^>]*)?>(.*?)<\/head>/si) {
		return "";
	}

	# Récupération du contenu de head
	$htmlCode =~ s/(.*)<head( [^>]*)?>(.*?)<\/head>(.*)/$3/sgi;

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
	my ($htmlCode) = @_;

	# S'il y a pas de title on retourne la chaîne vide
	if ($htmlCode !~ m/<title( [^>]*)?>(.*?)<\/title>/si) {
		return "";
	}

	# Récupération du contenu de head
	$htmlCode =~ s/(.*)<title( [^>]*)?>(.*?)<\/title>(.*)/$3/segi;

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
	my ($htmlCode) = @_;

	my $baseHref = "";

	# Récupération de l'URL absolue dans le href de la balise base
	$htmlCode =~ s/<base( [^>]*)? href=(\"|\')(.*?)\/?\2[^>]*>/$baseHref = $3;/segi;

	# Si l'URL dans le href de la balise base n'est pas absolue, on retourne la chaîne vide
	if ($baseHref !~ m/^[\w\d]+:\/\//si) {
		return "";
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
	my ($tagAttributes) = @_;

	# Supprimer tous les attributs style
	$tagAttributes =~ s/ style=(\"|\').*?\1//sgi;

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
	my ($htmlCode) = @_;

	# Suppression des balises link permettant d'inclure un feuille de style : rel="stylesheet"
	$htmlCode =~ s/<link( [^>]*)? rel=(\"|\')stylesheet\2[^>]*>//sgi;

	# Suppression des attributs HTML style
	$htmlCode =~ s/(<([\w\d]+))( [^>]*?)>/$1.cleanStyleAttributes($3).">"/segi;

	# Retourner le code HTML nettoyé de tous les styles
	return $htmlCode;
}

# Function: parseLinkAttributes
#	Traitement des attributs de la balise link : transformer la valeur de l'attribut href pour que ça soit toujours une url absolue
#
# Paramètres:
#	$tagAttributes - code HTML des attributs à traiter
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseLinkAttributes #($tagAttributes, $siteRootUrl, $pagePath)
{
	my ($tagAttributes, $siteRootUrl, $pagePath) = @_;

	# Mettre en absolue l'URL dans l'attribut href
	$tagAttributes =~ s/ href=(\"|\')(.*?)\1/" href=".$1.makeUrlAbsolute($2, $siteRootUrl, $pagePath).$1/segi;

	# Retourner le code HTML des attributs parsés
	return $tagAttributes;
}

# Function: parseLinks
#	Transformer la valeur de l'attribut href pour que ça soit toujours une url absolue pour les balises link
#
# Paramètres:
#	$htmlCode - code HTML à traiter
#	$siteRootUrl - URL racine du site
#	$pagePath - chemin vers la page en cours de traitement
sub parseLinks #($htmlCode, $siteRootUrl, $pagePath)
{
	my ($htmlCode, $siteRootUrl, $pagePath) = @_;

	# Chaîne qui contiendra tous les links
	my $allLinks = "";

	# Transformation des URL de toutes les balises link et récupération de tous les links dans $allLinks
	$htmlCode =~ s/<link( [^>]*)?>/$allLinks .= "<link".parseLinkAttributes($1, $siteRootUrl, $pagePath).">\n"; ""/segi;

	# Retourner le code HTML avec les balises link parsées (url mises en absolues)
	return ($htmlCode, $allLinks);
}

# Function: cleanRedirectUrl
#	Transformer l'URL dans l'attribut content de la balise meta pour rester dans CDL et ne pas prendre en compte l'URL de base
#
# Paramètres:
#	$url - URL dans la balise meta Refresh
#	$pagePath - chemin vers la page en cours de traitement
#	$siteId - identifiant du site parsé
#	$siteRootUrl - URL racine du site
sub cleanRedirectUrl #($url, $pagePath, $siteId, $siteRootUrl)
{
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
#	$siteRootUrl - URL racine du site
sub parseMetaAttributes #($tagAttributes, $pagePath, $siteId, $siteRootUrl)
{
	my ($tagAttributes, $pagePath, $siteId, $siteRootUrl) = @_;

	# Transformation de l'URL de redirection dans l'attribut content
	$tagAttributes =~ s/ content=((\"|\').*?[\s;]+)URL=(.*?)\s*\2/
		" content=".$1." URL=".cleanRedirectUrl($3, $pagePath, $siteId, $siteRootUrl).$2/segi;

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
#	$siteRootUrl - URL racine du site
#	$contentType - encodage transmis dans l'entête de la réponse HTTP
sub parseMetas #($htmlCode, $pagePath, $siteId, $siteRootUrl, $contentType)
{
	my ($htmlCode, $pagePath, $siteId, $siteRootUrl, $contentType) = @_;

	# Chaîne qui contiendra tous les métas
	my $allMetas = "";

	$htmlCode =~ s/<meta( [^>]*?)? name="viewport"([^>]*)>//sgi;

	# Transformation des URL de redirection de toutes les balises meta dont l'attribut http-equiv="Refresh"
	$htmlCode =~ s/<meta( [^>]*?)?( http-equiv=(\"|\')Refresh\3)([^>]*)>/
		"<meta".parseMetaAttributes($1, $pagePath, $siteId, $siteRootUrl).$2.parseMetaAttributes($4, $pagePath, $siteId, $siteRootUrl).">"/segi;

	# Récupération de tous les métas
	$htmlCode =~ s/(<meta( [^>]*)?>)/$allMetas .= $1."\n"; ""/segi;

	# Si la balise meta définissant l'encodage de la page (Content-type) n'est pas défini, on le redéfinit avec l'encodage transmis dans l'entête de la réponse HTTP
	if ($allMetas !~ m/<meta( [^>]*)? http-equiv=(\"|\')Content\-Type\2[^>]*>/si) {
		$allMetas .= "<meta content=\"".$contentType."\" http-equiv=\"Content-Type\">\n".$allMetas;
	}

	$allMetas =~ s/(<meta( [^>]*)? content=(\"|\').*?)iso\-\d+\-\d+(.*?\3)/$1windows-1252$4/sgi;

	$allMetas =~ s/<meta( [^>]*)? http\-equiv=(\"|\')(Expires|X-UA-Compatible|Content-Style-Type|Content-Language|Content-Script-Type)\2[^>]*>\n//sgi;

	# Retourner le code html
	return ($htmlCode, $allMetas);
}

# Pour dire au pl que le pm s'est bien exécuté, il faut lui faire retourner vrai (donc 1 par ex)
1;