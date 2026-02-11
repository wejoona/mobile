/// Centralized user-facing strings for localization.
///
/// All strings here are in French (primary market: Cote d'Ivoire).
/// English fallbacks are provided as comments.
abstract class AppStrings {
  // ── General ──
  static const appName = 'Korido';
  static const ok = 'OK';
  static const cancel = 'Annuler'; // Cancel
  static const save = 'Enregistrer'; // Save
  static const delete = 'Supprimer'; // Delete
  static const edit = 'Modifier'; // Edit
  static const close = 'Fermer'; // Close
  static const retry = 'Réessayer'; // Retry
  static const loading = 'Chargement...'; // Loading...
  static const error = 'Erreur'; // Error
  static const success = 'Succès'; // Success
  static const confirm = 'Confirmer'; // Confirm
  static const next = 'Suivant'; // Next
  static const back = 'Retour'; // Back
  static const done = 'Terminé'; // Done
  static const search = 'Rechercher'; // Search
  static const noResults = 'Aucun résultat'; // No results
  static const seeAll = 'Voir tout'; // See all

  // ── Auth ──
  static const login = 'Connexion'; // Login
  static const loginSubtitle = 'Entrez votre numéro de téléphone'; // Enter your phone number
  static const phoneNumber = 'Numéro de téléphone'; // Phone number
  static const enterOtp = 'Entrez le code OTP'; // Enter OTP code
  static const otpSent = 'Code envoyé au'; // Code sent to
  static const resendOtp = 'Renvoyer le code'; // Resend code
  static const verifyOtp = 'Vérifier'; // Verify

  // ── PIN ──
  static const enterPin = 'Entrez votre PIN'; // Enter your PIN
  static const createPin = 'Créez votre PIN'; // Create your PIN
  static const confirmPin = 'Confirmez votre PIN'; // Confirm your PIN
  static const pinMismatch = 'Les PINs ne correspondent pas'; // PINs don\'t match
  static const forgotPin = 'PIN oublié ?'; // Forgot PIN?

  // ── Wallet ──
  static const wallet = 'Portefeuille'; // Wallet
  static const balance = 'Solde'; // Balance
  static const send = 'Envoyer'; // Send
  static const receive = 'Recevoir'; // Receive
  static const deposit = 'Dépôt'; // Deposit
  static const withdraw = 'Retrait'; // Withdraw
  static const transactions = 'Transactions';
  static const noTransactions = 'Aucune transaction'; // No transactions
  static const recentTransactions = 'Transactions récentes'; // Recent transactions

  // ── Send ──
  static const sendMoney = 'Envoyer de l\'argent'; // Send money
  static const recipient = 'Destinataire'; // Recipient
  static const amount = 'Montant'; // Amount
  static const note = 'Note';
  static const fee = 'Frais'; // Fee
  static const total = 'Total';
  static const transferSuccessful = 'Transfert réussi'; // Transfer successful
  static const transferFailed = 'Transfert échoué'; // Transfer failed

  // ── Deposit ──
  static const depositAmount = 'Montant du dépôt'; // Deposit amount
  static const selectProvider = 'Choisir un opérateur'; // Select provider
  static const orangeMoney = 'Orange Money';
  static const mtnMomo = 'MTN MoMo';
  static const moovMoney = 'Moov Money';
  static const wave = 'Wave';
  static const bankTransfer = 'Virement bancaire'; // Bank transfer

  // ── Cards ──
  static const cards = 'Cartes'; // Cards
  static const virtualCard = 'Carte virtuelle'; // Virtual card
  static const physicalCard = 'Carte physique'; // Physical card
  static const freezeCard = 'Geler la carte'; // Freeze card
  static const unfreezeCard = 'Dégeler la carte'; // Unfreeze card

  // ── Savings ──
  static const savingsPots = 'Cagnottes'; // Savings pots
  static const createPot = 'Créer une cagnotte'; // Create a pot
  static const potName = 'Nom de la cagnotte'; // Pot name
  static const targetAmount = 'Objectif'; // Target amount
  static const depositToPot = 'Alimenter'; // Deposit to pot
  static const withdrawFromPot = 'Retirer'; // Withdraw from pot

  // ── Bill Payments ──
  static const billPayments = 'Paiement de factures'; // Bill payments
  static const electricity = 'Électricité'; // Electricity
  static const water = 'Eau'; // Water
  static const internet = 'Internet';
  static const television = 'Télévision'; // Television
  static const payBill = 'Payer la facture'; // Pay bill

  // ── Settings ──
  static const settings = 'Paramètres'; // Settings
  static const profile = 'Profil'; // Profile
  static const security = 'Sécurité'; // Security
  static const notifications = 'Notifications';
  static const language = 'Langue'; // Language
  static const theme = 'Thème'; // Theme
  static const about = 'À propos'; // About
  static const logout = 'Déconnexion'; // Logout
  static const logoutConfirm = 'Voulez-vous vraiment vous déconnecter ?'; // Are you sure?

  // ── KYC ──
  static const kycVerification = 'Vérification d\'identité'; // Identity verification
  static const kycPending = 'En cours de vérification'; // Verification pending
  static const kycVerified = 'Vérifié'; // Verified
  static const kycRejected = 'Rejeté'; // Rejected

  // ── Errors ──
  static const networkError = 'Erreur de connexion. Vérifiez votre internet.'; // Network error
  static const serverError = 'Erreur serveur. Réessayez plus tard.'; // Server error
  static const sessionExpired = 'Session expirée. Veuillez vous reconnecter.'; // Session expired
  static const insufficientFunds = 'Solde insuffisant'; // Insufficient funds
  static const dailyLimitReached = 'Limite journalière atteinte'; // Daily limit reached
  static const genericError = 'Une erreur est survenue'; // An error occurred
}
