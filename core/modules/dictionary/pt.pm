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

# File: pt.pm
#	Module des constantes de langue portugaise

# String: $defaultVoice
# La code de la langue par défaut
$defaultLanguage = "fr-FR";

# Hash: %dictionary
# Le tableau des termes à traduire
%dictionary = ();

$dictionary{'TITLE_PERSONNALISER_AFFICHAGE'} = "Personnaliser vos paramètres d'affichage";
$dictionary{'TITLE_PERSONNALISER_AUDIO'} = "Personnaliser vos paramètres audio";
$dictionary{'TITLE_AIDE_AUDIO'} = "Aide audio";

$dictionary{'EXPLICATION_CONFIG'} = "Sélectionnez une couleur, un contraste et la taille des caractères.";
$dictionary{'LABEL_FOND_NOIR'} = "Couleur de fond noire";
$dictionary{'LABEL_FOND_BLANC'} = "Couleur de fond blanche";
$dictionary{'LABEL_FOND_VERT'} = "Couleur de fond verte";
$dictionary{'LABEL_FOND_JAUNE'} = "Couleur de fond jaune";
$dictionary{'LABEL_FOND_BLEU'} = "Couleur de fond bleue";
$dictionary{'TITLE_BOUTON_PLUS_DE_COULEURS_FOND'} = "Choisir d'autres couleurs pour le fond";

$dictionary{'LABEL_TRES_PETITE'} = "Taille de texte très petite";
$dictionary{'LABEL_PETITE'} = "Taille de texte petite";
$dictionary{'LABEL_MOYENNE'} = "Taille de texte moyenne";
$dictionary{'LABEL_GRANDE'} = "Taille de texte grande";
$dictionary{'LABEL_TRES_GRANDE'} = "Taille de texte très grande";
$dictionary{'TITLE_BOUTON_PLUS_DE_TAILLES'} = "Choisir d'autres tailles pour le texte";

$dictionary{'LABEL_TEXTE_NOIR'} = "Couleur de texte noire";
$dictionary{'LABEL_TEXTE_BLANC'} = "Couleur de texte blanche";
$dictionary{'LABEL_TEXTE_VERT'} = "Couleur de texte verte";
$dictionary{'LABEL_TEXTE_JAUNE'} = "Couleur de texte jaune";
$dictionary{'LABEL_TEXTE_BLEU'} = "Couleur de texte bleue";
$dictionary{'LABEL_TEXTE_ROUGE'} = "Couleur de texte rouge";
$dictionary{'TITLE_BOUTON_PLUS_DE_COULEURS_TEXTE'} = "Choisir d'autres couleurs pour le texte";

$dictionary{'LABEL_LIEN_NOIR'} = "Couleur de liens noire";
$dictionary{'LABEL_LIEN_BLANC'} = "Couleur de liens blanche";
$dictionary{'LABEL_LIEN_VERT'} = "Couleur de liens verte";
$dictionary{'LABEL_LIEN_JAUNE'} = "Couleur de liens jaune";
$dictionary{'LABEL_LIEN_BLEU'} = "Couleur de liens bleue";
$dictionary{'LABEL_LIEN_ROUGE'} = "Couleur de liens rouge";
$dictionary{'TITLE_BOUTON_PLUS_DE_COULEURS_LIEN'} = "Choisir d'autres couleurs pour les liens";

$dictionary{'BOUTON_PLUS_DE_COULEURS'} = "de couleurs";
$dictionary{'BOUTON_PLUS_DE_TAILLES'} = "de tailles";

$dictionary{'BOUTON_APERCU'} = "<span>a</span><span>p</span><span>e</span><span>r</span><span>ç</span><span>u</span><br><a href='#' title='aperçu du lien'><span>l</span><span>i</span><span>e</span><span>n</span></a>";

$dictionary{'PARAMETRES_AVANCES'} = "Paramètres avancés";
$dictionary{'TITLE_PARAMETRES_AVANCES'} = "Personnaliser vos paramètres avancés d'affichage";

$dictionary{'BOUTON_VALIDER'} = "Valider";
$dictionary{'BOUTON_RETOUR'} = "Retour";

$dictionary{'TITLE_PALETTE'} = "Palette de couleurs";
$dictionary{'EXPLICATION_PALETTE'} = "Sélectionnez une couleur puis validez en bas";
$dictionary{'INTRO_PALETTE'} = "Vous disposez d'une palette de 216 couleurs";
$dictionary{'LABEL_COULEUR'} = "Couleur";

$dictionary{'LABEL_ESPACEMENT_LETTRE'} = "Espacement entre les lettres";
$dictionary{'LABEL_ESPACEMENT_LETTRE_NORMAL'} = "normal";
$dictionary{'LABEL_ESPACEMENT_LETTRE_GRAND'} = "grand";
$dictionary{'LABEL_ESPACEMENT_LETTRE_IMPORTANT'} = "très grand";
$dictionary{'LABEL_ESPACEMENT_MOT'} = "Espacement entre les mots";
$dictionary{'LABEL_ESPACEMENT_MOT_NORMAL'} = "normal";
$dictionary{'LABEL_ESPACEMENT_MOT_GRAND'} = "grand";
$dictionary{'LABEL_ESPACEMENT_MOT_IMPORTANT'} = "très grand";
$dictionary{'LABEL_ESPACEMENT_LIGNE'} = "Espacement entre les lignes";
$dictionary{'LABEL_ESPACEMENT_LIGNE_NORMAL'} = "normal";
$dictionary{'LABEL_ESPACEMENT_LIGNE_GRAND'} = "grand";
$dictionary{'LABEL_ESPACEMENT_LIGNE_IMPORTANT'} = "très grand";

$dictionary{'PARAMETRES_AVANCES_FIL_ARIANE'} = "Choisir la position du fil d'Ariane";
$dictionary{'PARAMETRES_AVANCES_IMG'} = "Afficher les images";
$dictionary{'PARAMETRES_AVANCES_OBJECT'} = "Afficher les contenus animations, audios et vidéos";
$dictionary{'PARAMETRES_AVANCES_TABLE'} = "Linéariser les tableaux";
$dictionary{'PARAMETRES_AVANCES_JS'} = "Activer les scripts";
$dictionary{'PARAMETRES_AVANCES_JS_INFO'} = "(si 'non' est coché, le fonctionnement alternatif est activé)";
$dictionary{'PARAMETRES_AVANCES_IMG_INFO'} = "(si 'non' est coché, le contenu alternatif est affiché)";
$dictionary{'PARAMETRES_AVANCES_OBJECT_INFO'} = "(si 'non' est coché, le contenu alternatif est affiché)";
$dictionary{'PARAMETRES_AVANCES_TABLE_INFO'} = "(les transformer en listes à puces)";
$dictionary{'OUI'} = "oui";
$dictionary{'NON'} = "non";
$dictionary{'ONLY_WITH_ALT'} = "avec alternative";
$dictionary{'PARAMETRES_AVANCES_HAUT_PAGE'} = "en haut de page";
$dictionary{'PARAMETRES_AVANCES_BAS_PAGE'} = "en bas de page";
$dictionary{'PARAMETRES_AVANCES_HAUT_ET_BAS_PAGE'} = "en haut et en bas de page";

$dictionary{'INTRO_AUDIO'} = "<strong class=\"cdlWarning\">Attention : si vous utilisez une synthèse vocale et/ou une revue d'écran, veuillez les désactiver puis,</strong> pour démarrer la lecture vocale de cette page, veuillez appuyer sur la touche <strong>P</strong> de votre clavier ou cliquez sur le bouton <strong>Lecture</strong> du lecteur audio ci-dessus.";
$dictionary{'PARAMETRES_ACTIVER_AUDIO'} = "Activer l'audio";
$dictionary{'PARAMETRES_AUDIO_VOIX'} = "Voix";
$dictionary{'PARAMETRES_AUDIO_VITESSE'} = "Vitesse de lecture des pages";
$dictionary{'JE_M_APPELLE'} = "Je m'appelle";
$dictionary{'VITESSE_DE_LECTURE'} = "Vitesse de lecture";
$dictionary{'TRES_LENTE'} = "Très lente";
$dictionary{'LENTE'} = "Lente";
$dictionary{'STANDARD'} = "Standard";
$dictionary{'RAPIDE'} = "Rapide";
$dictionary{'TRES_RAPIDE'} = "Très rapide";

$dictionary{'BLOC_PRECEDENT'} = "Bloc précédent";
$dictionary{'PHRASE_PRECEDENTE'} = "Phrase précédente";
$dictionary{'LECTURE_PAUSE'} = "Lecture / Pause";
$dictionary{'STOPPER_LA_LECTURE'} = "Stopper la lecture";
$dictionary{'STOP'} = "Stop";
$dictionary{'PHRASE_SUIVANTE'} = "Phrase suivante";
$dictionary{'BLOC_SUIVANT'} = "Bloc suivant";

$dictionary{'AIDE_AUDIO'} = "<p><strong>Comment naviguer avec « Confort de lecture audio » ?</strong></p><br><p>« Confort de lecture audio » propose deux modes de lecture : le mode automatique et le mode manuel.</p><br><ol><li><strong>Le mode automatique</strong><br><p>Dès la page d’accueil d’un site en mode « Confort de lecture audio », la lecture vocale s’active automatiquement en utilisant un des 3 profils de voix suivants :</p><ul><li>Un profil par défaut si vous n’avez jamais configuré de voix « Confort de lecture audio » sur ce poste informatique.<br></li><li>Le profil de voix que vous venez de configurer pour la première fois sur ce poste.</li><li>Le dernier profil que vous avez configuré sur ce poste si les cookies de votre navigateur n’ont pas été supprimés depuis.</li></ul><br><p>Si aucune action de la souris ou du clavier n’est détectée par le « lecteur audio », la lecture se fera sans interruption jusqu’au bas de la page avec un temps d’arrêt après chaque lien, chaque champ de saisie ou liste déroulante. Ces arrêts vous permettent d’agir sereinement sur ces propositions si vous le souhaitez.</p><br><p>Toute intervention de votre part sur le « lecteur audio », arrête le « mode automatique ». Vous pouvez alors continuer votre lecture en « mode manuel » ou redémarrer le « mode automatique » en cliquant sur la touche « play » du lecteur en haut de votre écran ou avec la touche « P » du clavier.</p></li><li><strong>Le Mode manuel</strong><br><p><strong>2.1 Mode manuel avec souris</strong><br>Dans l’environnement « Confort de lecture audio » toutes les fonctionnalités normales de votre souris sont opérationnelles. Avec le navigateur Firefox, Google Chrome, Safari et Opéra, le pointeur de votre souris est optimisé en fonction de la taille de caractères choisis.</p><br><strong>Utilisation du lecteur audio</strong><br><ul><li>Bouton « Pause » et bouton « Play » du lecteur audio.<br>La synthèse suspend la lecture mais la phrase en cours reste surlignée.</li><li>Bouton « Play » du lecteur audio.<br>À la reprise de la lecture la synthèse reprend toujours en automatique là où elle s'était arrêtée dans le bloc.</li><li>Bouton « Suivant » du lecteur audio.<br>Interruption de la lecture en cours et passage à la lecture de la phrase suivante, puis arrêt. En cliquant un nombre de fois sur « suivant » la phrase lue sera celle correspondant à ce même nombre ( ex : 3 clics = 3ème phrase après celle déjà lue).</li><li>Bouton « Précédent » du lecteur audio.<br>Interruption de la lecture en cours et passage à la lecture de la phrase précédente, puis arrêt. En cliquant un nombre de fois sur « précédent » la phrase lue sera celle correspondant à ce même nombre ( ex : 3 clics = 3ème phrase avant celle déjà lue).</li><li>Bouton « Avance rapide » du lecteur audio.<br>Interruption de la lecture en cours et passage à la lecture du cadre suivant, puis arrêt. En cliquant un nombre de fois sur « Avance rapide » le cadre lu sera celui correspondant à ce même nombre (ex : 3 clics = 3ème cadre après celui déjà lu).</li><li>Bouton « Retour rapide » du lecteur audio.<br>Interruption de la lecture en cours et retour à la lecture du cadre précédent, puis arrêt. En cliquant un nombre de fois sur « Retour rapide » le cadre lu sera celui correspondant à ce même nombre (ex : 3 clics = 3ème cadre avant celui déjà lu).</li><li>Bouton « Stop » du lecteur audio.<br>Stoppe la lecture de la page. Le sur-lignage de la phrase en cours de lecture disparait. L’écran remonte en haut de page.</li></ul><br><strong>2.2 Mode manuel avec clavier : les fonctionnalités spécifiques de « Confort de lecture audio »</strong><br><ul><li>La lettre « P » sert à la fois à activer la lecture automatique et à la mettre en pause.</li><li>La lettre « S » stoppe la lecture. Dans ce cas, la lecture reprendra au redémarrage en début de page.</li><li>La touche de direction « bas » permet de passer à la lecture du bloc phrase suivant ou du lien suivant. Elle permet aussi dans un bloc de texte important de trouver rapidement un lien.</li><li>La touche de direction« haut » permet de passer à la lecture du bloc phrase précédent ou du lien précédent.</li><li>La touche « page suivante » permet de passer au bloc cadre suivant.</li><li>La touche « page précédente » permet de passer au bloc cadre précédent.</li><li>La touche « Entrée » permet d'ouvrir le lien qui vient d'être énoncé, de valider un champ texte rempli ou une option choisie d’une boite déroulante.</li><li>La touche « tabulation » agit normalement. Elle permet entre autres de naviguer de lien en lien, d'accéder au champ de formulaire suivant, etc.</li><li>La touche « Echap » permet de sortir d’un champ de saisie non rempli ou d’une liste déroulante pour aller sur la ligne suivante (ou le champ de saisie suivant).</li><li>La combinaison des touches «shift + Echap » permet de sortir d’un champ de saisie non rempli ou d’une liste déroulante pour aller sur la ligne précédente (ou le champ de saisie précédant).</li><li>Tous les <strong>raccourcis clavier (ou accesskeys) utilisés sous Windows, Linux et Mac Intoch fonctionnent avec « Confort de lecture audio ».</strong></li></ul></li></ol>";
$dictionary{'AIDE_AUDIO_SUITE'} = "Les paramètres audio vous donnent accès au choix d'une voix parmi les cinq qui vous sont proposées. Vous pouvez également sélectionner la vitesse d'élocution de la voix choisie.";

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
	"crochet_fermant", "crochet_fermant",
	"crochet_ouvrant", "crochet_ouvrant",
	"c", "c",
	"degre", "degré",
	"deux_points", "deux_points",
	"diese", "dièse",
	"divise_par", "divisé_par",
	"dollar", "dollar",
	"d", "d",
	"e_accent_aigu", "é",
	"e_accent_grave", "è",
	"egal", "égal",
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
	"r", "r",
	"signe_section", "signe_section",
	"slash", "slash",
	"souligne", "souligné",
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