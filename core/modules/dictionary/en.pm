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

# File: en.pm
#	Module des constantes de langue anglaise

# String: $defaultVoice
# La code de la langue par défaut
$defaultLanguage = "fr-FR";

# Hash: %dictionary
# Le tableau des termes à traduire
%dictionary = ();

$dictionary{'TITLE_PERSONNALISER_AFFICHAGE'} = "personnalisez vos paramètres d'affichage";
$dictionary{'TITLE_PERSONNALISER_AUDIO'} = "personnalisez vos paramètres audio";
$dictionary{'TITLE_AIDE_AUDIO'} = "aide audio";
$dictionary{'TITLE_HAUT_PAGE'} = "retour en haut de page";

$dictionary{'EXPLICATION_CONFIG'} = "sélectionnez vos paramètres d’affichage, pré-visualisez le profil configuré, naviguez !";
$dictionary{'LABEL_FOND_NOIR'} = "couleur de fond noire";
$dictionary{'LABEL_FOND_BLANC'} = "couleur de fond blanche";
$dictionary{'LABEL_FOND_VERT'} = "couleur de fond verte";
$dictionary{'LABEL_FOND_JAUNE'} = "couleur de fond jaune";
$dictionary{'LABEL_FOND_BLEU'} = "couleur de fond bleue";
$dictionary{'LABEL_FOND_ROUGE'} = "couleur de fond rouge";
$dictionary{'TITLE_BOUTON_PLUS_DE_COULEURS_FOND'} = "choisir d'autres couleurs pour le fond";

$dictionary{'LABEL_TRES_PETITE'} = "taille de texte très petite";
$dictionary{'LABEL_PETITE'} = "taille de texte petite";
$dictionary{'LABEL_MOYENNE'} = "taille de texte moyenne";
$dictionary{'LABEL_GRANDE'} = "taille de texte grande";
$dictionary{'LABEL_TRES_GRANDE'} = "taille de texte très grande";
$dictionary{'LABEL_TRES_TRES_GRANDE'} = "taille de texte très très grande";
$dictionary{'TITLE_BOUTON_PLUS_DE_TAILLES'} = "choisir d'autres tailles pour le texte";

$dictionary{'LABEL_TEXTE_NOIR'} = "couleur de texte noire";
$dictionary{'LABEL_TEXTE_BLANC'} = "couleur de texte blanche";
$dictionary{'LABEL_TEXTE_VERT'} = "couleur de texte verte";
$dictionary{'LABEL_TEXTE_JAUNE'} = "couleur de texte jaune";
$dictionary{'LABEL_TEXTE_BLEU'} = "couleur de texte bleue";
$dictionary{'LABEL_TEXTE_ROUGE'} = "couleur de texte rouge";
$dictionary{'TITLE_BOUTON_PLUS_DE_COULEURS_TEXTE'} = "choisir d'autres couleurs pour le texte";

$dictionary{'LABEL_LIEN_NOIR'} = "couleur de liens noire";
$dictionary{'LABEL_LIEN_BLANC'} = "couleur de liens blanche";
$dictionary{'LABEL_LIEN_VERT'} = "couleur de liens verte";
$dictionary{'LABEL_LIEN_JAUNE'} = "couleur de liens jaune";
$dictionary{'LABEL_LIEN_BLEU'} = "couleur de liens bleue";
$dictionary{'LABEL_LIEN_ROUGE'} = "couleur de liens rouge";
$dictionary{'TITLE_BOUTON_PLUS_DE_COULEURS_LIEN'} = "choisir d'autres couleurs pour les liens";

$dictionary{'BOUTON_PLUS_DE_COULEURS_FOND'} = "de fond";
$dictionary{'BOUTON_PLUS_DE_TAILLES'} = "de taille";
$dictionary{'BOUTON_PLUS_DE_COULEURS_TEXTE'} = "de contraste";
$dictionary{'BOUTON_PLUS_DE_COULEURS_LIENS'} = "de lien";

$dictionary{'TITRE_PREVISUALISATION'} = "zone de prévisualisation";
$dictionary{'TEXTE_PREVISUALISATION'} = "<a href=\"http://www.confortdelecture.org\" target=\"_blank\">Confort de lecture</a> <span class=\"cdlPartOfText\">vous permet de choisir la couleur de fond, la taille et la couleur des caractères, et la couleur des liens, adaptés à votre vision et à vos pages imprimées.</span>";

$dictionary{'PARAMETRES_AVANCES'} = "paramètres avancés";
$dictionary{'TITLE_PARAMETRES_AVANCES'} = "personnalisez vos paramètres avancés";

$dictionary{'BOUTON_VALIDER'} = "valider";
$dictionary{'BOUTON_VALIDER_ET_ACCEDER'} = "valider et accéder";
$dictionary{'BOUTON_RETOUR'} = "retour";

$dictionary{'TITLE_PALETTE'} = "choisissez une couleur";
$dictionary{'EXPLICATION_PALETTE'} = "sélectionnez une couleur parmi les 64 disponibles";
$dictionary{'INTRO_PALETTE'} = "";
$dictionary{'LABEL_COULEUR'} = "couleur";

$dictionary{'TITLE_TAILLES_TEXTE'} = "sélectionnez une taille de texte";
$dictionary{'EXPLICATION_TAILLES_TEXTE'} = "sélectionnez une taille de texte";
$dictionary{'LABEL_TAILLE'} = "taille";
$dictionary{'TEXTE_SOIT'} = "soit&nbsp;: ";

$dictionary{'LABEL_ESPACEMENT_LETTRE'} = "espacement entre les lettres";
$dictionary{'LABEL_ESPACEMENT_LETTRE_NORMAL'} = "normal";
$dictionary{'LABEL_ESPACEMENT_LETTRE_GRAND'} = "grand";
$dictionary{'LABEL_ESPACEMENT_LETTRE_IMPORTANT'} = "très grand";
$dictionary{'LABEL_ESPACEMENT_MOT'} = "espacement entre les mots";
$dictionary{'LABEL_ESPACEMENT_MOT_NORMAL'} = "normal";
$dictionary{'LABEL_ESPACEMENT_MOT_GRAND'} = "grand";
$dictionary{'LABEL_ESPACEMENT_MOT_IMPORTANT'} = "très grand";
$dictionary{'LABEL_ESPACEMENT_LIGNE'} = "espacement entre les lignes";
$dictionary{'LABEL_ESPACEMENT_LIGNE_NORMAL'} = "normal";
$dictionary{'LABEL_ESPACEMENT_LIGNE_GRAND'} = "grand";
$dictionary{'LABEL_ESPACEMENT_LIGNE_IMPORTANT'} = "très grand";

$dictionary{'PARAMETRES_AVANCES_FIL_ARIANE'} = "choisir la position du fil d'Ariane";
$dictionary{'PARAMETRES_AVANCES_IMG'} = "afficher les images";
$dictionary{'PARAMETRES_AVANCES_OBJECT'} = "afficher les contenus animations, audios et vidéos";
$dictionary{'PARAMETRES_AVANCES_TABLE'} = "linéariser les tableaux";
$dictionary{'PARAMETRES_AVANCES_JS'} = "activer les scripts";
$dictionary{'PARAMETRES_AVANCES_JS_INFO'} = "(si \"non\" est coché, le fonctionnement alternatif est activé)";
$dictionary{'PARAMETRES_AVANCES_IMG_INFO'} = "(si \"non\" est coché, le contenu alternatif est affiché)";
$dictionary{'PARAMETRES_AVANCES_OBJECT_INFO'} = "(si \"non\" est coché, le contenu alternatif est affiché)";
$dictionary{'PARAMETRES_AVANCES_TABLE_INFO'} = "(les transformer en listes à puces)";
$dictionary{'OUI'} = "oui";
$dictionary{'NON'} = "non";
$dictionary{'ONLY_WITH_ALT'} = "avec alternative";
$dictionary{'PARAMETRES_AVANCES_HAUT_PAGE'} = "en haut de page";
$dictionary{'PARAMETRES_AVANCES_BAS_PAGE'} = "en bas de page";
$dictionary{'PARAMETRES_AVANCES_HAUT_ET_BAS_PAGE'} = "en haut et en bas de page";

$dictionary{'INTRO_AUDIO'} = "<strong class=\"cdlWarning\">attention : si vous utilisez une synthèse vocale et/ou une revue d'écran, veuillez les désactiver puis,</strong> pour démarrer la lecture vocale de cette page, veuillez appuyer sur la touche <strong>P</strong> de votre clavier ou cliquez sur le bouton <strong>lecture</strong> du lecteur audio ci-dessus.";
$dictionary{'PARAMETRES_ACTIVER_AUDIO'} = "activer l'audio";
$dictionary{'PARAMETRES_AUDIO_VOIX'} = "voix";
$dictionary{'PARAMETRES_AUDIO_VITESSE'} = "vitesse de lecture des pages";
$dictionary{'JE_M_APPELLE'} = "Je m'appelle";
$dictionary{'VITESSE_DE_LECTURE'} = "vitesse de lecture";
$dictionary{'TRES_LENTE'} = "très lente";
$dictionary{'LENTE'} = "lente";
$dictionary{'STANDARD'} = "standard";
$dictionary{'RAPIDE'} = "rapide";
$dictionary{'TRES_RAPIDE'} = "très rapide";

$dictionary{'BLOC_PRECEDENT'} = "bloc précédent";
$dictionary{'PHRASE_PRECEDENTE'} = "phrase précédente";
$dictionary{'LECTURE_PAUSE'} = "lecture / Pause";
$dictionary{'STOPPER_LA_LECTURE'} = "stopper la lecture";
$dictionary{'STOP'} = "stop";
$dictionary{'PHRASE_SUIVANTE'} = "phrase suivante";
$dictionary{'BLOC_SUIVANT'} = "bloc suivant";

$dictionary{'AIDE_AUDIO'} = "<p><h1>Comment naviguer avec \"Confort de lecture audio\" ?</h1></p><br><p>\"Confort de lecture audio\" propose deux modes de lecture : le mode automatique et le mode manuel.</p><br><h2>1. Le mode automatique</h2><br><p>Dès la page d’accueil d’un site en mode \"Confort de lecture audio\", la lecture vocale s’active automatiquement en utilisant un des 3 profils de voix suivants :</p><ul><li>Un profil par défaut si vous n’avez jamais configuré de voix \"Confort de lecture audio\" sur ce poste informatique.<li>Le profil de voix que vous venez de configurer pour la première fois sur ce poste.<li>Le dernier profil que vous avez configuré sur ce poste si les cookies de votre navigateur n’ont pas été supprimés depuis.</ul><br><p>Si aucune action de la souris ou du clavier n’est détectée par le \"lecteur audio\", la lecture se fera sans interruption jusqu’au bas de la page avec un temps d’arrêt après chaque lien, chaque champ de saisie ou liste déroulante. Ces arrêts vous permettent d’agir sereinement sur ces propositions si vous le souhaitez.</p><br><p>Toute intervention de votre part sur le \"lecteur audio\", arrête le \"mode automatique\". Vous pouvez alors continuer votre lecture en \"mode manuel\" ou redémarrer le \"mode automatique\" en cliquant sur la touche \"play\" du lecteur en haut de votre écran ou avec la touche \"P\" du clavier.</p><br><br><h2>2. Le Mode manuel</h2><br><p><h3>2.1 Mode manuel avec souris</h3><br><span class=\"cdlPartOfText\">Dans l’environnement \"Confort de lecture audio\" toutes les fonctionnalités normales de votre souris sont opérationnelles. Le pointeur de votre souris est optimisé en fonction de la taille de caractères choisis.</span></p><br><h4>Utilisation du lecteur audio</h4><ul><li><span class=\"cdlPartOfText\">Bouton \"pause\" et bouton \"play\" du lecteur audio.</span><br><span class=\"cdlPartOfText\">La synthèse suspend la lecture mais la phrase en cours reste surlignée.</span><li><span class=\"cdlPartOfText\">Bouton \"play\" du lecteur audio.</span><br><span class=\"cdlPartOfText\">À la reprise de la lecture la synthèse reprend toujours en automatique là où elle s'était arrêtée dans le bloc.</span><li><span class=\"cdlPartOfText\">Bouton \"suivant\" du lecteur audio.</span><br><span class=\"cdlPartOfText\">Interruption de la lecture en cours et passage à la lecture de la phrase suivante, puis arrêt. En cliquant un nombre de fois sur \"suivant\" la phrase lue sera celle correspondant à ce même nombre ( ex : 3 clics = 3ème phrase après celle déjà lue).</span><li><span class=\"cdlPartOfText\">Bouton \"précédent\" du lecteur audio.</span><br><span class=\"cdlPartOfText\">Interruption de la lecture en cours et passage à la lecture de la phrase précédente, puis arrêt. En cliquant un nombre de fois sur \"précédent\" la phrase lue sera celle correspondant à ce même nombre ( ex : 3 clics = 3ème phrase avant celle déjà lue).</span><li><span class=\"cdlPartOfText\">Bouton \"avance rapide\" du lecteur audio.</span><br><span class=\"cdlPartOfText\">Interruption de la lecture en cours et passage à la lecture du cadre suivant, puis arrêt. En cliquant un nombre de fois sur \"avance rapide\" le cadre lu sera celui correspondant à ce même nombre (ex : 3 clics = 3ème cadre après celui déjà lu).</span><li><span class=\"cdlPartOfText\">Bouton \"retour rapide\" du lecteur audio.</span><br><span class=\"cdlPartOfText\">Interruption de la lecture en cours et retour à la lecture du cadre précédent, puis arrêt. En cliquant un nombre de fois sur \"retour rapide\" le cadre lu sera celui correspondant à ce même nombre (ex : 3 clics = 3ème cadre avant celui déjà lu).</span><li><span class=\"cdlPartOfText\">Bouton \"stop\" du lecteur audio.</span><br><span class=\"cdlPartOfText\">Stoppe la lecture de la page. Le sur-lignage de la phrase en cours de lecture disparait. L’écran remonte en haut de page.</span></ul><br><h3>2.2 Mode manuel avec clavier : les fonctionnalités spécifiques de \"Confort de lecture audio\"</h3><ul><li>La lettre \"P\" sert à la fois à activer la lecture automatique et à la mettre en pause.<li>La lettre \"S\" stoppe la lecture. Dans ce cas, la lecture reprendra au redémarrage en début de page.<li>La touche de direction \"bas\" permet de passer à la lecture du bloc phrase suivant ou du lien suivant. Elle permet aussi dans un bloc de texte important de trouver rapidement un lien.<li>La touche de direction\"haut\" permet de passer à la lecture du bloc phrase précédent ou du lien précédent.<li>La touche \"page suivante\" permet de passer au bloc cadre suivant.<li>La touche \"page précédente\" permet de passer au bloc cadre précédent.<li>La touche \"entrée\" permet d'ouvrir le lien qui vient d'être énoncé, de valider un champ texte rempli ou une option choisie d’une boite déroulante.<li>La touche \"tabulation\" agit normalement. Elle permet entre autres de naviguer de lien en lien, d'accéder au champ de formulaire suivant, etc.<li>La touche \"échap\" permet de sortir d’un champ de saisie non rempli ou d’une liste déroulante pour aller sur la ligne suivante (ou le champ de saisie suivant).<li>La combinaison des touches \"shift + échap\" permet de sortir d’un champ de saisie non rempli ou d’une liste déroulante pour aller sur la ligne précédente (ou le champ de saisie précédant).<li>Tous les <strong>raccourcis clavier (ou accesskeys) utilisés sous Windows, Linux et Mac Intoch fonctionnent avec \"Confort de lecture audio\".</strong></ul></ol>";
$dictionary{'AIDE_AUDIO_SUITE'} = "Les paramètres audio vous donnent accès au choix d'une voix parmi les cinq qui vous sont proposées. Vous pouvez également sélectionner la vitesse d'élocution de la voix choisie.";

$dictionary{'PHRASE_ACCES_PAGE_PROTEGEE'} = "Vous allez accéder à une page qui est protégée. Veuillez saisir votre identifiant et votre mot de passe.";
$dictionary{'LABEL_NOM_UTILISATEUR'} = "nom d'utilisateur&nbsp;:";
$dictionary{'LABEL_NOM_UTILISATEUR2'} = "nom d'utilisateur";
$dictionary{'LABEL_MOT_DE_PASSE'} = "mot de passe&nbsp;:";

$dictionary{'RETOUR_ACCUEIL'} = "retour à l'accueil";

$dictionary{'PHRASE_ACCES_DOCUMENT'} = "vous allez accéder à un document de type :";
$dictionary{'LIEN_OUVRIR_DOCUMENT'} = "ouvrir le document";
$dictionary{'LIEN_TELECHARGER_DOCUMENT'} = "télécharger le document";
$dictionary{'LIEN_ANNULER_ET_RETOURNER'} = "annuler et retourner à la page précédente";

$dictionary{'ERREUR'} = "erreur";
$dictionary{'PHRASE_SUR_LA_PAGE'} = "sur la page :";
$dictionary{'PHRASE_REESSAYER'} = "vous pouvez réessayer en cliquant ici";

$dictionary{'PHRASE_ACCEDER_PAGE_EXTERNE'} = "vous allez accéder à une page qui ne prend pas en compte Confort de lecture.";
$dictionary{'PHRASE_CONFIRMATION_ACCEDER_PAGE_EXTERNE'} = "voulez vous vraiment accéder à la page suivante ?";

$dictionary{'LABEL_OPTION_DE_LISTE'} = "option de liste";
$dictionary{'LABEL_SELECTIONNEE'} = "sélectionnée";
$dictionary{'LABEL_VIDE'} = "vide";
$dictionary{'LABEL_LIEN'} = "lien";
$dictionary{'LABEL_BOUTON'} = "bouton";
$dictionary{'LABEL_REINITIALISATION'} = "réinitialisation";
$dictionary{'LABEL_VALIDATION'} = "validation";
$dictionary{'LABEL_CASE_A_COCHER'} = "case à cocher";
$dictionary{'LABEL_COCHEE'} = "cochée";
$dictionary{'LABEL_BOUTON_RADIO'} = "bouton radio";
$dictionary{'LABEL_COCHE'} = "coché";
$dictionary{'LABEL_CHAMP'} = "champ";
$dictionary{'LABEL_CHAMP_EDITION'} = "champ d'édition";
$dictionary{'LABEL_FICHIER'} = "fichier";
$dictionary{'LABEL_CRYPTE'} = "crypté";
$dictionary{'LABEL_COULEUR'} = "de couleur";
$dictionary{'LABEL_DATE'} = "de date";
$dictionary{'LABEL_DATE_ET_HEURE'} = "de date et heure";
$dictionary{'LABEL_DATE_ET_HEURE_LOCALE'} = "de date et heure locale";
$dictionary{'LABEL_EMAIL'} = "d'email";
$dictionary{'LABEL_MOIS'} = "de mois";
$dictionary{'LABEL_NOMBRE'} = "numérique";
$dictionary{'LABEL_INTERVALLE'} = "d'intervalle";
$dictionary{'LABEL_DE_RECHERCHE'} = "de recherche";
$dictionary{'LABEL_TELEPHONE'} = "de téléphone";
$dictionary{'LABEL_HEURE'} = "d'heure";
$dictionary{'LABEL_URL'} = "d'U.R.L.";
$dictionary{'LABEL_SEMAINE'} = "de semaine";
$dictionary{'LABEL_MULTILIGNE'} = "multiligne";
$dictionary{'PHRASE_SORTIR_DU_CHAMP'} = "pour sortir de ce champ, utilisez la touche échappe.";
$dictionary{'LABEL_LISTE_DEROULANTE'} = "liste déroulante";
$dictionary{'LABEL_LEGENDE'} = "légende";
$dictionary{'LABEL_TERME_DEFINI'} = "terme défini";
$dictionary{'LABEL_DEFINITION_TERME'} = "définition terme";
$dictionary{'LABEL_ZONE_DE_CODE'} = "zone de code";
$dictionary{'LABEL_CITATION'} = "citation";
$dictionary{'LABEL_CELLULE'} = "cellule";
$dictionary{'LABEL_ENTETE_DE_CELLULE'} = "entête de cellule";

$dictionary{'TEXTE_CONTENU_CHAMP_APRES_COLLER'} = "Contenu du champ après coller :";

$dictionary{'TITLE_GALERIE_FERMER'} = "fermer le diaporama d'images";
$dictionary{'TITLE_GALERIE_PRECEDENT'} = "image précédente";
$dictionary{'TITLE_GALERIE_SUIVANT'} = "image suivante";

# Hash: %lettersToSpell
# La liste des lettres correspondant aux touches du clavier
%lettersToSpell = (
	"0", "0",
	"1", "1",
	"2", "2",
	"3", "3",
	"4", "4",
	"5", "5",
	"6", "6",
	"7", "7",
	"8", "8",
	"9", "9",
	"a_accent_grave", "à",
	"accent_circonflexe", "accent_circonflexe",
	"accent_grave", "accent_grave",
	"acollade_fermante", "acollade_fermante",
	"acollade_ouvrante", "acollade_ouvrante",
	"anti_slash", "anti_slash",
	"apostrophe", "apostrophe",
	"arobase", "arobase",
	"a", "a",
	"barre_verticale", "barre_verticale",
	"b", "b",
	"c_cedille", "ç",
	"chevron_fermant", "chevron_fermant",
	"chevron_ouvrant", "chevron_ouvrant",
	"coche", "coché",
	"crochet_fermant", "crochet_fermant",
	"crochet_ouvrant", "crochet_ouvrant",
	"c", "c",
	"decoche", "décoché",
	"degre", "degré",
	"deux_points", "deux_points",
	"diese", "dièse",
	"divise_par", "divisé_par",
	"dollar", "dollar",
	"d", "d",
	"e_accent_aigu", "é",
	"e_accent_grave", "è",
	"egal", "égal",
	"entree", "entrée",
	"espace", "espace",
	"et_commercial", "et_commercial",
	"etoile", "étoile",
	"euro", "euro",
	"e", "e",
	"exposant_2", "²",
	"f", "f",
	"guillemet", "guillemet",
	"g", "g",
	"h", "h",
	"i", "i",
	"j", "j",
	"k", "k",
	"livre_sterling", "livre_sterling",
	"l", "l",
	"majuscule", "grand",
	"moins", "moins",
	"multiplie_par", "multiplié_par",
	"mu", "mu",
	"m", "m",
	"n", "n",
	"o", "o",
	"parenthese_fermante", "parenthèse_fermante",
	"parenthese_ouvrante", "parenthèse_ouvrante",
	"pluss", "pluss",
	"point_dexclamation", "point_dexclamation",
	"point_dinterrogation", "point_dinterrogation",
	"point", "point",
	"point_virgule", "point_virgule",
	"pourcent", "pourcent",
	"p", "p",
	"q", "q",
	"retour", "retour",
	"r", "r",
	"signe_section", "signe_section",
	"slash", "slash",
	"souligne", "souligné",
	"supprimer", "suppression",
	"s", "s",
	"symbole_monetaire", "symbole_monétaire",
	"tilde", "tilde",
	"tiret", "tiret",
	"trema", "tréma",
	"t", "t",
	"u_accent_grave", "ù",
	"u", "u",
	"virgule", "virgule",
	"v", "v",
	"w", "w",
	"x", "x",
	"y", "y",
	"z", "z"
);

# Hash: %checkedToSpell
# les termes "coché" et "décoché"
%checkedToSpell = (
	"coche", "coché",
	"decoche", "décoché"
);

# Hash: %unordoredVoices
# La liste des voix sans ordre
%unordoredVoices = ('Thomas' => 'Thomas', 'Virginie' => 'Virginie', 'Sebastien' => 'Sébastien');

# Hash: %voices
# La liste des voix
%voices = ('1Thomas' => 'Thomas', '2Virginie' => 'Virginie', '3Sebastien' => 'Sébastien');

# String: $defaultVoice
# La voix par défaut utilisée pour lire les pages
$defaultVoice = "Thomas";

# Pour dire au pl que le pm s'est bien exécuté, il faut lui renvoyer une valeur vraie (donc 1 par ex)
1;