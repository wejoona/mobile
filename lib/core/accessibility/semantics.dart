/// Semantic labels for accessibility.
///
/// Used with Semantics widget and semanticLabel properties.
abstract class AppSemantics {
  // ── Navigation ──
  static const home = 'Accueil';
  static const back = 'Retour';
  static const closeDialog = 'Fermer';
  static const menu = 'Menu';
  static const search = 'Rechercher';

  // ── Actions ──
  static const send = 'Envoyer de l\'argent';
  static const receive = 'Recevoir de l\'argent';
  static const deposit = 'Faire un dépôt';
  static const withdraw = 'Faire un retrait';
  static const scanQr = 'Scanner un code QR';
  static const copyToClipboard = 'Copier';
  static const share = 'Partager';
  static const refresh = 'Actualiser';
  static const toggleBalanceVisibility = 'Afficher ou masquer le solde';

  // ── Status ──
  static const successIcon = 'Succès';
  static const errorIcon = 'Erreur';
  static const warningIcon = 'Avertissement';
  static const infoIcon = 'Information';
  static const loadingIndicator = 'Chargement en cours';
  static const emptyState = 'Aucun élément';

  // ── Wallet ──
  static String balance(String amount) => 'Solde: $amount';
  static String transaction(String type, String amount) => 'Transaction $type de $amount';

  // ── Cards ──
  static String cardNumber(String last4) => 'Carte terminant par $last4';
  static const frozenCard = 'Carte gelée';
  static const activeCard = 'Carte active';

  // ── Notifications ──
  static const unreadNotification = 'Notification non lue';
  static const readNotification = 'Notification lue';
  static String notificationCount(int count) => '$count notifications non lues';
}
