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
  String get language_english => 'Anglais';

  @override
  String get language_french => 'Français';

  @override
  String get language_selectLanguage => 'Sélectionner la langue';

  @override
  String get language_changeLanguage => 'Changer de langue';
}
