// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Korido';

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
  String get action_clear => 'Effacer';

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
  String get auth_resendOtp => 'Renvoyer le code';

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
  String get send_joonaPayUser => 'Utilisateur Korido';

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
    return 'Envoyez de l\'USDC à mon portefeuille Korido:\n\n$address';
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
  String get transactions_fromKoridoUser => 'D\'un utilisateur Korido';

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
  String get settings_selectTheme => 'Sélectionner le thème';

  @override
  String get settings_themeLight => 'Clair';

  @override
  String get settings_themeDark => 'Sombre';

  @override
  String get settings_themeSystem => 'Système';

  @override
  String get settings_themeLightDescription => 'Apparence lumineuse et propre';

  @override
  String get settings_themeDarkDescription => 'Facile pour les yeux la nuit';

  @override
  String get settings_themeSystemDescription =>
      'Correspond aux paramètres de votre appareil';

  @override
  String get settings_appearance => 'Apparence';

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
  String get kyc_personalInfo_title => 'Informations personnelles';

  @override
  String get kyc_personalInfo_subtitle =>
      'Entrez vos informations exactement comme elles apparaissent sur votre pièce d\'identité';

  @override
  String get kyc_personalInfo_firstName => 'Prénom';

  @override
  String get kyc_personalInfo_firstNameRequired => 'Le prénom est requis';

  @override
  String get kyc_personalInfo_lastName => 'Nom de famille';

  @override
  String get kyc_personalInfo_lastNameRequired =>
      'Le nom de famille est requis';

  @override
  String get kyc_personalInfo_dateOfBirth => 'Date de naissance';

  @override
  String get kyc_personalInfo_selectDate => 'Sélectionner une date';

  @override
  String get kyc_personalInfo_dateRequired =>
      'La date de naissance est requise';

  @override
  String get kyc_personalInfo_matchIdHint =>
      'Vos informations doivent correspondre exactement à ce qui figure sur votre pièce d\'identité pour que la vérification réussisse';

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
  String get kyc_camera_unavailable => 'Caméra non disponible';

  @override
  String get kyc_camera_unavailable_description =>
      'La caméra de votre appareil n\'est pas accessible. Vous pouvez sélectionner une photo depuis votre galerie.';

  @override
  String get kyc_chooseFromGallery => 'Choisir depuis la galerie';

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
      'Nous avons rencontré un problème. Veuillez réessayer dans un instant.';

  @override
  String get error_network =>
      'Impossible de se connecter. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get error_failedToLoadBalance =>
      'Impossible de charger votre solde. Tirez vers le bas pour actualiser ou réessayez plus tard.';

  @override
  String get error_failedToLoadTransactions =>
      'Impossible de charger les transactions. Tirez vers le bas pour actualiser ou réessayez plus tard.';

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
  String get beneficiaries_typeJoonapay => 'Utilisateur Korido';

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
  String get beneficiaries_accountDetails => 'Détails du compte';

  @override
  String get beneficiaries_statistics => 'Statistiques de transfert';

  @override
  String get beneficiaries_totalTransfers => 'Transferts totaux';

  @override
  String get beneficiaries_totalAmount => 'Montant total';

  @override
  String get beneficiaries_lastTransfer => 'Dernier transfert';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_logout => 'Déconnexion';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_verified => 'Vérifié';

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
      'Partagez ce code QR avec l\'expéditeur. Ils peuvent le scanner avec leur application Korido pour vous envoyer de l\'argent instantanément.';

  @override
  String get qr_savedToGallery => 'Code QR enregistré dans la galerie';

  @override
  String get qr_failedToSave => 'Échec de l\'enregistrement du code QR';

  @override
  String get qr_initializingCamera => 'Initialisation de la caméra...';

  @override
  String get qr_scanInstruction => 'Scanner un code QR Korido';

  @override
  String get qr_scanSubInstruction =>
      'Pointez votre caméra vers un code QR pour envoyer de l\'argent';

  @override
  String get qr_scanned => 'Code QR scanné';

  @override
  String get qr_invalidCode => 'Code QR invalide';

  @override
  String get qr_invalidCodeMessage =>
      'Ce code QR n\'est pas un code de paiement Korido valide.';

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
  String deposit_rateUpdated(String time, DateTime hora) {
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
  String deposit_expiresIn(String time) {
    return 'Expire dans $time';
  }

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
  String get common_requiredField => 'Ce champ est obligatoire';

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
  String get help_needHelp => 'Besoin d\'aide?';

  @override
  String get transactionDetails_title => 'Détails de la transaction';

  @override
  String get transactionDetails_transactionId => 'ID de transaction';

  @override
  String get transactionDetails_date => 'Date';

  @override
  String get transactionDetails_currency => 'Devise';

  @override
  String get transactionDetails_recipientPhone => 'Téléphone du destinataire';

  @override
  String get transactionDetails_recipientAddress => 'Adresse du destinataire';

  @override
  String get transactionDetails_description => 'Description';

  @override
  String get transactionDetails_additionalDetails => 'Détails supplémentaires';

  @override
  String get transactionDetails_failureReason => 'Raison de l\'échec';

  @override
  String get filters_title => 'Filtrer les transactions';

  @override
  String get filters_reset => 'Réinitialiser';

  @override
  String get filters_transactionType => 'Type de transaction';

  @override
  String get filters_status => 'Statut';

  @override
  String get filters_dateRange => 'Période';

  @override
  String get filters_amountRange => 'Montant';

  @override
  String get filters_sortBy => 'Trier par';

  @override
  String get filters_from => 'Du';

  @override
  String get filters_to => 'Au';

  @override
  String get filters_clear => 'Effacer';

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
  String get onboarding_success_title => 'Bienvenue sur Korido!';

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
  String get onboarding_success_continue => 'Commencer à utiliser Korido';

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
  String get savingsPots_chooseEmoji => 'Choisir un emoji';

  @override
  String get savingsPots_chooseColor => 'Choisir une couleur';

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
  String get billPayments_title => 'Payer les factures';

  @override
  String get billPayments_categories => 'Catégories';

  @override
  String get billPayments_providers => 'Fournisseurs';

  @override
  String get billPayments_allProviders => 'Tous les fournisseurs';

  @override
  String get billPayments_searchProviders => 'Rechercher des fournisseurs...';

  @override
  String get billPayments_noProvidersFound => 'Aucun fournisseur trouvé';

  @override
  String get billPayments_tryAdjustingSearch =>
      'Essayez d\'ajuster votre recherche';

  @override
  String get billPayments_history => 'Historique des paiements';

  @override
  String get billPayments_category_electricity => 'Électricité';

  @override
  String get billPayments_category_water => 'Eau';

  @override
  String get billPayments_category_airtime => 'Crédit téléphonique';

  @override
  String get billPayments_category_internet => 'Internet';

  @override
  String get billPayments_category_tv => 'Télévision';

  @override
  String get billPayments_verifyAccount => 'Vérifier le compte';

  @override
  String get billPayments_accountVerified => 'Compte vérifié';

  @override
  String get billPayments_verificationFailed => 'Échec de la vérification';

  @override
  String get billPayments_amount => 'Montant';

  @override
  String get billPayments_processingFee => 'Frais de traitement';

  @override
  String get billPayments_totalAmount => 'Total';

  @override
  String get billPayments_paymentSuccessful => 'Paiement réussi !';

  @override
  String get billPayments_paymentProcessing => 'Paiement en cours';

  @override
  String get billPayments_billPaidSuccessfully =>
      'Votre facture a été payée avec succès';

  @override
  String get billPayments_paymentBeingProcessed =>
      'Votre paiement est en cours de traitement';

  @override
  String get billPayments_receiptNumber => 'Numéro de reçu';

  @override
  String get billPayments_provider => 'Fournisseur';

  @override
  String get billPayments_account => 'Compte';

  @override
  String get billPayments_customer => 'Client';

  @override
  String get billPayments_totalPaid => 'Total payé';

  @override
  String get billPayments_date => 'Date';

  @override
  String get billPayments_reference => 'Référence';

  @override
  String get billPayments_yourToken => 'Votre jeton';

  @override
  String get billPayments_shareReceipt => 'Partager le reçu';

  @override
  String get billPayments_confirmPayment => 'Confirmer le paiement';

  @override
  String get billPayments_failedToLoadProviders =>
      'Échec du chargement des fournisseurs';

  @override
  String get billPayments_failedToLoadReceipt => 'Échec du chargement du reçu';

  @override
  String get billPayments_returnHome => 'Retour à l\'accueil';

  @override
  String billPayments_payProvider(String providerName, Object providername) {
    return 'Payer $providerName';
  }

  @override
  String billPayments_enterField(String field) {
    return 'Entrer $field';
  }

  @override
  String billPayments_pleaseEnterField(String field) {
    return 'Veuillez entrer $field';
  }

  @override
  String billPayments_fieldMustBeLength(String field, int length) {
    return '$field doit contenir $length caractères';
  }

  @override
  String get billPayments_meterNumber => 'Numéro de compteur';

  @override
  String get billPayments_enterMeterNumber => 'Entrer le numéro de compteur';

  @override
  String get billPayments_pleaseEnterMeterNumber =>
      'Veuillez entrer le numéro de compteur';

  @override
  String billPayments_outstanding(String amount, String currency) {
    return 'Impayé : $amount $currency';
  }

  @override
  String get billPayments_pleaseEnterAmount => 'Veuillez entrer le montant';

  @override
  String get billPayments_pleaseEnterValidAmount =>
      'Veuillez entrer un montant valide';

  @override
  String billPayments_minimumAmount(int amount, String currency) {
    return 'Le montant minimum est $amount $currency';
  }

  @override
  String billPayments_maximumAmount(int amount, String currency) {
    return 'Le montant maximum est $amount $currency';
  }

  @override
  String billPayments_minMaxRange(int min, int max, String currency) {
    return 'Min : $min - Max : $max $currency';
  }

  @override
  String billPayments_available(String amount, String currency) {
    return 'Disponible : $amount $currency';
  }

  @override
  String billPayments_payAmount(String amount, String currency) {
    return 'Payer $amount $currency';
  }

  @override
  String billPayments_enterPinToPay(String providerName, Object providername) {
    return 'Entrez votre code PIN pour payer $providerName';
  }

  @override
  String get billPayments_paymentFailed => 'Échec du paiement';

  @override
  String get billPayments_noProvidersAvailable =>
      'Aucun fournisseur disponible pour cette catégorie';

  @override
  String get billPayments_feeNone => 'Aucun frais';

  @override
  String billPayments_feePercentage(String percentage) {
    return '$percentage% de frais';
  }

  @override
  String billPayments_feeFixed(int amount, String currency) {
    return '$amount $currency de frais';
  }

  @override
  String get billPayments_statusCompleted => 'Terminé';

  @override
  String get billPayments_statusPending => 'En attente';

  @override
  String get billPayments_statusProcessing => 'En cours';

  @override
  String get billPayments_statusFailed => 'Échoué';

  @override
  String get billPayments_statusRefunded => 'Remboursé';

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
  String get cards_featureDisabled =>
      'Fonctionnalité de cartes virtuelles non disponible';

  @override
  String get cards_noCards => 'Aucune carte';

  @override
  String get cards_noCardsDescription =>
      'Demandez votre première carte virtuelle pour commencer à faire des achats en ligne';

  @override
  String get cards_requestCard => 'Demander une carte';

  @override
  String get cards_cardDetails => 'Détails de la carte';

  @override
  String get cards_cardNotFound => 'Carte introuvable';

  @override
  String get cards_cardInformation => 'Informations de la carte';

  @override
  String get cards_cardNumber => 'Numéro de carte';

  @override
  String get cards_cvv => 'CVV';

  @override
  String get cards_expiryDate => 'Date d\'expiration';

  @override
  String get cards_spendingLimit => 'Limite de dépenses';

  @override
  String get cards_spent => 'Dépensé';

  @override
  String get cards_limit => 'Limite';

  @override
  String get cards_viewTransactions => 'Voir les transactions';

  @override
  String get cards_freezeCard => 'Geler la carte';

  @override
  String get cards_unfreezeCard => 'Dégeler la carte';

  @override
  String get cards_freezeConfirmation =>
      'Êtes-vous sûr de vouloir geler cette carte? Vous pouvez la dégeler à tout moment.';

  @override
  String get cards_unfreezeConfirmation =>
      'Êtes-vous sûr de vouloir dégeler cette carte?';

  @override
  String get cards_cardFrozen => 'Carte gelée avec succès';

  @override
  String get cards_cardUnfrozen => 'Carte dégelée avec succès';

  @override
  String get cards_copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get cards_requestInfo =>
      'Votre carte virtuelle sera prête instantanément après approbation. Nécessite KYC niveau 2.';

  @override
  String get cards_cardholderName => 'Nom du titulaire';

  @override
  String get cards_cardholderNameHint =>
      'Entrez le nom tel qu\'il apparaît sur la carte';

  @override
  String get cards_nameRequired => 'Le nom du titulaire est requis';

  @override
  String get cards_spendingLimitHint => 'Entrez la limite de dépenses en USD';

  @override
  String get cards_limitRequired => 'La limite de dépenses est requise';

  @override
  String get cards_limitInvalid => 'Limite de dépenses invalide';

  @override
  String get cards_limitTooLow => 'La limite minimale est de 10 \$';

  @override
  String get cards_limitTooHigh => 'La limite maximale est de 10 000 \$';

  @override
  String get cards_cardFeatures => 'Fonctionnalités de la carte';

  @override
  String get cards_featureOnlineShopping =>
      'Achetez en ligne dans le monde entier';

  @override
  String get cards_featureSecure => 'Sécurisé et crypté';

  @override
  String get cards_featureFreeze => 'Geler et dégeler instantanément';

  @override
  String get cards_featureAlerts => 'Alertes de transaction en temps réel';

  @override
  String get cards_requestCardSubmit => 'Demander une carte virtuelle';

  @override
  String get cards_kycRequired => 'Vérification KYC requise';

  @override
  String get cards_kycRequiredDescription =>
      'Vous devez compléter la vérification KYC niveau 2 pour demander une carte virtuelle.';

  @override
  String get cards_completeKYC => 'Compléter KYC';

  @override
  String get cards_requestSuccess => 'Carte demandée avec succès';

  @override
  String get cards_requestFailed => 'Échec de la demande de carte';

  @override
  String get cards_cardSettings => 'Paramètres de la carte';

  @override
  String get cards_cardStatus => 'État de la carte';

  @override
  String get cards_statusActive => 'Active';

  @override
  String get cards_statusFrozen => 'Gelée';

  @override
  String get cards_statusActiveDescription =>
      'Votre carte est active et prête à être utilisée';

  @override
  String get cards_statusFrozenDescription =>
      'Votre carte est gelée et ne peut pas être utilisée';

  @override
  String get cards_currentLimit => 'Limite actuelle';

  @override
  String get cards_availableLimit => 'Disponible';

  @override
  String get cards_updateLimit => 'Mettre à jour la limite';

  @override
  String get cards_newLimit => 'Nouvelle limite';

  @override
  String get cards_limitRange => 'La limite doit être entre 10 \$ et 10 000 \$';

  @override
  String get cards_limitUpdated => 'Limite de dépenses mise à jour avec succès';

  @override
  String get cards_dangerZone => 'Zone dangereuse';

  @override
  String get cards_blockCard => 'Bloquer la carte';

  @override
  String get cards_blockCardDescription =>
      'Bloquer définitivement cette carte. Cette action ne peut pas être annulée.';

  @override
  String get cards_blockCardButton => 'Bloquer définitivement la carte';

  @override
  String get cards_blockCardConfirmation =>
      'Êtes-vous sûr de vouloir bloquer définitivement cette carte? Cette action ne peut pas être annulée et vous devrez demander une nouvelle carte.';

  @override
  String get cards_cardBlocked => 'Carte bloquée avec succès';

  @override
  String get cards_transactions => 'Transactions de la carte';

  @override
  String get cards_noTransactions => 'Aucune transaction';

  @override
  String get cards_noTransactionsDescription =>
      'Vous n\'avez pas encore effectué d\'achat avec cette carte';

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
      'Commencez à utiliser Korido pour voir vos aperçus et analyses de dépenses';

  @override
  String get insights_export_report => 'Exporter le rapport';

  @override
  String get insights_daily_spending => 'Dépenses quotidiennes';

  @override
  String get insights_daily_average => 'Moy. quotidienne';

  @override
  String get insights_highest_day => 'Plus élevé';

  @override
  String get insights_income_vs_expenses => 'Revenus vs Dépenses';

  @override
  String get insights_income => 'Revenus';

  @override
  String get insights_expenses => 'Dépenses';

  @override
  String get contacts_title => 'Contacts';

  @override
  String get contacts_search => 'Rechercher des contacts';

  @override
  String get contacts_on_joonapay => 'Sur Korido';

  @override
  String get contacts_invite_to_joonapay => 'Inviter sur Korido';

  @override
  String get contacts_empty =>
      'Aucun contact trouvé. Tirez vers le bas pour actualiser.';

  @override
  String get contacts_no_results =>
      'Aucun contact ne correspond à votre recherche';

  @override
  String contacts_sync_success(int count) {
    return '$count utilisateurs Korido trouvés!';
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
      'Découvrez quels contacts utilisent déjà Korido';

  @override
  String get contacts_permission_benefit1_title =>
      'Trouvez des Amis Instantanément';

  @override
  String get contacts_permission_benefit1_desc =>
      'Voyez quels contacts sont sur Korido et envoyez de l\'argent instantanément';

  @override
  String get contacts_permission_benefit2_title => 'Privé et Sécurisé';

  @override
  String get contacts_permission_benefit2_desc =>
      'Nous ne stockons jamais vos contacts. Les numéros sont hachés avant la synchronisation.';

  @override
  String get contacts_permission_benefit3_title => 'Toujours à Jour';

  @override
  String get contacts_permission_benefit3_desc =>
      'Synchronisation automatique quand de nouveaux contacts rejoignent Korido';

  @override
  String get contacts_permission_allow => 'Autoriser l\'Accès';

  @override
  String get contacts_permission_later => 'Peut-être Plus Tard';

  @override
  String get contacts_permission_denied_title => 'Permission Refusée';

  @override
  String get contacts_permission_denied_message =>
      'Pour trouver vos amis sur Korido, veuillez autoriser l\'accès aux contacts dans les Paramètres.';

  @override
  String contacts_invite_title(String name) {
    return 'Inviter $name sur Korido';
  }

  @override
  String get contacts_invite_subtitle =>
      'Envoyez de l\'argent à vos amis instantanément avec Korido';

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
      'Salut! J\'utilise Korido pour envoyer de l\'argent instantanément. Rejoins-moi et obtiens ton premier transfert gratuit! Télécharger: https://joonapay.com/app';

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

  @override
  String get limits_title => 'Limites de transaction';

  @override
  String get limits_dailyLimits => 'Limites quotidiennes';

  @override
  String get limits_monthlyLimits => 'Limites mensuelles';

  @override
  String get limits_dailyTransactions => 'Transactions quotidiennes';

  @override
  String get limits_monthlyTransactions => 'Transactions mensuelles';

  @override
  String get limits_remaining => 'restant';

  @override
  String get limits_of => 'sur';

  @override
  String get limits_upgradeTitle => 'Besoin de limites plus élevées?';

  @override
  String get limits_upgradeDescription =>
      'Vérifiez votre identité pour débloquer des limites premium';

  @override
  String get limits_upgradeToTier => 'Passer à';

  @override
  String get limits_day => 'jour';

  @override
  String get limits_month => 'mois';

  @override
  String get limits_aboutTitle => 'À propos des limites';

  @override
  String get limits_aboutDescription =>
      'Les limites sont réinitialisées à minuit UTC. Complétez la vérification KYC pour augmenter vos limites.';

  @override
  String get limits_kycPrompt =>
      'Complétez le KYC pour des limites plus élevées';

  @override
  String get limits_maxTier => 'Vous avez le niveau le plus élevé';

  @override
  String get limits_singleTransaction => 'Transaction Unique';

  @override
  String get limits_withdrawal => 'Limite de Retrait';

  @override
  String get limits_resetIn => 'Se réinitialise dans';

  @override
  String get limits_hours => 'heures';

  @override
  String get limits_minutes => 'minutes';

  @override
  String get limits_otherLimits => 'Autres Limites';

  @override
  String get limits_noData => 'Aucune donnée de limite disponible';

  @override
  String get limits_limitReached => 'Limite atteinte';

  @override
  String get limits_dailyLimitReached =>
      'Vous avez atteint votre limite de transaction quotidienne de';

  @override
  String get limits_monthlyLimitReached =>
      'Vous avez atteint votre limite de transaction mensuelle de';

  @override
  String get limits_upgradeToIncrease =>
      'Mettez à niveau votre compte pour augmenter les limites';

  @override
  String get limits_approachingLimit => 'Limite approchée';

  @override
  String get limits_remainingToday => 'restant aujourd\'hui';

  @override
  String get limits_remainingThisMonth => 'restant ce mois-ci';

  @override
  String get paymentLinks_title => 'Liens de Paiement';

  @override
  String get paymentLinks_createLink => 'Créer un Lien de Paiement';

  @override
  String get paymentLinks_createNew => 'Créer Nouveau';

  @override
  String get paymentLinks_createDescription =>
      'Générez un lien de paiement partageable pour recevoir de l\'argent de n\'importe qui';

  @override
  String get paymentLinks_amount => 'Montant';

  @override
  String get paymentLinks_description => 'Description';

  @override
  String get paymentLinks_descriptionHint =>
      'À quoi sert ce paiement ? (facultatif)';

  @override
  String get paymentLinks_expiresIn => 'Le lien expire dans';

  @override
  String get paymentLinks_6hours => '6 heures';

  @override
  String get paymentLinks_24hours => '24 heures';

  @override
  String get paymentLinks_3days => '3 jours';

  @override
  String get paymentLinks_7days => '7 jours';

  @override
  String get paymentLinks_info =>
      'Toute personne possédant ce lien peut vous payer. Le lien expire automatiquement.';

  @override
  String get paymentLinks_invalidAmount => 'Veuillez saisir un montant valide';

  @override
  String get paymentLinks_minimumAmount => 'Le montant minimum est de CFA 100';

  @override
  String get paymentLinks_linkCreated => 'Lien Créé';

  @override
  String get paymentLinks_linkReadyTitle => 'Votre lien de paiement est prêt !';

  @override
  String get paymentLinks_linkReadyDescription =>
      'Partagez ce lien avec n\'importe qui pour recevoir un paiement';

  @override
  String get paymentLinks_requestedAmount => 'Montant Demandé';

  @override
  String get paymentLinks_shareLink => 'Partager le Lien';

  @override
  String get paymentLinks_viewDetails => 'Voir les Détails';

  @override
  String get paymentLinks_copyLink => 'Copier le Lien';

  @override
  String get paymentLinks_shareWhatsApp => 'Partager sur WhatsApp';

  @override
  String get paymentLinks_shareSMS => 'Partager par SMS';

  @override
  String get paymentLinks_shareOther => 'Partager Autrement';

  @override
  String get paymentLinks_linkCopied => 'Lien copié dans le presse-papiers';

  @override
  String get paymentLinks_paymentRequest => 'Demande de Paiement';

  @override
  String get paymentLinks_emptyTitle => 'Aucun lien de paiement pour le moment';

  @override
  String get paymentLinks_emptyDescription =>
      'Créez votre premier lien de paiement pour commencer à recevoir de l\'argent facilement';

  @override
  String get paymentLinks_createFirst => 'Créer Votre Premier Lien';

  @override
  String get paymentLinks_activeLinks => 'Liens Actifs';

  @override
  String get paymentLinks_paidLinks => 'Liens Payés';

  @override
  String get paymentLinks_filterAll => 'Tous';

  @override
  String get paymentLinks_filterPending => 'En attente';

  @override
  String get paymentLinks_filterViewed => 'Vue';

  @override
  String get paymentLinks_filterPaid => 'Payé';

  @override
  String get paymentLinks_filterExpired => 'Expiré';

  @override
  String get paymentLinks_noLinksWithFilter =>
      'Aucun lien ne correspond à ce filtre';

  @override
  String get paymentLinks_linkDetails => 'Détails du Lien';

  @override
  String get paymentLinks_linkCode => 'Code du Lien';

  @override
  String get paymentLinks_linkUrl => 'URL du Lien';

  @override
  String get paymentLinks_viewCount => 'Nombre de Vues';

  @override
  String get paymentLinks_created => 'Créé';

  @override
  String get paymentLinks_expires => 'Expire';

  @override
  String get paymentLinks_paidBy => 'Payé Par';

  @override
  String get paymentLinks_paidAt => 'Payé Le';

  @override
  String get paymentLinks_cancelLink => 'Annuler le Lien';

  @override
  String get paymentLinks_cancelConfirmTitle => 'Annuler le lien ?';

  @override
  String get paymentLinks_cancelConfirmMessage =>
      'Êtes-vous sûr de vouloir annuler ce lien de paiement ? Cette action ne peut pas être annulée.';

  @override
  String get paymentLinks_linkCancelled => 'Lien de paiement annulé';

  @override
  String get paymentLinks_viewTransaction => 'Voir la Transaction';

  @override
  String get paymentLinks_payTitle => 'Payer via lien';

  @override
  String get paymentLinks_payingTo => 'Paiement à';

  @override
  String paymentLinks_payAmount(String amount) {
    return 'Payer $amount';
  }

  @override
  String get paymentLinks_paymentFor => 'Paiement pour';

  @override
  String get paymentLinks_linkExpiredTitle => 'Lien expiré';

  @override
  String get paymentLinks_linkExpiredMessage =>
      'Ce lien de paiement a expiré et ne peut plus être utilisé';

  @override
  String get paymentLinks_linkPaidTitle => 'Déjà payé';

  @override
  String get paymentLinks_linkPaidMessage =>
      'Ce lien de paiement a déjà été payé';

  @override
  String get paymentLinks_linkNotFoundTitle => 'Lien introuvable';

  @override
  String get paymentLinks_linkNotFoundMessage =>
      'Ce lien de paiement n\'existe pas ou a été annulé';

  @override
  String get paymentLinks_paymentSuccess => 'Paiement réussi';

  @override
  String get paymentLinks_paymentSuccessMessage =>
      'Votre paiement a été envoyé avec succès';

  @override
  String get paymentLinks_insufficientBalance =>
      'Solde insuffisant pour effectuer ce paiement';

  @override
  String get common_done => 'Terminé';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_unknown => 'Inconnu';

  @override
  String get common_yes => 'Oui';

  @override
  String get common_no => 'Non';

  @override
  String get offline_youreOffline => 'Vous êtes hors ligne';

  @override
  String offline_youreOfflineWithPending(int count) {
    return 'Vous êtes hors ligne · $count en attente';
  }

  @override
  String get offline_syncing => 'Synchronisation...';

  @override
  String get offline_pendingTransfer => 'Transfert en attente';

  @override
  String get offline_transferQueued => 'Transfert mis en file d\'attente';

  @override
  String get offline_transferQueuedDesc =>
      'Votre transfert sera envoyé lorsque vous serez de nouveau en ligne';

  @override
  String get offline_viewPending => 'Voir en attente';

  @override
  String get offline_retryFailed => 'Réessayer l\'échec';

  @override
  String get offline_cancelTransfer => 'Annuler le transfert';

  @override
  String get offline_noConnection => 'Pas de connexion Internet';

  @override
  String get offline_checkConnection =>
      'Veuillez vérifier votre connexion Internet et réessayer';

  @override
  String get offline_cacheData => 'Affichage des données en cache';

  @override
  String offline_lastSynced(String time) {
    return 'Dernière synchronisation: $time';
  }

  @override
  String get referrals_title => 'Parrainer et gagner';

  @override
  String get referrals_subtitle =>
      'Invitez des amis et gagnez des récompenses ensemble';

  @override
  String get referrals_earnAmount => 'Gagnez 5\$';

  @override
  String get referrals_earnDescription =>
      'pour chaque ami qui s\'inscrit et effectue son premier dépôt';

  @override
  String get referrals_yourCode => 'Votre code de parrainage';

  @override
  String get referrals_shareLink => 'Partager le lien';

  @override
  String get referrals_invite => 'Inviter';

  @override
  String get referrals_yourRewards => 'Vos récompenses';

  @override
  String get referrals_friendsInvited => 'Amis invités';

  @override
  String get referrals_totalEarned => 'Total gagné';

  @override
  String get referrals_howItWorks => 'Comment ça marche';

  @override
  String get referrals_step1Title => 'Partagez votre code';

  @override
  String get referrals_step1Description =>
      'Envoyez votre code ou lien de parrainage à vos amis';

  @override
  String get referrals_step2Title => 'L\'ami s\'inscrit';

  @override
  String get referrals_step2Description =>
      'Ils créent un compte en utilisant votre code';

  @override
  String get referrals_step3Title => 'Premier dépôt';

  @override
  String get referrals_step3Description =>
      'Ils effectuent leur premier dépôt de 10\$ ou plus';

  @override
  String get referrals_step4Title => 'Vous gagnez tous les deux!';

  @override
  String get referrals_step4Description =>
      'Vous recevez 5\$, et votre ami reçoit également 5\$';

  @override
  String get referrals_history => 'Historique des parrainages';

  @override
  String get referrals_noReferrals => 'Aucun parrainage pour le moment';

  @override
  String get referrals_startInviting =>
      'Commencez à inviter des amis pour voir vos récompenses ici';

  @override
  String get referrals_codeCopied => 'Code de parrainage copié!';

  @override
  String referrals_shareMessage(String code) {
    return 'Rejoignez Korido et obtenez un bonus de 5\$ sur votre premier dépôt! Utilisez mon code de parrainage: $code\n\nTéléchargez maintenant: https://joonapay.com/download';
  }

  @override
  String get referrals_shareSubject =>
      'Rejoignez Korido - Obtenez un bonus de 5\$!';

  @override
  String get referrals_inviteComingSoon =>
      'Invitation par contact bientôt disponible';

  @override
  String get analytics_title => 'Analyses';

  @override
  String get analytics_income => 'Revenus';

  @override
  String get analytics_expenses => 'Dépenses';

  @override
  String get analytics_netChange => 'Variation nette';

  @override
  String get analytics_surplus => 'Excédent';

  @override
  String get analytics_deficit => 'Déficit';

  @override
  String get analytics_spendingByCategory => 'Dépenses par catégorie';

  @override
  String get analytics_categoryDetails => 'Détails de la catégorie';

  @override
  String get analytics_transactionFrequency => 'Fréquence des transactions';

  @override
  String get analytics_insights => 'Aperçus';

  @override
  String get analytics_period7Days => '7 jours';

  @override
  String get analytics_period30Days => '30 jours';

  @override
  String get analytics_period90Days => '90 jours';

  @override
  String get analytics_period1Year => '1 an';

  @override
  String get analytics_categoryTransfers => 'Transferts';

  @override
  String get analytics_categoryWithdrawals => 'Retraits';

  @override
  String get analytics_categoryBills => 'Factures';

  @override
  String get analytics_categoryOther => 'Autres';

  @override
  String analytics_transactions(int count) {
    return '$count transactions';
  }

  @override
  String get analytics_insightSpendingDown => 'Dépenses en baisse';

  @override
  String get analytics_insightSpendingDownDesc =>
      'Vos dépenses sont inférieures de 5,2% au mois dernier. Excellent travail!';

  @override
  String get analytics_insightSavings => 'Opportunité d\'épargne';

  @override
  String get analytics_insightSavingsDesc =>
      'Vous pourriez économiser 50\$/mois en réduisant les frais de retrait.';

  @override
  String get analytics_insightPeakActivity => 'Activité de pointe';

  @override
  String get analytics_insightPeakActivityDesc =>
      'La plupart de vos transactions ont lieu les jeudis.';

  @override
  String get analytics_exportingReport => 'Exportation du rapport...';

  @override
  String get converter_title => 'Convertisseur de devises';

  @override
  String get converter_from => 'De';

  @override
  String get converter_to => 'Vers';

  @override
  String get converter_selectCurrency => 'Sélectionner la devise';

  @override
  String get converter_rateInfo => 'Informations sur le taux';

  @override
  String get converter_rateDisclaimer =>
      'Les taux de change sont fournis à titre indicatif uniquement et peuvent différer des taux de transaction réels. Les taux sont mis à jour toutes les heures.';

  @override
  String get converter_quickAmounts => 'Montants rapides';

  @override
  String get converter_popularCurrencies => 'Devises populaires';

  @override
  String get converter_perUsdc => 'par USDC';

  @override
  String get converter_ratesUpdated => 'Taux de change mis à jour';

  @override
  String get converter_updatedJustNow => 'Mis à jour à l\'instant';

  @override
  String converter_exchangeRate(String from, String rate, String to) {
    return '1 $from = $rate $to';
  }

  @override
  String get currency_usd => 'Dollar américain';

  @override
  String get currency_usdc => 'USD Coin';

  @override
  String get currency_eur => 'Euro';

  @override
  String get currency_gbp => 'Livre sterling';

  @override
  String get currency_xof => 'Franc CFA d\'Afrique de l\'Ouest';

  @override
  String get currency_ngn => 'Naira nigérian';

  @override
  String get currency_kes => 'Shilling kenyan';

  @override
  String get currency_zar => 'Rand sud-africain';

  @override
  String get currency_ghs => 'Cedi ghanéen';

  @override
  String get settings_accountType => 'Type de compte';

  @override
  String get settings_personalAccount => 'Personnel';

  @override
  String get settings_businessAccount => 'Entreprise';

  @override
  String get settings_selectAccountType => 'Sélectionner le type de compte';

  @override
  String get settings_personalAccountDescription => 'Pour usage individuel';

  @override
  String get settings_businessAccountDescription =>
      'Pour les opérations commerciales';

  @override
  String get settings_switchedToPersonal => 'Basculé vers compte personnel';

  @override
  String get settings_switchedToBusiness => 'Basculé vers compte entreprise';

  @override
  String get business_setupTitle => 'Configuration entreprise';

  @override
  String get business_setupDescription =>
      'Configurez votre profil d\'entreprise pour débloquer les fonctionnalités professionnelles';

  @override
  String get business_businessName => 'Nom de l\'entreprise';

  @override
  String get business_registrationNumber => 'Numéro d\'enregistrement';

  @override
  String get business_businessType => 'Type d\'entreprise';

  @override
  String get business_businessAddress => 'Adresse de l\'entreprise';

  @override
  String get business_taxId => 'Numéro fiscal';

  @override
  String get business_verificationNote =>
      'Votre entreprise devra faire l\'objet d\'une vérification (KYB) avant de pouvoir accéder à toutes les fonctionnalités commerciales.';

  @override
  String get business_completeSetup => 'Terminer la configuration';

  @override
  String get business_setupSuccess => 'Profil d\'entreprise créé avec succès';

  @override
  String get business_profileTitle => 'Profil d\'entreprise';

  @override
  String get business_noProfile => 'Aucun profil d\'entreprise trouvé';

  @override
  String get business_setupNow => 'Configurer le profil d\'entreprise';

  @override
  String get business_verified => 'Entreprise vérifiée';

  @override
  String get business_verifiedDescription =>
      'Votre entreprise a été vérifiée avec succès';

  @override
  String get business_verificationPending => 'Vérification en attente';

  @override
  String get business_verificationPendingDescription =>
      'La vérification de votre entreprise est en cours d\'examen';

  @override
  String get business_information => 'Informations sur l\'entreprise';

  @override
  String get business_completeVerification =>
      'Terminer la vérification de l\'entreprise';

  @override
  String get business_kybDescription =>
      'Vérifiez votre entreprise pour débloquer toutes les fonctionnalités';

  @override
  String get business_kybTitle => 'Vérification d\'entreprise (KYB)';

  @override
  String get business_kybInfo =>
      'La vérification de l\'entreprise vous permet de :\n\n• Accepter des limites de transaction plus élevées\n• Accéder à des rapports avancés\n• Activer les fonctionnalités marchandes\n• Renforcer la confiance avec les clients\n\nLa vérification prend généralement 2 à 3 jours ouvrables.';

  @override
  String get action_close => 'Fermer';

  @override
  String get subBusiness_title => 'Sous-Entreprises';

  @override
  String get subBusiness_emptyTitle => 'Aucune Sous-Entreprise';

  @override
  String get subBusiness_emptyMessage =>
      'Créez des départements, succursales ou équipes pour organiser vos opérations commerciales.';

  @override
  String get subBusiness_createFirst => 'Créer la première sous-entreprise';

  @override
  String get subBusiness_totalBalance => 'Solde Total';

  @override
  String get subBusiness_unit => 'unité';

  @override
  String get subBusiness_units => 'unités';

  @override
  String get subBusiness_listTitle => 'Toutes les Sous-Entreprises';

  @override
  String get subBusiness_createTitle => 'Créer une Sous-Entreprise';

  @override
  String get subBusiness_nameLabel => 'Nom';

  @override
  String get subBusiness_descriptionLabel => 'Description (Optionnel)';

  @override
  String get subBusiness_typeLabel => 'Type';

  @override
  String get subBusiness_typeDepartment => 'Département';

  @override
  String get subBusiness_typeBranch => 'Succursale';

  @override
  String get subBusiness_typeSubsidiary => 'Filiale';

  @override
  String get subBusiness_typeTeam => 'Équipe';

  @override
  String get subBusiness_createInfo =>
      'Chaque sous-entreprise aura son propre portefeuille pour suivre séparément les revenus et dépenses.';

  @override
  String get subBusiness_createButton => 'Créer la Sous-Entreprise';

  @override
  String get subBusiness_createSuccess => 'Sous-entreprise créée avec succès';

  @override
  String get subBusiness_balance => 'Solde';

  @override
  String get subBusiness_transfer => 'Transférer';

  @override
  String get subBusiness_transactions => 'Transactions';

  @override
  String get subBusiness_information => 'Informations';

  @override
  String get subBusiness_type => 'Type';

  @override
  String get subBusiness_description => 'Description';

  @override
  String get subBusiness_created => 'Créé le';

  @override
  String get subBusiness_staff => 'Personnel';

  @override
  String get subBusiness_manageStaff => 'Gérer le Personnel';

  @override
  String get subBusiness_noStaff =>
      'Aucun membre du personnel. Ajoutez des membres pour leur donner accès à cette sous-entreprise.';

  @override
  String get subBusiness_addFirstStaff => 'Ajouter un Membre';

  @override
  String get subBusiness_viewAllStaff => 'Voir Tout le Personnel';

  @override
  String get subBusiness_staffTitle => 'Gestion du Personnel';

  @override
  String get subBusiness_noStaffTitle => 'Aucun Membre';

  @override
  String get subBusiness_noStaffMessage =>
      'Invitez des membres d\'équipe à collaborer sur cette sous-entreprise.';

  @override
  String get subBusiness_staffInfo =>
      'Les membres peuvent consulter et gérer cette sous-entreprise selon leur rôle.';

  @override
  String get subBusiness_member => 'membre';

  @override
  String get subBusiness_members => 'membres';

  @override
  String get subBusiness_addStaffTitle => 'Ajouter un Membre';

  @override
  String get subBusiness_phoneLabel => 'Numéro de Téléphone';

  @override
  String get subBusiness_roleLabel => 'Rôle';

  @override
  String get subBusiness_roleOwner => 'Propriétaire';

  @override
  String get subBusiness_roleAdmin => 'Administrateur';

  @override
  String get subBusiness_roleViewer => 'Observateur';

  @override
  String get subBusiness_roleOwnerDesc => 'Accès complet pour tout gérer';

  @override
  String get subBusiness_roleAdminDesc => 'Peut gérer et transférer des fonds';

  @override
  String get subBusiness_roleViewerDesc =>
      'Peut uniquement voir les transactions';

  @override
  String get subBusiness_inviteButton => 'Inviter';

  @override
  String get subBusiness_inviteSuccess => 'Membre invité avec succès';

  @override
  String get subBusiness_changeRole => 'Changer le Rôle';

  @override
  String get subBusiness_removeStaff => 'Retirer le Membre';

  @override
  String get subBusiness_changeRoleTitle => 'Changer le Rôle';

  @override
  String get subBusiness_roleUpdateSuccess => 'Rôle mis à jour avec succès';

  @override
  String get subBusiness_removeStaffTitle => 'Retirer le Membre';

  @override
  String get subBusiness_removeStaffConfirm =>
      'Êtes-vous sûr de vouloir retirer ce membre ? Il perdra l\'accès à cette sous-entreprise.';

  @override
  String get subBusiness_removeButton => 'Retirer';

  @override
  String get subBusiness_removeSuccess => 'Membre retiré avec succès';

  @override
  String get bulkPayments_title => 'Paiements groupés';

  @override
  String get bulkPayments_uploadCsv => 'Télécharger un fichier CSV';

  @override
  String get bulkPayments_emptyTitle => 'Aucun paiement groupé pour le moment';

  @override
  String get bulkPayments_emptyDescription =>
      'Téléchargez un fichier CSV pour envoyer des paiements à plusieurs destinataires à la fois';

  @override
  String get bulkPayments_active => 'Lots actifs';

  @override
  String get bulkPayments_completed => 'Terminé';

  @override
  String get bulkPayments_failed => 'Échoué';

  @override
  String get bulkPayments_uploadTitle => 'Télécharger des paiements groupés';

  @override
  String get bulkPayments_instructions => 'Instructions';

  @override
  String get bulkPayments_instructionsDescription =>
      'Téléchargez un fichier CSV contenant les numéros de téléphone, montants et descriptions pour plusieurs paiements';

  @override
  String get bulkPayments_uploadFile => 'Télécharger le fichier';

  @override
  String get bulkPayments_selectFile =>
      'Appuyez pour sélectionner un fichier CSV';

  @override
  String get bulkPayments_csvOnly => 'Fichiers CSV uniquement';

  @override
  String get bulkPayments_csvFormat => 'Format CSV';

  @override
  String get bulkPayments_phoneFormat =>
      'Téléphone: Format international (+225...)';

  @override
  String get bulkPayments_amountFormat => 'Montant: Valeur numérique (50.00)';

  @override
  String get bulkPayments_descriptionFormat => 'Description: Texte requis';

  @override
  String get bulkPayments_example => 'Exemple';

  @override
  String get bulkPayments_preview => 'Aperçu des paiements';

  @override
  String get bulkPayments_totalPayments => 'Total des paiements';

  @override
  String get bulkPayments_totalAmount => 'Montant total';

  @override
  String bulkPayments_errorsFound(int count) {
    return '$count erreurs trouvées';
  }

  @override
  String get bulkPayments_fixErrors =>
      'Veuillez corriger les erreurs avant de soumettre';

  @override
  String get bulkPayments_showInvalidOnly =>
      'Afficher uniquement les invalides';

  @override
  String get bulkPayments_noPayments => 'Aucun paiement à afficher';

  @override
  String get bulkPayments_submitBatch => 'Soumettre le lot';

  @override
  String get bulkPayments_confirmSubmit => 'Confirmer la soumission du lot';

  @override
  String bulkPayments_confirmMessage(int count, String amount) {
    return 'Envoyer $count paiements pour un total de $amount?';
  }

  @override
  String get bulkPayments_submitSuccess => 'Lot soumis avec succès';

  @override
  String get bulkPayments_batchStatus => 'État du lot';

  @override
  String get bulkPayments_progress => 'Progression';

  @override
  String get bulkPayments_successful => 'Réussi';

  @override
  String get bulkPayments_pending => 'En attente';

  @override
  String get bulkPayments_details => 'Détails';

  @override
  String get bulkPayments_createdAt => 'Créé';

  @override
  String get bulkPayments_processedAt => 'Traité';

  @override
  String get bulkPayments_failedPayments => 'Paiements échoués';

  @override
  String get bulkPayments_failedDescription =>
      'Téléchargez un rapport des paiements échoués pour réessayer';

  @override
  String get bulkPayments_downloadReport => 'Télécharger le rapport';

  @override
  String get bulkPayments_failedReportTitle => 'Rapport des paiements échoués';

  @override
  String get bulkPayments_downloadFailed =>
      'Échec du téléchargement du rapport';

  @override
  String get bulkPayments_statusDraft => 'Brouillon';

  @override
  String get bulkPayments_statusPending => 'En attente';

  @override
  String get bulkPayments_statusProcessing => 'En cours de traitement';

  @override
  String get bulkPayments_statusCompleted => 'Terminé';

  @override
  String get bulkPayments_statusPartial => 'Partiellement terminé';

  @override
  String get bulkPayments_statusFailed => 'Échoué';

  @override
  String get expenses_title => 'Dépenses';

  @override
  String get expenses_emptyTitle => 'Aucune dépense pour le moment';

  @override
  String get expenses_emptyMessage =>
      'Commencez à suivre vos dépenses en capturant des reçus ou en les ajoutant manuellement';

  @override
  String get expenses_captureReceipt => 'Capturer un reçu';

  @override
  String get expenses_addManually => 'Ajouter manuellement';

  @override
  String get expenses_addExpense => 'Ajouter une dépense';

  @override
  String get expenses_totalExpenses => 'Total des dépenses';

  @override
  String get expenses_items => 'articles';

  @override
  String get expenses_category => 'Catégorie';

  @override
  String get expenses_amount => 'Montant';

  @override
  String get expenses_vendor => 'Fournisseur';

  @override
  String get expenses_date => 'Date';

  @override
  String get expenses_time => 'Heure';

  @override
  String get expenses_description => 'Description';

  @override
  String get expenses_categoryTravel => 'Voyage';

  @override
  String get expenses_categoryMeals => 'Repas';

  @override
  String get expenses_categoryOffice => 'Bureau';

  @override
  String get expenses_categoryTransport => 'Transport';

  @override
  String get expenses_categoryOther => 'Autre';

  @override
  String get expenses_errorAmountRequired => 'Le montant est requis';

  @override
  String get expenses_errorInvalidAmount => 'Montant invalide';

  @override
  String get expenses_addedSuccessfully => 'Dépense ajoutée avec succès';

  @override
  String get expenses_positionReceipt => 'Positionnez le reçu dans le cadre';

  @override
  String get expenses_receiptPreview => 'Aperçu du reçu';

  @override
  String get expenses_processingReceipt => 'Traitement du reçu en cours...';

  @override
  String get expenses_extractedData => 'Données extraites';

  @override
  String get expenses_confirmAndEdit => 'Confirmer et modifier';

  @override
  String get expenses_retake => 'Reprendre la photo';

  @override
  String get expenses_confirmDetails => 'Confirmer les détails';

  @override
  String get expenses_saveExpense => 'Enregistrer la dépense';

  @override
  String get expenses_expenseDetails => 'Détails de la dépense';

  @override
  String get expenses_details => 'Détails';

  @override
  String get expenses_linkedTransaction => 'Transaction liée';

  @override
  String get expenses_deleteExpense => 'Supprimer la dépense';

  @override
  String get expenses_deleteConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette dépense?';

  @override
  String get expenses_deletedSuccessfully => 'Dépense supprimée avec succès';

  @override
  String get expenses_reports => 'Rapports de dépenses';

  @override
  String get expenses_viewReports => 'Voir les rapports';

  @override
  String get expenses_reportPeriod => 'Période du rapport';

  @override
  String get expenses_startDate => 'Date de début';

  @override
  String get expenses_endDate => 'Date de fin';

  @override
  String get expenses_reportSummary => 'Résumé';

  @override
  String get expenses_averageExpense => 'Dépense moyenne';

  @override
  String get expenses_byCategory => 'Par catégorie';

  @override
  String get expenses_exportPdf => 'Exporter en PDF';

  @override
  String get expenses_exportCsv => 'Exporter en CSV';

  @override
  String get expenses_reportGenerated => 'Rapport généré avec succès';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_markAllRead => 'Marquer comme lu';

  @override
  String get notifications_emptyTitle => 'Aucune notification';

  @override
  String get notifications_emptyMessage => 'Vous êtes à jour!';

  @override
  String get notifications_errorTitle => 'Échec du chargement';

  @override
  String get notifications_errorGeneric => 'Une erreur s\'est produite';

  @override
  String get notifications_timeJustNow => 'À l\'instant';

  @override
  String notifications_timeMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Il y a ${countString}m';
  }

  @override
  String notifications_timeHoursAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Il y a ${countString}h';
  }

  @override
  String notifications_timeDaysAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Il y a ${countString}j';
  }

  @override
  String get security_title => 'Sécurité';

  @override
  String get security_authentication => 'Authentification';

  @override
  String get security_changePin => 'Changer le code PIN';

  @override
  String get security_changePinSubtitle =>
      'Mettre à jour votre code PIN à 4 chiffres';

  @override
  String get security_biometricLogin => 'Connexion biométrique';

  @override
  String get security_biometricSubtitle =>
      'Utiliser Face ID ou empreinte digitale';

  @override
  String get security_biometricNotAvailable =>
      'Non disponible sur cet appareil';

  @override
  String get security_biometricUnavailableMessage =>
      'L\'authentification biométrique n\'est pas disponible sur cet appareil';

  @override
  String get security_biometricVerifyReason =>
      'Vérifiez pour activer la connexion biométrique';

  @override
  String get security_loading => 'Chargement...';

  @override
  String get security_checkingAvailability =>
      'Vérification de la disponibilité...';

  @override
  String get security_errorLoadingState => 'Erreur de chargement de l\'état';

  @override
  String get security_errorCheckingAvailability =>
      'Erreur de vérification de la disponibilité';

  @override
  String get security_twoFactorAuth => 'Authentification à deux facteurs';

  @override
  String get security_twoFactorEnabledSubtitle =>
      'Activée via l\'application Authenticator';

  @override
  String get security_twoFactorDisabledSubtitle =>
      'Ajouter une protection supplémentaire';

  @override
  String get security_transactionSecurity => 'Sécurité des transactions';

  @override
  String get security_requirePinForTransactions =>
      'Exiger un code PIN pour les transactions';

  @override
  String get security_requirePinSubtitle =>
      'Confirmer toutes les transactions avec le code PIN';

  @override
  String get security_alerts => 'Alertes de sécurité';

  @override
  String get security_loginNotifications => 'Notifications de connexion';

  @override
  String get security_loginNotificationsSubtitle =>
      'Recevoir des notifications pour les nouvelles connexions';

  @override
  String get security_newDeviceAlerts => 'Alertes de nouvel appareil';

  @override
  String get security_newDeviceAlertsSubtitle =>
      'Alerte lorsqu\'un nouvel appareil est utilisé';

  @override
  String get security_sessions => 'Sessions';

  @override
  String get security_devices => 'Appareils';

  @override
  String get security_devicesSubtitle => 'Gérer vos appareils';

  @override
  String get security_activeSessions => 'Sessions actives';

  @override
  String get security_activeSessionsSubtitle => 'Gérer vos sessions actives';

  @override
  String get security_logoutAllDevices => 'Déconnecter tous les appareils';

  @override
  String get security_logoutAllDevicesSubtitle =>
      'Se déconnecter de tous les autres appareils';

  @override
  String get security_privacy => 'Confidentialité';

  @override
  String get security_loginHistory => 'Historique de connexion';

  @override
  String get security_loginHistorySubtitle =>
      'Voir l\'activité de connexion récente';

  @override
  String get security_deleteAccount => 'Supprimer le compte';

  @override
  String get security_deleteAccountSubtitle =>
      'Supprimer définitivement votre compte';

  @override
  String get security_scoreTitle => 'Score de sécurité';

  @override
  String get security_scoreExcellent =>
      'Excellent! Votre compte est bien protégé.';

  @override
  String get security_scoreGood =>
      'Bonne sécurité. Quelques améliorations possibles.';

  @override
  String get security_scoreModerate =>
      'Sécurité modérée. Activez plus de fonctionnalités.';

  @override
  String get security_scoreLow =>
      'Sécurité faible. Veuillez activer les fonctionnalités de protection.';

  @override
  String get security_tipEnable2FA =>
      'Activez 2FA pour augmenter votre score de 25 points';

  @override
  String get security_tipEnableBiometrics =>
      'Activez la biométrie pour une connexion sécurisée plus facile';

  @override
  String get security_tipRequirePin =>
      'Exigez un code PIN pour les transactions pour plus de sécurité';

  @override
  String get security_tipEnableNotifications =>
      'Activez toutes les notifications pour une sécurité maximale';

  @override
  String get security_setup2FATitle =>
      'Configurer l\'authentification à deux facteurs';

  @override
  String get security_setup2FAMessage =>
      'Utilisez une application d\'authentification comme Google Authenticator ou Authy pour une sécurité renforcée.';

  @override
  String get security_continueSetup => 'Continuer la configuration';

  @override
  String get security_2FAEnabledSuccess => '2FA activée avec succès';

  @override
  String get security_disable2FATitle => 'Désactiver 2FA?';

  @override
  String get security_disable2FAMessage =>
      'Cela rendra votre compte moins sécurisé. Êtes-vous sûr?';

  @override
  String get security_disable => 'Désactiver';

  @override
  String get security_logoutAllTitle => 'Déconnecter tous les appareils?';

  @override
  String get security_logoutAllMessage =>
      'Vous serez déconnecté de tous les autres appareils. Vous devrez vous reconnecter sur ces appareils.';

  @override
  String get security_logoutAll => 'Tout déconnecter';

  @override
  String get security_logoutAllSuccess =>
      'Tous les autres appareils ont été déconnectés';

  @override
  String get security_loginHistoryTitle => 'Historique de connexion';

  @override
  String get security_loginSuccess => 'Succès';

  @override
  String get security_loginFailed => 'Échec';

  @override
  String get security_deleteAccountTitle => 'Supprimer le compte?';

  @override
  String get security_deleteAccountMessage =>
      'Cette action est permanente et ne peut pas être annulée. Toutes vos données, l\'historique des transactions et les fonds seront perdus.';

  @override
  String get security_delete => 'Supprimer';

  @override
  String get biometric_enrollment_title => 'Sécurisez votre compte';

  @override
  String get biometric_enrollment_subtitle =>
      'Ajoutez une couche de sécurité supplémentaire avec l\'authentification biométrique';

  @override
  String get biometric_enrollment_enable =>
      'Activer l\'authentification biométrique';

  @override
  String get biometric_enrollment_skip => 'Ignorer pour l\'instant';

  @override
  String get biometric_enrollment_benefit_fast_title => 'Accès rapide';

  @override
  String get biometric_enrollment_benefit_fast_desc =>
      'Déverrouillez votre portefeuille instantanément sans saisir de code PIN';

  @override
  String get biometric_enrollment_benefit_secure_title => 'Sécurité renforcée';

  @override
  String get biometric_enrollment_benefit_secure_desc =>
      'Vos données biométriques uniques offrent une couche de sécurité supplémentaire';

  @override
  String get biometric_enrollment_benefit_convenient_title =>
      'Authentification pratique';

  @override
  String get biometric_enrollment_benefit_convenient_desc =>
      'Vérifiez rapidement les transactions et les actions sensibles';

  @override
  String get biometric_enrollment_authenticate_reason =>
      'Authentifiez-vous pour activer la connexion biométrique';

  @override
  String get biometric_enrollment_success_title => 'Biométrie activée !';

  @override
  String get biometric_enrollment_success_message =>
      'Vous pouvez maintenant utiliser l\'authentification biométrique pour accéder à votre portefeuille';

  @override
  String get biometric_enrollment_error_not_available =>
      'L\'authentification biométrique n\'est pas disponible sur cet appareil';

  @override
  String get biometric_enrollment_error_failed =>
      'L\'authentification biométrique a échoué. Veuillez réessayer';

  @override
  String get biometric_enrollment_error_generic =>
      'Échec de l\'activation de l\'authentification biométrique';

  @override
  String get biometric_enrollment_skip_confirm_title =>
      'Ignorer la configuration biométrique ?';

  @override
  String get biometric_enrollment_skip_confirm_message =>
      'Vous pouvez activer l\'authentification biométrique plus tard dans les paramètres';

  @override
  String get biometric_settings_title => 'Paramètres biométriques';

  @override
  String get biometric_settings_authentication => 'Authentification';

  @override
  String get biometric_settings_use_cases => 'Utiliser la biométrie pour';

  @override
  String get biometric_settings_advanced => 'Avancé';

  @override
  String get biometric_settings_actions => 'Actions';

  @override
  String get biometric_settings_status_enabled => 'Activé';

  @override
  String get biometric_settings_status_disabled => 'Désactivé';

  @override
  String get biometric_settings_active => 'Actif';

  @override
  String get biometric_settings_inactive => 'Inactif';

  @override
  String get biometric_settings_unavailable => 'Indisponible';

  @override
  String get biometric_settings_enabled_subtitle =>
      'L\'authentification biométrique est active';

  @override
  String get biometric_settings_disabled_subtitle =>
      'Activer pour utiliser l\'authentification biométrique';

  @override
  String get biometric_settings_app_unlock_title =>
      'Déverrouillage de l\'application';

  @override
  String get biometric_settings_app_unlock_subtitle =>
      'Utiliser la biométrie pour déverrouiller l\'application';

  @override
  String get biometric_settings_transactions_title =>
      'Confirmation de transaction';

  @override
  String get biometric_settings_transactions_subtitle =>
      'Vérifier les transactions avec la biométrie';

  @override
  String get biometric_settings_sensitive_title => 'Paramètres sensibles';

  @override
  String get biometric_settings_sensitive_subtitle =>
      'Protéger le changement de code PIN et les paramètres de sécurité';

  @override
  String get biometric_settings_view_balance_title => 'Afficher le solde';

  @override
  String get biometric_settings_view_balance_subtitle =>
      'Exiger la biométrie pour voir le solde du portefeuille';

  @override
  String get biometric_settings_timeout_title =>
      'Délai d\'expiration biométrique';

  @override
  String get biometric_settings_timeout_immediate =>
      'Immédiat (toujours requis)';

  @override
  String get biometric_settings_timeout_5min => '5 minutes';

  @override
  String get biometric_settings_timeout_15min => '15 minutes';

  @override
  String get biometric_settings_timeout_30min => '30 minutes';

  @override
  String biometric_settings_timeout_custom(String minutes) {
    return '$minutes minutes';
  }

  @override
  String get biometric_settings_timeout_select_title => 'Sélectionner le délai';

  @override
  String get biometric_settings_high_value_title => 'Seuil de valeur élevée';

  @override
  String biometric_settings_high_value_subtitle(String amount) {
    return 'Exiger biométrie + PIN pour les transferts supérieurs à \$$amount';
  }

  @override
  String get biometric_settings_threshold_select_title =>
      'Sélectionner le seuil';

  @override
  String get biometric_settings_reenroll_title => 'Réinscrire la biométrie';

  @override
  String get biometric_settings_reenroll_subtitle =>
      'Mettre à jour votre authentification biométrique';

  @override
  String get biometric_settings_reenroll_confirm_title =>
      'Réinscrire la biométrie ?';

  @override
  String get biometric_settings_reenroll_confirm_message =>
      'Votre configuration biométrique actuelle sera supprimée et vous devrez la configurer à nouveau';

  @override
  String get biometric_settings_fallback_title => 'Gérer le code PIN';

  @override
  String get biometric_settings_fallback_subtitle =>
      'Le code PIN est toujours disponible en secours';

  @override
  String get biometric_settings_disable_title => 'Désactiver la biométrie ?';

  @override
  String get biometric_settings_disable_message =>
      'Vous devrez utiliser votre code PIN pour vous authentifier à la place';

  @override
  String get biometric_settings_disable => 'Désactiver';

  @override
  String get biometric_settings_error_loading =>
      'Échec du chargement des paramètres biométriques';

  @override
  String get biometric_type_face_id => 'Face ID';

  @override
  String get biometric_type_fingerprint => 'Empreinte digitale';

  @override
  String get biometric_type_iris => 'Iris';

  @override
  String get biometric_type_none => 'Aucun';

  @override
  String get biometric_error_lockout =>
      'L\'authentification biométrique est temporairement verrouillée. Veuillez réessayer plus tard';

  @override
  String get biometric_error_not_enrolled =>
      'Aucune biométrie enregistrée sur cet appareil. Veuillez ajouter des données biométriques dans les paramètres de l\'appareil';

  @override
  String get biometric_error_hardware_unavailable =>
      'Le matériel biométrique n\'est pas disponible';

  @override
  String get biometric_change_detected_title =>
      'Changement biométrique détecté';

  @override
  String get biometric_change_detected_message =>
      'L\'enregistrement biométrique de l\'appareil a changé. Pour des raisons de sécurité, l\'authentification biométrique a été désactivée. Veuillez vous réinscrire si vous souhaitez continuer à l\'utiliser';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_kycStatus => 'Statut KYC';

  @override
  String get profile_country => 'Pays';

  @override
  String get profile_notSet => 'Non défini';

  @override
  String get profile_verify => 'Vérifier';

  @override
  String get profile_kycNotVerified => 'Non vérifié';

  @override
  String get profile_kycPending => 'En attente d\'examen';

  @override
  String get profile_kycVerified => 'Vérifié';

  @override
  String get profile_kycRejected => 'Rejeté';

  @override
  String get profile_countryIvoryCoast => 'Côte d\'Ivoire';

  @override
  String get profile_countryNigeria => 'Nigéria';

  @override
  String get profile_countryKenya => 'Kenya';

  @override
  String get profile_countryGhana => 'Ghana';

  @override
  String get profile_countrySenegal => 'Sénégal';

  @override
  String get changePin_title => 'Changer le code PIN';

  @override
  String get changePin_newPinTitle => 'Nouveau code PIN';

  @override
  String get changePin_confirmTitle => 'Confirmer le code PIN';

  @override
  String get changePin_enterCurrentPinTitle => 'Entrer le code PIN actuel';

  @override
  String get changePin_enterCurrentPinSubtitle =>
      'Entrez votre code PIN actuel à 4 chiffres pour continuer';

  @override
  String get changePin_createNewPinTitle => 'Créer un nouveau code PIN';

  @override
  String get changePin_createNewPinSubtitle =>
      'Choisissez un nouveau code PIN à 4 chiffres pour votre compte';

  @override
  String get changePin_confirmPinTitle => 'Confirmez votre code PIN';

  @override
  String get changePin_confirmPinSubtitle =>
      'Entrez à nouveau votre nouveau code PIN pour confirmer';

  @override
  String get changePin_errorBiometricRequired =>
      'Confirmation biométrique requise';

  @override
  String get changePin_errorIncorrectPin =>
      'Code PIN incorrect. Veuillez réessayer.';

  @override
  String get changePin_errorUnableToVerify =>
      'Impossible de vérifier le code PIN. Veuillez réessayer.';

  @override
  String get changePin_errorWeakPin =>
      'Le code PIN est trop simple. Choisissez un code PIN plus fort.';

  @override
  String get changePin_errorSameAsCurrentPin =>
      'Le nouveau code PIN doit être différent du code PIN actuel.';

  @override
  String get changePin_errorPinMismatch =>
      'Les codes PIN ne correspondent pas. Réessayez.';

  @override
  String get changePin_successMessage => 'Code PIN modifié avec succès!';

  @override
  String get changePin_errorFailedToSet =>
      'Échec de la définition du nouveau code PIN. Veuillez essayer un code PIN différent.';

  @override
  String get changePin_errorFailedToSave =>
      'Échec de l\'enregistrement du code PIN. Veuillez réessayer.';

  @override
  String get notifications_email => 'Notifications par email';

  @override
  String get notifications_emailReceipts => 'Reçus par email';

  @override
  String get notifications_emailReceiptsDescription =>
      'Recevoir les reçus de transaction par email';

  @override
  String get notifications_loadError =>
      'Échec du chargement des paramètres de notification';

  @override
  String get notifications_marketing => 'Marketing';

  @override
  String get notifications_marketingDescription =>
      'Offres promotionnelles et mises à jour';

  @override
  String get notifications_monthlyStatement => 'Relevé mensuel';

  @override
  String get notifications_monthlyStatementDescription =>
      'Recevoir le relevé de compte mensuel';

  @override
  String get notifications_newsletter => 'Newsletter';

  @override
  String get notifications_newsletterDescription =>
      'Actualités et mises à jour des produits';

  @override
  String get notifications_push => 'Notifications push';

  @override
  String get notifications_required => 'Requis';

  @override
  String get notifications_saveError =>
      'Échec de l\'enregistrement des préférences';

  @override
  String get notifications_savePreferences => 'Enregistrer les préférences';

  @override
  String get notifications_saveSuccess =>
      'Préférences enregistrées avec succès';

  @override
  String get notifications_security => 'Alertes de sécurité';

  @override
  String get notifications_securityCodes => 'Codes de sécurité';

  @override
  String get notifications_securityCodesDescription =>
      'Recevoir les codes de connexion et de vérification';

  @override
  String get notifications_securityDescription =>
      'Notifications de sécurité du compte';

  @override
  String get notifications_securityNote =>
      'Les notifications de sécurité ne peuvent pas être désactivées';

  @override
  String get notifications_sms => 'Notifications SMS';

  @override
  String get notifications_smsTransactions => 'Alertes de transaction';

  @override
  String get notifications_smsTransactionsDescription =>
      'Recevoir des SMS pour les transactions';

  @override
  String get notifications_transactions => 'Transactions';

  @override
  String get notifications_transactionsDescription =>
      'Recevoir des notifications pour les transferts et paiements';

  @override
  String get notifications_unsavedChanges => 'Modifications non enregistrées';

  @override
  String get notifications_unsavedChangesMessage =>
      'Vous avez des modifications non enregistrées. Les ignorer ?';

  @override
  String get help_callUs => 'Appelez-nous';

  @override
  String get help_emailUs => 'Envoyez-nous un email';

  @override
  String get help_getHelp => 'Obtenir de l\'aide';

  @override
  String get help_results => 'Résultats';

  @override
  String get help_searchPlaceholder => 'Rechercher des articles d\'aide...';

  @override
  String get action_discard => 'Ignorer';

  @override
  String get common_comingSoon => 'Bientôt disponible';

  @override
  String get common_maybeLater => 'Peut-être plus tard';

  @override
  String get common_optional => 'Optionnel';

  @override
  String get common_share => 'Partager';

  @override
  String get error_invalidNumber => 'Numéro invalide';

  @override
  String get export_title => 'Exporter';

  @override
  String get bankLinking_accountDetails => 'Détails du compte';

  @override
  String get bankLinking_accountHolderName => 'Nom du titulaire';

  @override
  String get bankLinking_accountHolderNameRequired =>
      'Le nom du titulaire est requis';

  @override
  String get bankLinking_accountNumber => 'Numéro de compte';

  @override
  String get bankLinking_accountNumberRequired =>
      'Le numéro de compte est requis';

  @override
  String get bankLinking_amount => 'Montant';

  @override
  String get bankLinking_amountRequired => 'Le montant est requis';

  @override
  String get bankLinking_balance => 'Solde';

  @override
  String get bankLinking_balanceCheck => 'Vérification du solde';

  @override
  String get bankLinking_confirmDeposit => 'Confirmer le dépôt';

  @override
  String get bankLinking_confirmWithdraw => 'Confirmer le retrait';

  @override
  String get bankLinking_deposit => 'Dépôt';

  @override
  String bankLinking_depositConfirmation(String amount) {
    return 'Déposer $amount depuis votre banque ?';
  }

  @override
  String get bankLinking_depositFromBank => 'Dépôt depuis la banque';

  @override
  String get bankLinking_depositInfo =>
      'Les fonds seront crédités sous 24 heures';

  @override
  String get bankLinking_depositSuccess => 'Dépôt réussi';

  @override
  String get bankLinking_devOtpHint => 'OTP dev: 123456';

  @override
  String get bankLinking_directDebit => 'Prélèvement automatique';

  @override
  String get bankLinking_enterAmount => 'Entrez le montant';

  @override
  String get bankLinking_failed => 'Échoué';

  @override
  String get bankLinking_invalidAmount => 'Montant invalide';

  @override
  String get bankLinking_invalidOtp => 'OTP invalide';

  @override
  String get bankLinking_linkAccount => 'Lier le compte';

  @override
  String get bankLinking_linkAccountDesc =>
      'Liez votre compte bancaire pour des transferts faciles';

  @override
  String get bankLinking_linkedAccounts => 'Comptes liés';

  @override
  String get bankLinking_linkFailed => 'Échec de la liaison du compte';

  @override
  String get bankLinking_linkNewAccount => 'Lier un nouveau compte';

  @override
  String get bankLinking_noLinkedAccounts => 'Aucun compte lié';

  @override
  String get bankLinking_otpCode => 'Code OTP';

  @override
  String get bankLinking_otpResent => 'OTP renvoyé';

  @override
  String get bankLinking_pending => 'En attente';

  @override
  String get bankLinking_primary => 'Principal';

  @override
  String get bankLinking_primaryAccountSet => 'Compte principal défini';

  @override
  String get bankLinking_resendOtp => 'Renvoyer l\'OTP';

  @override
  String bankLinking_resendOtpIn(int seconds) {
    return 'Renvoyer l\'OTP dans ${seconds}s';
  }

  @override
  String get bankLinking_selectBank => 'Sélectionner une banque';

  @override
  String get bankLinking_selectBankDesc => 'Choisissez votre banque à lier';

  @override
  String get bankLinking_selectBankTitle => 'Sélectionnez votre banque';

  @override
  String get bankLinking_suspended => 'Suspendu';

  @override
  String get bankLinking_verificationDesc =>
      'Entrez l\'OTP envoyé sur votre téléphone';

  @override
  String get bankLinking_verificationFailed => 'Vérification échouée';

  @override
  String get bankLinking_verificationRequired => 'Vérification requise';

  @override
  String get bankLinking_verificationSuccess => 'Compte vérifié';

  @override
  String get bankLinking_verificationTitle => 'Vérifier le compte';

  @override
  String get bankLinking_verified => 'Vérifié';

  @override
  String get bankLinking_verify => 'Vérifier';

  @override
  String get bankLinking_verifyAccount => 'Vérifier le compte';

  @override
  String get bankLinking_withdraw => 'Retrait';

  @override
  String bankLinking_withdrawConfirmation(String amount) {
    return 'Retirer $amount vers votre banque ?';
  }

  @override
  String get bankLinking_withdrawInfo =>
      'Les fonds arriveront sous 1-3 jours ouvrés';

  @override
  String get bankLinking_withdrawSuccess => 'Retrait réussi';

  @override
  String get bankLinking_withdrawTime =>
      'Délai de traitement: 1-3 jours ouvrés';

  @override
  String get bankLinking_withdrawToBank => 'Retrait vers la banque';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get expenses_totalAmount => 'Montant total';

  @override
  String get kyc_additionalDocs_title => 'Documents supplémentaires';

  @override
  String get kyc_additionalDocs_description =>
      'Fournir des informations supplémentaires pour vérification';

  @override
  String get kyc_additionalDocs_employment_title => 'Informations d\'emploi';

  @override
  String get kyc_additionalDocs_occupation => 'Profession';

  @override
  String get kyc_additionalDocs_employer => 'Employeur';

  @override
  String get kyc_additionalDocs_monthlyIncome => 'Revenu mensuel';

  @override
  String get kyc_additionalDocs_sourceOfFunds_title => 'Source des fonds';

  @override
  String get kyc_additionalDocs_sourceOfFunds_description =>
      'Parlez-nous de votre source de fonds';

  @override
  String get kyc_additionalDocs_sourceDetails => 'Détails de la source';

  @override
  String get kyc_additionalDocs_supportingDocs_title =>
      'Documents justificatifs';

  @override
  String get kyc_additionalDocs_supportingDocs_description =>
      'Télécharger des documents pour vérifier vos informations';

  @override
  String get kyc_additionalDocs_takePhoto => 'Prendre une photo';

  @override
  String get kyc_additionalDocs_uploadFile => 'Télécharger un fichier';

  @override
  String get kyc_additionalDocs_error => 'Échec de la soumission des documents';

  @override
  String get kyc_additionalDocs_info_title => 'Pourquoi nous en avons besoin';

  @override
  String get kyc_additionalDocs_info_description =>
      'Cela nous aide à vérifier votre identité';

  @override
  String get kyc_additionalDocs_submit => 'Soumettre les documents';

  @override
  String get kyc_additionalDocs_sourceType_salary => 'Salaire';

  @override
  String get kyc_additionalDocs_sourceType_business => 'Revenu d\'entreprise';

  @override
  String get kyc_additionalDocs_sourceType_investments => 'Investissements';

  @override
  String get kyc_additionalDocs_sourceType_savings => 'Épargne';

  @override
  String get kyc_additionalDocs_sourceType_inheritance => 'Héritage';

  @override
  String get kyc_additionalDocs_sourceType_gift => 'Don';

  @override
  String get kyc_additionalDocs_sourceType_other => 'Autre';

  @override
  String get kyc_additionalDocs_suggestion_paySlip => 'Bulletin de salaire';

  @override
  String get kyc_additionalDocs_suggestion_bankStatement => 'Relevé bancaire';

  @override
  String get kyc_additionalDocs_suggestion_businessReg =>
      'Enregistrement d\'entreprise';

  @override
  String get kyc_additionalDocs_suggestion_taxReturn => 'Déclaration d\'impôts';

  @override
  String get kyc_address_title => 'Vérification d\'adresse';

  @override
  String get kyc_address_description => 'Vérifiez votre adresse résidentielle';

  @override
  String get kyc_address_form_title => 'Votre adresse';

  @override
  String get kyc_address_addressLine1 => 'Adresse ligne 1';

  @override
  String get kyc_address_addressLine2 => 'Adresse ligne 2';

  @override
  String get kyc_address_city => 'Ville';

  @override
  String get kyc_address_state => 'État/Région';

  @override
  String get kyc_address_postalCode => 'Code postal';

  @override
  String get kyc_address_country => 'Pays';

  @override
  String get kyc_address_proofDocument_title => 'Justificatif de domicile';

  @override
  String get kyc_address_proofDocument_description =>
      'Télécharger un document indiquant votre adresse';

  @override
  String get kyc_address_takePhoto => 'Prendre une photo';

  @override
  String get kyc_address_retakePhoto => 'Reprendre une photo';

  @override
  String get kyc_address_chooseFile => 'Choisir un fichier';

  @override
  String get kyc_address_changeFile => 'Changer de fichier';

  @override
  String get kyc_address_uploadDocument => 'Télécharger le document';

  @override
  String get kyc_address_submit => 'Soumettre l\'adresse';

  @override
  String get kyc_address_error => 'Échec de la soumission de l\'adresse';

  @override
  String get kyc_address_info_title => 'Documents acceptés';

  @override
  String get kyc_address_info_description =>
      'Les documents doivent être datés de moins de 3 mois';

  @override
  String get kyc_address_docType_utilityBill => 'Facture de services publics';

  @override
  String get kyc_address_docType_utilityBill_description =>
      'Facture d\'électricité, d\'eau ou de gaz';

  @override
  String get kyc_address_docType_bankStatement => 'Relevé bancaire';

  @override
  String get kyc_address_docType_bankStatement_description =>
      'Relevé bancaire récent';

  @override
  String get kyc_address_docType_governmentLetter => 'Lettre du gouvernement';

  @override
  String get kyc_address_docType_governmentLetter_description =>
      'Correspondance officielle du gouvernement';

  @override
  String get kyc_address_docType_rentalAgreement => 'Contrat de location';

  @override
  String get kyc_address_docType_rentalAgreement_description =>
      'Contrat de location ou de bail signé';

  @override
  String get kyc_video_title => 'Vérification vidéo';

  @override
  String get kyc_video_instructions_title => 'Avant de commencer';

  @override
  String get kyc_video_instructions_description =>
      'Suivez ces directives pour de meilleurs résultats';

  @override
  String get kyc_video_instruction_lighting_title => 'Bon éclairage';

  @override
  String get kyc_video_instruction_lighting_description =>
      'Trouvez un endroit bien éclairé';

  @override
  String get kyc_video_instruction_position_title => 'Position du visage';

  @override
  String get kyc_video_instruction_position_description =>
      'Gardez votre visage dans le cadre';

  @override
  String get kyc_video_instruction_quiet_title => 'Environnement calme';

  @override
  String get kyc_video_instruction_quiet_description =>
      'Trouvez un endroit calme';

  @override
  String get kyc_video_instruction_solo_title => 'Soyez seul';

  @override
  String get kyc_video_instruction_solo_description =>
      'Seul vous devez être dans le cadre';

  @override
  String get kyc_video_actions_title => 'Suivez les instructions';

  @override
  String get kyc_video_actions_description =>
      'Complétez chaque action comme demandé';

  @override
  String get kyc_video_action_lookStraight => 'Regardez droit';

  @override
  String get kyc_video_action_turnLeft => 'Tournez à gauche';

  @override
  String get kyc_video_action_turnRight => 'Tournez à droite';

  @override
  String get kyc_video_action_smile => 'Souriez';

  @override
  String get kyc_video_action_blink => 'Clignez des yeux';

  @override
  String get kyc_video_startRecording => 'Commencer l\'enregistrement';

  @override
  String get kyc_video_continue => 'Continuer';

  @override
  String get kyc_video_preview_title => 'Aperçu';

  @override
  String get kyc_video_preview_description => 'Examinez votre vidéo';

  @override
  String get kyc_video_preview_videoRecorded => 'Vidéo enregistrée';

  @override
  String get kyc_video_retake => 'Recommencer';

  @override
  String get kyc_upgrade_title => 'Mise à niveau de vérification';

  @override
  String get kyc_upgrade_selectTier => 'Sélectionner le niveau';

  @override
  String get kyc_upgrade_selectTier_description =>
      'Choisissez votre niveau de vérification';

  @override
  String get kyc_upgrade_currentTier => 'Niveau actuel';

  @override
  String get kyc_upgrade_recommended => 'Recommandé';

  @override
  String get kyc_upgrade_perTransaction => 'Par transaction';

  @override
  String get kyc_upgrade_dailyLimit => 'Limite quotidienne';

  @override
  String get kyc_upgrade_monthlyLimit => 'Limite mensuelle';

  @override
  String get kyc_upgrade_andMore => 'et plus';

  @override
  String get kyc_upgrade_requirements_title => 'Exigences';

  @override
  String get kyc_upgrade_requirement_idDocument => 'Document d\'identité';

  @override
  String get kyc_upgrade_requirement_selfie => 'Selfie';

  @override
  String get kyc_upgrade_requirement_addressProof => 'Justificatif de domicile';

  @override
  String get kyc_upgrade_requirement_sourceOfFunds => 'Source des fonds';

  @override
  String get kyc_upgrade_requirement_videoVerification => 'Vérification vidéo';

  @override
  String get kyc_upgrade_startVerification => 'Commencer la vérification';

  @override
  String get kyc_upgrade_reason_title => 'Pourquoi mettre à niveau?';

  @override
  String get settings_deviceTrustedSuccess => 'Appareil marqué comme fiable';

  @override
  String get settings_deviceTrustError =>
      'Échec de la confiance de l\'appareil';

  @override
  String get settings_deviceRemovedSuccess => 'Appareil supprimé avec succès';

  @override
  String get settings_deviceRemoveError =>
      'Échec de la suppression de l\'appareil';

  @override
  String get settings_help => 'Aide et support';

  @override
  String get settings_rateApp => 'Noter Korido';

  @override
  String get settings_rateAppDescription =>
      'Vous aimez Korido? Notez-nous sur l\'App Store';

  @override
  String get action_copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get transfer_successTitle => 'Transfert réussi!';

  @override
  String transfer_successMessage(String amount) {
    return 'Votre transfert de $amount a réussi';
  }

  @override
  String get transactions_transactionId => 'ID de transaction';

  @override
  String get common_amount => 'Montant';

  @override
  String get transactions_status => 'Statut';

  @override
  String get transactions_completed => 'Terminé';

  @override
  String get transactions_noAccountTitle => 'Aucun Portefeuille';

  @override
  String get transactions_noAccountMessage =>
      'Créez votre portefeuille pour commencer à suivre vos transactions et votre historique de paiements.';

  @override
  String get transactions_connectionErrorTitle => 'Impossible de Charger';

  @override
  String get transactions_connectionErrorMessage =>
      'Veuillez vérifier votre connexion internet et réessayer.';

  @override
  String get transactions_emptyStateTitle => 'Aucune Transaction';

  @override
  String get transactions_emptyStateMessage =>
      'Une fois que vous effectuez votre premier dépôt ou transfert, votre historique de transactions apparaîtra ici.';

  @override
  String get transactions_emptyStateAction => 'Faire un Premier Dépôt';

  @override
  String get common_note => 'Note';

  @override
  String get action_shareReceipt => 'Partager le reçu';

  @override
  String get withdraw_mobileMoney => 'Mobile Money';

  @override
  String get withdraw_bankTransfer => 'Virement bancaire';

  @override
  String get withdraw_crypto => 'Portefeuille crypto';

  @override
  String get withdraw_mobileMoneyDesc => 'Retirer vers Orange Money, MTN, Wave';

  @override
  String get withdraw_bankDesc => 'Transférer vers votre compte bancaire';

  @override
  String get withdraw_cryptoDesc => 'Envoyer vers un portefeuille externe';

  @override
  String get navigation_withdraw => 'Retirer';

  @override
  String get withdraw_method => 'Méthode de retrait';

  @override
  String get withdraw_processingInfo =>
      'Les délais de traitement varient selon la méthode';

  @override
  String get withdraw_amountLabel => 'Montant à retirer';

  @override
  String get withdraw_mobileNumber => 'Numéro Mobile Money';

  @override
  String get withdraw_bankDetails => 'Coordonnées bancaires';

  @override
  String get withdraw_walletAddress => 'Adresse du portefeuille';

  @override
  String get withdraw_networkWarning =>
      'Assurez-vous d\'envoyer vers une adresse Solana USDC';

  @override
  String get legal_cookiePolicy => 'Politique de cookies';

  @override
  String get legal_effectiveDate => 'En vigueur depuis';

  @override
  String get legal_whatsNew => 'Nouveautes';

  @override
  String get legal_contactUs => 'Nous contacter';

  @override
  String get legal_cookieContactDescription =>
      'Si vous avez des questions sur notre politique de cookies, veuillez nous contacter:';

  @override
  String get legal_cookieCategories => 'Categories de cookies';

  @override
  String get legal_essential => 'Essentiels';

  @override
  String get legal_functional => 'Fonctionnels';

  @override
  String get legal_analytics => 'Analytiques';

  @override
  String get legal_required => 'Requis';

  @override
  String get legal_cookiePolicyDescription =>
      'Consulter notre politique d\'utilisation des cookies';

  @override
  String get legal_legalDocuments => 'Documents juridiques';

  @override
  String get error_loadFailed => 'Echec du chargement';

  @override
  String get error_tryAgainLater => 'Veuillez reessayer plus tard';

  @override
  String get error_timeout =>
      'La requête a expiré. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get error_noInternet =>
      'Aucune connexion Internet. Veuillez vérifier votre réseau et réessayer.';

  @override
  String get error_requestCancelled => 'La requête a été annulée';

  @override
  String get error_sslError =>
      'Erreur de sécurité de connexion. Veuillez réessayer.';

  @override
  String get error_otpExpired =>
      'Le code de vérification a expiré. Demandez un nouveau code.';

  @override
  String get error_tooManyOtpAttempts =>
      'Trop de tentatives échouées. Veuillez attendre avant de réessayer.';

  @override
  String get error_invalidCredentials =>
      'Identifiants invalides. Veuillez vérifier et réessayer.';

  @override
  String get error_accountLocked =>
      'Votre compte a été verrouillé. Veuillez contacter le support.';

  @override
  String get error_accountSuspended =>
      'Votre compte a été suspendu. Veuillez contacter le support pour assistance.';

  @override
  String get error_sessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get error_kycRequired =>
      'Vérification d\'identité requise pour continuer. Complétez la vérification dans les paramètres.';

  @override
  String get error_kycPending =>
      'Votre vérification d\'identité est en cours d\'examen. Veuillez patienter.';

  @override
  String get error_kycRejected =>
      'Votre vérification d\'identité a été rejetée. Veuillez soumettre à nouveau avec des documents valides.';

  @override
  String get error_kycExpired =>
      'Votre vérification d\'identité a expiré. Veuillez vérifier à nouveau.';

  @override
  String get error_amountTooLow =>
      'Le montant est inférieur au minimum. Veuillez saisir un montant plus élevé.';

  @override
  String get error_amountTooHigh =>
      'Le montant dépasse le maximum. Veuillez saisir un montant inférieur.';

  @override
  String get error_dailyLimitExceeded =>
      'Limite de transaction quotidienne atteinte. Réessayez demain ou améliorez votre compte.';

  @override
  String get error_monthlyLimitExceeded =>
      'Limite de transaction mensuelle atteinte. Veuillez patienter ou améliorer votre compte.';

  @override
  String get error_transactionLimitExceeded =>
      'Limite de transaction dépassée pour cette opération.';

  @override
  String get error_duplicateTransaction =>
      'Cette transaction a déjà été traitée. Veuillez vérifier votre historique.';

  @override
  String get error_pinLocked =>
      'PIN verrouillé en raison de trop de tentatives incorrectes. Réinitialisez votre PIN pour continuer.';

  @override
  String get error_pinTooWeak =>
      'Le PIN est trop simple. Veuillez choisir un PIN plus fort.';

  @override
  String get error_beneficiaryNotFound =>
      'Bénéficiaire non trouvé. Veuillez vérifier et réessayer.';

  @override
  String get error_beneficiaryLimitReached =>
      'Nombre maximum de bénéficiaires atteint. Supprimez-en un pour ajouter un nouveau bénéficiaire.';

  @override
  String get error_providerUnavailable =>
      'Le fournisseur de services est actuellement indisponible. Veuillez réessayer plus tard.';

  @override
  String get error_providerTimeout =>
      'Le fournisseur de services ne répond pas. Veuillez réessayer.';

  @override
  String get error_providerMaintenance =>
      'Le fournisseur de services est en maintenance. Veuillez réessayer plus tard.';

  @override
  String get error_rateLimited =>
      'Trop de requêtes. Veuillez ralentir et réessayer dans un instant.';

  @override
  String get error_invalidAddress =>
      'Adresse de portefeuille invalide. Veuillez vérifier et réessayer.';

  @override
  String get error_invalidCountry => 'Service non disponible dans votre pays.';

  @override
  String get error_deviceNotTrusted =>
      'Cet appareil n\'est pas de confiance. Veuillez vérifier votre identité.';

  @override
  String get error_deviceLimitReached =>
      'Nombre maximum d\'appareils atteint. Supprimez un appareil pour ajouter celui-ci.';

  @override
  String get error_biometricRequired =>
      'L\'authentification biométrique est requise pour cette action.';

  @override
  String get error_badRequest =>
      'Requête invalide. Veuillez vérifier vos informations et réessayer.';

  @override
  String get error_unauthorized =>
      'Authentification requise. Veuillez vous reconnecter.';

  @override
  String get error_accessDenied =>
      'Vous n\'avez pas la permission d\'effectuer cette action.';

  @override
  String get error_notFound => 'Ressource demandée non trouvée.';

  @override
  String get error_conflict =>
      'La requête entre en conflit avec l\'état actuel. Veuillez actualiser et réessayer.';

  @override
  String get error_validationFailed =>
      'Veuillez vérifier les informations que vous avez fournies et réessayer.';

  @override
  String get error_serverError =>
      'Erreur du serveur. Notre équipe a été informée. Veuillez réessayer plus tard.';

  @override
  String get error_serviceUnavailable =>
      'Service temporairement indisponible. Veuillez réessayer dans quelques instants.';

  @override
  String get error_gatewayTimeout =>
      'Le service met trop de temps à répondre. Veuillez réessayer.';

  @override
  String get error_authenticationFailed =>
      'Authentification échouée. Veuillez réessayer.';

  @override
  String get error_suggestion_checkConnection =>
      'Vérifiez votre connexion Internet';

  @override
  String get error_suggestion_tryAgain => 'Réessayer';

  @override
  String get error_suggestion_loginAgain => 'Connectez-vous à nouveau';

  @override
  String get error_suggestion_completeKyc => 'Complétez la vérification';

  @override
  String get error_suggestion_addFunds =>
      'Ajoutez des fonds à votre portefeuille';

  @override
  String get error_suggestion_waitOrUpgrade =>
      'Attendez ou améliorez votre compte';

  @override
  String get error_suggestion_tryLater => 'Réessayez plus tard';

  @override
  String get error_suggestion_resetPin => 'Réinitialisez votre PIN';

  @override
  String get error_suggestion_slowDown => 'Ralentissez et attendez un instant';

  @override
  String get error_offline_title => 'Vous êtes hors ligne';

  @override
  String get error_offline_message =>
      'Vous n\'êtes pas connecté à Internet. Certaines fonctionnalités peuvent ne pas être disponibles.';

  @override
  String get error_offline_retry => 'Réessayer la connexion';

  @override
  String get action_skip => 'Passer';

  @override
  String get action_next => 'Suivant';

  @override
  String get onboarding_page1_title => 'Votre argent, à votre façon';

  @override
  String get onboarding_page1_description =>
      'Stockez, envoyez et recevez des USDC en toute sécurité. Votre portefeuille numérique conçu pour l\'Afrique de l\'Ouest.';

  @override
  String get onboarding_page1_feature1 => 'Stockez vos USDC en toute sécurité';

  @override
  String get onboarding_page1_feature2 => 'Envoyez de l\'argent instantanément';

  @override
  String get onboarding_page1_feature3 => 'Accédez à vos fonds 24h/24 et 7j/7';

  @override
  String get onboarding_page2_title => 'Transferts ultra-rapides';

  @override
  String get onboarding_page2_description =>
      'Transférez des fonds à vos proches en quelques secondes. Sans frontières, sans délais.';

  @override
  String get onboarding_page2_feature1 =>
      'Transferts instantanés au sein de Korido';

  @override
  String get onboarding_page2_feature2 =>
      'Envoyez vers n\'importe quel compte Mobile Money';

  @override
  String get onboarding_page2_feature3 =>
      'Mises à jour des transactions en temps réel';

  @override
  String get onboarding_page3_title => 'Dépôts et retraits faciles';

  @override
  String get onboarding_page3_description =>
      'Ajoutez de l\'argent via Mobile Money. Retirez sur votre compte local à tout moment.';

  @override
  String get onboarding_page3_feature1 => 'Dépôts avec Orange Money, MTN, Wave';

  @override
  String get onboarding_page3_feature2 => 'Frais de transaction faibles (1%)';

  @override
  String get onboarding_page3_feature3 =>
      'Retirez à tout moment sur votre compte';

  @override
  String get onboarding_page4_title => 'Sécurité bancaire';

  @override
  String get onboarding_page4_description =>
      'Vos fonds sont protégés par un chiffrement de pointe et une authentification biométrique.';

  @override
  String get onboarding_page4_feature1 =>
      'Protection par code PIN et biométrie';

  @override
  String get onboarding_page4_feature2 => 'Chiffrement de bout en bout';

  @override
  String get onboarding_page4_feature3 =>
      'Surveillance anti-fraude 24h/24 et 7j/7';

  @override
  String welcome_title(String name) {
    return 'Bienvenue, $name !';
  }

  @override
  String get welcome_subtitle =>
      'Votre portefeuille Korido est prêt. Commencez à envoyer et recevoir de l\'argent dès aujourd\'hui !';

  @override
  String get welcome_addFunds => 'Ajouter des fonds';

  @override
  String get welcome_exploreDashboard => 'Explorer le tableau de bord';

  @override
  String get welcome_stat_wallet => 'Portefeuille sécurisé';

  @override
  String get welcome_stat_wallet_desc => 'Vos fonds sont en sécurité avec nous';

  @override
  String get welcome_stat_instant => 'Transferts instantanés';

  @override
  String get welcome_stat_instant_desc =>
      'Envoyez de l\'argent en quelques secondes';

  @override
  String get welcome_stat_secure => 'Sécurité bancaire';

  @override
  String get welcome_stat_secure_desc => 'Protégé par chiffrement avancé';

  @override
  String get onboarding_deposit_prompt_title =>
      'Commencez avec votre premier dépôt';

  @override
  String get onboarding_deposit_prompt_subtitle =>
      'Ajoutez des fonds pour commencer à envoyer et recevoir de l\'argent';

  @override
  String get onboarding_deposit_benefit1 =>
      'Dépôts instantanés via Mobile Money';

  @override
  String get onboarding_deposit_benefit2 =>
      'Seulement 1% de frais de transaction';

  @override
  String get onboarding_deposit_benefit3 => 'Fonds disponibles immédiatement';

  @override
  String get onboarding_deposit_cta => 'Ajouter de l\'argent maintenant';

  @override
  String get help_whatIsUsdc => 'Qu\'est-ce que l\'USDC ?';

  @override
  String get help_usdc_title => 'USDC : Dollar numérique';

  @override
  String get help_usdc_subtitle => 'La monnaie numérique stable';

  @override
  String get help_usdc_what_title => 'Qu\'est-ce que l\'USDC ?';

  @override
  String get help_usdc_what_description =>
      'L\'USDC (USD Coin) est une monnaie numérique qui vaut toujours exactement 1\$ USD. Elle combine la stabilité du dollar américain avec la rapidité et l\'efficacité de la technologie blockchain.';

  @override
  String get help_usdc_why_title => 'Pourquoi utiliser l\'USDC ?';

  @override
  String get help_usdc_benefit1_title => 'Valeur stable';

  @override
  String get help_usdc_benefit1_description =>
      'Toujours égal à 1\$ USD - aucune volatilité';

  @override
  String get help_usdc_benefit2_title => 'Sécurisé et transparent';

  @override
  String get help_usdc_benefit2_description =>
      'Adossé 1:1 à de vrais dollars américains détenus en réserve';

  @override
  String get help_usdc_benefit3_title => 'Accès mondial';

  @override
  String get help_usdc_benefit3_description =>
      'Envoyez de l\'argent partout dans le monde instantanément';

  @override
  String get help_usdc_benefit4_title => 'Disponibilité 24h/24 et 7j/7';

  @override
  String get help_usdc_benefit4_description =>
      'Accédez à votre argent à tout moment, n\'importe où';

  @override
  String get help_usdc_how_title => 'Comment ça marche';

  @override
  String get help_usdc_how_description =>
      'Lorsque vous déposez de l\'argent, il est converti en USDC à un taux de 1:1 avec l\'USD. Vous pouvez ensuite envoyer des USDC à n\'importe qui ou les reconvertir dans votre monnaie locale à tout moment.';

  @override
  String get help_usdc_safety_title => 'Est-ce sûr ?';

  @override
  String get help_usdc_safety_description =>
      'Oui ! L\'USDC est émis par Circle, une institution financière réglementée. Chaque USDC est adossé à de vrais dollars américains détenus dans des comptes de réserve.';

  @override
  String get help_howDepositsWork => 'Comment fonctionnent les dépôts';

  @override
  String get help_deposits_header =>
      'Ajouter de l\'argent à votre portefeuille';

  @override
  String get help_deposits_intro =>
      'Déposer des fonds sur votre portefeuille Korido est rapide et facile grâce aux services Mobile Money disponibles à travers l\'Afrique de l\'Ouest.';

  @override
  String get help_deposits_steps_title => 'Comment déposer';

  @override
  String get help_deposits_step1_title => 'Choisir le montant';

  @override
  String get help_deposits_step1_description =>
      'Entrez le montant que vous souhaitez ajouter à votre portefeuille';

  @override
  String get help_deposits_step2_title => 'Sélectionner le fournisseur';

  @override
  String get help_deposits_step2_description =>
      'Choisissez votre fournisseur Mobile Money (Orange Money, MTN, etc.)';

  @override
  String get help_deposits_step3_title => 'Finaliser le paiement';

  @override
  String get help_deposits_step3_description =>
      'Suivez l\'invite USSD sur votre téléphone pour autoriser le paiement';

  @override
  String get help_deposits_step4_title => 'Fonds ajoutés';

  @override
  String get help_deposits_step4_description =>
      'Votre solde USDC est mis à jour en quelques secondes';

  @override
  String get help_deposits_providers_title => 'Fournisseurs pris en charge';

  @override
  String get help_deposits_time_title => 'Temps de traitement';

  @override
  String get help_deposits_time_description =>
      'La plupart des dépôts sont traités en 1-2 minutes';

  @override
  String get help_deposits_faq_title => 'Questions fréquentes';

  @override
  String get help_deposits_faq1_question => 'Quel est le dépôt minimum ?';

  @override
  String get help_deposits_faq1_answer =>
      'Le dépôt minimum est de 1 000 XOF (environ 1,60\$ USD)';

  @override
  String get help_deposits_faq2_question => 'Y a-t-il des frais ?';

  @override
  String get help_deposits_faq2_answer =>
      'Oui, il y a des frais de transaction de 1% sur les dépôts';

  @override
  String get help_deposits_faq3_question =>
      'Que se passe-t-il si mon dépôt échoue ?';

  @override
  String get help_deposits_faq3_answer =>
      'Votre argent sera automatiquement remboursé sur votre compte Mobile Money dans les 24 heures';

  @override
  String get help_transactionFees => 'Frais de transaction';

  @override
  String get help_fees_no_hidden_title => 'Pas de frais cachés';

  @override
  String get help_fees_no_hidden_description =>
      'Nous croyons en la transparence. Voici exactement ce que vous payez.';

  @override
  String get help_fees_breakdown_title => 'Détail des frais';

  @override
  String get help_fees_internal_transfers =>
      'Transferts vers les utilisateurs Korido';

  @override
  String get help_fees_free => 'GRATUIT';

  @override
  String get help_fees_internal_description =>
      'Envoyez de l\'argent à d\'autres utilisateurs Korido sans frais';

  @override
  String get help_fees_deposits => 'Dépôts Mobile Money';

  @override
  String get help_fees_deposits_amount => '1%';

  @override
  String get help_fees_deposits_description =>
      'Frais de 1% lors de l\'ajout de fonds via Mobile Money';

  @override
  String get help_fees_withdrawals => 'Retraits vers Mobile Money';

  @override
  String get help_fees_withdrawals_amount => '1%';

  @override
  String get help_fees_withdrawals_description =>
      'Frais de 1% lors du retrait vers Mobile Money';

  @override
  String get help_fees_external_transfers => 'Transferts crypto externes';

  @override
  String get help_fees_external_amount => 'Frais de réseau';

  @override
  String get help_fees_external_description =>
      'Des frais de réseau blockchain s\'appliquent (varient selon le réseau)';

  @override
  String get help_fees_why_title => 'Pourquoi facturons-nous des frais ?';

  @override
  String get help_fees_why_description => 'Nos frais nous aident à :';

  @override
  String get help_fees_why_point1 =>
      'Maintenir une infrastructure sécurisée et conforme';

  @override
  String get help_fees_why_point2 =>
      'Fournir une assistance client 24h/24 et 7j/7';

  @override
  String get help_fees_why_point3 =>
      'Couvrir les frais des fournisseurs Mobile Money';

  @override
  String get help_fees_why_point4 => 'Continuer à améliorer nos services';

  @override
  String get help_fees_comparison_title => 'Notre comparaison';

  @override
  String get help_fees_comparison_description =>
      'Nos frais sont nettement inférieurs à ceux des services de transfert d\'argent traditionnels :';

  @override
  String get help_fees_comparison_traditional => 'Services traditionnels';

  @override
  String get help_fees_comparison_joonapay => 'Korido';

  @override
  String get offline_banner_title => 'Vous êtes hors ligne';

  @override
  String offline_banner_last_sync(String time) {
    return 'Dernière synchro $time';
  }

  @override
  String get offline_banner_syncing => 'Synchronisation des opérations...';

  @override
  String get offline_banner_reconnected =>
      'De retour en ligne ! Tout est synchronisé.';

  @override
  String get state_otpExpired => 'Code OTP expiré';

  @override
  String get state_otpExpiredDescription =>
      'Votre mot de passe à usage unique a expiré. Veuillez demander un nouveau code.';

  @override
  String get state_tokenRefreshing => 'Actualisation de votre accès...';

  @override
  String get state_accountLocked => 'Compte verrouillé';

  @override
  String get state_accountLockedDescription =>
      'Votre compte a été verrouillé suite à plusieurs tentatives échouées. Veuillez réessayer plus tard.';

  @override
  String get state_accountSuspended => 'Compte suspendu';

  @override
  String get state_accountSuspendedDescription =>
      'Votre compte a été suspendu. Veuillez contacter l\'assistance pour plus d\'informations.';

  @override
  String get state_walletFrozen => 'Portefeuille gelé';

  @override
  String get state_walletFrozenDescription =>
      'Votre portefeuille a été gelé pour des raisons de sécurité. Veuillez contacter l\'assistance.';

  @override
  String get state_walletUnderReview => 'Portefeuille en révision';

  @override
  String get state_walletUnderReviewDescription =>
      'Votre portefeuille est actuellement en révision. Les transactions sont temporairement restreintes.';

  @override
  String get state_walletLimited => 'Portefeuille limité';

  @override
  String get state_walletLimitedDescription =>
      'Votre portefeuille a atteint sa limite de transactions ou de solde. Mettez à niveau votre compte pour augmenter les limites.';

  @override
  String get state_kycExpired => 'Vérification KYC expirée';

  @override
  String get state_kycExpiredDescription =>
      'Votre vérification d\'identité a expiré. Veuillez mettre à jour vos informations pour continuer.';

  @override
  String get state_kycManualReview => 'Examen manuel du KYC en attente';

  @override
  String get state_kycManualReviewDescription =>
      'Votre vérification d\'identité est actuellement examinée manuellement. Cela peut prendre 24 à 48 heures.';

  @override
  String get state_kycUpgrading => 'Niveau KYC en cours de mise à niveau';

  @override
  String get state_kycUpgradingDescription =>
      'Votre niveau de vérification d\'identité est en cours de mise à niveau. Veuillez patienter.';

  @override
  String get state_biometricPrompt => 'Authentification biométrique requise';

  @override
  String get state_biometricPromptDescription =>
      'Veuillez utiliser votre empreinte digitale ou votre visage pour vous authentifier.';

  @override
  String get state_deviceChanged => 'Vérification d\'appareil requise';

  @override
  String get state_deviceChangedDescription =>
      'Cela semble être un nouvel appareil. Veuillez vérifier votre identité pour continuer.';

  @override
  String get state_sessionConflict => 'Une autre session est active';

  @override
  String get state_sessionConflictDescription =>
      'Vous êtes connecté sur un autre appareil. Veuillez vous déconnecter là-bas ou continuer ici.';

  @override
  String get auth_lockedReason =>
      'Votre compte a été temporairement verrouillé en raison de plusieurs tentatives échouées';

  @override
  String get auth_accountLocked => 'Compte temporairement verrouillé';

  @override
  String get auth_tryAgainIn => 'Réessayez dans';

  @override
  String get common_backToLogin => 'Retour à la connexion';

  @override
  String get auth_suspendedReason =>
      'Votre compte a été suspendu. Veuillez contacter le support pour plus d\'informations.';

  @override
  String get auth_accountSuspended => 'Compte suspendu';

  @override
  String get auth_suspendedUntil => 'Suspendu jusqu\'au';

  @override
  String get auth_contactSupport => 'Besoin d\'aide ?';

  @override
  String get auth_suspendedContactMessage =>
      'Si vous pensez qu\'il s\'agit d\'une erreur, veuillez contacter notre équipe d\'assistance.';

  @override
  String get common_contactSupport => 'Contacter le support';

  @override
  String get biometric_authenticateReason => 'Authentifiez-vous pour continuer';

  @override
  String get biometric_promptReason =>
      'Veuillez utiliser votre empreinte digitale ou votre visage pour vous authentifier';

  @override
  String get biometric_promptTitle => 'Authentification biométrique';

  @override
  String get biometric_tryAgain => 'Réessayer';

  @override
  String get biometric_usePinInstead => 'Utiliser le code PIN';

  @override
  String get auth_otpExpired => 'Code OTP expiré';

  @override
  String get auth_otpExpiredMessage =>
      'Votre code de vérification a expiré. Veuillez demander un nouveau code.';

  @override
  String get session_locked => 'Session verrouillée';

  @override
  String get session_lockedMessage =>
      'Votre session a été verrouillée. Veuillez entrer votre code PIN pour continuer.';

  @override
  String get session_enterPinToUnlock =>
      'Entrez le code PIN pour déverrouiller';

  @override
  String get session_useBiometric => 'Utiliser la biométrie';

  @override
  String get session_unlockReason =>
      'Déverrouillez votre session pour continuer';

  @override
  String get session_expiring => 'Session expirante';

  @override
  String session_expiringMessage(int seconds) {
    return 'Votre session expirera dans $seconds secondes en raison d\'inactivité.';
  }

  @override
  String get session_stayLoggedIn => 'Rester connecté';

  @override
  String get device_newDeviceDetected => 'Nouvel appareil détecté';

  @override
  String get device_verificationRequired =>
      'Nous avons détecté un nouvel appareil. Veuillez vérifier votre identité pour continuer à utiliser Korido.';

  @override
  String get device_deviceId => 'ID de l\'appareil';

  @override
  String get device_verificationOptions => 'Options de vérification';

  @override
  String get device_verificationOptionsDesc =>
      'Choisissez comment vous souhaitez vérifier cet appareil';

  @override
  String get device_verifyWithOtp => 'Vérifier avec un code SMS';

  @override
  String get device_verifyWithEmail => 'Vérifier avec un e-mail';

  @override
  String get session_conflict => 'Session active détectée';

  @override
  String get session_conflictMessage =>
      'Vous êtes actuellement connecté sur un autre appareil. Vous pouvez continuer ici, ce qui vous déconnectera de l\'autre appareil.';

  @override
  String get session_otherDevice => 'Autre appareil';

  @override
  String get session_forceLogoutWarning =>
      'Continuer ici mettra fin à votre session sur l\'autre appareil.';

  @override
  String get session_continueHere => 'Continuer ici';

  @override
  String get wallet_frozenReason =>
      'Votre portefeuille a été gelé. Veuillez contacter le support pour plus d\'informations.';

  @override
  String get wallet_frozen => 'Portefeuille gelé';

  @override
  String get wallet_frozenTitle => 'Portefeuille temporairement gelé';

  @override
  String get wallet_frozenUntil => 'Gelé jusqu\'au';

  @override
  String get wallet_frozenContactSupport => 'Contacter le support';

  @override
  String get wallet_frozenContactMessage =>
      'Notre équipe d\'assistance peut vous aider à comprendre pourquoi votre portefeuille a été gelé et les étapes à suivre.';

  @override
  String get common_backToHome => 'Retour à l\'accueil';

  @override
  String get wallet_underReviewReason =>
      'Votre portefeuille est en cours d\'examen de conformité. Vous serez informé une fois l\'examen terminé.';

  @override
  String get wallet_underReview => 'En cours d\'examen';

  @override
  String get wallet_underReviewTitle => 'Portefeuille en cours d\'examen';

  @override
  String get wallet_reviewStatus => 'État de l\'examen';

  @override
  String get wallet_reviewStarted => 'Commencé';

  @override
  String get wallet_estimatedTime => 'Temps estimé';

  @override
  String get wallet_reviewEstimate => '24-48 heures';

  @override
  String get wallet_whileUnderReview => 'Pendant l\'examen';

  @override
  String get wallet_reviewRestriction1 =>
      'Les dépôts sont temporairement désactivés';

  @override
  String get wallet_reviewRestriction2 =>
      'Les retraits sont temporairement désactivés';

  @override
  String get wallet_reviewRestriction3 =>
      'Vous pouvez consulter votre solde et l\'historique des transactions';

  @override
  String get wallet_checkStatus => 'Vérifier l\'état';

  @override
  String get kyc_expired => 'KYC expiré';

  @override
  String get kyc_expiredTitle => 'Documents d\'identité expirés';

  @override
  String get kyc_expiredMessage =>
      'Vos documents de vérification d\'identité ont expiré. Veuillez les renouveler pour continuer à utiliser toutes les fonctionnalités.';

  @override
  String get kyc_expiredOn => 'Expiré le';

  @override
  String get kyc_renewalRequired => 'Renouvellement requis';

  @override
  String get kyc_renewalMessage =>
      'Pour restaurer l\'accès complet à votre portefeuille, veuillez mettre à jour vos documents d\'identité.';

  @override
  String get kyc_currentRestrictions => 'Restrictions actuelles';

  @override
  String get kyc_restriction1 => 'Montants de transaction limités';

  @override
  String get kyc_restriction2 =>
      'Certaines fonctionnalités peuvent être indisponibles';

  @override
  String get kyc_restriction3 => 'Les retraits peuvent être restreints';

  @override
  String get kyc_renewDocuments => 'Renouveler les documents';

  @override
  String get kyc_remindLater => 'Me le rappeler plus tard';

  @override
  String get action_backToHome => 'Retour à l\'accueil';

  @override
  String get action_checkStatus => 'Vérifier le statut';

  @override
  String get action_ok => 'OK';

  @override
  String get common_errorTryAgain =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get common_loading => 'Chargement...';

  @override
  String get common_unknownError => 'Une erreur inconnue est survenue';

  @override
  String get deposit_amount => 'Montant';

  @override
  String get deposit_approveOnPhone =>
      'Approuvez le paiement sur votre téléphone en saisissant votre code PIN';

  @override
  String get deposit_balanceUpdated => 'Votre solde a été mis à jour';

  @override
  String get deposit_cardPaymentComingSoon =>
      'Paiement par carte bientôt disponible';

  @override
  String get deposit_choosePaymentMethod => 'Choisir le mode de paiement';

  @override
  String get deposit_dialUSSD =>
      'Composez le code USSD ci-dessous pour obtenir votre OTP';

  @override
  String get deposit_enterOTP => 'Entrer le code OTP';

  @override
  String deposit_errorReason(String reason) {
    return 'Erreur : $reason';
  }

  @override
  String get deposit_failedDesc => 'Votre dépôt n\'a pas pu être effectué';

  @override
  String get deposit_failedTitle => 'Dépôt échoué';

  @override
  String get deposit_noDepositData => 'Aucune donnée de dépôt disponible';

  @override
  String get deposit_noProvidersAvailable => 'Aucun fournisseur disponible';

  @override
  String get deposit_noProvidersAvailableDesc =>
      'Aucun fournisseur de dépôt n\'est actuellement disponible. Veuillez réessayer plus tard.';

  @override
  String get deposit_openInWave => 'Ouvrir dans Wave';

  @override
  String get deposit_orScanQR => 'Ou scannez le code QR ci-dessous';

  @override
  String get deposit_payment => 'Paiement';

  @override
  String get deposit_processingDesc =>
      'Nous traitons votre dépôt. Cela peut prendre un moment.';

  @override
  String get deposit_processingSubtitle =>
      'Veuillez patienter pendant la vérification de votre paiement';

  @override
  String get deposit_processingTitle => 'Dépôt en cours';

  @override
  String get deposit_scanQRCode => 'Scanner le code QR';

  @override
  String get deposit_selectHowToDeposit => 'Sélectionnez comment déposer';

  @override
  String get deposit_submitOTP => 'Valider le code OTP';

  @override
  String get deposit_successDesc => 'Votre dépôt a été effectué avec succès';

  @override
  String get deposit_successTitle => 'Dépôt réussi';

  @override
  String get deposit_waitingForApproval =>
      'En attente d\'approbation sur votre téléphone';

  @override
  String get deposit_waitingForPayment => 'En attente de paiement';

  @override
  String get deposit_youPay => 'Vous payez';

  @override
  String get deposit_youReceive => 'Vous recevez';

  @override
  String airtime_billPaymentSuccess(Object amount) {
    return 'Paiement de facture de \$$amount réussi !';
  }

  @override
  String airtime_providerSelected(Object provider) {
    return 'Fournisseur $provider sélectionné';
  }

  @override
  String airtime_purchaseSuccess(Object amount) {
    return 'Crédit de \$$amount acheté avec succès !';
  }

  @override
  String get analytics_failedToLoad => 'Impossible de charger les analyses';

  @override
  String get analytics_monthlyTotal => 'Total mensuel';

  @override
  String get bankLinking_accounts => 'Comptes bancaires';

  @override
  String get bankLinking_enterCode => 'Saisissez le code de vérification';

  @override
  String get bankLinking_linkSuccess => 'Compte bancaire lié avec succès';

  @override
  String get beneficiaries_addError =>
      'Impossible d\'ajouter le bénéficiaire. Veuillez réessayer.';

  @override
  String get beneficiaries_deleteConfirm => 'Supprimer le destinataire ?';

  @override
  String get beneficiaries_failedToAdd =>
      'Impossible d\'ajouter le destinataire';

  @override
  String get beneficiaries_failedToDelete =>
      'Impossible de supprimer le contact';

  @override
  String get beneficiaries_failedToUpdateFavorite =>
      'Impossible de mettre à jour le favori';

  @override
  String get beneficiaries_recipientAdded => 'Destinataire ajouté';

  @override
  String get beneficiaries_recipientRemoved => 'Destinataire supprimé';

  @override
  String get billPayments_category => 'Catégorie';

  @override
  String get billPayments_paymentComplete => 'Paiement effectué';

  @override
  String get budget_categoryAdded => 'Catégorie ajoutée';

  @override
  String get budget_deleteCategory => 'Supprimer la catégorie ?';

  @override
  String get budget_tapCategoryToEdit =>
      'Appuyez sur une catégorie pour modifier son budget';

  @override
  String bulkPayments_error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get bulkPayments_fileLoadError =>
      'Impossible de charger le fichier. Veuillez réessayer.';

  @override
  String get cards_blockError =>
      'Impossible de bloquer la carte. Veuillez réessayer.';

  @override
  String get cards_cardCreated => 'Carte créée avec succès';

  @override
  String get cards_cardType => 'Type de carte';

  @override
  String get cards_createCard => 'Créer la carte';

  @override
  String get cards_createError =>
      'Impossible de créer la carte. Veuillez réessayer.';

  @override
  String cards_error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get cards_myCards => 'Mes cartes';

  @override
  String get cards_newCard => 'Nouvelle carte';

  @override
  String get common_copy => 'Copier';

  @override
  String get common_default => 'Par défaut';

  @override
  String common_errorFormat(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get common_genericError =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get common_recent => 'Récent';

  @override
  String get common_seeAll => 'Voir tout';

  @override
  String get common_status => 'Statut';

  @override
  String get common_tooManyAttempts =>
      'Trop de tentatives incorrectes. Veuillez réessayer plus tard.';

  @override
  String get common_type => 'Type';

  @override
  String get contacts_allContacts => 'Tous les contacts';

  @override
  String contacts_error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get contacts_favorites => 'Favoris';

  @override
  String get deviceVerification_failed => 'Vérification échouée';

  @override
  String get expenses_captureError =>
      'Erreur lors de la capture. Veuillez réessayer.';

  @override
  String get expenses_receiptProcessError =>
      'Erreur lors du traitement du reçu. Veuillez réessayer.';

  @override
  String expenses_reportError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get expenses_saveError =>
      'Impossible d\'enregistrer la dépense. Veuillez réessayer.';

  @override
  String insights_error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get kyc_cameraInitFailed => 'Échec de l\'initialisation de la caméra';

  @override
  String get kyc_completeLivenessFirst =>
      'Veuillez d\'abord compléter la vérification de vivacité';

  @override
  String kyc_completeVerification(Object limit) {
    return 'Complétez la vérification pour augmenter votre limite quotidienne à \$$limit';
  }

  @override
  String get kyc_documentType => 'Type de document';

  @override
  String get kyc_documentsSubmitted => 'Documents soumis';

  @override
  String get kyc_failedToPickImage => 'Impossible de sélectionner l\'image';

  @override
  String get kyc_failedToSubmit =>
      'Impossible de soumettre la vérification KYC';

  @override
  String get kyc_failedToTakeSelfie => 'Impossible de prendre le selfie';

  @override
  String kyc_livenessCheckFailed(Object reason) {
    return 'Vérification de vivacité échouée : $reason';
  }

  @override
  String get kyc_livenessCheckPassed =>
      'Vérification de vivacité réussie ! Vous pouvez maintenant prendre votre selfie.';

  @override
  String get kyc_submit => 'Soumettre';

  @override
  String get kyc_takeSelfie => 'Prenez un selfie';

  @override
  String get kyc_verificationProcessing =>
      'Votre vérification sera traitée sous 24-48h.';

  @override
  String get kyc_verify => 'Vérifier';

  @override
  String limits_error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get limits_maxPerTransaction => 'Max par transaction';

  @override
  String get limits_transactionLimits => 'Limites de transaction';

  @override
  String get liveness_goBack => 'Retour';

  @override
  String get liveness_title => 'Vérification de vivacité';

  @override
  String get liveness_tryAgain => 'Réessayer';

  @override
  String get merchant_dashboard => 'Tableau de bord marchand';

  @override
  String get merchant_myQrCode => 'Mon code QR';

  @override
  String get merchant_requestPayment => 'Demande de paiement';

  @override
  String get merchant_scanToPay => 'Scannez pour me payer';

  @override
  String get merchant_shareQr => 'Partager le code QR';

  @override
  String get paymentLinks_copied => 'Lien copié';

  @override
  String get paymentLinks_create => 'Créer un lien de paiement';

  @override
  String paymentLinks_error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get paymentLinks_generate => 'Générer le lien';

  @override
  String get paymentLinks_ready => 'Lien de paiement prêt';

  @override
  String get paymentLinks_singleUse => 'Usage unique';

  @override
  String get paymentLinks_singleUseDescription =>
      'Le lien expire après un paiement';

  @override
  String get profile_completion => 'Complétion du profil';

  @override
  String get profile_setName => 'Définir votre nom';

  @override
  String get qr_failedToScan =>
      'Impossible de scanner le code QR depuis l\'image';

  @override
  String get qr_failedToShare => 'Impossible de partager le code QR';

  @override
  String get qr_myCode => 'Mon code QR';

  @override
  String get qr_noCodeFound => 'Aucun code QR trouvé dans l\'image';

  @override
  String get qr_receive => 'Recevoir';

  @override
  String get qr_scanToPay => 'Scannez pour me payer';

  @override
  String get qr_shareCode => 'Partager le code QR';

  @override
  String get receipts_enterEmailAddress => 'Saisissez l\'adresse e-mail';

  @override
  String get receipts_receiptView => 'Reçu';

  @override
  String get receipts_referenceNumberCopied => 'Numéro de référence copié';

  @override
  String get recurringTransfers_createTransfer => 'Créer le transfert';

  @override
  String get recurringTransfers_created => 'Transfert récurrent créé';

  @override
  String referrals_error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get referrals_yourReferrals => 'Vos parrainages';

  @override
  String get savingsGoals_created => 'Objectif créé avec succès !';

  @override
  String get savingsGoals_deleteConfirm => 'Supprimer l\'objectif ?';

  @override
  String get savingsGoals_deleted => 'Objectif supprimé';

  @override
  String get savingsGoals_setTargetDate => 'Définir la date cible (optionnel)';

  @override
  String get savingsGoals_totalSavings => 'Épargne totale';

  @override
  String get savingsPots_createPot => 'Créer la cagnotte';

  @override
  String savingsPots_error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get scheduledTransfers_created => 'Programme créé avec succès !';

  @override
  String get scheduledTransfers_deleted => 'Programme supprimé';

  @override
  String get security_account => 'Compte';

  @override
  String get security_autoLock => 'Verrouillage automatique';

  @override
  String get security_autoLockAfter => 'Verrouillage après';

  @override
  String security_autoLockMinutes(Object minutes) {
    return 'Après $minutes minutes d\'inactivité';
  }

  @override
  String get security_manageDevices => 'Gérer les appareils';

  @override
  String security_minutesFormat(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String get security_pinOnAppOpen => 'Exiger le PIN à l\'ouverture';

  @override
  String get security_pinOnAppOpenSubtitle =>
      'Exiger le PIN à chaque ouverture de l\'application';

  @override
  String get security_screenshotProtection =>
      'Protection des captures d\'écran';

  @override
  String get security_screenshotProtectionSubtitle =>
      'Empêcher les captures d\'écran sur les écrans sensibles';

  @override
  String get security_transactionAlerts => 'Alertes de transaction';

  @override
  String get security_transactionAlertsSubtitle =>
      'Être notifié pour chaque transaction';

  @override
  String get send_searchRecipient => 'Rechercher un destinataire';

  @override
  String get settings_activeDevices => 'Appareils actifs';

  @override
  String get settings_approve => 'Approuver';

  @override
  String get settings_chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get settings_connectingToSupport =>
      'Connexion à un agent de support...';

  @override
  String get settings_copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get settings_failedToUpdateProfile =>
      'Impossible de mettre à jour le profil';

  @override
  String get settings_improveAnswer => 'Nous améliorerons cette réponse';

  @override
  String get settings_openingLiveChat => 'Ouverture du chat en direct...';

  @override
  String settings_openingUrl(Object url) {
    return 'Ouverture : $url';
  }

  @override
  String get settings_openingWhatsApp => 'Ouverture de WhatsApp...';

  @override
  String get settings_performanceMonitor => 'Moniteur de performance';

  @override
  String get settings_problemReported =>
      'Problème signalé. Nous reviendrons vers vous bientôt.';

  @override
  String get settings_profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get settings_takePhoto => 'Prendre une photo';

  @override
  String get settings_thanksFeedback => 'Merci pour votre retour !';

  @override
  String get settings_verificationFailed =>
      'La vérification a échoué. Veuillez réessayer.';

  @override
  String splitBill_requestsSent(Object count) {
    return 'Demandes de paiement envoyées à $count personnes';
  }

  @override
  String get subBusiness_view => 'Voir';

  @override
  String get transactions_export => 'Exporter les transactions';

  @override
  String get transactions_exportAsCsv => 'Exporter en CSV';

  @override
  String transactions_exported(Object format) {
    return 'Transactions exportées en $format';
  }

  @override
  String get transactions_noTransactionsYet =>
      'Aucune transaction pour le moment';

  @override
  String get transactions_viewTransaction => 'Voir la transaction';

  @override
  String get wallet_insufficientBalance => 'Solde insuffisant';

  @override
  String wallet_pending(Object amount) {
    return 'En attente : \$$amount';
  }

  @override
  String get withdraw_comingSoon =>
      'Fonctionnalité de retrait bientôt disponible';

  @override
  String get withdraw_failed => 'Le retrait a échoué. Veuillez réessayer.';

  @override
  String get withdraw_initiated => 'Retrait initié';

  @override
  String get auth_useBiometric => 'Utiliser la biométrie';
}
