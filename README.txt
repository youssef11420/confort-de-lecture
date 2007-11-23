Solution d'accessibilité Confort De Lecture.

-----------------------------------------------------------------------------

- Pré-requis matériels et logiciels
	• Une machine (1,5Go de RAM minimum, 10Mo minimum d’espace de disque dur)
	• Une distribution Linux installée sur la machine (CentOS par exemple) 
	• Commande file versions supérieures ou égales à 4.21 
	• Apache 2.0.*
	• PHP4 versions supérieures ou égales à 4.3
	• MySQL4 versions supérieures ou égales 4.0
	• Perl 5.8.*

- Procédure d’installation
	• Insérer les lignes suivantes à la fin du fichier de configuration d’Apache (httpd.conf dans le répertoire conf) :
		<VirtualHost *:80>
			ServerAdmin {ADRESSE_MAIL_WEBMASTER}
			DocumentRoot {REPERTOIRE__SOURCES_APPLICATION}
			ServerName {NOM_DE_DOMAINE}
			ErrorLog logs/{NOM_DE_DOMAINE}-error_log
			CustomLog logs/{NOM_DE_DOMAINE}-access_log common
			RewriteLog logs/{NOM_DE_DOMAINE}-urlrewrite.log
			RewriteLogLevel 9
			ScriptAlias /filtre "{REPERTOIRE__SOURCES_APPLICATION}/cdl/scripts"
			AddHandler cgi-script .pl
		</VirtualHost>
		<Directory "{REPERTOIRE__SOURCES_APPLICATION}">
			Options ExecCGI FollowSymLinks Includes
			AllowOverride all
			Order allow,deny
			Allow from all
		</Directory>

	• Décompresser l’archive du projet dans le répertoire du site spécifié dans la configuration Apache ({REPERTOIRE__SOURCES_APPLICATION}).

	• Mettre les droits en lecture et écriture pour l'utilisateur internet sur /includes/cache et /configuration/sites + droits d’exécution pour tous sur tous les fichiers *.pl et *.pm.

	• Dans le fichier /configuration/admin/.htaccess, remplacer le chemin vers le fichier .htpasswd pour pointer vers le bon, et choisissez le nom d’utilisateur de votre choix :
		AuthUserFile {REPERTOIRE__SOURCES_APPLICATION}/configuration/admin/.htpasswd
		AuthName "'Administration des sites'"
		Require user {LOGIN_UTILISATEUR_ADMIN}
		AuthType Basic

	• Dans le fichier /configuration/admin/.htpasswd, mettre un mot de passe de votre choix encrypté. Vous pouvez utiliser l’outil suivant pour encrypter un mot de passe : http://www.4webhelp.net/us/password.php (mettre le login spécifié dans /configuration/admin/.htaccess. voir point précédent)

	• Editer chacune des constantes suivantes dans le fichier /includes/contants.pm (si la valeur vous convient, vous la laissez inchangée) : $sessionExpireIn, $cdlAccept, $cdlRootPath, $databaseHost, $databaseName, $databaseLogin, $databasePassword, $agentNameToSend, $fontFamily, %fontSizes, $defaultLanguage, $defaultButtonText).

	• Créer la base de données MySQL (que vous avez spécifiée dans le fichier de constantes), et jouer le script SQL suivant :
		SET AUTOCOMMIT=0;
		START TRANSACTION;

		-- 
		-- Base de données: `{NOM_BASE_DE_DONNEES}`
		-- 

		----------------------------------------------------------

		-- 
		-- Structure de la table `users`
		-- 

		CREATE TABLE `users` (
		  `ID_USER` int(11) NOT NULL auto_increment,
		  `LOGIN_USER` varchar(255) NOT NULL default '',
		  `PASSWORD_USER` varchar(255) NOT NULL default '',
		  `FONT_SIZE` varchar(255) NOT NULL default '',
		  `BACKGROUND_COLOR` varchar(255) NOT NULL default '',
		  `FONT_COLOR` varchar(255) NOT NULL default '',
		  `ACTIVATE_JS` tinyint(1) NOT NULL default '0',
		  `ACTIVATE_FRAMES` tinyint(1) NOT NULL default '1',
		  `DISPLAY_IMAGES` tinyint(1) NOT NULL default '0',
		  `DISPLAY_OBJECTS` tinyint(1) NOT NULL default '0',
		  `DISPLAY_APPLETS` tinyint(1) NOT NULL default '0',
		  `PARSE_TABLES` tinyint(1) NOT NULL default '1',
		  `CREATE_TIME` datetime NOT NULL default '0000-00-00 00:00:00',
		  `UPDATE_TIME` datetime default '0000-00-00 00:00:00',
		  PRIMARY KEY  (`ID_USER`),
		  UNIQUE KEY `LOGIN_USER` (`LOGIN_USER`)
		) TYPE=MyISAM;

		COMMIT;

	• Dans le fichier /style_personalization/inc/constantes_fonctions.php, Modifier les paramètres de base de données et de base d’URL qui se trouvent aux lignes suivantes :
		$UrlSiteCdl			= "http://{NOM_DE_DOMAINE}";
		$parserUrl			= "http://{NOM_DE_DOMAINE}/filtre/index.pl";

		$dbHost				= "{ADRESSE_SERVEUR_BASE_DE_DONNEES}";
		$dbName				= "{NOM_BASE_DE_DONNEES}";
		$dbLogin			= "{LOGIN_UTILISATEUR_BASE_DE_DONNEES}";
		$dbPassword		= "{MOT_DE_PASSE_UTILISATEUR_BASE_DE_DONNEES}";

	• Installer les librairies Perl manquantes

----------------------------------------------------------------------------------

Pour plus d'informations, vous pouvez contacter le responsable de la solution :

	Youssef IMZOURH - Groupe SQLi
	Agence de Poitiers
	6, rue Gaspard Monge
	86130 JAUNAY CLAN

	Tél :
		(+33)549414600
		(+33)617077544
		(+212)11484633
	Email :
		yimzourh@sqli.com