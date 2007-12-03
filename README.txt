Solution d'accessibilité Confort De Lecture.

-----------------------------------------------------------------------------

- Pré-requis matériels et logiciels
	• Une machine (1,5Go de RAM minimum, 100Mo minimum d’espace de disque dur)
	• Une distribution Linux installée sur la machine (CentOS par exemple) 
	• Commande file versions supérieures ou égales à 4.21 
	• Apache 2.0.*
	• PHP4 versions supérieures ou égales à 4.3
	• MySQL4 versions supérieures ou égales 4.0
	• Perl 5.8.*

- Procédure d’installation
	• Insérer les lignes suivantes à la fin du fichier de configuration d’Apache (httpd.conf dans le répertoire conf), et remplir les paramètres qui sont entre accolades { } :
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
		<Directory "{REPERTOIRE_SOURCES_APPLICATION}/cdl/scripts/admin">
			AuthUserFile {REPERTOIRE_SOURCES_APPLICATION}/configuration/.htpasswd
			AuthName "'Administration des sites'"
			Require user {LOGIN_UTILISATEUR_ADMIN}
			AuthType Basic
		</Directory>

	• Décompresser l’archive du projet dans le répertoire du site spécifié dans la configuration Apache ({REPERTOIRE__SOURCES_APPLICATION}).

	• Mettre les droits en lecture et écriture pour l'utilisateur internet sur /cache et /configuration/sites + droits d’exécution pour tous sur tous les fichiers *.pl et *.pm qui se trouvent dans le répertoire /cdl.

	• Dans le fichier /configuration/.htpasswd, mettre un mot de passe de votre choix encrypté. Vous pouvez utiliser l’outil suivant pour encrypter un mot de passe : http://www.4webhelp.net/us/password.php (mettre le login {LOGIN_UTILISATEUR_ADMIN} spécifié dans la configuration Apache. cf. 1er point concernant la configuration Apache, 2e balise Directory)

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
		  `ACTIVATE_JS` tinyint(1) default NULL,
		  `ACTIVATE_FRAMES` tinyint(1) default NULL,
		  `DISPLAY_IMAGES` tinyint(1) default NULL,
		  `DISPLAY_OBJECTS` tinyint(1) default NULL,
		  `DISPLAY_APPLETS` tinyint(1) default NULL,
		  `PARSE_TABLES` tinyint(1) default NULL,
		  `CREATE_TIME` datetime NOT NULL default '0000-00-00 00:00:00',
		  `UPDATE_TIME` datetime default '0000-00-00 00:00:00',
		  PRIMARY KEY  (`ID_USER`),
		  UNIQUE KEY `LOGIN_USER` (`LOGIN_USER`)
		) TYPE=MyISAM;

		COMMIT;

	• Dans le fichier /configuration/constantes.php, Modifier les paramètres de base de données qui se trouvent aux lignes suivantes :
		$dbHost			= "{ADRESSE_SERVEUR_BASE_DE_DONNEES}";
		$dbName			= "{NOM_BASE_DE_DONNEES}";
		$dbLogin		= "{LOGIN_UTILISATEUR_BASE_DE_DONNEES}";
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