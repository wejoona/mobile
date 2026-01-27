// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'JoonaPay';

  @override
  String get navigation_home => 'Accueil';

  @override
  String get navigation_settings => 'Paramètres';

  @override
  String get navigation_send => 'Envoyer';

  @override
  String get navigation_receive => 'Recevoir';

  @override
  String get navigation_transactions => 'Transactions';

  @override
  String get navigation_services => 'Services';

  @override
  String get action_continue => 'Continuer';

  @override
  String get action_cancel => 'Annuler';

  @override
  String get action_confirm => 'Confirmer';

  @override
  String get action_back => 'Retour';

  @override
  String get action_submit => 'Soumettre';

  @override
  String get action_done => 'Terminé';

  @override
  String get action_save => 'Enregistrer';

  @override
  String get action_edit => 'Modifier';

  @override
  String get action_copy => 'Copier';

  @override
  String get action_share => 'Partager';

  @override
  String get action_scan => 'Scanner';

  @override
  String get action_retry => 'Réessayer';

  @override
  String get action_clearAll => 'Tout effacer';

  @override
  String get action_clearFilters => 'Effacer les filtres';

  @override
  String get action_tryAgain => 'Réessayer';

  @override
  String get auth_login => 'Connexion';

  @override
  String get auth_verify => 'Vérifier';

  @override
  String get auth_enterOtp => 'Entrer le code OTP';

  @override
  String get auth_phoneNumber => 'Numéro de téléphone';

  @override
  String get auth_pin => 'Code PIN';

  @override
  String get auth_logout => 'Déconnexion';

  @override
  String get auth_logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get auth_welcomeBack => 'Bon retour';

  @override
  String get auth_createWallet => 'Créez votre portefeuille USDC';

  @override
  String get auth_createAccount => 'Créer un compte';

  @override
  String get auth_alreadyHaveAccount => 'Vous avez déjà un compte? ';

  @override
  String get auth_dontHaveAccount => 'Vous n\'avez pas de compte? ';

  @override
  String get auth_signIn => 'Se connecter';

  @override
  String get auth_signUp => 'S\'inscrire';

  @override
  String get auth_country => 'Pays';

  @override
  String get auth_selectCountry => 'Sélectionner un pays';

  @override
  String get auth_searchCountry => 'Rechercher un pays...';

  @override
  String auth_enterDigits(int count) {
    return 'Entrer $count chiffres';
  }

  @override
  String get auth_termsPrompt => 'En continuant, vous acceptez nos';

  @override
  String get auth_termsOfService => 'Conditions d\'utilisation';

  @override
  String get auth_privacyPolicy => 'Politique de confidentialité';

  @override
  String get auth_and => ' et ';

  @override
  String get auth_secureLogin => 'Connexion sécurisée';

  @override
  String auth_otpMessage(String phone) {
    return 'Entrez le code à 6 chiffres envoyé à $phone';
  }

  @override
  String get auth_waitingForSms => 'En attente du SMS...';

  @override
  String get auth_resendCode => 'Renvoyer le code';

  @override
  String get wallet_balance => 'Solde';

  @override
  String get wallet_sendMoney => 'Envoyer de l\'argent';

  @override
  String get wallet_receiveMoney => 'Recevoir de l\'argent';

  @override
  String get wallet_transactionHistory => 'Historique des transactions';

  @override
  String get wallet_availableBalance => 'Solde disponible';

  @override
  String get wallet_totalBalance => 'Solde total';

  @override
  String get wallet_usdBalance => 'USD';

  @override
  String get wallet_usdcBalance => 'USDC';

  @override
  String get wallet_fiatBalance => 'Solde fiduciaire';

  @override
  String get wallet_stablecoin => 'Stablecoin';

  @override
  String get wallet_createWallet => 'Créer un portefeuille';

  @override
  String get wallet_noWalletFound => 'Aucun portefeuille trouvé';

  @override
  String get wallet_createWalletMessage =>
      'Créez votre portefeuille pour commencer à envoyer et recevoir de l\'argent';

  @override
  String get wallet_loadingWallet => 'Chargement du portefeuille...';

  @override
  String get home_welcomeBack => 'Bon retour';

  @override
  String get home_allServices => 'Tous les services';

  @override
  String get home_viewAllFeatures =>
      'Voir toutes les fonctionnalités disponibles';

  @override
  String get home_recentTransactions => 'Transactions récentes';

  @override
  String get home_noTransactionsYet => 'Aucune transaction pour le moment';

  @override
  String get home_transactionsWillAppear =>
      'Vos transactions récentes apparaîtront ici';

  @override
  String get send_title => 'Envoyer de l\'argent';

  @override
  String get send_toPhone => 'Vers téléphone';

  @override
  String get send_toWallet => 'Vers portefeuille';

  @override
  String get send_recent => 'Récents';

  @override
  String get send_recipient => 'Destinataire';

  @override
  String get send_saved => 'Enregistrés';

  @override
  String get send_contacts => 'Contacts';

  @override
  String get send_amountUsd => 'Montant (USD)';

  @override
  String get send_walletAddress => 'Adresse du portefeuille';

  @override
  String get send_networkInfo =>
      'Les transferts externes sont sur le réseau Polygon. Des frais de réseau s\'appliquent.';

  @override
  String get send_transferSuccess => 'Transfert réussi!';

  @override
  String get send_invalidAmount => 'Entrez un montant valide';

  @override
  String get send_insufficientBalance => 'Solde insuffisant';

  @override
  String get send_addressMustStartWith0x => 'L\'adresse doit commencer par 0x';

  @override
  String get send_addressLength =>
      'L\'adresse doit comporter exactement 42 caractères';

  @override
  String get send_invalidEthereumAddress =>
      'Format d\'adresse Ethereum invalide';

  @override
  String get send_saveRecipientPrompt => 'Enregistrer le destinataire?';

  @override
  String get send_saveRecipientMessage =>
      'Souhaitez-vous enregistrer ce destinataire pour de futurs transferts?';

  @override
  String get send_notNow => 'Pas maintenant';

  @override
  String get send_saveRecipientTitle => 'Enregistrer le destinataire';

  @override
  String get send_enterRecipientName => 'Entrez un nom pour ce destinataire';

  @override
  String get send_name => 'Nom';

  @override
  String get send_recipientSaved => 'Destinataire enregistré';

  @override
  String get send_failedToSaveRecipient =>
      'Échec de l\'enregistrement du destinataire';

  @override
  String get send_selectSavedRecipient =>
      'Sélectionner un destinataire enregistré';

  @override
  String get send_selectContact => 'Sélectionner un contact';

  @override
  String get send_searchRecipients => 'Rechercher des destinataires...';

  @override
  String get send_searchContacts => 'Rechercher des contacts...';

  @override
  String get send_noSavedRecipients => 'Aucun destinataire enregistré';

  @override
  String get send_failedToLoadRecipients =>
      'Échec du chargement des destinataires';

  @override
  String get send_joonaPayUser => 'Utilisateur JoonaPay';

  @override
  String get send_tooManyAttempts =>
      'Trop de tentatives incorrectes. Veuillez réessayer plus tard.';

  @override
  String get receive_title => 'Recevoir USDC';

  @override
  String get receive_receiveUsdc => 'Recevoir USDC';

  @override
  String receive_onlySendUsdc(String network) {
    return 'Envoyez uniquement de l\'USDC sur le réseau $network';
  }

  @override
  String get receive_yourWalletAddress => 'Votre adresse de portefeuille';

  @override
  String get receive_walletNotAvailable =>
      'Adresse de portefeuille non disponible';

  @override
  String get receive_addressCopied =>
      'Adresse copiée dans le presse-papiers (s\'efface automatiquement dans 60s)';

  @override
  String receive_shareMessage(String network, String address) {
    return 'Envoyez de l\'USDC à mon portefeuille sur $network:\n\n$address';
  }

  @override
  String get receive_shareSubject => 'Mon adresse de portefeuille USDC';

  @override
  String get receive_important => 'Important';

  @override
  String receive_warningMessage(String network) {
    return 'Envoyez uniquement de l\'USDC sur le réseau $network à cette adresse. L\'envoi d\'autres jetons ou l\'utilisation d\'un réseau différent peut entraîner une perte permanente de fonds.';
  }

  @override
  String get transactions_title => 'Transactions';

  @override
  String get transactions_searchPlaceholder => 'Rechercher des transactions...';

  @override
  String get transactions_noResultsFound => 'Aucun résultat trouvé';

  @override
  String get transactions_noTransactions => 'Aucune transaction';

  @override
  String get transactions_adjustFilters =>
      'Essayez d\'ajuster vos filtres ou votre requête de recherche pour trouver ce que vous cherchez.';

  @override
  String get transactions_historyMessage =>
      'Votre historique de transactions apparaîtra ici une fois que vous aurez effectué votre premier dépôt ou transfert.';

  @override
  String get transactions_somethingWentWrong =>
      'Quelque chose s\'est mal passé';

  @override
  String get transactions_today => 'Aujourd\'hui';

  @override
  String get transactions_yesterday => 'Hier';

  @override
  String get transactions_deposit => 'Dépôt';

  @override
  String get transactions_withdrawal => 'Retrait';

  @override
  String get transactions_transferReceived => 'Transfert reçu';

  @override
  String get transactions_transferSent => 'Transfert envoyé';

  @override
  String get transactions_mobileMoneyDeposit => 'Dépôt Mobile Money';

  @override
  String get transactions_mobileMoneyWithdrawal => 'Retrait Mobile Money';

  @override
  String get transactions_fromJoonaPayUser => 'D\'un utilisateur JoonaPay';

  @override
  String get transactions_externalWallet => 'Portefeuille externe';

  @override
  String get transactions_deposits => 'Dépôts';

  @override
  String get transactions_withdrawals => 'Retraits';

  @override
  String get transactions_receivedFilter => 'Reçus';

  @override
  String get transactions_sentFilter => 'Envoyés';

  @override
  String get services_title => 'Services';

  @override
  String get services_coreServices => 'Services principaux';

  @override
  String get services_financialServices => 'Services financiers';

  @override
  String get services_billsPayments => 'Factures et paiements';

  @override
  String get services_toolsAnalytics => 'Outils et analyses';

  @override
  String get services_sendMoney => 'Envoyer de l\'argent';

  @override
  String get services_sendMoneyDesc =>
      'Transférer vers n\'importe quel portefeuille';

  @override
  String get services_receiveMoney => 'Recevoir de l\'argent';

  @override
  String get services_receiveMoneyDesc =>
      'Obtenir votre adresse de portefeuille';

  @override
  String get services_requestMoney => 'Demander de l\'argent';

  @override
  String get services_requestMoneyDesc => 'Créer une demande de paiement';

  @override
  String get services_scanQr => 'Scanner QR';

  @override
  String get services_scanQrDesc => 'Scanner pour payer ou recevoir';

  @override
  String get services_recipients => 'Destinataires';

  @override
  String get services_recipientsDesc => 'Gérer les contacts enregistrés';

  @override
  String get services_scheduledTransfers => 'Transferts programmés';

  @override
  String get services_scheduledTransfersDesc =>
      'Gérer les paiements récurrents';

  @override
  String get services_virtualCard => 'Carte virtuelle';

  @override
  String get services_virtualCardDesc => 'Carte pour achats en ligne';

  @override
  String get services_savingsGoals => 'Objectifs d\'épargne';

  @override
  String get services_savingsGoalsDesc => 'Suivre votre épargne';

  @override
  String get services_budget => 'Budget';

  @override
  String get services_budgetDesc => 'Gérer les limites de dépenses';

  @override
  String get services_currencyConverter => 'Convertisseur de devises';

  @override
  String get services_currencyConverterDesc => 'Convertir les devises';

  @override
  String get services_billPayments => 'Paiement de factures';

  @override
  String get services_billPaymentsDesc =>
      'Payer les factures de services publics';

  @override
  String get services_buyAirtime => 'Acheter du crédit';

  @override
  String get services_buyAirtimeDesc => 'Recharge mobile';

  @override
  String get services_splitBills => 'Partager les factures';

  @override
  String get services_splitBillsDesc => 'Partager les dépenses';

  @override
  String get services_analytics => 'Analyses';

  @override
  String get services_analyticsDesc => 'Voir les informations sur les dépenses';

  @override
  String get services_referrals => 'Parrainages';

  @override
  String get services_referralsDesc => 'Inviter et gagner';

  @override
  String get settings_profile => 'Profil';

  @override
  String get settings_profileDescription =>
      'Gérez vos informations personnelles';

  @override
  String get settings_security => 'Sécurité';

  @override
  String get settings_securitySettings => 'Paramètres de sécurité';

  @override
  String get settings_securityDescription => 'PIN, 2FA, biométrie';

  @override
  String get settings_language => 'Langue';

  @override
  String get settings_theme => 'Thème';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_preferences => 'Préférences';

  @override
  String get settings_defaultCurrency => 'Devise par défaut';

  @override
  String get settings_support => 'Support';

  @override
  String get settings_helpSupport => 'Aide et support';

  @override
  String get settings_helpDescription => 'FAQ, chat, contact';

  @override
  String get settings_kycVerification => 'Vérification KYC';

  @override
  String get settings_transactionLimits => 'Limites de transaction';

  @override
  String get settings_limitsDescription => 'Voir et augmenter les limites';

  @override
  String get settings_referEarn => 'Parrainer et gagner';

  @override
  String get settings_referDescription =>
      'Invitez des amis et gagnez des récompenses';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String get kyc_verified => 'Vérifié';

  @override
  String get kyc_pending => 'En attente';

  @override
  String get kyc_rejected => 'Rejeté - Réessayer';

  @override
  String get kyc_notStarted => 'Non commencé';

  @override
  String get transaction_sent => 'Envoyé';

  @override
  String get transaction_received => 'Reçu';

  @override
  String get transaction_pending => 'En attente';

  @override
  String get transaction_failed => 'Échoué';

  @override
  String get transaction_completed => 'Terminé';

  @override
  String get error_generic =>
      'Quelque chose s\'est mal passé. Veuillez réessayer.';

  @override
  String get error_network =>
      'Erreur réseau. Veuillez vérifier votre connexion.';

  @override
  String get error_failedToLoadBalance => 'Échec du chargement du solde';

  @override
  String get error_failedToLoadTransactions =>
      'Échec du chargement des transactions';

  @override
  String get language_english => 'Anglais';

  @override
  String get language_french => 'Français';

  @override
  String get language_selectLanguage => 'Sélectionner la langue';

  @override
  String get language_changeLanguage => 'Changer de langue';
}
