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

  // ── Auth Biometric ──
  static const unlockKorido = 'Déverrouiller Korido'; // Unlock Korido
  static const authenticateToAccess = 'Authentifiez-vous pour accéder à Korido'; // Authenticate to access Korido
  static const sessionExpiredRelogin = 'Session expirée. Veuillez vous reconnecter.'; // Session expired. Please log in again.
  static const authenticating = 'Authentification...'; // Authenticating...
  static const tapToUnlock = 'Appuyez pour déverrouiller'; // Tap to unlock
  static const usePhoneInstead = 'Utiliser le numéro de téléphone'; // Use phone number instead

  // ── Legal ──
  static const termsOfService = 'Conditions d\'utilisation'; // Terms of Service
  static const privacyPolicy = 'Politique de confidentialité'; // Privacy Policy
  static const failedToLoadDocument = 'Impossible de charger le document'; // Failed to load document
  static const tryAgainLater = 'Veuillez réessayer plus tard'; // Please try again later
  static const whatsNew = 'Nouveautés'; // What's New
  static const legalAgreements = 'Accords juridiques'; // Legal Agreements
  static const reviewTermsPrompt = 'Veuillez lire et accepter nos conditions pour continuer'; // Please review and accept our terms to continue
  static const acceptTermsDisclaimer = 'En appuyant sur Accepter, vous acceptez nos Conditions d\'utilisation et reconnaissez notre Politique de confidentialité'; // By tapping Accept...
  static const acceptAndContinue = 'Accepter et continuer'; // Accept & Continue
  static const effective = 'En vigueur'; // Effective

  // ── Wallet Home ──
  static const settingUpWallet = 'Configuration de votre portefeuille...'; // Setting up your wallet...
  static const onlyTakeAMoment = 'Cela ne prendra qu\'un instant'; // This will only take a moment
  static const depositLabel = 'Dépôt'; // Deposit
  static const withdrawalLabel = 'Retrait'; // Withdrawal
  static const transferReceived = 'Transfert reçu'; // Transfer Received
  static const transferSent = 'Transfert envoyé'; // Transfer Sent

  // ── Deposit ──
  static const depositFunds = 'Déposer des fonds'; // Deposit Funds
  static const selectPaymentMethod = 'Choisir le mode de paiement'; // Select Payment Method
  static const amountToDeposit = 'Montant à déposer'; // Amount to deposit
  static const continueLabel = 'Continuer'; // Continue
  static const paymentInstructions = 'Instructions de paiement'; // Payment Instructions
  static const pendingPayment = 'Paiement en attente'; // Pending Payment
  static const completePaymentPrompt = 'Effectuez le paiement pour alimenter votre portefeuille'; // Complete the payment...
  static const amountToPay = 'Montant à payer'; // Amount to Pay
  static const youWillReceive = 'Vous recevrez environ'; // You will receive ~

  // ── Bill Pay ──
  static const payBills = 'Payer les factures'; // Pay Bills
  static const selectCategory = 'Choisir une catégorie'; // Select Category
  static const accountMeterNumber = 'Numéro de compte/compteur'; // Account/Meter Number
  static const amountLabel = 'Montant'; // Amount

  // ── Scan ──
  static const scanQrCode = 'Scanner le code QR'; // Scan QR Code
  static const invalidQrCode = 'Code QR invalide. Veuillez scanner un code de paiement Korido.'; // Invalid QR code...
  static const shareQrToReceive = 'Partagez ce code QR pour recevoir des paiements'; // Share this QR code...
  static const anyoneCanScan = 'Toute personne ayant Korido peut scanner ce code pour vous envoyer de l\'argent.'; // Anyone with Korido...
  static const qrSavedToGallery = 'Code QR enregistré dans la galerie'; // QR code saved to gallery
  static const failedToSaveQr = 'Impossible d\'enregistrer le code QR'; // Failed to save QR code

  // ── Budget ──
  static const monthlyBudget = 'Budget mensuel'; // Monthly Budget
  static const spent = 'Dépensé'; // Spent
  static const remaining = 'Restant'; // Remaining
  static const dailyBudget = 'Budget quotidien'; // Daily Budget
  static const budgetCategories = 'Catégories de budget'; // Budget Categories
  static const budgetInsights = 'Aperçu du budget'; // Budget Insights
  static const budgetingTips = 'Conseils de budget'; // Budgeting Tips
  static const addBudgetCategory = 'Ajouter une catégorie'; // Add Budget Category

  // ── Airtime ──
  static const buyAirtime = 'Acheter du crédit'; // Buy Airtime
  static const airtime = 'Crédit'; // Airtime
  static const dataBundles = 'Forfaits data'; // Data Bundles
  static const selectNetwork = 'Choisir un réseau'; // Select Network
  static const processing = 'Traitement...'; // Processing...

  // ── Virtual Card ──
  static const virtualCardTitle = 'Carte virtuelle'; // Virtual Card
  static const virtualDebitCard = 'Carte de débit virtuelle'; // Virtual Debit Card

  // ── Request Money ──
  static const requestAmount = 'Montant demandé'; // Request Amount
  static const addNote = 'Ajouter une note (optionnel)'; // Add a Note (Optional)
  static const generateRequest = 'Générer la demande'; // Generate Request
  static const copyLink = 'Copier le lien'; // Copy Link
  static const share = 'Partager'; // Share
  static const createNewRequest = 'Nouvelle demande'; // Create New Request
  static const howItWorks = 'Comment ça marche'; // How it works

  // ── Saved Recipients ──
  static const all = 'Tous'; // All
  static const favorites = 'Favoris'; // Favorites
  static const noResultsFound = 'Aucun résultat trouvé'; // No results found
  static const noRecipientsFound = 'Aucun destinataire trouvé'; // No recipients found
  static const addRecipient = 'Ajouter un destinataire'; // Add Recipient
  static const failedToLoadContacts = 'Impossible de charger les contacts'; // Failed to load contacts
  static const favoriteUpdated = 'Favori mis à jour'; // Favorite updated
  static const failedToUpdateFavorite = 'Impossible de mettre à jour le favori'; // Failed to update favorite

  // ── Savings Goals ──
  static const savingsGoals = 'Objectifs d\'épargne'; // Savings Goals
  static const yourGoals = 'Vos objectifs'; // Your Goals
  static const newGoal = 'Nouvel objectif'; // New Goal
  static const totalSaved = 'Total épargné'; // Total Saved
  static const available = 'Disponible'; // Available
  static const autoSaving = 'Épargne automatique'; // Auto-Saving

  // ── Scheduled Transfers ──
  static const scheduledTransfers = 'Transferts programmés'; // Scheduled Transfers
  static const newSchedule = 'Nouveau programme'; // New Schedule
  static const noScheduledTransfers = 'Aucun transfert programmé'; // No Scheduled Transfers
  static const setupRecurring = 'Configurez des transferts récurrents automatiques pour gagner du temps.'; // Set up automatic recurring transfers...

  // ── Split Bill ──
  static const totalBillAmount = 'Montant total de la facture'; // Total Bill Amount
  static const whatsThisFor = 'C\'est pour quoi ?'; // What's this for?
  static const sending = 'Envoi...'; // Sending...
  static const sendPaymentRequests = 'Envoyer les demandes de paiement'; // Send Payment Requests
  static const splitEqually = 'Partager également'; // Split Equally
  static const customAmounts = 'Montants personnalisés'; // Custom Amounts
  static const includeMyselfInSplit = 'M\'inclure dans le partage'; // Include myself in the split
  static const splitWith = 'Partager avec'; // Split With
  static const addPerson = 'Ajouter une personne'; // Add Person
  static const you = 'Vous'; // You
  static const yourShare = 'Votre part'; // Your share

  // ── Withdraw ──
  static const confirmWithdrawal = 'Confirmer le retrait'; // Confirm Withdrawal
  static const enterPinToWithdraw = 'Entrez votre PIN pour retirer les fonds'; // Enter your PIN to withdraw funds
  static const withdrawalSubmitted = 'Demande de retrait soumise avec succès !'; // Withdrawal request submitted successfully!
  static const withdrawalProcessingTime = 'Les retraits sont généralement traités sous 1 à 3 jours ouvrables. Des frais peuvent s\'appliquer.'; // Withdrawals typically process...
  static const bankName = 'Nom de la banque'; // Bank Name
  static const accountNumber = 'Numéro de compte'; // Account Number

  // ── Errors ──
  static const networkError = 'Erreur de connexion. Vérifiez votre internet.'; // Network error
  static const serverError = 'Erreur serveur. Réessayez plus tard.'; // Server error
  static const sessionExpired = 'Session expirée. Veuillez vous reconnecter.'; // Session expired
  static const insufficientFunds = 'Solde insuffisant'; // Insufficient funds
  static const dailyLimitReached = 'Limite journalière atteinte'; // Daily limit reached
  static const genericError = 'Une erreur est survenue'; // An error occurred
}
