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
  String get action_remove => 'Supprimer';

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
  String get auth_logout => 'Se déconnecter';

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
  String get auth_phoneInvalid =>
      'Veuillez entrer un numéro de téléphone valide';

  @override
  String get auth_otp => 'Code OTP';

  @override
  String get auth_resendOtp => 'Renvoyer le code OTP';

  @override
  String get auth_error_invalidOtp => 'Code OTP invalide. Veuillez réessayer.';

  @override
  String get login_welcomeBack => 'Bon retour';

  @override
  String get login_enterPhone =>
      'Entrez votre numéro de téléphone pour vous connecter';

  @override
  String get login_rememberPhone => 'Se souvenir de cet appareil';

  @override
  String get login_noAccount => 'Vous n\'avez pas de compte?';

  @override
  String get login_createAccount => 'Créer un compte';

  @override
  String get login_verifyCode => 'Vérifiez votre code';

  @override
  String login_codeSentTo(String countryCode, String phone) {
    return 'Entrez le code à 6 chiffres envoyé au $countryCode $phone';
  }

  @override
  String get login_resendCode => 'Renvoyer le code';

  @override
  String login_resendIn(int seconds) {
    return 'Renvoyer le code dans ${seconds}s';
  }

  @override
  String get login_verifying => 'Vérification...';

  @override
  String get login_enterPin => 'Entrez votre code PIN';

  @override
  String get login_pinSubtitle =>
      'Entrez votre code PIN à 6 chiffres pour accéder à votre portefeuille';

  @override
  String get login_forgotPin => 'Code PIN oublié?';

  @override
  String login_attemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentatives restantes',
      one: '1 tentative restante',
    );
    return '$_temp0';
  }

  @override
  String get login_accountLocked => 'Compte verrouillé';

  @override
  String get login_lockedMessage =>
      'Trop de tentatives échouées. Votre compte a été verrouillé pendant 15 minutes pour des raisons de sécurité.';

  @override
  String get common_ok => 'OK';

  @override
  String get common_continue => 'Continuer';

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
  String get wallet_activateTitle => 'Activez votre portefeuille';

  @override
  String get wallet_activateDescription =>
      'Configurez votre portefeuille USDC pour envoyer et recevoir de l\'argent instantanément';

  @override
  String get wallet_activateButton => 'Activer le portefeuille';

  @override
  String get wallet_activating => 'Activation de votre portefeuille...';

  @override
  String get wallet_activateFailed =>
      'Échec de l\'activation. Veuillez réessayer.';

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
  String get home_balance => 'Solde';

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
      'Les transferts externes peuvent prendre quelques minutes. De petits frais s\'appliquent.';

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
  String get send_searchContacts => 'Rechercher des contacts';

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
  String get receive_onlySendUsdc =>
      'Partagez votre adresse pour recevoir de l\'USDC';

  @override
  String get receive_yourWalletAddress => 'Votre adresse de portefeuille';

  @override
  String get receive_walletNotAvailable =>
      'Adresse de portefeuille non disponible';

  @override
  String get receive_addressCopied =>
      'Adresse copiée dans le presse-papiers (s\'efface automatiquement dans 60s)';

  @override
  String receive_shareMessage(String address) {
    return 'Envoyez de l\'USDC à mon portefeuille JoonaPay:\n\n$address';
  }

  @override
  String get receive_shareSubject => 'Mon adresse de portefeuille USDC';

  @override
  String get receive_important => 'Important';

  @override
  String get receive_warningMessage =>
      'Envoyez uniquement de l\'USDC à cette adresse. L\'envoi d\'autres jetons peut entraîner une perte permanente de fonds.';

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
  String get settings_devices => 'Appareils';

  @override
  String get settings_devicesDescription =>
      'Gérez les appareils qui ont accès à votre compte. Révoquez l\'accès depuis n\'importe quel appareil.';

  @override
  String get settings_thisDevice => 'Cet appareil';

  @override
  String get settings_lastActive => 'Dernière activité';

  @override
  String get settings_loginCount => 'Connexions';

  @override
  String get settings_times => 'fois';

  @override
  String get settings_lastIp => 'Dernière IP';

  @override
  String get settings_trustDevice => 'Faire confiance';

  @override
  String get settings_removeDevice => 'Supprimer l\'appareil';

  @override
  String get settings_removeDeviceConfirm =>
      'Cet appareil sera déconnecté et devra s\'authentifier à nouveau pour accéder à votre compte.';

  @override
  String get settings_noDevices => 'Aucun appareil trouvé';

  @override
  String get settings_noDevicesDescription =>
      'Vous n\'avez pas encore d\'appareils enregistrés.';

  @override
  String get kyc_verified => 'Vérifié';

  @override
  String get kyc_pending => 'En attente';

  @override
  String get kyc_rejected => 'Rejeté - Réessayer';

  @override
  String get kyc_notStarted => 'Non commencé';

  @override
  String get kyc_title => 'Vérification d\'identité';

  @override
  String get kyc_selectDocumentType => 'Sélectionner le type de document';

  @override
  String get kyc_selectDocumentType_description =>
      'Choisissez le type de document que vous souhaitez utiliser pour la vérification';

  @override
  String get kyc_documentType_nationalId => 'Carte d\'identité nationale';

  @override
  String get kyc_documentType_nationalId_description =>
      'Carte d\'identité émise par le gouvernement';

  @override
  String get kyc_documentType_passport => 'Passeport';

  @override
  String get kyc_documentType_passport_description =>
      'Document de voyage international';

  @override
  String get kyc_documentType_driversLicense => 'Permis de conduire';

  @override
  String get kyc_documentType_driversLicense_description =>
      'Permis de conduire émis par le gouvernement';

  @override
  String get kyc_capture_frontSide_guidance =>
      'Alignez le recto de votre document dans le cadre';

  @override
  String get kyc_capture_backSide_guidance =>
      'Alignez le verso de votre document dans le cadre';

  @override
  String get kyc_capture_nationalIdInstructions =>
      'Positionnez votre carte d\'identité à plat et bien éclairée dans le cadre';

  @override
  String get kyc_capture_passportInstructions =>
      'Positionnez la page photo de votre passeport dans le cadre';

  @override
  String get kyc_capture_driversLicenseInstructions =>
      'Positionnez votre permis de conduire à plat dans le cadre';

  @override
  String get kyc_capture_backInstructions =>
      'Capturez maintenant le verso de votre document';

  @override
  String get kyc_checkingQuality => 'Vérification de la qualité de l\'image...';

  @override
  String get kyc_reviewImage => 'Vérifier l\'image';

  @override
  String get kyc_retake => 'Reprendre';

  @override
  String get kyc_accept => 'Accepter';

  @override
  String get kyc_error_imageQuality =>
      'La qualité de l\'image n\'est pas acceptable. Veuillez réessayer.';

  @override
  String get kyc_error_imageBlurry =>
      'L\'image est trop floue. Tenez votre téléphone stable et réessayez.';

  @override
  String get kyc_error_imageGlare =>
      'Trop de reflets détectés. Évitez la lumière directe et réessayez.';

  @override
  String get kyc_error_imageTooDark =>
      'L\'image est trop sombre. Utilisez un meilleur éclairage et réessayez.';

  @override
  String get kyc_status_pending_title => 'Démarrer la vérification';

  @override
  String get kyc_status_pending_description =>
      'Complétez votre vérification d\'identité pour débloquer des limites plus élevées et toutes les fonctionnalités.';

  @override
  String get kyc_status_submitted_title => 'Vérification en cours';

  @override
  String get kyc_status_submitted_description =>
      'Vos documents sont en cours d\'examen. Cela prend généralement 1 à 2 jours ouvrables.';

  @override
  String get kyc_status_approved_title => 'Vérification terminée';

  @override
  String get kyc_status_approved_description =>
      'Votre identité a été vérifiée. Vous avez maintenant accès à toutes les fonctionnalités!';

  @override
  String get kyc_status_rejected_title => 'Échec de la vérification';

  @override
  String get kyc_status_rejected_description =>
      'Nous n\'avons pas pu vérifier vos documents. Veuillez consulter la raison ci-dessous et réessayer.';

  @override
  String get kyc_status_additionalInfo_title =>
      'Informations supplémentaires requises';

  @override
  String get kyc_status_additionalInfo_description =>
      'Veuillez fournir des informations supplémentaires pour compléter votre vérification.';

  @override
  String get kyc_rejectionReason => 'Raison du rejet';

  @override
  String get kyc_tryAgain => 'Réessayer';

  @override
  String get kyc_startVerification => 'Démarrer la vérification';

  @override
  String get kyc_info_security_title => 'Vos données sont sécurisées';

  @override
  String get kyc_info_security_description =>
      'Tous les documents sont cryptés et stockés en toute sécurité';

  @override
  String get kyc_info_time_title => 'Processus rapide';

  @override
  String get kyc_info_time_description =>
      'La vérification prend généralement 1 à 2 jours ouvrables';

  @override
  String get kyc_info_documents_title => 'Documents requis';

  @override
  String get kyc_info_documents_description =>
      'Pièce d\'identité ou passeport émis par le gouvernement';

  @override
  String get kyc_reviewDocuments => 'Vérifier les documents';

  @override
  String get kyc_review_description =>
      'Vérifiez vos documents capturés avant de les soumettre pour vérification';

  @override
  String get kyc_review_documents => 'Documents';

  @override
  String get kyc_review_documentFront => 'Recto du document';

  @override
  String get kyc_review_documentBack => 'Verso du document';

  @override
  String get kyc_review_selfie => 'Selfie';

  @override
  String get kyc_review_yourSelfie => 'Votre selfie';

  @override
  String get kyc_submitForVerification => 'Soumettre pour vérification';

  @override
  String get kyc_selfie_title => 'Prendre un selfie';

  @override
  String get kyc_selfie_guidance =>
      'Positionnez votre visage dans le cadre ovale';

  @override
  String get kyc_selfie_livenessHint =>
      'Assurez-vous d\'être dans un endroit bien éclairé';

  @override
  String get kyc_selfie_instructions =>
      'Regardez directement la caméra et gardez votre visage dans le cadre';

  @override
  String get kyc_reviewSelfie => 'Vérifier le selfie';

  @override
  String get kyc_submitted_title => 'Vérification soumise';

  @override
  String get kyc_submitted_description =>
      'Merci! Vos documents ont été soumis pour vérification. Nous vous informerons une fois l\'examen terminé.';

  @override
  String get kyc_submitted_timeEstimate =>
      'La vérification prend généralement 1 à 2 jours ouvrables';

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

  @override
  String get currency_primary => 'Devise principale';

  @override
  String get currency_reference => 'Devise de référence';

  @override
  String get currency_referenceDescription =>
      'Affiche l\'équivalent en devise locale sous votre solde USDC à titre indicatif. Les taux de change sont approximatifs.';

  @override
  String get currency_showReference => 'Afficher la devise locale';

  @override
  String get currency_showReferenceDescription =>
      'Afficher la valeur approximative en devise locale sous les montants USDC';

  @override
  String get currency_preview => 'Aperçu';

  @override
  String get settings_activeSessions => 'Sessions actives';

  @override
  String get sessions_currentSession => 'Session actuelle';

  @override
  String get sessions_unknownLocation => 'Localisation inconnue';

  @override
  String get sessions_unknownIP => 'IP inconnue';

  @override
  String get sessions_lastActive => 'Dernière activité';

  @override
  String get sessions_revokeTitle => 'Révoquer la session';

  @override
  String get sessions_revokeMessage =>
      'Êtes-vous sûr de vouloir révoquer cette session? Cet appareil sera déconnecté immédiatement.';

  @override
  String get sessions_revoke => 'Révoquer';

  @override
  String get sessions_revokeSuccess => 'Session révoquée avec succès';

  @override
  String get sessions_logoutAllDevices =>
      'Se déconnecter de tous les appareils';

  @override
  String get sessions_logoutAllTitle => 'Se déconnecter de tous les appareils?';

  @override
  String get sessions_logoutAllMessage =>
      'Cela vous déconnectera de tous les appareils y compris celui-ci. Vous devrez vous reconnecter.';

  @override
  String get sessions_logoutAllWarning =>
      'Cette action ne peut pas être annulée';

  @override
  String get sessions_logoutAll => 'Déconnecter tout';

  @override
  String get sessions_logoutAllSuccess => 'Déconnecté de tous les appareils';

  @override
  String get sessions_errorLoading => 'Échec du chargement des sessions';

  @override
  String get sessions_noActiveSessions => 'Aucune session active';

  @override
  String get sessions_noActiveSessionsDesc =>
      'Vous n\'avez aucune session active pour le moment.';

  @override
  String get beneficiaries_title => 'Bénéficiaires';

  @override
  String get beneficiaries_tabAll => 'Tous';

  @override
  String get beneficiaries_tabFavorites => 'Favoris';

  @override
  String get beneficiaries_tabRecent => 'Récents';

  @override
  String get beneficiaries_searchHint => 'Rechercher par nom ou téléphone';

  @override
  String get beneficiaries_addTitle => 'Ajouter un bénéficiaire';

  @override
  String get beneficiaries_editTitle => 'Modifier le bénéficiaire';

  @override
  String get beneficiaries_fieldName => 'Nom';

  @override
  String get beneficiaries_fieldPhone => 'Numéro de téléphone';

  @override
  String get beneficiaries_fieldAccountType => 'Type de compte';

  @override
  String get beneficiaries_fieldWalletAddress => 'Adresse du portefeuille';

  @override
  String get beneficiaries_fieldBankCode => 'Code bancaire';

  @override
  String get beneficiaries_fieldBankAccount => 'Numéro de compte bancaire';

  @override
  String get beneficiaries_fieldMobileMoneyProvider =>
      'Fournisseur de mobile money';

  @override
  String get beneficiaries_typeJoonapay => 'Utilisateur JoonaPay';

  @override
  String get beneficiaries_typeWallet => 'Portefeuille externe';

  @override
  String get beneficiaries_typeBank => 'Compte bancaire';

  @override
  String get beneficiaries_typeMobileMoney => 'Mobile Money';

  @override
  String get beneficiaries_addButton => 'Ajouter un bénéficiaire';

  @override
  String get beneficiaries_addFirst => 'Ajoutez votre premier bénéficiaire';

  @override
  String get beneficiaries_emptyTitle => 'Aucun bénéficiaire';

  @override
  String get beneficiaries_emptyMessage =>
      'Ajoutez des bénéficiaires pour envoyer de l\'argent plus rapidement';

  @override
  String get beneficiaries_emptyFavoritesTitle => 'Aucun favori';

  @override
  String get beneficiaries_emptyFavoritesMessage =>
      'Marquez vos bénéficiaires fréquents pour les voir ici';

  @override
  String get beneficiaries_emptyRecentTitle => 'Aucun transfert récent';

  @override
  String get beneficiaries_emptyRecentMessage =>
      'Les bénéficiaires auxquels vous avez envoyé de l\'argent apparaîtront ici';

  @override
  String get beneficiaries_menuEdit => 'Modifier';

  @override
  String get beneficiaries_menuDelete => 'Supprimer';

  @override
  String get beneficiaries_deleteTitle => 'Supprimer le bénéficiaire?';

  @override
  String beneficiaries_deleteMessage(String name) {
    return 'Êtes-vous sûr de vouloir supprimer $name?';
  }

  @override
  String get beneficiaries_deleteSuccess => 'Bénéficiaire supprimé avec succès';

  @override
  String get beneficiaries_createSuccess => 'Bénéficiaire ajouté avec succès';

  @override
  String get beneficiaries_updateSuccess =>
      'Bénéficiaire mis à jour avec succès';

  @override
  String get beneficiaries_errorTitle =>
      'Erreur de chargement des bénéficiaires';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get error_required => 'Ce champ est obligatoire';

  @override
  String get qr_receiveTitle => 'Recevoir un paiement';

  @override
  String get qr_scanTitle => 'Scanner le code QR';

  @override
  String get qr_requestSpecificAmount => 'Demander un montant spécifique';

  @override
  String get qr_amountLabel => 'Montant (USD)';

  @override
  String get qr_howToReceive => 'Comment recevoir un paiement';

  @override
  String get qr_receiveInstructions =>
      'Partagez ce code QR avec l\'expéditeur. Ils peuvent le scanner avec leur application JoonaPay pour vous envoyer de l\'argent instantanément.';

  @override
  String get qr_savedToGallery => 'Code QR enregistré dans la galerie';

  @override
  String get qr_failedToSave => 'Échec de l\'enregistrement du code QR';

  @override
  String get qr_initializingCamera => 'Initialisation de la caméra...';

  @override
  String get qr_scanInstruction => 'Scanner un code QR JoonaPay';

  @override
  String get qr_scanSubInstruction =>
      'Pointez votre caméra vers un code QR pour envoyer de l\'argent';

  @override
  String get qr_scanned => 'Code QR scanné';

  @override
  String get qr_invalidCode => 'Code QR invalide';

  @override
  String get qr_invalidCodeMessage =>
      'Ce code QR n\'est pas un code de paiement JoonaPay valide.';

  @override
  String get qr_scanAgain => 'Scanner à nouveau';

  @override
  String get qr_sendMoney => 'Envoyer de l\'argent';

  @override
  String get qr_cameraPermissionRequired => 'Permission de caméra requise';

  @override
  String get qr_cameraPermissionMessage =>
      'Veuillez accorder la permission de la caméra pour scanner les codes QR.';

  @override
  String get qr_openSettings => 'Ouvrir les paramètres';

  @override
  String get qr_galleryImportSoon =>
      'L\'importation depuis la galerie arrive bientôt';

  @override
  String get home_goodMorning => 'Bonjour';

  @override
  String get home_goodAfternoon => 'Bon après-midi';

  @override
  String get home_goodEvening => 'Bonsoir';

  @override
  String get home_goodNight => 'Bonne nuit';

  @override
  String get home_totalBalance => 'Solde total';

  @override
  String get home_hideBalance => 'Masquer le solde';

  @override
  String get home_showBalance => 'Afficher le solde';

  @override
  String get home_quickAction_send => 'Envoyer';

  @override
  String get home_quickAction_receive => 'Recevoir';

  @override
  String get home_quickAction_deposit => 'Dépôt';

  @override
  String get home_quickAction_history => 'Historique';

  @override
  String get home_kycBanner_title =>
      'Complétez la vérification pour débloquer toutes les fonctionnalités';

  @override
  String get home_kycBanner_action => 'Vérifier maintenant';

  @override
  String get home_recentActivity => 'Activité récente';

  @override
  String get home_seeAll => 'Voir tout';

  @override
  String get deposit_title => 'Déposer des fonds';

  @override
  String get deposit_quickAmounts => 'Montants rapides';

  @override
  String deposit_rateUpdated(String time) {
    return 'Mis à jour $time';
  }

  @override
  String get deposit_youWillReceive => 'Vous recevrez';

  @override
  String get deposit_youWillPay => 'Vous paierez';

  @override
  String get deposit_limits => 'Limites de dépôt';

  @override
  String get deposit_selectProvider => 'Sélectionner le fournisseur';

  @override
  String get deposit_chooseProvider => 'Choisissez un mode de paiement';

  @override
  String get deposit_amountToPay => 'Montant à payer';

  @override
  String get deposit_noFee => 'Sans frais';

  @override
  String get deposit_fee => 'frais';

  @override
  String get deposit_paymentInstructions => 'Instructions de paiement';

  @override
  String get deposit_expiresIn => 'Expire dans';

  @override
  String deposit_via(String provider) {
    return 'via $provider';
  }

  @override
  String get deposit_referenceNumber => 'Numéro de référence';

  @override
  String get deposit_howToPay => 'Comment effectuer le paiement';

  @override
  String get deposit_ussdCode => 'Code USSD';

  @override
  String deposit_openApp(String provider) {
    return 'Ouvrir l\'application $provider';
  }

  @override
  String get deposit_completedPayment => 'J\'ai effectué le paiement';

  @override
  String get deposit_copied => 'Copié dans le presse-papiers';

  @override
  String get deposit_cancelTitle => 'Annuler le dépôt?';

  @override
  String get deposit_cancelMessage =>
      'Votre session de paiement sera annulée. Vous pourrez commencer un nouveau dépôt plus tard.';

  @override
  String get deposit_processing => 'Traitement en cours';

  @override
  String get deposit_success => 'Dépôt réussi!';

  @override
  String get deposit_failed => 'Échec du dépôt';

  @override
  String get deposit_expired => 'Session expirée';

  @override
  String get deposit_processingMessage =>
      'Nous traitons votre paiement. Cela peut prendre quelques instants.';

  @override
  String get deposit_successMessage =>
      'Vos fonds ont été ajoutés à votre portefeuille!';

  @override
  String get deposit_failedMessage =>
      'Nous n\'avons pas pu traiter votre paiement. Veuillez réessayer.';

  @override
  String get deposit_expiredMessage =>
      'Votre session de paiement a expiré. Veuillez commencer un nouveau dépôt.';

  @override
  String get deposit_deposited => 'Déposé';

  @override
  String get deposit_received => 'Reçu';

  @override
  String get deposit_backToHome => 'Retour à l\'accueil';

  @override
  String get common_error => 'Une erreur s\'est produite';

  @override
  String get pin_createTitle => 'Créer votre code PIN';

  @override
  String get pin_confirmTitle => 'Confirmer votre code PIN';

  @override
  String get pin_changeTitle => 'Changer le code PIN';

  @override
  String get pin_resetTitle => 'Réinitialiser le code PIN';

  @override
  String get pin_enterNewPin => 'Entrez votre nouveau code PIN à 6 chiffres';

  @override
  String get pin_reenterPin => 'Entrez à nouveau votre code PIN pour confirmer';

  @override
  String get pin_enterCurrentPin => 'Entrez votre code PIN actuel';

  @override
  String get pin_confirmNewPin => 'Confirmez votre nouveau code PIN';

  @override
  String get pin_requirements => 'Exigences du code PIN';

  @override
  String get pin_rule_6digits => '6 chiffres';

  @override
  String get pin_rule_noSequential => 'Pas de numéros séquentiels (123456)';

  @override
  String get pin_rule_noRepeated => 'Pas de chiffres répétés (111111)';

  @override
  String get pin_error_sequential =>
      'Le code PIN ne peut pas être des numéros séquentiels';

  @override
  String get pin_error_repeated =>
      'Le code PIN ne peut pas être le même chiffre';

  @override
  String get pin_error_noMatch =>
      'Les codes PIN ne correspondent pas. Veuillez réessayer.';

  @override
  String get pin_error_wrongCurrent => 'Le code PIN actuel est incorrect';

  @override
  String get pin_error_saveFailed =>
      'Échec de l\'enregistrement du code PIN. Veuillez réessayer.';

  @override
  String get pin_error_changeFailed =>
      'Échec du changement de code PIN. Veuillez réessayer.';

  @override
  String get pin_error_resetFailed =>
      'Échec de la réinitialisation du code PIN. Veuillez réessayer.';

  @override
  String get pin_success_set => 'Code PIN créé avec succès';

  @override
  String get pin_success_changed => 'Code PIN changé avec succès';

  @override
  String get pin_success_reset => 'Code PIN réinitialisé avec succès';

  @override
  String pin_attemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentatives restantes',
      one: '1 tentative restante',
    );
    return '$_temp0';
  }

  @override
  String get pin_forgotPin => 'Code PIN oublié?';

  @override
  String get pin_locked_title => 'Code PIN verrouillé';

  @override
  String get pin_locked_message =>
      'Trop de tentatives échouées. Votre code PIN est temporairement verrouillé.';

  @override
  String get pin_locked_tryAgainIn => 'Réessayer dans';

  @override
  String get pin_resetViaOtp => 'Réinitialiser le code PIN par SMS';

  @override
  String get pin_reset_requestTitle => 'Réinitialiser votre code PIN';

  @override
  String get pin_reset_requestMessage =>
      'Nous enverrons un code de vérification à votre numéro de téléphone enregistré pour réinitialiser votre code PIN.';

  @override
  String get pin_reset_sendOtp => 'Envoyer le code de vérification';

  @override
  String get pin_reset_enterOtp =>
      'Entrez le code à 6 chiffres envoyé à votre téléphone';

  @override
  String get send_selectRecipient => 'Sélectionner le destinataire';

  @override
  String get send_recipientPhone => 'Numéro de téléphone du destinataire';

  @override
  String get send_fromContacts => 'Contacts';

  @override
  String get send_fromBeneficiaries => 'Bénéficiaires';

  @override
  String get send_recentRecipients => 'Destinataires récents';

  @override
  String get send_contactsPermissionDenied =>
      'La permission des contacts est requise pour sélectionner un contact';

  @override
  String get send_noContactsFound => 'Aucun contact trouvé';

  @override
  String get send_selectBeneficiary => 'Sélectionner un bénéficiaire';

  @override
  String get send_searchBeneficiaries => 'Rechercher des bénéficiaires';

  @override
  String get send_noBeneficiariesFound => 'Aucun bénéficiaire trouvé';

  @override
  String get send_enterAmount => 'Entrer le montant';

  @override
  String get send_amount => 'Montant';

  @override
  String get send_max => 'MAX';

  @override
  String get send_note => 'Note';

  @override
  String get send_noteOptional => 'Ajouter une note (facultatif)';

  @override
  String get send_fee => 'Frais';

  @override
  String get send_total => 'Total';

  @override
  String get send_confirmTransfer => 'Confirmer le transfert';

  @override
  String get send_pinVerificationRequired =>
      'Vous devrez entrer votre code PIN pour confirmer ce transfert';

  @override
  String get send_confirmAndSend => 'Confirmer & Envoyer';

  @override
  String get send_verifyPin => 'Vérifier le code PIN';

  @override
  String get send_enterPinToConfirm => 'Entrez votre code PIN';

  @override
  String get send_pinVerificationDescription =>
      'Entrez votre code PIN à 6 chiffres pour confirmer ce transfert';

  @override
  String get send_useBiometric => 'Utiliser la biométrie';

  @override
  String get send_biometricReason =>
      'Vérifiez votre identité pour effectuer le transfert';

  @override
  String get send_transferFailed => 'Échec du transfert';

  @override
  String get send_transferSuccessMessage =>
      'Votre argent a été envoyé avec succès';

  @override
  String get send_sentTo => 'Envoyé à';

  @override
  String get send_reference => 'Référence';

  @override
  String get send_date => 'Date';

  @override
  String get send_saveAsBeneficiary => 'Enregistrer comme bénéficiaire';

  @override
  String get send_shareReceipt => 'Partager le reçu';

  @override
  String get send_transferReceipt => 'Reçu de transfert';

  @override
  String get send_beneficiarySaved => 'Bénéficiaire enregistré avec succès';

  @override
  String get error_phoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get error_phoneInvalid => 'Numéro de téléphone invalide';

  @override
  String get error_amountRequired => 'Le montant est requis';

  @override
  String get error_amountInvalid => 'Montant invalide';

  @override
  String get error_insufficientBalance => 'Solde insuffisant';

  @override
  String get error_pinIncorrect => 'Code PIN incorrect. Veuillez réessayer.';

  @override
  String get error_biometricFailed =>
      'L\'authentification biométrique a échoué';

  @override
  String get error_transferFailed =>
      'Le transfert a échoué. Veuillez réessayer.';

  @override
  String get common_copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get notifications_permission_title => 'Restez informé';

  @override
  String get notifications_permission_description =>
      'Recevez des mises à jour instantanées sur vos transactions, alertes de sécurité et activités importantes de votre compte.';

  @override
  String get notifications_benefit_transactions =>
      'Mises à jour des transactions';

  @override
  String get notifications_benefit_transactions_desc =>
      'Alertes instantanées lors de l\'envoi ou de la réception d\'argent';

  @override
  String get notifications_benefit_security => 'Alertes de sécurité';

  @override
  String get notifications_benefit_security_desc =>
      'Soyez informé des activités suspectes et des nouvelles connexions';

  @override
  String get notifications_benefit_updates => 'Mises à jour importantes';

  @override
  String get notifications_benefit_updates_desc =>
      'Restez informé des nouvelles fonctionnalités et offres spéciales';

  @override
  String get notifications_enable_notifications => 'Activer les notifications';

  @override
  String get notifications_maybe_later => 'Plus tard';

  @override
  String get notifications_enabled_success =>
      'Notifications activées avec succès';

  @override
  String get notifications_permission_denied_title => 'Permission requise';

  @override
  String get notifications_permission_denied_message =>
      'Pour recevoir des notifications, vous devez les activer dans les paramètres de votre appareil.';

  @override
  String get action_open_settings => 'Ouvrir les paramètres';

  @override
  String get notifications_preferences_title => 'Préférences de notification';

  @override
  String get notifications_preferences_description =>
      'Choisissez les notifications que vous souhaitez recevoir';

  @override
  String get notifications_pref_transaction_title => 'Alertes de transaction';

  @override
  String get notifications_pref_transaction_alerts =>
      'Toutes les alertes de transaction';

  @override
  String get notifications_pref_transaction_alerts_desc =>
      'Soyez informé de toutes les transactions entrantes et sortantes';

  @override
  String get notifications_pref_security_title => 'Sécurité';

  @override
  String get notifications_pref_security_alerts => 'Alertes de sécurité';

  @override
  String get notifications_pref_security_alerts_desc =>
      'Alertes de sécurité critiques (ne peuvent pas être désactivées)';

  @override
  String get notifications_pref_promotional_title => 'Promotionnel';

  @override
  String get notifications_pref_promotions => 'Promotions et offres';

  @override
  String get notifications_pref_promotions_desc =>
      'Offres spéciales et campagnes promotionnelles';

  @override
  String get notifications_pref_price_title => 'Mises à jour du marché';

  @override
  String get notifications_pref_price_alerts => 'Alertes de prix';

  @override
  String get notifications_pref_price_alerts_desc =>
      'Mouvements de prix USDC et crypto';

  @override
  String get notifications_pref_summary_title => 'Rapports';

  @override
  String get notifications_pref_weekly_summary =>
      'Résumé hebdomadaire des dépenses';

  @override
  String get notifications_pref_weekly_summary_desc =>
      'Recevez un résumé de votre activité hebdomadaire';

  @override
  String get notifications_pref_thresholds_title => 'Seuils d\'alerte';

  @override
  String get notifications_pref_thresholds_description =>
      'Définir des montants personnalisés pour déclencher des alertes';

  @override
  String get notifications_pref_large_transaction_threshold =>
      'Alerte de transaction importante';

  @override
  String get notifications_pref_low_balance_threshold =>
      'Alerte de solde faible';

  @override
  String get settings_editProfile => 'Modifier le profil';

  @override
  String get settings_account => 'Compte';

  @override
  String get settings_about => 'À propos';

  @override
  String get settings_termsOfService => 'Conditions d\'utilisation';

  @override
  String get settings_privacyPolicy => 'Politique de confidentialité';

  @override
  String get settings_appVersion => 'Version de l\'application';

  @override
  String get profile_firstName => 'Prénom';

  @override
  String get profile_lastName => 'Nom de famille';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_phoneNumber => 'Numéro de téléphone';

  @override
  String get profile_phoneCannotChange =>
      'Le numéro de téléphone ne peut pas être changé';

  @override
  String get profile_updateSuccess => 'Profil mis à jour avec succès';

  @override
  String get profile_updateError => 'Échec de la mise à jour du profil';

  @override
  String get help_faq => 'Questions fréquemment posées';

  @override
  String get help_needMoreHelp => 'Besoin d\'aide supplémentaire?';

  @override
  String get help_reportProblem => 'Signaler un problème';

  @override
  String get help_liveChat => 'Chat en direct';

  @override
  String get help_emailSupport => 'Support par email';

  @override
  String get help_whatsappSupport => 'Support WhatsApp';

  @override
  String get help_copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get onboarding_skip => 'Passer';

  @override
  String get onboarding_getStarted => 'Commencer';

  @override
  String get onboarding_slide1_title => 'Envoyez de l\'argent instantanément';

  @override
  String get onboarding_slide1_description =>
      'Transférez des USDC à n\'importe qui, n\'importe où en Afrique de l\'Ouest. Rapide, sécurisé et avec des frais minimes.';

  @override
  String get onboarding_slide2_title => 'Payez vos factures facilement';

  @override
  String get onboarding_slide2_description =>
      'Payez vos factures de services publics, achetez du crédit et gérez tous vos paiements en un seul endroit.';

  @override
  String get onboarding_slide3_title => 'Épargnez pour vos objectifs';

  @override
  String get onboarding_slide3_description =>
      'Fixez des objectifs d\'épargne et regardez votre argent croître avec la valeur stable de l\'USDC.';

  @override
  String get onboarding_phoneInput_title => 'Entrez votre numéro de téléphone';

  @override
  String get onboarding_phoneInput_subtitle =>
      'Nous vous enverrons un code pour vérifier votre numéro';

  @override
  String get onboarding_phoneInput_label => 'Numéro de téléphone';

  @override
  String get onboarding_phoneInput_terms =>
      'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité';

  @override
  String get onboarding_phoneInput_loginLink =>
      'Vous avez déjà un compte? Connexion';

  @override
  String get onboarding_otp_title => 'Vérifiez votre numéro';

  @override
  String onboarding_otp_subtitle(String dialCode, String phoneNumber) {
    return 'Entrez le code à 6 chiffres envoyé au $dialCode $phoneNumber';
  }

  @override
  String get onboarding_otp_resend => 'Renvoyer le code';

  @override
  String onboarding_otp_resendIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get onboarding_otp_verifying => 'Vérification...';

  @override
  String get onboarding_pin_title => 'Créez votre PIN';

  @override
  String get onboarding_pin_confirmTitle => 'Confirmez votre PIN';

  @override
  String get onboarding_pin_enterPin => 'Entrez votre nouveau PIN à 6 chiffres';

  @override
  String get onboarding_pin_confirmPin =>
      'Ressaisissez votre PIN pour confirmer';

  @override
  String get pin_error_mismatch =>
      'Les PIN ne correspondent pas. Veuillez réessayer.';

  @override
  String get onboarding_profile_title => 'Parlez-nous de vous';

  @override
  String get onboarding_profile_subtitle =>
      'Cela nous aide à personnaliser votre expérience';

  @override
  String get onboarding_profile_firstName => 'Prénom';

  @override
  String get onboarding_profile_firstNameHint => 'par ex., Amadou';

  @override
  String get onboarding_profile_firstNameRequired => 'Le prénom est requis';

  @override
  String get onboarding_profile_lastName => 'Nom de famille';

  @override
  String get onboarding_profile_lastNameHint => 'par ex., Diallo';

  @override
  String get onboarding_profile_lastNameRequired =>
      'Le nom de famille est requis';

  @override
  String get onboarding_profile_email => 'Email (Optionnel)';

  @override
  String get onboarding_profile_emailHint => 'par ex., amadou@exemple.com';

  @override
  String get onboarding_profile_emailInvalid =>
      'Veuillez entrer une adresse email valide';

  @override
  String get onboarding_kyc_title => 'Vérifiez votre identité';

  @override
  String get onboarding_kyc_subtitle =>
      'Débloquez des limites plus élevées et toutes les fonctionnalités';

  @override
  String get onboarding_kyc_benefit1 => 'Limites de transaction plus élevées';

  @override
  String get onboarding_kyc_benefit2 =>
      'Envoyez vers des portefeuilles externes';

  @override
  String get onboarding_kyc_benefit3 => 'Toutes les fonctionnalités débloquées';

  @override
  String get onboarding_kyc_verify => 'Vérifier maintenant';

  @override
  String get onboarding_kyc_later => 'Peut-être plus tard';

  @override
  String get onboarding_success_title => 'Bienvenue sur JoonaPay!';

  @override
  String onboarding_success_subtitle(String name) {
    return 'Salut $name, vous êtes prêt!';
  }

  @override
  String get onboarding_success_walletCreated => 'Votre portefeuille est prêt';

  @override
  String get onboarding_success_walletMessage =>
      'Commencez à envoyer, recevoir et gérer vos USDC dès aujourd\'hui';

  @override
  String get onboarding_success_continue => 'Commencer à utiliser JoonaPay';

  @override
  String get action_delete => 'Supprimer';

  @override
  String get savingsPots_title => 'Pots d\'épargne';

  @override
  String get savingsPots_emptyTitle =>
      'Commencez à épargner pour vos objectifs';

  @override
  String get savingsPots_emptyMessage =>
      'Créez des pots pour épargner de l\'argent pour des objectifs spécifiques comme des vacances, des gadgets ou des urgences.';

  @override
  String get savingsPots_createFirst => 'Créer votre premier pot';

  @override
  String get savingsPots_totalSaved => 'Total épargné';

  @override
  String get savingsPots_createTitle => 'Créer un pot d\'épargne';

  @override
  String get savingsPots_editTitle => 'Modifier le pot';

  @override
  String get savingsPots_nameLabel => 'Nom du pot';

  @override
  String get savingsPots_nameHint => 'par ex., Vacances, Nouveau téléphone';

  @override
  String get savingsPots_nameRequired => 'Veuillez entrer un nom de pot';

  @override
  String get savingsPots_targetLabel => 'Montant cible (Optionnel)';

  @override
  String get savingsPots_targetHint => 'Combien voulez-vous économiser?';

  @override
  String get savingsPots_targetOptional =>
      'Laissez vide si vous n\'avez pas d\'objectif spécifique';

  @override
  String get savingsPots_emojiRequired => 'Veuillez sélectionner un emoji';

  @override
  String get savingsPots_colorRequired => 'Veuillez sélectionner une couleur';

  @override
  String get savingsPots_createButton => 'Créer le pot';

  @override
  String get savingsPots_updateButton => 'Mettre à jour le pot';

  @override
  String get savingsPots_createSuccess => 'Pot créé avec succès!';

  @override
  String get savingsPots_updateSuccess => 'Pot mis à jour avec succès!';

  @override
  String get savingsPots_addMoney => 'Ajouter de l\'argent';

  @override
  String get savingsPots_withdraw => 'Retirer';

  @override
  String get savingsPots_availableBalance => 'Solde disponible';

  @override
  String get savingsPots_potBalance => 'Solde du pot';

  @override
  String get savingsPots_amount => 'Montant';

  @override
  String get savingsPots_quick10 => '10%';

  @override
  String get savingsPots_quick25 => '25%';

  @override
  String get savingsPots_quick50 => '50%';

  @override
  String get savingsPots_addButton => 'Ajouter au pot';

  @override
  String get savingsPots_withdrawButton => 'Retirer';

  @override
  String get savingsPots_withdrawAll => 'Tout retirer';

  @override
  String get savingsPots_invalidAmount => 'Veuillez entrer un montant valide';

  @override
  String get savingsPots_insufficientBalance =>
      'Solde insuffisant dans votre portefeuille';

  @override
  String get savingsPots_insufficientPotBalance =>
      'Solde insuffisant dans ce pot';

  @override
  String get savingsPots_addSuccess => 'Argent ajouté avec succès!';

  @override
  String get savingsPots_withdrawSuccess => 'Argent retiré avec succès!';

  @override
  String get savingsPots_transactionHistory => 'Historique des transactions';

  @override
  String get savingsPots_noTransactions => 'Aucune transaction pour le moment';

  @override
  String get savingsPots_deposit => 'Dépôt';

  @override
  String get savingsPots_withdrawal => 'Retrait';

  @override
  String get savingsPots_goalReached => 'Objectif atteint!';

  @override
  String get savingsPots_deleteTitle => 'Supprimer le pot?';

  @override
  String get savingsPots_deleteMessage =>
      'L\'argent dans ce pot sera retourné à votre solde principal. Cette action ne peut pas être annulée.';

  @override
  String get savingsPots_deleteSuccess => 'Pot supprimé avec succès';

  @override
  String get sendExternal_title => 'Envoyer vers un portefeuille externe';

  @override
  String get sendExternal_info =>
      'Envoyez des USDC vers n\'importe quelle adresse de portefeuille sur les réseaux Polygon ou Ethereum';

  @override
  String get sendExternal_walletAddress => 'Adresse du portefeuille';

  @override
  String get sendExternal_addressHint => '0x1234...abcd';

  @override
  String get sendExternal_addressRequired =>
      'L\'adresse du portefeuille est requise';

  @override
  String get sendExternal_paste => 'Coller';

  @override
  String get sendExternal_scanQr => 'Scanner QR';

  @override
  String get sendExternal_supportedNetworks => 'Réseaux pris en charge';

  @override
  String get sendExternal_polygonInfo =>
      'Rapide (1-2 min), Frais bas (~\$0.01)';

  @override
  String get sendExternal_ethereumInfo =>
      'Plus lent (5-10 min), Frais élevés (~\$2-5)';

  @override
  String get sendExternal_enterAmount => 'Entrer le montant';

  @override
  String get sendExternal_recipientAddress => 'Adresse du destinataire';

  @override
  String get sendExternal_selectNetwork => 'Sélectionner le réseau';

  @override
  String get sendExternal_recommended => 'Recommandé';

  @override
  String get sendExternal_fee => 'Frais';

  @override
  String get sendExternal_amount => 'Montant';

  @override
  String get sendExternal_networkFee => 'Frais de réseau';

  @override
  String get sendExternal_total => 'Total';

  @override
  String get sendExternal_confirmTransfer => 'Confirmer le transfert';

  @override
  String get sendExternal_warningTitle => 'Important';

  @override
  String get sendExternal_warningMessage =>
      'Les transferts externes ne peuvent pas être annulés. Veuillez vérifier l\'adresse avec soin.';

  @override
  String get sendExternal_transferSummary => 'Résumé du transfert';

  @override
  String get sendExternal_network => 'Réseau';

  @override
  String get sendExternal_totalDeducted => 'Total déduit';

  @override
  String get sendExternal_estimatedTime => 'Temps estimé';

  @override
  String get sendExternal_confirmAndSend => 'Confirmer et envoyer';

  @override
  String get sendExternal_addressCopied =>
      'Adresse copiée dans le presse-papiers';

  @override
  String get sendExternal_transferSuccess => 'Transfert réussi';

  @override
  String get sendExternal_processingMessage =>
      'Votre transaction est en cours de traitement sur la blockchain';

  @override
  String get sendExternal_amountSent => 'Montant envoyé';

  @override
  String get sendExternal_transactionDetails => 'Détails de la transaction';

  @override
  String get sendExternal_transactionHash => 'Hash de transaction';

  @override
  String get sendExternal_status => 'Statut';

  @override
  String get sendExternal_viewOnExplorer => 'Voir sur l\'explorateur de blocs';

  @override
  String get sendExternal_shareDetails => 'Partager les détails';

  @override
  String get sendExternal_hashCopied =>
      'Hash de transaction copié dans le presse-papiers';

  @override
  String get sendExternal_statusPending => 'En attente';

  @override
  String get sendExternal_statusCompleted => 'Terminé';

  @override
  String get sendExternal_statusProcessing => 'En cours';

  @override
  String get billPayments_title => 'Pay Bills';

  @override
  String get billPayments_categories => 'Categories';

  @override
  String get billPayments_providers => 'Providers';

  @override
  String get billPayments_allProviders => 'All Providers';

  @override
  String get billPayments_searchProviders => 'Search providers...';

  @override
  String get billPayments_noProvidersFound => 'No Providers Found';

  @override
  String get billPayments_tryAdjustingSearch => 'Try adjusting your search';

  @override
  String get billPayments_history => 'Payment History';

  @override
  String get billPayments_category_electricity => 'Electricity';

  @override
  String get billPayments_category_water => 'Water';

  @override
  String get billPayments_category_airtime => 'Airtime';

  @override
  String get billPayments_category_internet => 'Internet';

  @override
  String get billPayments_category_tv => 'TV';

  @override
  String get billPayments_verifyAccount => 'Verify Account';

  @override
  String get billPayments_accountVerified => 'Account verified';

  @override
  String get billPayments_verificationFailed => 'Verification failed';

  @override
  String get billPayments_amount => 'Amount';

  @override
  String get billPayments_processingFee => 'Processing Fee';

  @override
  String get billPayments_totalAmount => 'Total';

  @override
  String get billPayments_paymentSuccessful => 'Payment Successful!';

  @override
  String get billPayments_paymentProcessing => 'Payment Processing';

  @override
  String get billPayments_billPaidSuccessfully =>
      'Your bill has been paid successfully';

  @override
  String get billPayments_paymentBeingProcessed =>
      'Your payment is being processed';

  @override
  String get billPayments_receiptNumber => 'Receipt Number';

  @override
  String get billPayments_provider => 'Provider';

  @override
  String get billPayments_account => 'Account';

  @override
  String get billPayments_customer => 'Customer';

  @override
  String get billPayments_totalPaid => 'Total Paid';

  @override
  String get billPayments_date => 'Date';

  @override
  String get billPayments_reference => 'Reference';

  @override
  String get billPayments_yourToken => 'Your Token';

  @override
  String get billPayments_shareReceipt => 'Share Receipt';

  @override
  String get billPayments_confirmPayment => 'Confirm Payment';

  @override
  String get billPayments_failedToLoadProviders => 'Failed to Load Providers';

  @override
  String get billPayments_failedToLoadReceipt => 'Failed to Load Receipt';

  @override
  String get billPayments_returnHome => 'Return Home';

  @override
  String get navigation_cards => 'Cartes';

  @override
  String get navigation_history => 'Historique';

  @override
  String get cards_comingSoon => 'Bientôt disponible';

  @override
  String get cards_title => 'Cartes virtuelles';

  @override
  String get cards_description =>
      'Dépensez vos USDC avec des cartes de débit virtuelles. Parfait pour les achats en ligne et les abonnements.';

  @override
  String get cards_feature1Title => 'Achats en ligne';

  @override
  String get cards_feature1Description =>
      'Utilisez des cartes virtuelles pour des achats en ligne sécurisés';

  @override
  String get cards_feature2Title => 'Restez en sécurité';

  @override
  String get cards_feature2Description =>
      'Gelez, dégelez ou supprimez des cartes instantanément';

  @override
  String get cards_feature3Title => 'Contrôlez les dépenses';

  @override
  String get cards_feature3Description =>
      'Définissez des limites de dépenses personnalisées pour chaque carte';

  @override
  String get cards_notifyMe => 'Me notifier lorsque disponible';

  @override
  String get cards_notifyDialogTitle => 'Être notifié';

  @override
  String get cards_notifyDialogMessage =>
      'Nous vous enverrons une notification lorsque les cartes virtuelles seront disponibles dans votre région.';

  @override
  String get cards_notifySuccess =>
      'Vous serez notifié lorsque les cartes seront disponibles';

  @override
  String get insights_title => 'Aperçus';

  @override
  String get insights_period_week => 'Semaine';

  @override
  String get insights_period_month => 'Mois';

  @override
  String get insights_period_year => 'Année';

  @override
  String get insights_summary => 'Résumé';

  @override
  String get insights_total_spent => 'Total dépensé';

  @override
  String get insights_total_received => 'Total reçu';

  @override
  String get insights_net_flow => 'Flux net';

  @override
  String get insights_categories => 'Catégories';

  @override
  String get insights_spending_trend => 'Tendance des dépenses';

  @override
  String get insights_top_recipients => 'Destinataires principaux';

  @override
  String get insights_empty_title => 'Aucun aperçu pour le moment';

  @override
  String get insights_empty_description =>
      'Commencez à utiliser JoonaPay pour voir vos aperçus et analyses de dépenses';

  @override
  String get insights_export_report => 'Exporter le rapport';

  @override
  String get contacts_title => 'Contacts';

  @override
  String get contacts_search => 'Rechercher des contacts';

  @override
  String get contacts_on_joonapay => 'Sur JoonaPay';

  @override
  String get contacts_invite_to_joonapay => 'Inviter sur JoonaPay';

  @override
  String get contacts_empty =>
      'Aucun contact trouvé. Tirez vers le bas pour actualiser.';

  @override
  String get contacts_no_results =>
      'Aucun contact ne correspond à votre recherche';

  @override
  String contacts_sync_success(int count) {
    return '$count utilisateurs JoonaPay trouvés!';
  }

  @override
  String get contacts_synced_just_now => 'À l\'instant';

  @override
  String contacts_synced_minutes_ago(int minutes) {
    return 'Il y a ${minutes}m';
  }

  @override
  String contacts_synced_hours_ago(int hours) {
    return 'Il y a ${hours}h';
  }

  @override
  String contacts_synced_days_ago(int days) {
    return 'Il y a ${days}j';
  }

  @override
  String get contacts_permission_title => 'Trouvez Vos Amis';

  @override
  String get contacts_permission_subtitle =>
      'Découvrez quels contacts utilisent déjà JoonaPay';

  @override
  String get contacts_permission_benefit1_title =>
      'Trouvez des Amis Instantanément';

  @override
  String get contacts_permission_benefit1_desc =>
      'Voyez quels contacts sont sur JoonaPay et envoyez de l\'argent instantanément';

  @override
  String get contacts_permission_benefit2_title => 'Privé et Sécurisé';

  @override
  String get contacts_permission_benefit2_desc =>
      'Nous ne stockons jamais vos contacts. Les numéros sont hachés avant la synchronisation.';

  @override
  String get contacts_permission_benefit3_title => 'Toujours à Jour';

  @override
  String get contacts_permission_benefit3_desc =>
      'Synchronisation automatique quand de nouveaux contacts rejoignent JoonaPay';

  @override
  String get contacts_permission_allow => 'Autoriser l\'Accès';

  @override
  String get contacts_permission_later => 'Peut-être Plus Tard';

  @override
  String get contacts_permission_denied_title => 'Permission Refusée';

  @override
  String get contacts_permission_denied_message =>
      'Pour trouver vos amis sur JoonaPay, veuillez autoriser l\'accès aux contacts dans les Paramètres.';

  @override
  String contacts_invite_title(String name) {
    return 'Inviter $name sur JoonaPay';
  }

  @override
  String get contacts_invite_subtitle =>
      'Envoyez de l\'argent à vos amis instantanément avec JoonaPay';

  @override
  String get contacts_invite_via_sms => 'Envoyer une Invitation par SMS';

  @override
  String get contacts_invite_via_sms_desc =>
      'Envoyer un SMS avec votre lien d\'invitation';

  @override
  String get contacts_invite_via_whatsapp => 'Inviter via WhatsApp';

  @override
  String get contacts_invite_via_whatsapp_desc =>
      'Partager le lien d\'invitation sur WhatsApp';

  @override
  String get contacts_invite_copy_link => 'Copier le Lien d\'Invitation';

  @override
  String get contacts_invite_copy_link_desc =>
      'Copier le lien pour partager n\'importe où';

  @override
  String get contacts_invite_message =>
      'Salut! J\'utilise JoonaPay pour envoyer de l\'argent instantanément. Rejoins-moi et obtiens ton premier transfert gratuit! Télécharger: https://joonapay.com/app';

  @override
  String get recurringTransfers_title => 'Transferts récurrents';

  @override
  String get recurringTransfers_createNew => 'Créer nouveau';

  @override
  String get recurringTransfers_createTitle => 'Créer un transfert récurrent';

  @override
  String get recurringTransfers_createFirst => 'Créer le premier';

  @override
  String get recurringTransfers_emptyTitle => 'Aucun transfert récurrent';

  @override
  String get recurringTransfers_emptyMessage =>
      'Configurez des transferts automatiques pour envoyer de l\'argent régulièrement à vos proches';

  @override
  String get recurringTransfers_active => 'Transferts actifs';

  @override
  String get recurringTransfers_paused => 'Transferts en pause';

  @override
  String get recurringTransfers_upcoming => 'À venir cette semaine';

  @override
  String get recurringTransfers_amount => 'Montant';

  @override
  String get recurringTransfers_frequency => 'Fréquence';

  @override
  String get recurringTransfers_nextExecution => 'Prochain';

  @override
  String get recurringTransfers_recipientSection => 'Détails du destinataire';

  @override
  String get recurringTransfers_amountSection => 'Montant du transfert';

  @override
  String get recurringTransfers_scheduleSection => 'Calendrier';

  @override
  String get recurringTransfers_startDate => 'Date de début';

  @override
  String get recurringTransfers_endCondition => 'Condition de fin';

  @override
  String get recurringTransfers_neverEnd => 'Jamais (jusqu\'à annulation)';

  @override
  String get recurringTransfers_afterOccurrences =>
      'Après un nombre spécifique de transferts';

  @override
  String get recurringTransfers_untilDate => 'Jusqu\'à une date spécifique';

  @override
  String get recurringTransfers_occurrencesCount => 'Nombre de fois';

  @override
  String get recurringTransfers_selectDate => 'Sélectionner la date';

  @override
  String get recurringTransfers_note => 'Note (facultatif)';

  @override
  String get recurringTransfers_noteHint =>
      'par ex., Loyer mensuel, Allocation hebdomadaire';

  @override
  String get recurringTransfers_create => 'Créer un transfert récurrent';

  @override
  String get recurringTransfers_createSuccess =>
      'Transfert récurrent créé avec succès';

  @override
  String get recurringTransfers_createError =>
      'Échec de la création du transfert récurrent';

  @override
  String get recurringTransfers_details => 'Détails du transfert';

  @override
  String get recurringTransfers_schedule => 'Calendrier';

  @override
  String get recurringTransfers_upcomingExecutions => 'Prochains prévus';

  @override
  String get recurringTransfers_statistics => 'Statistiques';

  @override
  String get recurringTransfers_executed => 'Exécutés';

  @override
  String get recurringTransfers_remaining => 'Restants';

  @override
  String get recurringTransfers_executionHistory => 'Historique d\'exécution';

  @override
  String get recurringTransfers_executionSuccess => 'Terminé avec succès';

  @override
  String get recurringTransfers_executionFailed => 'Échoué';

  @override
  String get recurringTransfers_pause => 'Mettre en pause';

  @override
  String get recurringTransfers_resume => 'Reprendre le transfert';

  @override
  String get recurringTransfers_cancel => 'Annuler le transfert';

  @override
  String get recurringTransfers_pauseSuccess =>
      'Transfert mis en pause avec succès';

  @override
  String get recurringTransfers_pauseError =>
      'Échec de la mise en pause du transfert';

  @override
  String get recurringTransfers_resumeSuccess => 'Transfert repris avec succès';

  @override
  String get recurringTransfers_resumeError =>
      'Échec de la reprise du transfert';

  @override
  String get recurringTransfers_cancelConfirmTitle =>
      'Annuler le transfert récurrent?';

  @override
  String get recurringTransfers_cancelConfirmMessage =>
      'Cela annulera définitivement ce transfert récurrent. Cette action ne peut pas être annulée.';

  @override
  String get recurringTransfers_confirmCancel => 'Oui, annuler';

  @override
  String get recurringTransfers_cancelSuccess => 'Transfert annulé avec succès';

  @override
  String get recurringTransfers_cancelError =>
      'Échec de l\'annulation du transfert';

  @override
  String get validation_required => 'Ce champ est obligatoire';

  @override
  String get validation_invalidAmount => 'Veuillez entrer un montant valide';

  @override
  String get common_today => 'Aujourd\'hui';

  @override
  String get common_tomorrow => 'Demain';
}
