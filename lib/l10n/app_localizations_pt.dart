// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Korido';

  @override
  String get navigation_home => 'Início';

  @override
  String get navigation_settings => 'Definições';

  @override
  String get navigation_send => 'Enviar';

  @override
  String get navigation_receive => 'Receber';

  @override
  String get navigation_transactions => 'Transações';

  @override
  String get navigation_services => 'Serviços';

  @override
  String get action_continue => 'Continuar';

  @override
  String get action_cancel => 'Cancelar';

  @override
  String get action_confirm => 'Confirmar';

  @override
  String get action_back => 'Voltar';

  @override
  String get action_submit => 'Submeter';

  @override
  String get action_done => 'Concluído';

  @override
  String get action_save => 'Guardar';

  @override
  String get action_edit => 'Editar';

  @override
  String get action_copy => 'Copiar';

  @override
  String get action_share => 'Partilhar';

  @override
  String get action_scan => 'Digitalizar';

  @override
  String get action_retry => 'Tentar novamente';

  @override
  String get action_clearAll => 'Limpar tudo';

  @override
  String get action_clearFilters => 'Limpar filtros';

  @override
  String get action_clear => 'Limpar';

  @override
  String get action_tryAgain => 'Tentar novamente';

  @override
  String get action_remove => 'Remover';

  @override
  String get auth_login => 'Entrar';

  @override
  String get auth_verify => 'Verificar';

  @override
  String get auth_enterOtp => 'Inserir código OTP';

  @override
  String get auth_phoneNumber => 'Número de telefone';

  @override
  String get auth_pin => 'Código PIN';

  @override
  String get auth_logout => 'Sair';

  @override
  String get auth_logoutConfirm => 'Tem a certeza que deseja sair?';

  @override
  String get auth_welcomeBack => 'Bem-vindo de volta';

  @override
  String get auth_createWallet => 'Crie a sua carteira USDC';

  @override
  String get auth_createAccount => 'Criar conta';

  @override
  String get auth_alreadyHaveAccount => 'Já tem uma conta? ';

  @override
  String get auth_dontHaveAccount => 'Não tem uma conta? ';

  @override
  String get auth_signIn => 'Entrar';

  @override
  String get auth_signUp => 'Registar';

  @override
  String get auth_country => 'País';

  @override
  String get auth_selectCountry => 'Selecionar país';

  @override
  String get auth_searchCountry => 'Pesquisar país...';

  @override
  String auth_enterDigits(int count) {
    return 'Inserir $count dígitos';
  }

  @override
  String get auth_termsPrompt => 'Ao continuar, concorda com os nossos';

  @override
  String get auth_termsOfService => 'Termos de serviço';

  @override
  String get auth_privacyPolicy => 'Política de privacidade';

  @override
  String get auth_and => ' e ';

  @override
  String get auth_secureLogin => 'Login seguro';

  @override
  String auth_otpMessage(String phone) {
    return 'Insira o código de 6 dígitos enviado para $phone';
  }

  @override
  String get auth_waitingForSms => 'A aguardar SMS...';

  @override
  String get auth_resendCode => 'Reenviar código';

  @override
  String get auth_phoneInvalid =>
      'Por favor, insira um número de telefone válido';

  @override
  String get auth_otp => 'Código OTP';

  @override
  String get auth_resendOtp => 'Reenviar código OTP';

  @override
  String get auth_error_invalidOtp =>
      'Código OTP inválido. Por favor, tente novamente.';

  @override
  String get login_welcomeBack => 'Bem-vindo de volta';

  @override
  String get login_enterPhone => 'Insira o seu número de telefone para entrar';

  @override
  String get login_rememberPhone => 'Lembrar este dispositivo';

  @override
  String get login_noAccount => 'Não tem uma conta?';

  @override
  String get login_createAccount => 'Criar conta';

  @override
  String get login_verifyCode => 'Verifique o seu código';

  @override
  String login_codeSentTo(String countryCode, String phone) {
    return 'Insira o código de 6 dígitos enviado para $countryCode $phone';
  }

  @override
  String get login_resendCode => 'Reenviar código';

  @override
  String login_resendIn(int seconds) {
    return 'Reenviar código em ${seconds}s';
  }

  @override
  String get login_verifying => 'A verificar...';

  @override
  String get login_enterPin => 'Insira o seu código PIN';

  @override
  String get login_pinSubtitle =>
      'Insira o seu código PIN de 6 dígitos para aceder à sua carteira';

  @override
  String get login_forgotPin => 'Esqueceu o código PIN?';

  @override
  String login_attemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativas restantes',
      one: '1 tentativa restante',
    );
    return '$_temp0';
  }

  @override
  String get login_accountLocked => 'Conta bloqueada';

  @override
  String get login_lockedMessage =>
      'Demasiadas tentativas falhadas. A sua conta foi bloqueada por 15 minutos por segurança.';

  @override
  String get common_ok => 'OK';

  @override
  String get common_continue => 'Continuar';

  @override
  String get wallet_balance => 'Saldo';

  @override
  String get wallet_sendMoney => 'Enviar dinheiro';

  @override
  String get wallet_receiveMoney => 'Receber dinheiro';

  @override
  String get wallet_transactionHistory => 'Histórico de transações';

  @override
  String get wallet_availableBalance => 'Saldo disponível';

  @override
  String get wallet_totalBalance => 'Saldo total';

  @override
  String get wallet_usdBalance => 'USD';

  @override
  String get wallet_usdcBalance => 'USDC';

  @override
  String get wallet_fiatBalance => 'Saldo fiduciário';

  @override
  String get wallet_stablecoin => 'Stablecoin';

  @override
  String get wallet_createWallet => 'Criar carteira';

  @override
  String get wallet_noWalletFound => 'Nenhuma carteira encontrada';

  @override
  String get wallet_createWalletMessage =>
      'Crie a sua carteira para começar a enviar e receber dinheiro';

  @override
  String get wallet_loadingWallet => 'A carregar carteira...';

  @override
  String get wallet_activateTitle => 'Ative a sua carteira';

  @override
  String get wallet_activateDescription =>
      'Configure a sua carteira USDC para enviar e receber dinheiro instantaneamente';

  @override
  String get wallet_activateButton => 'Ativar carteira';

  @override
  String get wallet_activating => 'A ativar a sua carteira...';

  @override
  String get wallet_activateFailed =>
      'Falha ao ativar a carteira. Por favor, tente novamente.';

  @override
  String get home_welcomeBack => 'Bem-vindo de volta';

  @override
  String get home_allServices => 'Todos os serviços';

  @override
  String get home_viewAllFeatures => 'Ver todas as funcionalidades disponíveis';

  @override
  String get home_recentTransactions => 'Transações recentes';

  @override
  String get home_noTransactionsYet => 'Ainda sem transações';

  @override
  String get home_transactionsWillAppear =>
      'As suas transações recentes aparecerão aqui';

  @override
  String get home_balance => 'Saldo';

  @override
  String get send_title => 'Enviar dinheiro';

  @override
  String get send_toPhone => 'Para telefone';

  @override
  String get send_toWallet => 'Para carteira';

  @override
  String get send_recent => 'Recentes';

  @override
  String get send_recipient => 'Destinatário';

  @override
  String get send_saved => 'Guardados';

  @override
  String get send_contacts => 'Contactos';

  @override
  String get send_amountUsd => 'Valor (USD)';

  @override
  String get send_walletAddress => 'Endereço da carteira';

  @override
  String get send_networkInfo =>
      'Transferências externas podem demorar alguns minutos. Aplicam-se taxas reduzidas.';

  @override
  String get send_transferSuccess => 'Transferência bem-sucedida!';

  @override
  String get send_invalidAmount => 'Insira um valor válido';

  @override
  String get send_insufficientBalance => 'Saldo insuficiente';

  @override
  String get send_addressMustStartWith0x => 'Endereço must começar with 0x';

  @override
  String get send_addressLength =>
      'O endereço deve ter exatamente 42 caracteres';

  @override
  String get send_invalidEthereumAddress =>
      'Formato de endereço Ethereum inválido';

  @override
  String get send_saveRecipientPrompt => 'Guardar destinatário?';

  @override
  String get send_saveRecipientMessage =>
      'Deseja guardar este destinatário para transferências futuras?';

  @override
  String get send_notNow => 'Agora não';

  @override
  String get send_saveRecipientTitle => 'Guardar destinatário';

  @override
  String get send_enterRecipientName => 'Insira um nome para este destinatário';

  @override
  String get send_name => 'Nome';

  @override
  String get send_recipientSaved => 'Destinatário guardado';

  @override
  String get send_failedToSaveRecipient => 'Falha ao guardar destinatário';

  @override
  String get send_selectSavedRecipient => 'Selecionar destinatário guardado';

  @override
  String get send_selectContact => 'Selecionar contacto';

  @override
  String get send_searchRecipients => 'Pesquisar destinatários...';

  @override
  String get send_searchContacts => 'Pesquisar contactos...';

  @override
  String get send_noSavedRecipients => 'Sem destinatários guardados';

  @override
  String get send_failedToLoadRecipients => 'Falha ao carregar destinatários';

  @override
  String get send_joonaPayUser => 'Utilizador JoonaPay';

  @override
  String get send_tooManyAttempts =>
      'Demasiadas tentativas incorretas. Por favor, tente novamente mais tarde.';

  @override
  String get receive_title => 'Receber USDC';

  @override
  String get receive_receiveUsdc => 'Receber USDC';

  @override
  String get receive_onlySendUsdc =>
      'Partilhe o seu endereço para receber USDC';

  @override
  String get receive_yourWalletAddress => 'O seu endereço de carteira';

  @override
  String get receive_walletNotAvailable =>
      'Endereço de carteira não disponível';

  @override
  String get receive_addressCopied =>
      'Endereço copiado para a área de transferência (limpa automaticamente em 60s)';

  @override
  String receive_shareMessage(String address) {
    return 'Envie USDC para a minha carteira JoonaPay:\n\n$address';
  }

  @override
  String get receive_shareSubject => 'O meu endereço de carteira USDC';

  @override
  String get receive_important => 'Importante';

  @override
  String get receive_warningMessage =>
      'Envie apenas USDC para este endereço. Enviar outros tokens pode resultar em perda permanente de fundos.';

  @override
  String get transactions_title => 'Transações';

  @override
  String get transactions_searchPlaceholder => 'Pesquisar transações...';

  @override
  String get transactions_noResultsFound => 'Nenhum resultado encontrado';

  @override
  String get transactions_noTransactions => 'Sem transações';

  @override
  String get transactions_adjustFilters =>
      'Tente ajustar os seus filtros ou consulta de pesquisa para encontrar o que procura.';

  @override
  String get transactions_historyMessage =>
      'O seu histórico de transações aparecerá aqui assim que fizer o seu primeiro depósito ou transferência.';

  @override
  String get transactions_somethingWentWrong => 'Algo correu mal';

  @override
  String get transactions_today => 'Hoje';

  @override
  String get transactions_yesterday => 'Ontem';

  @override
  String get transactions_deposit => 'Depósito';

  @override
  String get transactions_withdrawal => 'Levantamento';

  @override
  String get transactions_transferReceived => 'Transferência recebida';

  @override
  String get transactions_transferSent => 'Transferência enviada';

  @override
  String get transactions_mobileMoneyDeposit => 'Depósito por Mobile Money';

  @override
  String get transactions_mobileMoneyWithdrawal =>
      'Levantamento por Mobile Money';

  @override
  String get transactions_fromJoonaPayUser => 'De utilizador JoonaPay';

  @override
  String get transactions_externalWallet => 'Carteira externa';

  @override
  String get transactions_deposits => 'Depósitos';

  @override
  String get transactions_withdrawals => 'Levantamentos';

  @override
  String get transactions_receivedFilter => 'Recebidos';

  @override
  String get transactions_sentFilter => 'Enviados';

  @override
  String get services_title => 'Serviços';

  @override
  String get services_coreServices => 'Serviços principais';

  @override
  String get services_financialServices => 'Serviços financeiros';

  @override
  String get services_billsPayments => 'Contas e pagamentos';

  @override
  String get services_toolsAnalytics => 'Ferramentas e análises';

  @override
  String get services_sendMoney => 'Enviar dinheiro';

  @override
  String get services_sendMoneyDesc => 'Transferir para qualquer carteira';

  @override
  String get services_receiveMoney => 'Receber dinheiro';

  @override
  String get services_receiveMoneyDesc => 'Obter o seu endereço de carteira';

  @override
  String get services_requestMoney => 'Solicitar dinheiro';

  @override
  String get services_requestMoneyDesc => 'Criar pedido de pagamento';

  @override
  String get services_scanQr => 'Digitalizar QR';

  @override
  String get services_scanQrDesc => 'Digitalizar para pagar ou receber';

  @override
  String get services_recipients => 'Destinatários';

  @override
  String get services_recipientsDesc => 'Gerir contactos guardados';

  @override
  String get services_scheduledTransfers => 'Transferências agendadas';

  @override
  String get services_scheduledTransfersDesc => 'Gerir pagamentos recorrentes';

  @override
  String get services_virtualCard => 'Cartão virtual';

  @override
  String get services_virtualCardDesc => 'Cartão para compras online';

  @override
  String get services_savingsGoals => 'Metas de poupança';

  @override
  String get services_savingsGoalsDesc => 'Acompanhar as suas poupanças';

  @override
  String get services_budget => 'Orçamento';

  @override
  String get services_budgetDesc => 'Gerir limites de gastos';

  @override
  String get services_currencyConverter => 'Conversor de moedas';

  @override
  String get services_currencyConverterDesc => 'Converter moedas';

  @override
  String get services_billPayments => 'Pagamento de contas';

  @override
  String get services_billPaymentsDesc => 'Pagar contas de serviços';

  @override
  String get services_buyAirtime => 'Comprar crédito';

  @override
  String get services_buyAirtimeDesc => 'Recarregar telemóvel';

  @override
  String get services_splitBills => 'Dividir contas';

  @override
  String get services_splitBillsDesc => 'Partilhar despesas';

  @override
  String get services_analytics => 'Análises';

  @override
  String get services_analyticsDesc => 'Ver análises de gastos';

  @override
  String get services_referrals => 'Referências';

  @override
  String get services_referralsDesc => 'Convidar e ganhar';

  @override
  String get settings_profile => 'Perfil';

  @override
  String get settings_profileDescription =>
      'Gerir as suas informações pessoais';

  @override
  String get settings_security => 'Segurança';

  @override
  String get settings_securitySettings => 'Definições de segurança';

  @override
  String get settings_securityDescription => 'PIN, 2FA, biometria';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_selectTheme => 'Selecionar tema';

  @override
  String get settings_themeLight => 'Claro';

  @override
  String get settings_themeDark => 'Escuro';

  @override
  String get settings_themeSystem => 'Sistema';

  @override
  String get settings_themeLightDescription => 'Bright and clean appearance';

  @override
  String get settings_themeDarkDescription => 'Easy on the eyes at night';

  @override
  String get settings_themeSystemDescription => 'Matches your device settings';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_notifications => 'Notificações';

  @override
  String get settings_preferences => 'Preferências';

  @override
  String get settings_defaultCurrency => 'Moeda padrão';

  @override
  String get settings_support => 'Suporte';

  @override
  String get settings_helpSupport => 'Ajuda e suporte';

  @override
  String get settings_helpDescription => 'Perguntas frequentes, chat, contacto';

  @override
  String get settings_kycVerification => 'Verificação KYC';

  @override
  String get settings_transactionLimits => 'Limites de transação';

  @override
  String get settings_limitsDescription => 'Ver e aumentar limites';

  @override
  String get settings_referEarn => 'Indicar e ganhar';

  @override
  String get settings_referDescription => 'Convide amigos e ganhe recompensas';

  @override
  String settings_version(String version) {
    return 'Versão $version';
  }

  @override
  String get settings_devices => 'Dispositivos';

  @override
  String get settings_devicesDescription =>
      'Gerir dispositivos que têm acesso à sua conta. Revogar acesso de qualquer dispositivo.';

  @override
  String get settings_thisDevice => 'Este dispositivo';

  @override
  String get settings_lastActive => 'Última atividade';

  @override
  String get settings_loginCount => 'Entradas';

  @override
  String get settings_times => 'vezes';

  @override
  String get settings_lastIp => 'Último IP';

  @override
  String get settings_trustDevice => 'Confiar no dispositivo';

  @override
  String get settings_removeDevice => 'Remover dispositivo';

  @override
  String get settings_removeDeviceConfirm =>
      'Este dispositivo será desconectado e precisará de autenticação novamente para aceder à sua conta.';

  @override
  String get settings_noDevices => 'Nenhum dispositivo encontrado';

  @override
  String get settings_noDevicesDescription =>
      'Ainda não tem nenhum dispositivo registado.';

  @override
  String get kyc_verified => 'Verificado';

  @override
  String get kyc_pending => 'Análise pendente';

  @override
  String get kyc_rejected => 'Rejeitado - Tentar novamente';

  @override
  String get kyc_notStarted => 'Não iniciado';

  @override
  String get kyc_title => 'Verificação de identidade';

  @override
  String get kyc_selectDocumentType => 'Selecionar tipo de documento';

  @override
  String get kyc_selectDocumentType_description =>
      'Choose the tipo of documento you\'d like to verificar with';

  @override
  String get kyc_documentType_nationalId => 'National id card';

  @override
  String get kyc_documentType_nationalId_description =>
      'Government-issued id card';

  @override
  String get kyc_documentType_passport => 'Passport';

  @override
  String get kyc_documentType_passport_description =>
      'International travel documento';

  @override
  String get kyc_documentType_driversLicense => 'Driver\'s license';

  @override
  String get kyc_documentType_driversLicense_description =>
      'Government-issued driver\'s license';

  @override
  String get kyc_personalInfo_title => 'Personal Information';

  @override
  String get kyc_personalInfo_subtitle =>
      'Enter your details exactly as they appear on your ID document';

  @override
  String get kyc_personalInfo_firstName => 'First name';

  @override
  String get kyc_personalInfo_firstNameRequired => 'First name is required';

  @override
  String get kyc_personalInfo_lastName => 'Last name';

  @override
  String get kyc_personalInfo_lastNameRequired => 'Last name is required';

  @override
  String get kyc_personalInfo_dateOfBirth => 'Date of birth';

  @override
  String get kyc_personalInfo_selectDate => 'Select date';

  @override
  String get kyc_personalInfo_dateRequired => 'Date of birth is required';

  @override
  String get kyc_personalInfo_matchIdHint =>
      'Your information must match exactly what appears on your ID document for verification to succeed';

  @override
  String get kyc_capture_frontSide_guidance =>
      'Align the front of your documento within the frame';

  @override
  String get kyc_capture_backSide_guidance =>
      'Align the voltar of your documento within the frame';

  @override
  String get kyc_capture_nationalIdInstructions =>
      'Position your id card flat and well-lit within the frame';

  @override
  String get kyc_capture_passportInstructions =>
      'Position your passport photo page within the frame';

  @override
  String get kyc_capture_driversLicenseInstructions =>
      'Position your driver\'s license flat within the frame';

  @override
  String get kyc_capture_backInstructions =>
      'Now capture the voltar side of your documento';

  @override
  String get kyc_checkingQuality => 'Checking image quality...';

  @override
  String get kyc_reviewImage => 'Review image';

  @override
  String get kyc_retake => 'Retake';

  @override
  String get kyc_accept => 'Accept';

  @override
  String get kyc_error_imageQuality =>
      'Image quality is not acceptable. please try again.';

  @override
  String get kyc_error_imageBlurry =>
      'Image is too blurry. hold your telefone steady and try again.';

  @override
  String get kyc_error_imageGlare =>
      'Too much glare detected. avoid direct light and try again.';

  @override
  String get kyc_error_imageTooDark =>
      'Image is too dark. use better lighting and try again.';

  @override
  String get kyc_camera_unavailable => 'Camera Not Available';

  @override
  String get kyc_camera_unavailable_description =>
      'Your device camera is not accessible. You can select a photo from your gallery instead.';

  @override
  String get kyc_chooseFromGallery => 'Choose from Gallery';

  @override
  String get kyc_status_pending_title => 'Começar verificação';

  @override
  String get kyc_status_pending_description =>
      'Completar your identity verificação to unlock higher limites and todos features.';

  @override
  String get kyc_status_submitted_title => 'Verificação in progress';

  @override
  String get kyc_status_submitted_description =>
      'Your documentos are being reviewed. this usually takes 1-2 business days.';

  @override
  String get kyc_status_approved_title => 'Verificação completar';

  @override
  String get kyc_status_approved_description =>
      'Your identity has been verificado. you now have access to todos features!';

  @override
  String get kyc_status_rejected_title => 'Verificação falhado';

  @override
  String get kyc_status_rejected_description =>
      'We couldn\'t verificar your documentos. please review the reason below and try again.';

  @override
  String get kyc_status_additionalInfo_title => 'Additional information needed';

  @override
  String get kyc_status_additionalInfo_description =>
      'Please provide additional information to completar your verificação.';

  @override
  String get kyc_rejectionReason => 'Rejection reason';

  @override
  String get kyc_tryAgain => 'Try again';

  @override
  String get kyc_startVerification => 'Começar verificação';

  @override
  String get kyc_info_security_title => 'Your data is secure';

  @override
  String get kyc_info_security_description =>
      'Todos documentos are encrypted and securely stored';

  @override
  String get kyc_info_time_title => 'Quick process';

  @override
  String get kyc_info_time_description =>
      'Verificação usually takes 1-2 business days';

  @override
  String get kyc_info_documents_title => 'Documentos needed';

  @override
  String get kyc_info_documents_description =>
      'Válido government-issued id or passport';

  @override
  String get kyc_reviewDocuments => 'Review documentos';

  @override
  String get kyc_review_description =>
      'Review your captured documentos before submitting for verificação';

  @override
  String get kyc_review_documents => 'Documentos';

  @override
  String get kyc_review_documentFront => 'Documento front';

  @override
  String get kyc_review_documentBack => 'Documento voltar';

  @override
  String get kyc_review_selfie => 'Selfie';

  @override
  String get kyc_review_yourSelfie => 'Your selfie';

  @override
  String get kyc_submitForVerification => 'Submeter for verificação';

  @override
  String get kyc_selfie_title => 'Take a selfie';

  @override
  String get kyc_selfie_guidance => 'Position your face in the oval frame';

  @override
  String get kyc_selfie_livenessHint => 'Make sure you\'re in a well-lit area';

  @override
  String get kyc_selfie_instructions =>
      'Look straight at the camera and keep your face within the frame';

  @override
  String get kyc_reviewSelfie => 'Review selfie';

  @override
  String get kyc_submitted_title => 'Verificação submitted';

  @override
  String get kyc_submitted_description =>
      'Thank you! your documentos have been submitted for verificação. we\'ll notify you once the review is completar.';

  @override
  String get kyc_submitted_timeEstimate =>
      'Verificação usually takes 1-2 business days';

  @override
  String get transaction_sent => 'Sent';

  @override
  String get transaction_received => 'Received';

  @override
  String get transaction_pending => 'Pendente';

  @override
  String get transaction_failed => 'Falhado';

  @override
  String get transaction_completed => 'Concluído';

  @override
  String get error_generic =>
      'We encountered an issue. please try again in a moment.';

  @override
  String get error_network =>
      'Erro de rede. Verifique a sua ligação à internet.';

  @override
  String get error_failedToLoadBalance =>
      'Unable to load your saldo. pull down to atualizar or try again later.';

  @override
  String get error_failedToLoadTransactions =>
      'Unable to load transações. pull down to atualizar or try again later.';

  @override
  String get language_english => 'English';

  @override
  String get language_french => 'Français';

  @override
  String get language_selectLanguage => 'Selecionar idioma';

  @override
  String get language_changeLanguage => 'Change idioma';

  @override
  String get currency_primary => 'Primary moeda';

  @override
  String get currency_reference => 'Reference moeda';

  @override
  String get currency_referenceDescription =>
      'Displays local moeda equivalent below your usdc saldo for reference only. exchange rates are approximate.';

  @override
  String get currency_showReference => 'Mostrar local moeda';

  @override
  String get currency_showReferenceDescription =>
      'Display approximate local moeda value below usdc amounts';

  @override
  String get currency_preview => 'Preview';

  @override
  String get settings_activeSessions => 'Active sessions';

  @override
  String get sessions_currentSession => 'Current session';

  @override
  String get sessions_unknownLocation => 'Unknown location';

  @override
  String get sessions_unknownIP => 'Unknown ip';

  @override
  String get sessions_lastActive => 'Last active';

  @override
  String get sessions_revokeTitle => 'Revoke session';

  @override
  String get sessions_revokeMessage =>
      'Are you sure you want to revoke this session? this dispositivo will be logged out immediately.';

  @override
  String get sessions_revoke => 'Revoke';

  @override
  String get sessions_revokeSuccess => 'Session revoked successfully';

  @override
  String get sessions_logoutAllDevices => 'Logout from todos dispositivos';

  @override
  String get sessions_logoutAllTitle => 'Logout from todos dispositivos?';

  @override
  String get sessions_logoutAllMessage =>
      'This will log you out from todos dispositivos including this one. you\'ll need to log in again.';

  @override
  String get sessions_logoutAllWarning => 'This action cannot be undone';

  @override
  String get sessions_logoutAll => 'Logout todos';

  @override
  String get sessions_logoutAllSuccess => 'Logged out from todos dispositivos';

  @override
  String get sessions_errorLoading => 'Falhado to load sessions';

  @override
  String get sessions_noActiveSessions => 'No active sessions';

  @override
  String get sessions_noActiveSessionsDesc =>
      'You don\'t have any active sessions at the moment.';

  @override
  String get beneficiaries_title => 'Beneficiaries';

  @override
  String get beneficiaries_tabAll => 'Todos';

  @override
  String get beneficiaries_tabFavorites => 'Favorites';

  @override
  String get beneficiaries_tabRecent => 'Recentes';

  @override
  String get beneficiaries_searchHint => 'Pesquisar by nome or telefone';

  @override
  String get beneficiaries_addTitle => 'Adicionar beneficiary';

  @override
  String get beneficiaries_editTitle => 'Editar beneficiary';

  @override
  String get beneficiaries_fieldName => 'Nome';

  @override
  String get beneficiaries_fieldPhone => 'Telefone number';

  @override
  String get beneficiaries_fieldAccountType => 'Conta tipo';

  @override
  String get beneficiaries_fieldWalletAddress => 'Carteira endereço';

  @override
  String get beneficiaries_fieldBankCode => 'Bank code';

  @override
  String get beneficiaries_fieldBankAccount => 'Bank conta number';

  @override
  String get beneficiaries_fieldMobileMoneyProvider => 'Mobile money provider';

  @override
  String get beneficiaries_typeJoonapay => 'Joonapay user';

  @override
  String get beneficiaries_typeWallet => 'External carteira';

  @override
  String get beneficiaries_typeBank => 'Bank conta';

  @override
  String get beneficiaries_typeMobileMoney => 'Mobile money';

  @override
  String get beneficiaries_addButton => 'Adicionar beneficiary';

  @override
  String get beneficiaries_addFirst => 'Adicionar your first beneficiary';

  @override
  String get beneficiaries_emptyTitle => 'No beneficiaries yet';

  @override
  String get beneficiaries_emptyMessage =>
      'Adicionar beneficiaries to enviar money faster seguinte hora';

  @override
  String get beneficiaries_emptyFavoritesTitle => 'No favorites';

  @override
  String get beneficiaries_emptyFavoritesMessage =>
      'Star your frequently used beneficiaries to see them here';

  @override
  String get beneficiaries_emptyRecentTitle => 'No recentes transfers';

  @override
  String get beneficiaries_emptyRecentMessage =>
      'Beneficiaries you\'ve sent money to will appear here';

  @override
  String get beneficiaries_menuEdit => 'Editar';

  @override
  String get beneficiaries_menuDelete => 'Eliminar';

  @override
  String get beneficiaries_deleteTitle => 'Eliminar beneficiary?';

  @override
  String beneficiaries_deleteMessage(String name) {
    return 'Are you sure you want to eliminar $name?';
  }

  @override
  String get beneficiaries_deleteSuccess => 'Beneficiary deleted successfully';

  @override
  String get beneficiaries_createSuccess => 'Beneficiary added successfully';

  @override
  String get beneficiaries_updateSuccess => 'Beneficiary updated successfully';

  @override
  String get beneficiaries_errorTitle => 'Erro a carregar beneficiaries';

  @override
  String get beneficiaries_accountDetails => 'Conta detalhes';

  @override
  String get beneficiaries_statistics => 'Transferir statistics';

  @override
  String get beneficiaries_totalTransfers => 'Total transfers';

  @override
  String get beneficiaries_totalAmount => 'Total valor';

  @override
  String get beneficiaries_lastTransfer => 'Last transferir';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_logout => 'Logout';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_retry => 'Tentar novamente';

  @override
  String get common_verified => 'Verificado';

  @override
  String get error_required => 'This field is obrigatório';

  @override
  String get qr_receiveTitle => 'Receber payment';

  @override
  String get qr_scanTitle => 'Scan qr code';

  @override
  String get qr_requestSpecificAmount => 'Request specific valor';

  @override
  String get qr_amountLabel => 'Valor (usd)';

  @override
  String get qr_howToReceive => 'How to receber payment';

  @override
  String get qr_receiveInstructions =>
      'Partilhar this qr code with the remetente. they can scan it with their joonapay app to enviar you money instantly.';

  @override
  String get qr_savedToGallery => 'Qr code saved to gallery';

  @override
  String get qr_failedToSave => 'Falhado to guardar qr code';

  @override
  String get qr_initializingCamera => 'Initializing camera...';

  @override
  String get qr_scanInstruction => 'Scan a joonapay qr code';

  @override
  String get qr_scanSubInstruction =>
      'Point your camera at a qr code to enviar money';

  @override
  String get qr_scanned => 'Qr code scanned';

  @override
  String get qr_invalidCode => 'Inválido qr code';

  @override
  String get qr_invalidCodeMessage =>
      'This qr code is not a válido joonapay payment code.';

  @override
  String get qr_scanAgain => 'Scan again';

  @override
  String get qr_sendMoney => 'Enviar money';

  @override
  String get qr_cameraPermissionRequired => 'Camera permission obrigatório';

  @override
  String get qr_cameraPermissionMessage =>
      'Please grant camera permission to scan qr codes.';

  @override
  String get qr_openSettings => 'Abrir definições';

  @override
  String get qr_galleryImportSoon => 'Gallery importar coming soon';

  @override
  String get home_goodMorning => 'Good morning';

  @override
  String get home_goodAfternoon => 'Good afternoon';

  @override
  String get home_goodEvening => 'Good evening';

  @override
  String get home_goodNight => 'Good night';

  @override
  String get home_totalBalance => 'Total saldo';

  @override
  String get home_hideBalance => 'Ocultar saldo';

  @override
  String get home_showBalance => 'Mostrar saldo';

  @override
  String get home_quickAction_send => 'Enviar';

  @override
  String get home_quickAction_receive => 'Receber';

  @override
  String get home_quickAction_deposit => 'Depositar';

  @override
  String get home_quickAction_history => 'Histórico';

  @override
  String get home_kycBanner_title =>
      'Completar verificação to unlock todos features';

  @override
  String get home_kycBanner_action => 'Verificar now';

  @override
  String get home_recentActivity => 'Recentes activity';

  @override
  String get home_seeAll => 'See todos';

  @override
  String get deposit_title => 'Depositar funds';

  @override
  String get deposit_quickAmounts => 'Quick amounts';

  @override
  String deposit_rateUpdated(String time, DateTime hora) {
    return 'Updated $time';
  }

  @override
  String get deposit_youWillReceive => 'You will receber';

  @override
  String get deposit_youWillPay => 'You will pay';

  @override
  String get deposit_limits => 'Depositar limites';

  @override
  String get deposit_selectProvider => 'Selecionar provider';

  @override
  String get deposit_chooseProvider => 'Choose a payment method';

  @override
  String get deposit_amountToPay => 'Valor to pay';

  @override
  String get deposit_noFee => 'No taxa';

  @override
  String get deposit_fee => 'taxa';

  @override
  String get deposit_paymentInstructions => 'Payment instructions';

  @override
  String deposit_expiresIn(String time) {
    return 'Expires in';
  }

  @override
  String deposit_via(String provider) {
    return 'via $provider';
  }

  @override
  String get deposit_referenceNumber => 'Reference number';

  @override
  String get deposit_howToPay => 'How to completar payment';

  @override
  String get deposit_ussdCode => 'Ussd code';

  @override
  String deposit_openApp(String provider) {
    return 'Abrir $provider app';
  }

  @override
  String get deposit_completedPayment => 'I\'ve concluído payment';

  @override
  String get deposit_copied => 'Copied to clipboard';

  @override
  String get deposit_cancelTitle => 'Cancelar depositar?';

  @override
  String get deposit_cancelMessage =>
      'Your payment session will be cancelado. you can começar a new depositar later.';

  @override
  String get deposit_processing => 'A processar';

  @override
  String get deposit_success => 'Depositar successful!';

  @override
  String get deposit_failed => 'Depositar falhado';

  @override
  String get deposit_expired => 'Session expired';

  @override
  String get deposit_processingMessage =>
      'We\'re a processar your payment. this may take a few moments.';

  @override
  String get deposit_successMessage =>
      'Your funds have been added to your carteira!';

  @override
  String get deposit_failedMessage =>
      'We couldn\'t process your payment. please try again.';

  @override
  String get deposit_expiredMessage =>
      'Your payment session has expired. please começar a new depositar.';

  @override
  String get deposit_deposited => 'Deposited';

  @override
  String get deposit_received => 'Received';

  @override
  String get deposit_backToHome => 'Voltar to início';

  @override
  String get common_error => 'An erro occurred';

  @override
  String get common_requiredField => 'This field is obrigatório';

  @override
  String get pin_createTitle => 'Criar your pin';

  @override
  String get pin_confirmTitle => 'Confirmar your pin';

  @override
  String get pin_changeTitle => 'Change pin';

  @override
  String get pin_resetTitle => 'Repor pin';

  @override
  String get pin_enterNewPin => 'Enter your new 6-digit pin';

  @override
  String get pin_reenterPin => 'Re-enter your pin to confirmar';

  @override
  String get pin_enterCurrentPin => 'Enter your current pin';

  @override
  String get pin_confirmNewPin => 'Confirmar your new pin';

  @override
  String get pin_requirements => 'Pin requirements';

  @override
  String get pin_rule_6digits => '6 digits';

  @override
  String get pin_rule_noSequential => 'No sequential numbers (123456)';

  @override
  String get pin_rule_noRepeated => 'No repeated digits (111111)';

  @override
  String get pin_error_sequential => 'Pin cannot be sequential numbers';

  @override
  String get pin_error_repeated => 'Pin cannot be todos the same digit';

  @override
  String get pin_error_noMatch => 'Pins don\'t match. please try again.';

  @override
  String get pin_error_wrongCurrent => 'Current pin is incorrect';

  @override
  String get pin_error_saveFailed =>
      'Falhado to guardar pin. please try again.';

  @override
  String get pin_error_changeFailed =>
      'Falhado to change pin. please try again.';

  @override
  String get pin_error_resetFailed => 'Falhado to repor pin. please try again.';

  @override
  String get pin_success_set => 'Pin created successfully';

  @override
  String get pin_success_changed => 'Pin changed successfully';

  @override
  String get pin_success_reset => 'Pin repor successfully';

  @override
  String pin_attemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts remaining',
      one: '1 attempt remaining',
    );
    return '$_temp0';
  }

  @override
  String get pin_forgotPin => 'Esqueceu o código PIN?';

  @override
  String get pin_locked_title => 'Pin locked';

  @override
  String get pin_locked_message =>
      'Too many falhado attempts. your pin is temporarily locked.';

  @override
  String get pin_locked_tryAgainIn => 'Try again in';

  @override
  String get pin_resetViaOtp => 'Repor pin via sms';

  @override
  String get pin_reset_requestTitle => 'Repor your pin';

  @override
  String get pin_reset_requestMessage =>
      'We\'ll enviar a verificação code to your registered telefone number to repor your pin.';

  @override
  String get pin_reset_sendOtp => 'Enviar verificação code';

  @override
  String get pin_reset_enterOtp =>
      'Enter the 6-digit code sent to your telefone';

  @override
  String get send_selectRecipient => 'Selecionar destinatário';

  @override
  String get send_recipientPhone => 'Destinatário telefone number';

  @override
  String get send_fromContacts => 'Contacts';

  @override
  String get send_fromBeneficiaries => 'Beneficiaries';

  @override
  String get send_recentRecipients => 'Recentes recipients';

  @override
  String get send_contactsPermissionDenied =>
      'Contacts permission is obrigatório to selecionar a contacto';

  @override
  String get send_noContactsFound => 'No contacts found';

  @override
  String get send_selectBeneficiary => 'Selecionar beneficiary';

  @override
  String get send_searchBeneficiaries => 'Pesquisar beneficiaries';

  @override
  String get send_noBeneficiariesFound => 'No beneficiaries found';

  @override
  String get send_enterAmount => 'Enter valor';

  @override
  String get send_amount => 'Valor';

  @override
  String get send_max => 'Max';

  @override
  String get send_note => 'Note';

  @override
  String get send_noteOptional => 'Adicionar a note (opcional)';

  @override
  String get send_fee => 'Taxa';

  @override
  String get send_total => 'Total';

  @override
  String get send_confirmTransfer => 'Confirmar transferir';

  @override
  String get send_pinVerificationRequired =>
      'You will be asked to enter your pin to confirmar this transferir';

  @override
  String get send_confirmAndSend => 'Confirmar & enviar';

  @override
  String get send_verifyPin => 'Verificar pin';

  @override
  String get send_enterPinToConfirm => 'Enter your pin';

  @override
  String get send_pinVerificationDescription =>
      'Enter your 6-digit pin to confirmar this transferir';

  @override
  String get send_useBiometric => 'Use biometric';

  @override
  String get send_biometricReason =>
      'Verificar your identity to completar the transferir';

  @override
  String get send_transferFailed => 'Transferir falhado';

  @override
  String get send_transferSuccessMessage =>
      'Your money has been sent successfully';

  @override
  String get send_sentTo => 'Sent to';

  @override
  String get send_reference => 'Reference';

  @override
  String get send_date => 'Data';

  @override
  String get send_saveAsBeneficiary => 'Guardar as beneficiary';

  @override
  String get send_shareReceipt => 'Partilhar receipt';

  @override
  String get send_transferReceipt => 'Transferir receipt';

  @override
  String get send_beneficiarySaved => 'Beneficiary saved successfully';

  @override
  String get error_phoneRequired => 'Telefone number is obrigatório';

  @override
  String get error_phoneInvalid => 'Inválido telefone number';

  @override
  String get error_amountRequired => 'Valor is obrigatório';

  @override
  String get error_amountInvalid => 'Inválido valor';

  @override
  String get error_insufficientBalance => 'Insufficient saldo';

  @override
  String get error_pinIncorrect => 'Incorrect pin. please try again.';

  @override
  String get error_biometricFailed => 'Biometric authentication falhado';

  @override
  String get error_transferFailed => 'Transferir falhado. please try again.';

  @override
  String get common_copiedToClipboard => 'Copied to clipboard';

  @override
  String get notifications_permission_title => 'Stay informed';

  @override
  String get notifications_permission_description =>
      'Get instant updates sobre your transações, segurança alerts, and important conta activity.';

  @override
  String get notifications_benefit_transactions => 'Transação updates';

  @override
  String get notifications_benefit_transactions_desc =>
      'Instant alerts when you enviar or receber money';

  @override
  String get notifications_benefit_security => 'Segurança alerts';

  @override
  String get notifications_benefit_security_desc =>
      'Be notified of suspicious activity and new dispositivo logins';

  @override
  String get notifications_benefit_updates => 'Important updates';

  @override
  String get notifications_benefit_updates_desc =>
      'Stay updated on new features and special offers';

  @override
  String get notifications_enable_notifications => 'Ativar notifications';

  @override
  String get notifications_maybe_later => 'Maybe later';

  @override
  String get notifications_enabled_success =>
      'Notifications enabled successfully';

  @override
  String get notifications_permission_denied_title => 'Permission obrigatório';

  @override
  String get notifications_permission_denied_message =>
      'To receber notifications, you need to ativar them in your dispositivo definições.';

  @override
  String get action_open_settings => 'Abrir definições';

  @override
  String get notifications_preferences_title => 'Notificação preferences';

  @override
  String get notifications_preferences_description =>
      'Choose which notifications you\'d like to receber';

  @override
  String get notifications_pref_transaction_title => 'Transação alerts';

  @override
  String get notifications_pref_transaction_alerts => 'Todos transação alerts';

  @override
  String get notifications_pref_transaction_alerts_desc =>
      'Get notified for todos incoming and outgoing transações';

  @override
  String get notifications_pref_security_title => 'Segurança';

  @override
  String get notifications_pref_security_alerts => 'Segurança alerts';

  @override
  String get notifications_pref_security_alerts_desc =>
      'Critical segurança alerts (cannot be disabled)';

  @override
  String get notifications_pref_promotional_title => 'Promotional';

  @override
  String get notifications_pref_promotions => 'Promotions and offers';

  @override
  String get notifications_pref_promotions_desc =>
      'Special offers and promotional campaigns';

  @override
  String get notifications_pref_price_title => 'Market updates';

  @override
  String get notifications_pref_price_alerts => 'Price alerts';

  @override
  String get notifications_pref_price_alerts_desc =>
      'Usdc and crypto price movements';

  @override
  String get notifications_pref_summary_title => 'Reports';

  @override
  String get notifications_pref_weekly_summary =>
      'Semanalmente spending summary';

  @override
  String get notifications_pref_weekly_summary_desc =>
      'Receber a summary of your semanalmente activity';

  @override
  String get notifications_pref_thresholds_title => 'Alert thresholds';

  @override
  String get notifications_pref_thresholds_description =>
      'Set custom amounts to trigger alerts';

  @override
  String get notifications_pref_large_transaction_threshold =>
      'Large transação alert';

  @override
  String get notifications_pref_low_balance_threshold => 'Low saldo alert';

  @override
  String get settings_editProfile => 'Editar perfil';

  @override
  String get settings_account => 'Conta';

  @override
  String get settings_about => 'Sobre';

  @override
  String get settings_termsOfService => 'Terms of service';

  @override
  String get settings_privacyPolicy => 'Privacidade policy';

  @override
  String get settings_appVersion => 'App versão';

  @override
  String get profile_firstName => 'Nome próprio';

  @override
  String get profile_lastName => 'Apelido';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_phoneNumber => 'Telefone number';

  @override
  String get profile_phoneCannotChange => 'Telefone number cannot be changed';

  @override
  String get profile_updateSuccess => 'Perfil updated successfully';

  @override
  String get profile_updateError => 'Falhado to atualizar perfil';

  @override
  String get help_faq => 'Perguntas frequentes';

  @override
  String get help_needMoreHelp => 'Need more ajuda?';

  @override
  String get help_reportProblem => 'Report problem';

  @override
  String get help_liveChat => 'Live chat';

  @override
  String get help_emailSupport => 'Email suporte';

  @override
  String get help_whatsappSupport => 'Whatsapp suporte';

  @override
  String get help_copiedToClipboard => 'Copied to clipboard';

  @override
  String get help_needHelp => 'Need ajuda?';

  @override
  String get transactionDetails_title => 'Transação detalhes';

  @override
  String get transactionDetails_transactionId => 'Transação id';

  @override
  String get transactionDetails_date => 'Data';

  @override
  String get transactionDetails_currency => 'Moeda';

  @override
  String get transactionDetails_recipientPhone => 'Destinatário telefone';

  @override
  String get transactionDetails_recipientAddress => 'Destinatário endereço';

  @override
  String get transactionDetails_description => 'Descrição';

  @override
  String get transactionDetails_additionalDetails => 'Additional detalhes';

  @override
  String get transactionDetails_failureReason => 'Failure reason';

  @override
  String get filters_title => 'Filtrar transações';

  @override
  String get filters_reset => 'Repor';

  @override
  String get filters_transactionType => 'Transação tipo';

  @override
  String get filters_status => 'Estado';

  @override
  String get filters_dateRange => 'Data range';

  @override
  String get filters_amountRange => 'Valor range';

  @override
  String get filters_sortBy => 'Ordenar by';

  @override
  String get filters_from => 'From';

  @override
  String get filters_to => 'To';

  @override
  String get filters_clear => 'Limpar';

  @override
  String get onboarding_skip => 'Saltar';

  @override
  String get onboarding_getStarted => 'Começar';

  @override
  String get onboarding_slide1_title => 'Enviar money instantly';

  @override
  String get onboarding_slide1_description =>
      'Transferir usdc to anyone, anywhere in west africa. fast, secure, and with minimal taxas.';

  @override
  String get onboarding_slide2_title => 'Pay bills easily';

  @override
  String get onboarding_slide2_description =>
      'Pay your utility bills, buy airtime, and manage todos your payments in one place.';

  @override
  String get onboarding_slide3_title => 'Guardar for goals';

  @override
  String get onboarding_slide3_description =>
      'Set savings goals and watch your money grow with usdc\'s stable value.';

  @override
  String get onboarding_phoneInput_title => 'Enter your telefone number';

  @override
  String get onboarding_phoneInput_subtitle =>
      'We\'ll enviar you a code to verificar your number';

  @override
  String get onboarding_phoneInput_label => 'Telefone number';

  @override
  String get onboarding_phoneInput_terms =>
      'I agree to the terms of service and privacidade policy';

  @override
  String get onboarding_phoneInput_loginLink => 'Already have an conta? login';

  @override
  String get onboarding_otp_title => 'Verificar your number';

  @override
  String onboarding_otp_subtitle(String dialCode, String phoneNumber) {
    return 'Enter the 6-digit code sent to $dialCode $phoneNumber';
  }

  @override
  String get onboarding_otp_resend => 'Resend code';

  @override
  String onboarding_otp_resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get onboarding_otp_verifying => 'Verifying...';

  @override
  String get onboarding_pin_title => 'Criar your pin';

  @override
  String get onboarding_pin_confirmTitle => 'Confirmar your pin';

  @override
  String get onboarding_pin_enterPin => 'Enter your new 6-digit pin';

  @override
  String get onboarding_pin_confirmPin => 'Re-enter your pin to confirmar';

  @override
  String get pin_error_mismatch => 'Pins don\'t match. please try again.';

  @override
  String get onboarding_profile_title => 'Tell us sobre yourself';

  @override
  String get onboarding_profile_subtitle =>
      'This helps us personalize your experience';

  @override
  String get onboarding_profile_firstName => 'First nome';

  @override
  String get onboarding_profile_firstNameHint => 'e.g., Amadou';

  @override
  String get onboarding_profile_firstNameRequired =>
      'First nome is obrigatório';

  @override
  String get onboarding_profile_lastName => 'Last nome';

  @override
  String get onboarding_profile_lastNameHint => 'e.g., Diallo';

  @override
  String get onboarding_profile_lastNameRequired => 'Last nome is obrigatório';

  @override
  String get onboarding_profile_email => 'Email (opcional)';

  @override
  String get onboarding_profile_emailHint => 'e.g., amadou@example.com';

  @override
  String get onboarding_profile_emailInvalid =>
      'Please enter a válido email endereço';

  @override
  String get onboarding_kyc_title => 'Verificar your identity';

  @override
  String get onboarding_kyc_subtitle =>
      'Unlock higher limites and todos features';

  @override
  String get onboarding_kyc_benefit1 => 'Higher transação limites';

  @override
  String get onboarding_kyc_benefit2 => 'Enviar to external wallets';

  @override
  String get onboarding_kyc_benefit3 => 'Todos features unlocked';

  @override
  String get onboarding_kyc_verify => 'Verificar now';

  @override
  String get onboarding_kyc_later => 'Maybe later';

  @override
  String get onboarding_success_title => 'Welcome to joonapay!';

  @override
  String onboarding_success_subtitle(String name) {
    return 'Hi $name, you\'re todos set!';
  }

  @override
  String get onboarding_success_walletCreated => 'Your carteira is ready';

  @override
  String get onboarding_success_walletMessage =>
      'Começar sending, receiving, and managing your usdc hoje';

  @override
  String get onboarding_success_continue => 'Começar using joonapay';

  @override
  String get action_delete => 'Eliminar';

  @override
  String get savingsPots_title => 'Savings pots';

  @override
  String get savingsPots_emptyTitle => 'Começar saving for your goals';

  @override
  String get savingsPots_emptyMessage =>
      'Criar pots to guardar money for specific goals like vacations, gadgets, or emergencies.';

  @override
  String get savingsPots_createFirst => 'Criar your first pot';

  @override
  String get savingsPots_totalSaved => 'Total saved';

  @override
  String get savingsPots_createTitle => 'Criar savings pot';

  @override
  String get savingsPots_editTitle => 'Editar pot';

  @override
  String get savingsPots_nameLabel => 'Pot nome';

  @override
  String get savingsPots_nameHint => 'e.g., vacation, new telefone';

  @override
  String get savingsPots_nameRequired => 'Please enter a pot nome';

  @override
  String get savingsPots_targetLabel => 'Target valor (opcional)';

  @override
  String get savingsPots_targetHint => 'How much do you want to guardar?';

  @override
  String get savingsPots_targetOptional =>
      'Leave blank if you don\'t have a specific goal';

  @override
  String get savingsPots_emojiRequired => 'Please selecionar an emoji';

  @override
  String get savingsPots_colorRequired => 'Please selecionar a color';

  @override
  String get savingsPots_createButton => 'Criar pot';

  @override
  String get savingsPots_updateButton => 'Atualizar pot';

  @override
  String get savingsPots_createSuccess => 'Pot created successfully!';

  @override
  String get savingsPots_updateSuccess => 'Pot updated successfully!';

  @override
  String get savingsPots_addMoney => 'Adicionar money';

  @override
  String get savingsPots_withdraw => 'Levantar';

  @override
  String get savingsPots_availableBalance => 'Disponível saldo';

  @override
  String get savingsPots_potBalance => 'Pot saldo';

  @override
  String get savingsPots_amount => 'Valor';

  @override
  String get savingsPots_quick10 => '10%';

  @override
  String get savingsPots_quick25 => '25%';

  @override
  String get savingsPots_quick50 => '50%';

  @override
  String get savingsPots_addButton => 'Adicionar to pot';

  @override
  String get savingsPots_withdrawButton => 'Levantar';

  @override
  String get savingsPots_withdrawAll => 'Levantar todos';

  @override
  String get savingsPots_invalidAmount => 'Please enter a válido valor';

  @override
  String get savingsPots_insufficientBalance =>
      'Insufficient saldo in your carteira';

  @override
  String get savingsPots_insufficientPotBalance =>
      'Insufficient saldo in this pot';

  @override
  String get savingsPots_addSuccess => 'Money added successfully!';

  @override
  String get savingsPots_withdrawSuccess => 'Money withdrawn successfully!';

  @override
  String get savingsPots_transactionHistory => 'Transação histórico';

  @override
  String get savingsPots_noTransactions => 'No transações yet';

  @override
  String get savingsPots_deposit => 'Depositar';

  @override
  String get savingsPots_withdrawal => 'Withdrawal';

  @override
  String get savingsPots_goalReached => 'Goal reached!';

  @override
  String get savingsPots_deleteTitle => 'Eliminar pot?';

  @override
  String get savingsPots_deleteMessage =>
      'The money in this pot will be returned to your main saldo. this action cannot be undone.';

  @override
  String get savingsPots_deleteSuccess => 'Pot deleted successfully';

  @override
  String get savingsPots_chooseEmoji => 'Choose an emoji';

  @override
  String get savingsPots_chooseColor => 'Choose a color';

  @override
  String get sendExternal_title => 'Enviar to external carteira';

  @override
  String get sendExternal_info =>
      'Enviar usdc to any carteira endereço on polygon or ethereum networks';

  @override
  String get sendExternal_walletAddress => 'Carteira endereço';

  @override
  String get sendExternal_addressHint => '0x1234...abcd';

  @override
  String get sendExternal_addressRequired => 'Carteira endereço is obrigatório';

  @override
  String get sendExternal_paste => 'Paste';

  @override
  String get sendExternal_scanQr => 'Scan qr';

  @override
  String get sendExternal_supportedNetworks => 'Supported networks';

  @override
  String get sendExternal_polygonInfo => 'Fast (1-2 min), low taxa (~\$0.01)';

  @override
  String get sendExternal_ethereumInfo =>
      'Slower (5-10 min), higher taxa (~\$2-5)';

  @override
  String get sendExternal_enterAmount => 'Enter valor';

  @override
  String get sendExternal_recipientAddress => 'Destinatário endereço';

  @override
  String get sendExternal_selectNetwork => 'Selecionar network';

  @override
  String get sendExternal_recommended => 'Recommended';

  @override
  String get sendExternal_fee => 'Taxa';

  @override
  String get sendExternal_amount => 'Valor';

  @override
  String get sendExternal_networkFee => 'Network taxa';

  @override
  String get sendExternal_total => 'Total';

  @override
  String get sendExternal_confirmTransfer => 'Confirmar transferir';

  @override
  String get sendExternal_warningTitle => 'Important';

  @override
  String get sendExternal_warningMessage =>
      'External transfers cannot be reversed. please verificar the endereço carefully.';

  @override
  String get sendExternal_transferSummary => 'Transferir summary';

  @override
  String get sendExternal_network => 'Network';

  @override
  String get sendExternal_totalDeducted => 'Total deducted';

  @override
  String get sendExternal_estimatedTime => 'Estimated hora';

  @override
  String get sendExternal_confirmAndSend => 'Confirmar and enviar';

  @override
  String get sendExternal_addressCopied => 'Endereço copied to clipboard';

  @override
  String get sendExternal_transferSuccess => 'Transferir successful';

  @override
  String get sendExternal_processingMessage =>
      'Your transação is being processed on the blockchain';

  @override
  String get sendExternal_amountSent => 'Valor sent';

  @override
  String get sendExternal_transactionDetails => 'Transação detalhes';

  @override
  String get sendExternal_transactionHash => 'Transação hash';

  @override
  String get sendExternal_status => 'Estado';

  @override
  String get sendExternal_viewOnExplorer => 'Ver on block explorer';

  @override
  String get sendExternal_shareDetails => 'Partilhar detalhes';

  @override
  String get sendExternal_hashCopied => 'Transação hash copied to clipboard';

  @override
  String get sendExternal_statusPending => 'Pendente';

  @override
  String get sendExternal_statusCompleted => 'Concluído';

  @override
  String get sendExternal_statusProcessing => 'A processar';

  @override
  String get billPayments_title => 'Pay bills';

  @override
  String get billPayments_categories => 'Categories';

  @override
  String get billPayments_providers => 'Providers';

  @override
  String get billPayments_allProviders => 'Todos providers';

  @override
  String get billPayments_searchProviders => 'Pesquisar providers...';

  @override
  String get billPayments_noProvidersFound => 'No providers found';

  @override
  String get billPayments_tryAdjustingSearch => 'Try adjusting your pesquisar';

  @override
  String get billPayments_history => 'Payment histórico';

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
  String get billPayments_verifyAccount => 'Verificar conta';

  @override
  String get billPayments_accountVerified => 'Conta verificado';

  @override
  String get billPayments_verificationFailed => 'Verificação falhado';

  @override
  String get billPayments_amount => 'Valor';

  @override
  String get billPayments_processingFee => 'A processar taxa';

  @override
  String get billPayments_totalAmount => 'Total';

  @override
  String get billPayments_paymentSuccessful => 'Payment successful!';

  @override
  String get billPayments_paymentProcessing => 'Payment a processar';

  @override
  String get billPayments_billPaidSuccessfully =>
      'Your bill has been paid successfully';

  @override
  String get billPayments_paymentBeingProcessed =>
      'Your payment is being processed';

  @override
  String get billPayments_receiptNumber => 'Receipt number';

  @override
  String get billPayments_provider => 'Provider';

  @override
  String get billPayments_account => 'Conta';

  @override
  String get billPayments_customer => 'Customer';

  @override
  String get billPayments_totalPaid => 'Total paid';

  @override
  String get billPayments_date => 'Data';

  @override
  String get billPayments_reference => 'Reference';

  @override
  String get billPayments_yourToken => 'Your token';

  @override
  String get billPayments_shareReceipt => 'Partilhar receipt';

  @override
  String get billPayments_confirmPayment => 'Confirmar payment';

  @override
  String get billPayments_failedToLoadProviders => 'Falhado to load providers';

  @override
  String get billPayments_failedToLoadReceipt => 'Falhado to load receipt';

  @override
  String get billPayments_returnHome => 'Return início';

  @override
  String billPayments_payProvider(String providerName, Object providername) {
    return 'Pay $providername';
  }

  @override
  String billPayments_enterField(String field) {
    return 'Enter $field';
  }

  @override
  String billPayments_pleaseEnterField(String field) {
    return 'Please enter $field';
  }

  @override
  String billPayments_fieldMustBeLength(String field, int length) {
    return '$field must be $length characters';
  }

  @override
  String get billPayments_meterNumber => 'Meter number';

  @override
  String get billPayments_enterMeterNumber => 'Enter meter number';

  @override
  String get billPayments_pleaseEnterMeterNumber => 'Please enter meter number';

  @override
  String billPayments_outstanding(String amount, String currency) {
    return 'Outstanding: $amount $currency';
  }

  @override
  String get billPayments_pleaseEnterAmount => 'Please enter valor';

  @override
  String get billPayments_pleaseEnterValidAmount =>
      'Please enter a válido valor';

  @override
  String billPayments_minimumAmount(int amount, String currency) {
    return 'Minimum valor is $amount $currency';
  }

  @override
  String billPayments_maximumAmount(int amount, String currency) {
    return 'Maximum valor is $amount $currency';
  }

  @override
  String billPayments_minMaxRange(int min, int max, String currency) {
    return 'Min: $min - max: $max $currency';
  }

  @override
  String billPayments_available(String amount, String currency) {
    return 'Disponível: $amount $currency';
  }

  @override
  String billPayments_payAmount(String amount, String currency) {
    return 'Pay $amount $currency';
  }

  @override
  String billPayments_enterPinToPay(String providerName, Object providername) {
    return 'Enter your pin to pay $providername';
  }

  @override
  String get billPayments_paymentFailed => 'Payment falhado';

  @override
  String get billPayments_noProvidersAvailable =>
      'No providers disponível for this categoria';

  @override
  String get billPayments_feeNone => 'No taxa';

  @override
  String billPayments_feePercentage(String percentage) {
    return '$percentage% taxa';
  }

  @override
  String billPayments_feeFixed(int amount, String currency) {
    return '$amount $currency taxa';
  }

  @override
  String get billPayments_statusCompleted => 'Concluído';

  @override
  String get billPayments_statusPending => 'Pendente';

  @override
  String get billPayments_statusProcessing => 'A processar';

  @override
  String get billPayments_statusFailed => 'Falhado';

  @override
  String get billPayments_statusRefunded => 'Refunded';

  @override
  String get navigation_cards => 'Cards';

  @override
  String get navigation_history => 'Histórico';

  @override
  String get cards_comingSoon => 'Coming soon';

  @override
  String get cards_title => 'Virtual cards';

  @override
  String get cards_description =>
      'Spend your usdc with virtual debit cards. perfect for online shopping and subscriptions.';

  @override
  String get cards_feature1Title => 'Shop online';

  @override
  String get cards_feature1Description =>
      'Use virtual cards for secure online purchases';

  @override
  String get cards_feature2Title => 'Stay secure';

  @override
  String get cards_feature2Description =>
      'Freeze, unfreeze, or eliminar cards instantly';

  @override
  String get cards_feature3Title => 'Control spending';

  @override
  String get cards_feature3Description =>
      'Set custom spending limites for each card';

  @override
  String get cards_notifyMe => 'Notify me when disponível';

  @override
  String get cards_notifyDialogTitle => 'Get notified';

  @override
  String get cards_notifyDialogMessage =>
      'We\'ll enviar you a notificação when virtual cards are disponível in your region.';

  @override
  String get cards_notifySuccess =>
      'You\'ll be notified when cards are disponível';

  @override
  String get cards_featureDisabled => 'Virtual cards feature is not disponível';

  @override
  String get cards_noCards => 'No cards yet';

  @override
  String get cards_noCardsDescription =>
      'Request your first virtual card to começar making online purchases';

  @override
  String get cards_requestCard => 'Request card';

  @override
  String get cards_cardDetails => 'Card detalhes';

  @override
  String get cards_cardNotFound => 'Card not found';

  @override
  String get cards_cardInformation => 'Card information';

  @override
  String get cards_cardNumber => 'Card number';

  @override
  String get cards_cvv => 'CVV';

  @override
  String get cards_expiryDate => 'Expiry data';

  @override
  String get cards_spendingLimit => 'Spending limite';

  @override
  String get cards_spent => 'Spent';

  @override
  String get cards_limit => 'Limite';

  @override
  String get cards_viewTransactions => 'Ver transações';

  @override
  String get cards_freezeCard => 'Freeze card';

  @override
  String get cards_unfreezeCard => 'Unfreeze card';

  @override
  String get cards_freezeConfirmation =>
      'Are you sure you want to freeze this card? you can unfreeze it anytime.';

  @override
  String get cards_unfreezeConfirmation =>
      'Are you sure you want to unfreeze this card?';

  @override
  String get cards_cardFrozen => 'Card frozen successfully';

  @override
  String get cards_cardUnfrozen => 'Card unfrozen successfully';

  @override
  String get cards_copiedToClipboard => 'Copied to clipboard';

  @override
  String get cards_requestInfo =>
      'Your virtual card will be ready instantly after approval. requires kyc level 2.';

  @override
  String get cards_cardholderName => 'Cardholder nome';

  @override
  String get cards_cardholderNameHint => 'Enter nome as it appears on card';

  @override
  String get cards_nameRequired => 'Cardholder nome is obrigatório';

  @override
  String get cards_spendingLimitHint => 'Enter spending limite in usd';

  @override
  String get cards_limitRequired => 'Spending limite is obrigatório';

  @override
  String get cards_limitInvalid => 'Inválido spending limite';

  @override
  String get cards_limitTooLow => 'Minimum spending limite is \$10';

  @override
  String get cards_limitTooHigh => 'Maximum spending limite is \$10,000';

  @override
  String get cards_cardFeatures => 'Card features';

  @override
  String get cards_featureOnlineShopping => 'Shop online worldwide';

  @override
  String get cards_featureSecure => 'Secure and encrypted';

  @override
  String get cards_featureFreeze => 'Freeze and unfreeze instantly';

  @override
  String get cards_featureAlerts => 'Real-hora transação alerts';

  @override
  String get cards_requestCardSubmit => 'Request virtual card';

  @override
  String get cards_kycRequired => 'Kyc verificação obrigatório';

  @override
  String get cards_kycRequiredDescription =>
      'You need to completar kyc level 2 verificação to request a virtual card.';

  @override
  String get cards_completeKYC => 'Completar kyc';

  @override
  String get cards_requestSuccess => 'Card requested successfully';

  @override
  String get cards_requestFailed => 'Falhado to request card';

  @override
  String get cards_cardSettings => 'Card definições';

  @override
  String get cards_cardStatus => 'Card estado';

  @override
  String get cards_statusActive => 'Active';

  @override
  String get cards_statusFrozen => 'Frozen';

  @override
  String get cards_statusActiveDescription =>
      'Your card is active and ready to use';

  @override
  String get cards_statusFrozenDescription =>
      'Your card is frozen and cannot be used';

  @override
  String get cards_currentLimit => 'Current limite';

  @override
  String get cards_availableLimit => 'Disponível';

  @override
  String get cards_updateLimit => 'Atualizar limite';

  @override
  String get cards_newLimit => 'New limite';

  @override
  String get cards_limitRange => 'Limite must be between \$10 and \$10,000';

  @override
  String get cards_limitUpdated => 'Spending limite updated successfully';

  @override
  String get cards_dangerZone => 'Danger zone';

  @override
  String get cards_blockCard => 'Block card';

  @override
  String get cards_blockCardDescription =>
      'Permanently block this card. this action cannot be undone.';

  @override
  String get cards_blockCardButton => 'Block card permanently';

  @override
  String get cards_blockCardConfirmation =>
      'Are you sure you want to permanently block this card? this action cannot be undone and you\'ll need to request a new card.';

  @override
  String get cards_cardBlocked => 'Card blocked successfully';

  @override
  String get cards_transactions => 'Card transações';

  @override
  String get cards_noTransactions => 'No transações';

  @override
  String get cards_noTransactionsDescription =>
      'You haven\'t made any purchases with this card yet';

  @override
  String get insights_title => 'Insights';

  @override
  String get insights_period_week => 'Semana';

  @override
  String get insights_period_month => 'Mês';

  @override
  String get insights_period_year => 'Ano';

  @override
  String get insights_summary => 'Summary';

  @override
  String get insights_total_spent => 'Total spent';

  @override
  String get insights_total_received => 'Total received';

  @override
  String get insights_net_flow => 'Net flow';

  @override
  String get insights_categories => 'Categories';

  @override
  String get insights_spending_trend => 'Spending trend';

  @override
  String get insights_top_recipients => 'Top recipients';

  @override
  String get insights_empty_title => 'No insights yet';

  @override
  String get insights_empty_description =>
      'Começar using joonapay to see your spending insights and analytics';

  @override
  String get insights_export_report => 'Exportar report';

  @override
  String get insights_daily_spending => 'Diariamente spending';

  @override
  String get insights_daily_average => 'Diariamente avg';

  @override
  String get insights_highest_day => 'Highest';

  @override
  String get insights_income_vs_expenses => 'Income vs expenses';

  @override
  String get insights_income => 'Income';

  @override
  String get insights_expenses => 'Expenses';

  @override
  String get contacts_title => 'Contacts';

  @override
  String get contacts_search => 'Pesquisar contacts';

  @override
  String get contacts_on_joonapay => 'On joonapay';

  @override
  String get contacts_invite_to_joonapay => 'Invite to joonapay';

  @override
  String get contacts_empty => 'No contacts found. pull down to atualizar.';

  @override
  String get contacts_no_results => 'No contacts match your pesquisar';

  @override
  String contacts_sync_success(int count) {
    return 'Found $count joonapay users!';
  }

  @override
  String get contacts_synced_just_now => 'Just now';

  @override
  String contacts_synced_minutes_ago(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String contacts_synced_hours_ago(int hours) {
    return '${hours}h ago';
  }

  @override
  String contacts_synced_days_ago(int days) {
    return '${days}d ago';
  }

  @override
  String get contacts_permission_title => 'Find your friends';

  @override
  String get contacts_permission_subtitle =>
      'See which of your contacts are already on joonapay';

  @override
  String get contacts_permission_benefit1_title => 'Find friends instantly';

  @override
  String get contacts_permission_benefit1_desc =>
      'See which contacts are on joonapay and enviar money instantly';

  @override
  String get contacts_permission_benefit2_title => 'Private & secure';

  @override
  String get contacts_permission_benefit2_desc =>
      'We never store your contacts. telefone numbers are hashed before syncing.';

  @override
  String get contacts_permission_benefit3_title => 'Always up to data';

  @override
  String get contacts_permission_benefit3_desc =>
      'Automatically sync when new contacts join joonapay';

  @override
  String get contacts_permission_allow => 'Allow access';

  @override
  String get contacts_permission_later => 'Maybe later';

  @override
  String get contacts_permission_denied_title => 'Permission denied';

  @override
  String get contacts_permission_denied_message =>
      'To find your friends on joonapay, please allow contacto access in definições.';

  @override
  String contacts_invite_title(String name) {
    return 'Invite $name to joonapay';
  }

  @override
  String get contacts_invite_subtitle =>
      'Enviar money to friends instantly with joonapay';

  @override
  String get contacts_invite_via_sms => 'Enviar sms invite';

  @override
  String get contacts_invite_via_sms_desc =>
      'Enviar an sms with your invite link';

  @override
  String get contacts_invite_via_whatsapp => 'Invite via whatsapp';

  @override
  String get contacts_invite_via_whatsapp_desc =>
      'Partilhar invite link on whatsapp';

  @override
  String get contacts_invite_copy_link => 'Copiar invite link';

  @override
  String get contacts_invite_copy_link_desc =>
      'Copiar link to partilhar anywhere';

  @override
  String get contacts_invite_message =>
      'Hey! i\'m using joonapay to enviar money instantly. join me and get your first transferir free! transferir: https://joonapay.com/app';

  @override
  String get recurringTransfers_title => 'Recurring transfers';

  @override
  String get recurringTransfers_createNew => 'Criar new';

  @override
  String get recurringTransfers_createTitle => 'Criar recurring transferir';

  @override
  String get recurringTransfers_createFirst => 'Criar your first';

  @override
  String get recurringTransfers_emptyTitle => 'No recurring transfers';

  @override
  String get recurringTransfers_emptyMessage =>
      'Set up automatic transfers to enviar money regularly to your loved ones';

  @override
  String get recurringTransfers_active => 'Active transfers';

  @override
  String get recurringTransfers_paused => 'Paused transfers';

  @override
  String get recurringTransfers_upcoming => 'Upcoming this semana';

  @override
  String get recurringTransfers_amount => 'Valor';

  @override
  String get recurringTransfers_frequency => 'Frequency';

  @override
  String get recurringTransfers_nextExecution => 'Seguinte';

  @override
  String get recurringTransfers_recipientSection => 'Destinatário detalhes';

  @override
  String get recurringTransfers_amountSection => 'Transferir valor';

  @override
  String get recurringTransfers_scheduleSection => 'Schedule';

  @override
  String get recurringTransfers_startDate => 'Começar data';

  @override
  String get recurringTransfers_endCondition => 'End condition';

  @override
  String get recurringTransfers_neverEnd => 'Never (until cancelado)';

  @override
  String get recurringTransfers_afterOccurrences =>
      'After specific number of transfers';

  @override
  String get recurringTransfers_untilDate => 'Until specific data';

  @override
  String get recurringTransfers_occurrencesCount => 'Number of times';

  @override
  String get recurringTransfers_selectDate => 'Selecionar data';

  @override
  String get recurringTransfers_note => 'Note (opcional)';

  @override
  String get recurringTransfers_noteHint =>
      'e.g., mensalmente rent, semanalmente allowance';

  @override
  String get recurringTransfers_create => 'Criar recurring transferir';

  @override
  String get recurringTransfers_createSuccess =>
      'Recurring transferir created successfully';

  @override
  String get recurringTransfers_createError =>
      'Falhado to criar recurring transferir';

  @override
  String get recurringTransfers_details => 'Transferir detalhes';

  @override
  String get recurringTransfers_schedule => 'Schedule';

  @override
  String get recurringTransfers_upcomingExecutions => 'Seguinte scheduled';

  @override
  String get recurringTransfers_statistics => 'Statistics';

  @override
  String get recurringTransfers_executed => 'Executed';

  @override
  String get recurringTransfers_remaining => 'Remaining';

  @override
  String get recurringTransfers_executionHistory => 'Execution histórico';

  @override
  String get recurringTransfers_executionSuccess => 'Concluído successfully';

  @override
  String get recurringTransfers_executionFailed => 'Falhado';

  @override
  String get recurringTransfers_pause => 'Pausar transferir';

  @override
  String get recurringTransfers_resume => 'Retomar transferir';

  @override
  String get recurringTransfers_cancel => 'Cancelar transferir';

  @override
  String get recurringTransfers_pauseSuccess =>
      'Transferir paused successfully';

  @override
  String get recurringTransfers_pauseError => 'Falhado to pausar transferir';

  @override
  String get recurringTransfers_resumeSuccess =>
      'Transferir resumed successfully';

  @override
  String get recurringTransfers_resumeError => 'Falhado to retomar transferir';

  @override
  String get recurringTransfers_cancelConfirmTitle =>
      'Cancelar recurring transferir?';

  @override
  String get recurringTransfers_cancelConfirmMessage =>
      'This will permanently cancelar this recurring transferir. this action cannot be undone.';

  @override
  String get recurringTransfers_confirmCancel => 'Yes, cancelar';

  @override
  String get recurringTransfers_cancelSuccess =>
      'Transferir cancelado successfully';

  @override
  String get recurringTransfers_cancelError => 'Falhado to cancelar transferir';

  @override
  String get validation_required => 'Este campo é obrigatório';

  @override
  String get validation_invalidAmount => 'Please enter a válido valor';

  @override
  String get common_today => 'Hoje';

  @override
  String get common_tomorrow => 'Tomorrow';

  @override
  String get limits_title => 'Transação limites';

  @override
  String get limits_dailyLimits => 'Diariamente limites';

  @override
  String get limits_monthlyLimits => 'Mensalmente limites';

  @override
  String get limits_dailyTransactions => 'Diariamente transações';

  @override
  String get limits_monthlyTransactions => 'Mensalmente transações';

  @override
  String get limits_remaining => 'Restante';

  @override
  String get limits_of => 'of';

  @override
  String get limits_upgradeTitle => 'Need higher limites?';

  @override
  String get limits_upgradeDescription =>
      'Verificar your identity to unlock premium limites';

  @override
  String get limits_upgradeToTier => 'Upgrade to';

  @override
  String get limits_day => 'day';

  @override
  String get limits_month => 'mês';

  @override
  String get limits_aboutTitle => 'Sobre limites';

  @override
  String get limits_aboutDescription =>
      'Limites repor at midnight utc. completar kyc verificação to increase your limites.';

  @override
  String get limits_kycPrompt => 'Completar kyc for higher limites';

  @override
  String get limits_maxTier => 'You have the highest tier';

  @override
  String get limits_singleTransaction => 'Single transação';

  @override
  String get limits_withdrawal => 'Withdrawal limite';

  @override
  String get limits_resetIn => 'Resets in';

  @override
  String get limits_hours => 'hours';

  @override
  String get limits_minutes => 'minutes';

  @override
  String get limits_otherLimits => 'Outro limites';

  @override
  String get limits_noData => 'No limite data disponível';

  @override
  String get limits_limitReached => 'Limite reached';

  @override
  String get limits_dailyLimitReached =>
      'You have reached your diariamente transação limite of';

  @override
  String get limits_monthlyLimitReached =>
      'You have reached your mensalmente transação limite of';

  @override
  String get limits_upgradeToIncrease =>
      'Upgrade your conta to increase limites';

  @override
  String get limits_approachingLimit => 'Approaching limite';

  @override
  String get limits_remainingToday => 'remaining hoje';

  @override
  String get limits_remainingThisMonth => 'remaining this mês';

  @override
  String get paymentLinks_title => 'Payment links';

  @override
  String get paymentLinks_createLink => 'Criar payment link';

  @override
  String get paymentLinks_createNew => 'Criar new';

  @override
  String get paymentLinks_createDescription =>
      'Generate a shareable payment link to receber money from anyone';

  @override
  String get paymentLinks_amount => 'Valor';

  @override
  String get paymentLinks_description => 'Descrição';

  @override
  String get paymentLinks_descriptionHint =>
      'What is this payment for? (opcional)';

  @override
  String get paymentLinks_expiresIn => 'Link expires in';

  @override
  String get paymentLinks_6hours => '6 hours';

  @override
  String get paymentLinks_24hours => '24 hours';

  @override
  String get paymentLinks_3days => '3 days';

  @override
  String get paymentLinks_7days => '7 days';

  @override
  String get paymentLinks_info =>
      'Anyone with this link can pay you. link expires automatically.';

  @override
  String get paymentLinks_invalidAmount => 'Please enter a válido valor';

  @override
  String get paymentLinks_minimumAmount => 'Minimum valor is cfa 100';

  @override
  String get paymentLinks_linkCreated => 'Link created';

  @override
  String get paymentLinks_linkReadyTitle => 'Your payment link is ready!';

  @override
  String get paymentLinks_linkReadyDescription =>
      'Partilhar this link with anyone to receber payment';

  @override
  String get paymentLinks_requestedAmount => 'Requested valor';

  @override
  String get paymentLinks_shareLink => 'Partilhar link';

  @override
  String get paymentLinks_viewDetails => 'Ver detalhes';

  @override
  String get paymentLinks_copyLink => 'Copiar link';

  @override
  String get paymentLinks_shareWhatsApp => 'Partilhar on whatsapp';

  @override
  String get paymentLinks_shareSMS => 'Partilhar via sms';

  @override
  String get paymentLinks_shareOther => 'Partilhar outro way';

  @override
  String get paymentLinks_linkCopied => 'Link copied to clipboard';

  @override
  String get paymentLinks_paymentRequest => 'Payment request';

  @override
  String get paymentLinks_emptyTitle => 'No payment links yet';

  @override
  String get paymentLinks_emptyDescription =>
      'Criar your first payment link to começar receiving money easily';

  @override
  String get paymentLinks_createFirst => 'Criar your first link';

  @override
  String get paymentLinks_activeLinks => 'Active links';

  @override
  String get paymentLinks_paidLinks => 'Paid links';

  @override
  String get paymentLinks_filterAll => 'Todos';

  @override
  String get paymentLinks_filterPending => 'Pendente';

  @override
  String get paymentLinks_filterViewed => 'Viewed';

  @override
  String get paymentLinks_filterPaid => 'Paid';

  @override
  String get paymentLinks_filterExpired => 'Expired';

  @override
  String get paymentLinks_noLinksWithFilter => 'No links match this filtrar';

  @override
  String get paymentLinks_linkDetails => 'Link detalhes';

  @override
  String get paymentLinks_linkCode => 'Link code';

  @override
  String get paymentLinks_linkUrl => 'Link url';

  @override
  String get paymentLinks_viewCount => 'Ver count';

  @override
  String get paymentLinks_created => 'Created';

  @override
  String get paymentLinks_expires => 'Expires';

  @override
  String get paymentLinks_paidBy => 'Paid by';

  @override
  String get paymentLinks_paidAt => 'Paid at';

  @override
  String get paymentLinks_cancelLink => 'Cancelar link';

  @override
  String get paymentLinks_cancelConfirmTitle => 'Cancelar link?';

  @override
  String get paymentLinks_cancelConfirmMessage =>
      'Are you sure you want to cancelar this payment link? this action cannot be undone.';

  @override
  String get paymentLinks_linkCancelled => 'Payment link cancelado';

  @override
  String get paymentLinks_viewTransaction => 'Ver transação';

  @override
  String get paymentLinks_payTitle => 'Pay via link';

  @override
  String get paymentLinks_payingTo => 'Paying to';

  @override
  String paymentLinks_payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get paymentLinks_paymentFor => 'Payment for';

  @override
  String get paymentLinks_linkExpiredTitle => 'Link expired';

  @override
  String get paymentLinks_linkExpiredMessage =>
      'This payment link has expired and can no longer be used';

  @override
  String get paymentLinks_linkPaidTitle => 'Already paid';

  @override
  String get paymentLinks_linkPaidMessage =>
      'This payment link has already been paid';

  @override
  String get paymentLinks_linkNotFoundTitle => 'Link not found';

  @override
  String get paymentLinks_linkNotFoundMessage =>
      'This payment link doesn\'t exist or has been cancelado';

  @override
  String get paymentLinks_paymentSuccess => 'Payment successful';

  @override
  String get paymentLinks_paymentSuccessMessage =>
      'Your payment has been sent successfully';

  @override
  String get paymentLinks_insufficientBalance =>
      'Insufficient saldo to completar this payment';

  @override
  String get common_done => 'Concluído';

  @override
  String get common_close => 'Fechar';

  @override
  String get common_unknown => 'Unknown';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get offline_youreOffline => 'You\'re offline';

  @override
  String offline_youreOfflineWithPending(int count) {
    return 'You\'re offline · $count pendente';
  }

  @override
  String get offline_syncing => 'Syncing...';

  @override
  String get offline_pendingTransfer => 'Pendente transferir';

  @override
  String get offline_transferQueued => 'Transferir queued';

  @override
  String get offline_transferQueuedDesc =>
      'Your transferir will be sent when you\'re voltar online';

  @override
  String get offline_viewPending => 'Ver pendente';

  @override
  String get offline_retryFailed => 'Tentar novamente falhado';

  @override
  String get offline_cancelTransfer => 'Cancelar transferir';

  @override
  String get offline_noConnection => 'No internet connection';

  @override
  String get offline_checkConnection =>
      'Please check your internet connection and try again';

  @override
  String get offline_cacheData => 'Showing cached data';

  @override
  String offline_lastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get referrals_title => 'Refer & earn';

  @override
  String get referrals_subtitle => 'Invite friends and earn rewards together';

  @override
  String get referrals_earnAmount => 'Earn \$5';

  @override
  String get referrals_earnDescription =>
      'for each friend who signs up and makes their first depositar';

  @override
  String get referrals_yourCode => 'Your referral code';

  @override
  String get referrals_shareLink => 'Partilhar link';

  @override
  String get referrals_invite => 'Invite';

  @override
  String get referrals_yourRewards => 'Your rewards';

  @override
  String get referrals_friendsInvited => 'Friends invited';

  @override
  String get referrals_totalEarned => 'Total earned';

  @override
  String get referrals_howItWorks => 'How it works';

  @override
  String get referrals_step1Title => 'Partilhar your code';

  @override
  String get referrals_step1Description =>
      'Enviar your referral code or link to friends';

  @override
  String get referrals_step2Title => 'Friend signs up';

  @override
  String get referrals_step2Description =>
      'They criar an conta using your code';

  @override
  String get referrals_step3Title => 'First depositar';

  @override
  String get referrals_step3Description =>
      'They make their first depositar of \$10 or more';

  @override
  String get referrals_step4Title => 'You both earn!';

  @override
  String get referrals_step4Description =>
      'You get \$5, and your friend gets \$5 too';

  @override
  String get referrals_history => 'Referral histórico';

  @override
  String get referrals_noReferrals => 'No referrals yet';

  @override
  String get referrals_startInviting =>
      'Começar inviting friends to see your rewards here';

  @override
  String get referrals_codeCopied => 'Referral code copied!';

  @override
  String referrals_shareMessage(String code) {
    return 'Join joonapay and get \$5 bonus on your first depositar! use my referral code: $code\n\ntransferir now: https://joonapay.com/transferir';
  }

  @override
  String get referrals_shareSubject => 'Join joonapay - get \$5 bonus!';

  @override
  String get referrals_inviteComingSoon => 'Contacto invite coming soon';

  @override
  String get analytics_title => 'Análises';

  @override
  String get analytics_income => 'Receitas';

  @override
  String get analytics_expenses => 'Expenses';

  @override
  String get analytics_netChange => 'Net change';

  @override
  String get analytics_surplus => 'Surplus';

  @override
  String get analytics_deficit => 'Deficit';

  @override
  String get analytics_spendingByCategory => 'Spending by categoria';

  @override
  String get analytics_categoryDetails => 'Categoria detalhes';

  @override
  String get analytics_transactionFrequency => 'Transação frequency';

  @override
  String get analytics_insights => 'Insights';

  @override
  String get analytics_period7Days => '7 Days';

  @override
  String get analytics_period30Days => '30 Days';

  @override
  String get analytics_period90Days => '90 Days';

  @override
  String get analytics_period1Year => '1 ano';

  @override
  String get analytics_categoryTransfers => 'Transfers';

  @override
  String get analytics_categoryWithdrawals => 'Withdrawals';

  @override
  String get analytics_categoryBills => 'Bills';

  @override
  String get analytics_categoryOther => 'Outro';

  @override
  String analytics_transactions(int count) {
    return '$count transações';
  }

  @override
  String get analytics_insightSpendingDown => 'Spending down';

  @override
  String get analytics_insightSpendingDownDesc =>
      'Your spending is 5.2% lower than last mês. great job!';

  @override
  String get analytics_insightSavings => 'Savings opportunity';

  @override
  String get analytics_insightSavingsDesc =>
      'You could guardar \$50/mês by reducing withdrawal taxas.';

  @override
  String get analytics_insightPeakActivity => 'Peak activity';

  @override
  String get analytics_insightPeakActivityDesc =>
      'Most of your transações happen on thursdays.';

  @override
  String get analytics_exportingReport => 'Exporting report...';

  @override
  String get converter_title => 'Conversor de moedas';

  @override
  String get converter_from => 'De';

  @override
  String get converter_to => 'Para';

  @override
  String get converter_selectCurrency => 'Selecionar moeda';

  @override
  String get converter_rateInfo => 'Rate information';

  @override
  String get converter_rateDisclaimer =>
      'Exchange rates are for informational purposes only and may differ from actual transação rates. rates are updated every hour.';

  @override
  String get converter_quickAmounts => 'Quick amounts';

  @override
  String get converter_popularCurrencies => 'Popular currencies';

  @override
  String get converter_perUsdc => 'per USDC';

  @override
  String get converter_ratesUpdated => 'Exchange rates updated';

  @override
  String get converter_updatedJustNow => 'Updated just now';

  @override
  String converter_exchangeRate(String from, String rate, String to) {
    return 'Taxa de câmbio';
  }

  @override
  String get currency_usd => 'Dólar americano (USD)';

  @override
  String get currency_usdc => 'Usd coin';

  @override
  String get currency_eur => 'Euro';

  @override
  String get currency_gbp => 'British pound';

  @override
  String get currency_xof => 'Franco CFA (XOF)';

  @override
  String get currency_ngn => 'Naira nigeriana (NGN)';

  @override
  String get currency_kes => 'Kenyan shilling';

  @override
  String get currency_zar => 'South african rand';

  @override
  String get currency_ghs => 'Ghanaian cedi';

  @override
  String get settings_accountType => 'Conta tipo';

  @override
  String get settings_personalAccount => 'Personal';

  @override
  String get settings_businessAccount => 'Business';

  @override
  String get settings_selectAccountType => 'Selecionar conta tipo';

  @override
  String get settings_personalAccountDescription => 'For individual use';

  @override
  String get settings_businessAccountDescription => 'For business operations';

  @override
  String get settings_switchedToPersonal => 'Switched to personal conta';

  @override
  String get settings_switchedToBusiness => 'Switched to business conta';

  @override
  String get business_setupTitle => 'Business setup';

  @override
  String get business_setupDescription =>
      'Set up your business perfil to unlock business features';

  @override
  String get business_businessName => 'Business nome';

  @override
  String get business_registrationNumber => 'Registration number';

  @override
  String get business_businessType => 'Business tipo';

  @override
  String get business_businessAddress => 'Business endereço';

  @override
  String get business_taxId => 'Tax id';

  @override
  String get business_verificationNote =>
      'Your business will need to undergo verificação (kyb) before you can access todos business features.';

  @override
  String get business_completeSetup => 'Completar setup';

  @override
  String get business_setupSuccess => 'Business perfil created successfully';

  @override
  String get business_profileTitle => 'Business perfil';

  @override
  String get business_noProfile => 'No business perfil found';

  @override
  String get business_setupNow => 'Set up business perfil';

  @override
  String get business_verified => 'Business verificado';

  @override
  String get business_verifiedDescription =>
      'Your business has been successfully verificado';

  @override
  String get business_verificationPending => 'Verificação pendente';

  @override
  String get business_verificationPendingDescription =>
      'Your business verificação is under review';

  @override
  String get business_information => 'Business information';

  @override
  String get business_completeVerification => 'Completar business verificação';

  @override
  String get business_kybDescription =>
      'Verificar your business to unlock todos features';

  @override
  String get business_kybTitle => 'Business verificação (kyb)';

  @override
  String get business_kybInfo =>
      'Business verificação allows you to:\n\n• accept higher transação limites\n• access advanced reporting\n• ativar merchant features\n• build trust with customers\n\nverificação typically takes 2-3 business days.';

  @override
  String get action_close => 'Fechar';

  @override
  String get subBusiness_title => 'Sub-businesses';

  @override
  String get subBusiness_emptyTitle => 'No sub-businesses yet';

  @override
  String get subBusiness_emptyMessage =>
      'Criar departments, branches, or teams to organize your business operations.';

  @override
  String get subBusiness_createFirst => 'Criar first sub-business';

  @override
  String get subBusiness_totalBalance => 'Total saldo';

  @override
  String get subBusiness_unit => 'unit';

  @override
  String get subBusiness_units => 'units';

  @override
  String get subBusiness_listTitle => 'Todos sub-businesses';

  @override
  String get subBusiness_createTitle => 'Criar sub-business';

  @override
  String get subBusiness_nameLabel => 'Nome';

  @override
  String get subBusiness_descriptionLabel => 'Descrição (opcional)';

  @override
  String get subBusiness_typeLabel => 'Tipo';

  @override
  String get subBusiness_typeDepartment => 'Department';

  @override
  String get subBusiness_typeBranch => 'Branch';

  @override
  String get subBusiness_typeSubsidiary => 'Subsidiary';

  @override
  String get subBusiness_typeTeam => 'Team';

  @override
  String get subBusiness_createInfo =>
      'Each sub-business will have its own carteira for tracking income and expenses separately.';

  @override
  String get subBusiness_createButton => 'Criar sub-business';

  @override
  String get subBusiness_createSuccess => 'Sub-business created successfully';

  @override
  String get subBusiness_balance => 'Saldo';

  @override
  String get subBusiness_transfer => 'Transferir';

  @override
  String get subBusiness_transactions => 'Transações';

  @override
  String get subBusiness_information => 'Information';

  @override
  String get subBusiness_type => 'Tipo';

  @override
  String get subBusiness_description => 'Descrição';

  @override
  String get subBusiness_created => 'Created';

  @override
  String get subBusiness_staff => 'Staff';

  @override
  String get subBusiness_manageStaff => 'Manage staff';

  @override
  String get subBusiness_noStaff =>
      'No staff members yet. adicionar team members to give them access to this sub-business.';

  @override
  String get subBusiness_addFirstStaff => 'Adicionar staff member';

  @override
  String get subBusiness_viewAllStaff => 'Ver todos staff';

  @override
  String get subBusiness_staffTitle => 'Staff management';

  @override
  String get subBusiness_noStaffTitle => 'No staff members';

  @override
  String get subBusiness_noStaffMessage =>
      'Invite team members to collaborate on this sub-business.';

  @override
  String get subBusiness_staffInfo =>
      'Staff members can ver and manage this sub-business based on their assigned role.';

  @override
  String get subBusiness_member => 'member';

  @override
  String get subBusiness_members => 'members';

  @override
  String get subBusiness_addStaffTitle => 'Adicionar staff member';

  @override
  String get subBusiness_phoneLabel => 'Telefone number';

  @override
  String get subBusiness_roleLabel => 'Role';

  @override
  String get subBusiness_roleOwner => 'Owner';

  @override
  String get subBusiness_roleAdmin => 'Admin';

  @override
  String get subBusiness_roleViewer => 'Viewer';

  @override
  String get subBusiness_roleOwnerDesc => 'Full access to manage everything';

  @override
  String get subBusiness_roleAdminDesc => 'Can manage and transferir funds';

  @override
  String get subBusiness_roleViewerDesc => 'Can only ver transações';

  @override
  String get subBusiness_inviteButton => 'Invite';

  @override
  String get subBusiness_inviteSuccess => 'Staff member invited successfully';

  @override
  String get subBusiness_changeRole => 'Change role';

  @override
  String get subBusiness_removeStaff => 'Remover staff';

  @override
  String get subBusiness_changeRoleTitle => 'Change role';

  @override
  String get subBusiness_roleUpdateSuccess => 'Role updated successfully';

  @override
  String get subBusiness_removeStaffTitle => 'Remover staff member';

  @override
  String get subBusiness_removeStaffConfirm =>
      'Are you sure you want to remover this staff member? they will lose access to this sub-business.';

  @override
  String get subBusiness_removeButton => 'Remover';

  @override
  String get subBusiness_removeSuccess => 'Staff member removed successfully';

  @override
  String get bulkPayments_title => 'Bulk payments';

  @override
  String get bulkPayments_uploadCsv => 'Carregar csv file';

  @override
  String get bulkPayments_emptyTitle => 'No bulk payments yet';

  @override
  String get bulkPayments_emptyDescription =>
      'Carregar a csv file to enviar payments to multiple recipients at once';

  @override
  String get bulkPayments_active => 'Active batches';

  @override
  String get bulkPayments_completed => 'Concluído';

  @override
  String get bulkPayments_failed => 'Falhado';

  @override
  String get bulkPayments_uploadTitle => 'Carregar bulk payments';

  @override
  String get bulkPayments_instructions => 'Instructions';

  @override
  String get bulkPayments_instructionsDescription =>
      'Carregar a csv file containing telefone numbers, amounts, and descriptions for multiple payments';

  @override
  String get bulkPayments_uploadFile => 'Carregar file';

  @override
  String get bulkPayments_selectFile => 'Tap to selecionar csv file';

  @override
  String get bulkPayments_csvOnly => 'Csv files only';

  @override
  String get bulkPayments_csvFormat => 'Csv format';

  @override
  String get bulkPayments_phoneFormat =>
      'Telefone: international format (+225...)';

  @override
  String get bulkPayments_amountFormat => 'Valor: numeric value (50.00)';

  @override
  String get bulkPayments_descriptionFormat => 'Descrição: obrigatório text';

  @override
  String get bulkPayments_example => 'Example';

  @override
  String get bulkPayments_preview => 'Preview payments';

  @override
  String get bulkPayments_totalPayments => 'Total payments';

  @override
  String get bulkPayments_totalAmount => 'Total valor';

  @override
  String bulkPayments_errorsFound(int count) {
    return '$count errors found';
  }

  @override
  String get bulkPayments_fixErrors => 'Please fix errors before submitting';

  @override
  String get bulkPayments_showInvalidOnly => 'Mostrar inválido only';

  @override
  String get bulkPayments_noPayments => 'No payments to display';

  @override
  String get bulkPayments_submitBatch => 'Submeter batch';

  @override
  String get bulkPayments_confirmSubmit => 'Confirmar batch submission';

  @override
  String bulkPayments_confirmMessage(int count, String amount) {
    return 'Enviar $count pagamentos totalizando $amount?';
  }

  @override
  String get bulkPayments_submitSuccess => 'Batch submitted successfully';

  @override
  String get bulkPayments_batchStatus => 'Batch estado';

  @override
  String get bulkPayments_progress => 'Progress';

  @override
  String get bulkPayments_successful => 'Successful';

  @override
  String get bulkPayments_pending => 'Pendente';

  @override
  String get bulkPayments_details => 'Detalhes';

  @override
  String get bulkPayments_createdAt => 'Created';

  @override
  String get bulkPayments_processedAt => 'Processed';

  @override
  String get bulkPayments_failedPayments => 'Falhado payments';

  @override
  String get bulkPayments_failedDescription =>
      'Transferir a report of falhado payments to tentar novamente';

  @override
  String get bulkPayments_downloadReport => 'Transferir report';

  @override
  String get bulkPayments_failedReportTitle => 'Falhado payments report';

  @override
  String get bulkPayments_downloadFailed => 'Falhado to transferir report';

  @override
  String get bulkPayments_statusDraft => 'Draft';

  @override
  String get bulkPayments_statusPending => 'Pendente';

  @override
  String get bulkPayments_statusProcessing => 'A processar';

  @override
  String get bulkPayments_statusCompleted => 'Concluído';

  @override
  String get bulkPayments_statusPartial => 'Partially concluído';

  @override
  String get bulkPayments_statusFailed => 'Falhado';

  @override
  String get expenses_title => 'Expenses';

  @override
  String get expenses_emptyTitle => 'No expenses yet';

  @override
  String get expenses_emptyMessage =>
      'Começar tracking your expenses by capturing receipts or adding them manually';

  @override
  String get expenses_captureReceipt => 'Capture receipt';

  @override
  String get expenses_addManually => 'Adicionar manually';

  @override
  String get expenses_addExpense => 'Adicionar expense';

  @override
  String get expenses_totalExpenses => 'Total expenses';

  @override
  String get expenses_items => 'items';

  @override
  String get expenses_category => 'Categoria';

  @override
  String get expenses_amount => 'Valor';

  @override
  String get expenses_vendor => 'Vendor';

  @override
  String get expenses_date => 'Data';

  @override
  String get expenses_time => 'Hora';

  @override
  String get expenses_description => 'Descrição';

  @override
  String get expenses_categoryTravel => 'Travel';

  @override
  String get expenses_categoryMeals => 'Meals';

  @override
  String get expenses_categoryOffice => 'Office';

  @override
  String get expenses_categoryTransport => 'Transport';

  @override
  String get expenses_categoryOther => 'Outro';

  @override
  String get expenses_errorAmountRequired => 'Valor is obrigatório';

  @override
  String get expenses_errorInvalidAmount => 'Inválido valor';

  @override
  String get expenses_addedSuccessfully => 'Expense added successfully';

  @override
  String get expenses_positionReceipt =>
      'Position the receipt within the frame';

  @override
  String get expenses_receiptPreview => 'Receipt preview';

  @override
  String get expenses_processingReceipt => 'A processar receipt...';

  @override
  String get expenses_extractedData => 'Extracted data';

  @override
  String get expenses_confirmAndEdit => 'Confirmar & editar';

  @override
  String get expenses_retake => 'Retake photo';

  @override
  String get expenses_confirmDetails => 'Confirmar detalhes';

  @override
  String get expenses_saveExpense => 'Guardar expense';

  @override
  String get expenses_expenseDetails => 'Expense detalhes';

  @override
  String get expenses_details => 'Detalhes';

  @override
  String get expenses_linkedTransaction => 'Linked transação';

  @override
  String get expenses_deleteExpense => 'Eliminar expense';

  @override
  String get expenses_deleteConfirmation =>
      'Are you sure you want to eliminar this expense?';

  @override
  String get expenses_deletedSuccessfully => 'Expense deleted successfully';

  @override
  String get expenses_reports => 'Expense reports';

  @override
  String get expenses_viewReports => 'Ver reports';

  @override
  String get expenses_reportPeriod => 'Report period';

  @override
  String get expenses_startDate => 'Começar data';

  @override
  String get expenses_endDate => 'End data';

  @override
  String get expenses_reportSummary => 'Summary';

  @override
  String get expenses_averageExpense => 'Average expense';

  @override
  String get expenses_byCategory => 'By categoria';

  @override
  String get expenses_exportPdf => 'Exportar as pdf';

  @override
  String get expenses_exportCsv => 'Exportar as csv';

  @override
  String get expenses_reportGenerated => 'Report generated successfully';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_markAllRead => 'Mark todos read';

  @override
  String get notifications_emptyTitle => 'No notifications';

  @override
  String get notifications_emptyMessage => 'You\'re todos caught up!';

  @override
  String get notifications_errorTitle => 'Falhado to load';

  @override
  String get notifications_errorGeneric => 'An erro occurred';

  @override
  String get notifications_timeJustNow => 'Just now';

  @override
  String notifications_timeMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '${countString}m ago';
  }

  @override
  String notifications_timeHoursAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '${countString}h ago';
  }

  @override
  String notifications_timeDaysAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '${countString}d ago';
  }

  @override
  String get security_title => 'Segurança';

  @override
  String get security_authentication => 'Authentication';

  @override
  String get security_changePin => 'Change pin';

  @override
  String get security_changePinSubtitle => 'Atualizar your 4-digit pin';

  @override
  String get security_biometricLogin => 'Biometric login';

  @override
  String get security_biometricSubtitle => 'Use face id or fingerprint';

  @override
  String get security_biometricNotAvailable =>
      'Not disponível on this dispositivo';

  @override
  String get security_biometricUnavailableMessage =>
      'Biometric authentication is not disponível on this dispositivo';

  @override
  String get security_biometricVerifyReason =>
      'Verificar to ativar biometric login';

  @override
  String get security_loading => 'A carregar...';

  @override
  String get security_checkingAvailability => 'Checking availability...';

  @override
  String get security_errorLoadingState => 'Erro a carregar state';

  @override
  String get security_errorCheckingAvailability => 'Erro checking availability';

  @override
  String get security_twoFactorAuth => 'Two-factor authentication';

  @override
  String get security_twoFactorEnabledSubtitle =>
      'Enabled via authenticator app';

  @override
  String get security_twoFactorDisabledSubtitle => 'Adicionar extra protection';

  @override
  String get security_transactionSecurity => 'Transação segurança';

  @override
  String get security_requirePinForTransactions => 'Require pin for transações';

  @override
  String get security_requirePinSubtitle =>
      'Confirmar todos transações with pin';

  @override
  String get security_alerts => 'Segurança alerts';

  @override
  String get security_loginNotifications => 'Login notifications';

  @override
  String get security_loginNotificationsSubtitle =>
      'Get notified of new logins';

  @override
  String get security_newDeviceAlerts => 'New dispositivo alerts';

  @override
  String get security_newDeviceAlertsSubtitle =>
      'Alert when a new dispositivo is used';

  @override
  String get security_sessions => 'Sessions';

  @override
  String get security_devices => 'Dispositivos';

  @override
  String get security_devicesSubtitle => 'Manage your dispositivos';

  @override
  String get security_activeSessions => 'Sessões ativas';

  @override
  String get security_activeSessionsSubtitle => 'Manage your active sessions';

  @override
  String get security_logoutAllDevices => 'Log out todos dispositivos';

  @override
  String get security_logoutAllDevicesSubtitle =>
      'Sign out from todos outro dispositivos';

  @override
  String get security_privacy => 'Privacidade';

  @override
  String get security_loginHistory => 'Histórico de entradas';

  @override
  String get security_loginHistorySubtitle => 'Ver recentes login activity';

  @override
  String get security_deleteAccount => 'Eliminar conta';

  @override
  String get security_deleteAccountSubtitle =>
      'Permanently eliminar your conta';

  @override
  String get security_scoreTitle => 'Segurança score';

  @override
  String get security_scoreExcellent =>
      'Excellent! your conta is well protected.';

  @override
  String get security_scoreGood =>
      'Good segurança. a few improvements possible.';

  @override
  String get security_scoreModerate =>
      'Moderate segurança. ativar more features.';

  @override
  String get security_scoreLow =>
      'Low segurança. please ativar protection features.';

  @override
  String get security_tipEnable2FA =>
      'Ativar 2fa to increase your score by 25 points';

  @override
  String get security_tipEnableBiometrics =>
      'Ativar biometrics for easier secure login';

  @override
  String get security_tipRequirePin =>
      'Require pin for transações for extra safety';

  @override
  String get security_tipEnableNotifications =>
      'Ativar todos notifications for maximum segurança';

  @override
  String get security_setup2FATitle => 'Set up two-factor authentication';

  @override
  String get security_setup2FAMessage =>
      'Use an authenticator app like google authenticator or authy for enhanced segurança.';

  @override
  String get security_continueSetup => 'Continuar setup';

  @override
  String get security_2FAEnabledSuccess => '2FA enabled successfully';

  @override
  String get security_disable2FATitle => 'Desativar 2fa?';

  @override
  String get security_disable2FAMessage =>
      'This will make your conta less secure. are you sure?';

  @override
  String get security_disable => 'Desativar';

  @override
  String get security_logoutAllTitle => 'Log out todos dispositivos?';

  @override
  String get security_logoutAllMessage =>
      'You will be logged out from todos outro dispositivos. you will need to log in again on those dispositivos.';

  @override
  String get security_logoutAll => 'Log out todos';

  @override
  String get security_logoutAllSuccess =>
      'Todos outro dispositivos have been logged out';

  @override
  String get security_loginHistoryTitle => 'Login histórico';

  @override
  String get security_loginSuccess => 'Sucesso';

  @override
  String get security_loginFailed => 'Falhado';

  @override
  String get security_deleteAccountTitle => 'Eliminar conta?';

  @override
  String get security_deleteAccountMessage =>
      'This action is permanent and cannot be undone. todos your data, transação histórico, and funds will be lost.';

  @override
  String get security_delete => 'Eliminar';

  @override
  String get biometric_enrollment_title => 'Secure your conta';

  @override
  String get biometric_enrollment_subtitle =>
      'Adicionar an extra layer of segurança with biometric authentication';

  @override
  String get biometric_enrollment_enable => 'Ativar biometric authentication';

  @override
  String get biometric_enrollment_skip => 'Saltar for now';

  @override
  String get biometric_enrollment_benefit_fast_title => 'Fast access';

  @override
  String get biometric_enrollment_benefit_fast_desc =>
      'Unlock your carteira instantly without entering pin';

  @override
  String get biometric_enrollment_benefit_secure_title => 'Enhanced segurança';

  @override
  String get biometric_enrollment_benefit_secure_desc =>
      'Your unique biometrics provide an additional segurança layer';

  @override
  String get biometric_enrollment_benefit_convenient_title =>
      'Convenient authentication';

  @override
  String get biometric_enrollment_benefit_convenient_desc =>
      'Quickly verificar transações and sensitive actions';

  @override
  String get biometric_enrollment_authenticate_reason =>
      'Authenticate to ativar biometric login';

  @override
  String get biometric_enrollment_success_title => 'Biometric enabled!';

  @override
  String get biometric_enrollment_success_message =>
      'You can now use biometric authentication to access your carteira';

  @override
  String get biometric_enrollment_error_not_available =>
      'Biometric authentication is not disponível on this dispositivo';

  @override
  String get biometric_enrollment_error_failed =>
      'Biometric authentication falhado. please try again';

  @override
  String get biometric_enrollment_error_generic =>
      'Falhado to ativar biometric authentication';

  @override
  String get biometric_enrollment_skip_confirm_title =>
      'Saltar biometric setup?';

  @override
  String get biometric_enrollment_skip_confirm_message =>
      'You can ativar biometric authentication later in definições';

  @override
  String get biometric_settings_title => 'Biometric definições';

  @override
  String get biometric_settings_authentication => 'Authentication';

  @override
  String get biometric_settings_use_cases => 'Use biometric for';

  @override
  String get biometric_settings_advanced => 'Advanced';

  @override
  String get biometric_settings_actions => 'Actions';

  @override
  String get biometric_settings_status_enabled => 'Enabled';

  @override
  String get biometric_settings_status_disabled => 'Disabled';

  @override
  String get biometric_settings_active => 'Active';

  @override
  String get biometric_settings_inactive => 'Inactive';

  @override
  String get biometric_settings_unavailable => 'Unavailable';

  @override
  String get biometric_settings_enabled_subtitle =>
      'Biometric authentication is active';

  @override
  String get biometric_settings_disabled_subtitle =>
      'Ativar to use biometric authentication';

  @override
  String get biometric_settings_app_unlock_title => 'App unlock';

  @override
  String get biometric_settings_app_unlock_subtitle =>
      'Use biometric to unlock the app';

  @override
  String get biometric_settings_transactions_title => 'Transação confirmation';

  @override
  String get biometric_settings_transactions_subtitle =>
      'Verificar transações with biometric';

  @override
  String get biometric_settings_sensitive_title => 'Sensitive definições';

  @override
  String get biometric_settings_sensitive_subtitle =>
      'Protect pin change and segurança definições';

  @override
  String get biometric_settings_view_balance_title => 'Ver saldo';

  @override
  String get biometric_settings_view_balance_subtitle =>
      'Require biometric to see carteira saldo';

  @override
  String get biometric_settings_timeout_title => 'Biometric timeout';

  @override
  String get biometric_settings_timeout_immediate =>
      'Immediate (always obrigatório)';

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
  String get biometric_settings_timeout_select_title => 'Selecionar timeout';

  @override
  String get biometric_settings_high_value_title => 'High-value threshold';

  @override
  String biometric_settings_high_value_subtitle(String amount) {
    return 'Require biometric + pin for transfers over \$$amount';
  }

  @override
  String get biometric_settings_threshold_select_title =>
      'Selecionar threshold';

  @override
  String get biometric_settings_reenroll_title => 'Re-enroll biometric';

  @override
  String get biometric_settings_reenroll_subtitle =>
      'Atualizar your biometric authentication';

  @override
  String get biometric_settings_reenroll_confirm_title =>
      'Re-enroll biometric?';

  @override
  String get biometric_settings_reenroll_confirm_message =>
      'Your current biometric setup will be removed and you\'ll need to set it up again';

  @override
  String get biometric_settings_fallback_title => 'Manage pin';

  @override
  String get biometric_settings_fallback_subtitle =>
      'Pin is always disponível as fallback';

  @override
  String get biometric_settings_disable_title => 'Desativar biometric?';

  @override
  String get biometric_settings_disable_message =>
      'You\'ll need to use your pin to authenticate instead';

  @override
  String get biometric_settings_disable => 'Desativar';

  @override
  String get biometric_settings_error_loading =>
      'Falhado to load biometric definições';

  @override
  String get biometric_type_face_id => 'Face id';

  @override
  String get biometric_type_fingerprint => 'Fingerprint';

  @override
  String get biometric_type_iris => 'Iris';

  @override
  String get biometric_type_none => 'Nenhum';

  @override
  String get biometric_error_lockout =>
      'Biometric authentication is temporarily locked. please try again later';

  @override
  String get biometric_error_not_enrolled =>
      'No biometrics enrolled on this dispositivo. please adicionar biometrics in dispositivo definições';

  @override
  String get biometric_error_hardware_unavailable =>
      'Biometric hardware is not disponível';

  @override
  String get biometric_change_detected_title => 'Biometric change detected';

  @override
  String get biometric_change_detected_message =>
      'Dispositivo biometric enrollment has changed. for segurança, biometric authentication has been disabled. please re-enroll if you want to continuar using it';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_kycStatus => 'Kyc estado';

  @override
  String get profile_country => 'País';

  @override
  String get profile_notSet => 'Not set';

  @override
  String get profile_verify => 'Verificar';

  @override
  String get profile_kycNotVerified => 'Not verificado';

  @override
  String get profile_kycPending => 'Pendente review';

  @override
  String get profile_kycVerified => 'Verificado';

  @override
  String get profile_kycRejected => 'Rejected';

  @override
  String get profile_countryIvoryCoast => 'Ivory coast';

  @override
  String get profile_countryNigeria => 'Nigeria';

  @override
  String get profile_countryKenya => 'Kenya';

  @override
  String get profile_countryGhana => 'Ghana';

  @override
  String get profile_countrySenegal => 'Senegal';

  @override
  String get changePin_title => 'Change pin';

  @override
  String get changePin_newPinTitle => 'New pin';

  @override
  String get changePin_confirmTitle => 'Confirmar pin';

  @override
  String get changePin_enterCurrentPinTitle => 'Enter current pin';

  @override
  String get changePin_enterCurrentPinSubtitle =>
      'Enter your current 4-digit pin to continuar';

  @override
  String get changePin_createNewPinTitle => 'Criar new pin';

  @override
  String get changePin_createNewPinSubtitle =>
      'Choose a new 4-digit pin for your conta';

  @override
  String get changePin_confirmPinTitle => 'Confirmar your pin';

  @override
  String get changePin_confirmPinSubtitle =>
      'Re-enter your new pin to confirmar';

  @override
  String get changePin_errorBiometricRequired =>
      'Biometric confirmation obrigatório';

  @override
  String get changePin_errorIncorrectPin => 'Incorrect pin. please try again.';

  @override
  String get changePin_errorUnableToVerify =>
      'Unable to verificar pin. please try again.';

  @override
  String get changePin_errorWeakPin =>
      'Pin is too simple. choose a stronger pin.';

  @override
  String get changePin_errorSameAsCurrentPin =>
      'New pin must be different from current pin.';

  @override
  String get changePin_errorPinMismatch => 'Pins do not match. try again.';

  @override
  String get changePin_successMessage => 'Pin changed successfully!';

  @override
  String get changePin_errorFailedToSet =>
      'Falhado to set new pin. please try a different pin.';

  @override
  String get changePin_errorFailedToSave =>
      'Falhado to guardar pin. please try again.';

  @override
  String get notifications_email => 'Notificações por email';

  @override
  String get notifications_emailReceipts => 'Email receipts';

  @override
  String get notifications_emailReceiptsDescription =>
      'Receber transação receipts by email';

  @override
  String get notifications_loadError =>
      'Falhado to load notificação definições';

  @override
  String get notifications_marketing => 'Promoções e ofertas';

  @override
  String get notifications_marketingDescription =>
      'Promotional offers and updates';

  @override
  String get notifications_monthlyStatement => 'Mensalmente statement';

  @override
  String get notifications_monthlyStatementDescription =>
      'Receber mensalmente conta statement';

  @override
  String get notifications_newsletter => 'Newsletter';

  @override
  String get notifications_newsletterDescription => 'Product news and updates';

  @override
  String get notifications_push => 'Notificações push';

  @override
  String get notifications_required => 'Obrigatório';

  @override
  String get notifications_saveError => 'Falhado to guardar preferences';

  @override
  String get notifications_savePreferences => 'Guardar preferences';

  @override
  String get notifications_saveSuccess => 'Preferences saved successfully';

  @override
  String get notifications_security => 'Alertas de segurança';

  @override
  String get notifications_securityCodes => 'Segurança codes';

  @override
  String get notifications_securityCodesDescription =>
      'Receber login and verificação codes';

  @override
  String get notifications_securityDescription =>
      'Conta segurança notifications';

  @override
  String get notifications_securityNote =>
      'Segurança notifications cannot be disabled';

  @override
  String get notifications_sms => 'Notificações por SMS';

  @override
  String get notifications_smsTransactions => 'Transação alerts';

  @override
  String get notifications_smsTransactionsDescription =>
      'Receber sms for transações';

  @override
  String get notifications_transactions => 'Transações';

  @override
  String get notifications_transactionsDescription =>
      'Receber notifications for transfers and payments';

  @override
  String get notifications_unsavedChanges => 'Unsaved changes';

  @override
  String get notifications_unsavedChangesMessage =>
      'You have unsaved changes. discard them?';

  @override
  String get help_callUs => 'Ligar-nos';

  @override
  String get help_emailUs => 'Enviar-nos um email';

  @override
  String get help_getHelp => 'Get ajuda';

  @override
  String get help_results => 'Results';

  @override
  String get help_searchPlaceholder => 'Pesquisar ajuda articles...';

  @override
  String get action_discard => 'Discard';

  @override
  String get common_comingSoon => 'Coming soon';

  @override
  String get common_maybeLater => 'Maybe later';

  @override
  String get common_optional => 'Opcional';

  @override
  String get common_share => 'Partilhar';

  @override
  String get error_invalidNumber => 'Inválido number';

  @override
  String get export_title => 'Exportar';

  @override
  String get bankLinking_accountDetails => 'Conta detalhes';

  @override
  String get bankLinking_accountHolderName => 'Conta holder nome';

  @override
  String get bankLinking_accountHolderNameRequired =>
      'Conta holder nome is obrigatório';

  @override
  String get bankLinking_accountNumber => 'Conta number';

  @override
  String get bankLinking_accountNumberRequired => 'Conta number is obrigatório';

  @override
  String get bankLinking_amount => 'Valor';

  @override
  String get bankLinking_amountRequired => 'Valor is obrigatório';

  @override
  String get bankLinking_balance => 'Saldo';

  @override
  String get bankLinking_balanceCheck => 'Saldo check';

  @override
  String get bankLinking_confirmDeposit => 'Confirmar depositar';

  @override
  String get bankLinking_confirmWithdraw => 'Confirmar withdrawal';

  @override
  String get bankLinking_deposit => 'Depositar';

  @override
  String bankLinking_depositConfirmation(String amount) {
    return 'Depositar $amount from your bank?';
  }

  @override
  String get bankLinking_depositFromBank => 'Depositar from bank';

  @override
  String get bankLinking_depositInfo =>
      'Funds will be credited within 24 hours';

  @override
  String get bankLinking_depositSuccess => 'Depositar successful';

  @override
  String get bankLinking_devOtpHint => 'Dev otp: 123456';

  @override
  String get bankLinking_directDebit => 'Direct debit';

  @override
  String get bankLinking_enterAmount => 'Enter valor';

  @override
  String get bankLinking_failed => 'Falhado';

  @override
  String get bankLinking_invalidAmount => 'Inválido valor';

  @override
  String get bankLinking_invalidOtp => 'Inválido otp';

  @override
  String get bankLinking_linkAccount => 'Link conta';

  @override
  String get bankLinking_linkAccountDesc =>
      'Link your bank conta for easy transfers';

  @override
  String get bankLinking_linkedAccounts => 'Linked accounts';

  @override
  String get bankLinking_linkFailed => 'Falhado to link conta';

  @override
  String get bankLinking_linkNewAccount => 'Link new conta';

  @override
  String get bankLinking_noLinkedAccounts => 'No linked accounts';

  @override
  String get bankLinking_otpCode => 'Otp code';

  @override
  String get bankLinking_otpResent => 'Otp resent';

  @override
  String get bankLinking_pending => 'Pendente';

  @override
  String get bankLinking_primary => 'Primary';

  @override
  String get bankLinking_primaryAccountSet => 'Primary conta set';

  @override
  String get bankLinking_resendOtp => 'Resend otp';

  @override
  String bankLinking_resendOtpIn(int seconds) {
    return 'Resend otp in ${seconds}s';
  }

  @override
  String get bankLinking_selectBank => 'Selecionar bank';

  @override
  String get bankLinking_selectBankDesc => 'Choose your bank to link';

  @override
  String get bankLinking_selectBankTitle => 'Selecionar your bank';

  @override
  String get bankLinking_suspended => 'Suspended';

  @override
  String get bankLinking_verificationDesc =>
      'Enter the otp sent to your telefone';

  @override
  String get bankLinking_verificationFailed => 'Verificação falhado';

  @override
  String get bankLinking_verificationRequired => 'Verificação obrigatório';

  @override
  String get bankLinking_verificationSuccess => 'Conta verificado';

  @override
  String get bankLinking_verificationTitle => 'Verificar conta';

  @override
  String get bankLinking_verified => 'Verificado';

  @override
  String get bankLinking_verify => 'Verificar';

  @override
  String get bankLinking_verifyAccount => 'Verificar conta';

  @override
  String get bankLinking_withdraw => 'Levantar';

  @override
  String bankLinking_withdrawConfirmation(String amount) {
    return 'Levantar $amount para o seu banco?';
  }

  @override
  String get bankLinking_withdrawInfo =>
      'Funds will arrive in 1-3 business days';

  @override
  String get bankLinking_withdrawSuccess => 'Withdrawal successful';

  @override
  String get bankLinking_withdrawTime => 'A processar hora: 1-3 business days';

  @override
  String get bankLinking_withdrawToBank => 'Levantar to bank';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get expenses_totalAmount => 'Total valor';

  @override
  String get kyc_additionalDocs_title => 'Additional documentos';

  @override
  String get kyc_additionalDocs_description =>
      'Provide additional information for verificação';

  @override
  String get kyc_additionalDocs_employment_title => 'Employment information';

  @override
  String get kyc_additionalDocs_occupation => 'Occupation';

  @override
  String get kyc_additionalDocs_employer => 'Employer';

  @override
  String get kyc_additionalDocs_monthlyIncome => 'Mensalmente income';

  @override
  String get kyc_additionalDocs_sourceOfFunds_title => 'Source of funds';

  @override
  String get kyc_additionalDocs_sourceOfFunds_description =>
      'Tell us sobre your source of funds';

  @override
  String get kyc_additionalDocs_sourceDetails => 'Source detalhes';

  @override
  String get kyc_additionalDocs_supportingDocs_title => 'Supporting documentos';

  @override
  String get kyc_additionalDocs_supportingDocs_description =>
      'Carregar documentos to verificar your information';

  @override
  String get kyc_additionalDocs_takePhoto => 'Take photo';

  @override
  String get kyc_additionalDocs_uploadFile => 'Carregar file';

  @override
  String get kyc_additionalDocs_error => 'Falhado to submeter documentos';

  @override
  String get kyc_additionalDocs_info_title => 'Why we need this';

  @override
  String get kyc_additionalDocs_info_description =>
      'This helps us verificar your identity';

  @override
  String get kyc_additionalDocs_submit => 'Submeter documentos';

  @override
  String get kyc_additionalDocs_sourceType_salary => 'Salary';

  @override
  String get kyc_additionalDocs_sourceType_business => 'Business income';

  @override
  String get kyc_additionalDocs_sourceType_investments => 'Investments';

  @override
  String get kyc_additionalDocs_sourceType_savings => 'Savings';

  @override
  String get kyc_additionalDocs_sourceType_inheritance => 'Inheritance';

  @override
  String get kyc_additionalDocs_sourceType_gift => 'Gift';

  @override
  String get kyc_additionalDocs_sourceType_other => 'Outro';

  @override
  String get kyc_additionalDocs_suggestion_paySlip => 'Pay slip';

  @override
  String get kyc_additionalDocs_suggestion_bankStatement => 'Bank statement';

  @override
  String get kyc_additionalDocs_suggestion_businessReg =>
      'Business registration';

  @override
  String get kyc_additionalDocs_suggestion_taxReturn => 'Tax return';

  @override
  String get kyc_address_title => 'Endereço verificação';

  @override
  String get kyc_address_description => 'Verificar your residential endereço';

  @override
  String get kyc_address_form_title => 'Your endereço';

  @override
  String get kyc_address_addressLine1 => 'Endereço line 1';

  @override
  String get kyc_address_addressLine2 => 'Endereço line 2';

  @override
  String get kyc_address_city => 'City';

  @override
  String get kyc_address_state => 'State/region';

  @override
  String get kyc_address_postalCode => 'Postal code';

  @override
  String get kyc_address_country => 'País';

  @override
  String get kyc_address_proofDocument_title => 'Proof of endereço';

  @override
  String get kyc_address_proofDocument_description =>
      'Carregar a documento showing your endereço';

  @override
  String get kyc_address_takePhoto => 'Take photo';

  @override
  String get kyc_address_retakePhoto => 'Retake photo';

  @override
  String get kyc_address_chooseFile => 'Choose file';

  @override
  String get kyc_address_changeFile => 'Change file';

  @override
  String get kyc_address_uploadDocument => 'Carregar documento';

  @override
  String get kyc_address_submit => 'Submeter endereço';

  @override
  String get kyc_address_error => 'Falhado to submeter endereço';

  @override
  String get kyc_address_info_title => 'Accepted documentos';

  @override
  String get kyc_address_info_description =>
      'Documentos must be dated within 3 months';

  @override
  String get kyc_address_docType_utilityBill => 'Utility bill';

  @override
  String get kyc_address_docType_utilityBill_description =>
      'Electricity, water, or gas bill';

  @override
  String get kyc_address_docType_bankStatement => 'Bank statement';

  @override
  String get kyc_address_docType_bankStatement_description =>
      'Recentes bank statement';

  @override
  String get kyc_address_docType_governmentLetter => 'Government letter';

  @override
  String get kyc_address_docType_governmentLetter_description =>
      'Official government correspondence';

  @override
  String get kyc_address_docType_rentalAgreement => 'Rental agreement';

  @override
  String get kyc_address_docType_rentalAgreement_description =>
      'Signed rental or lease agreement';

  @override
  String get kyc_video_title => 'Video verificação';

  @override
  String get kyc_video_instructions_title => 'Before you começar';

  @override
  String get kyc_video_instructions_description =>
      'Follow these guidelines for best results';

  @override
  String get kyc_video_instruction_lighting_title => 'Good lighting';

  @override
  String get kyc_video_instruction_lighting_description =>
      'Find a well-lit area';

  @override
  String get kyc_video_instruction_position_title => 'Face position';

  @override
  String get kyc_video_instruction_position_description =>
      'Keep your face in the frame';

  @override
  String get kyc_video_instruction_quiet_title => 'Quiet environment';

  @override
  String get kyc_video_instruction_quiet_description => 'Find a quiet place';

  @override
  String get kyc_video_instruction_solo_title => 'Be alone';

  @override
  String get kyc_video_instruction_solo_description =>
      'Only you should be in the frame';

  @override
  String get kyc_video_actions_title => 'Follow instructions';

  @override
  String get kyc_video_actions_description =>
      'Completar each action as prompted';

  @override
  String get kyc_video_action_lookStraight => 'Look straight';

  @override
  String get kyc_video_action_turnLeft => 'Turn left';

  @override
  String get kyc_video_action_turnRight => 'Turn right';

  @override
  String get kyc_video_action_smile => 'Smile';

  @override
  String get kyc_video_action_blink => 'Blink';

  @override
  String get kyc_video_startRecording => 'Começar recording';

  @override
  String get kyc_video_continue => 'Continuar';

  @override
  String get kyc_video_preview_title => 'Preview';

  @override
  String get kyc_video_preview_description => 'Review your video';

  @override
  String get kyc_video_preview_videoRecorded => 'Video recorded';

  @override
  String get kyc_video_retake => 'Retake';

  @override
  String get kyc_upgrade_title => 'Upgrade verificação';

  @override
  String get kyc_upgrade_selectTier => 'Selecionar tier';

  @override
  String get kyc_upgrade_selectTier_description =>
      'Choose your verificação level';

  @override
  String get kyc_upgrade_currentTier => 'Current tier';

  @override
  String get kyc_upgrade_recommended => 'Recommended';

  @override
  String get kyc_upgrade_perTransaction => 'Per transação';

  @override
  String get kyc_upgrade_dailyLimit => 'Diariamente limite';

  @override
  String get kyc_upgrade_monthlyLimit => 'Mensalmente limite';

  @override
  String get kyc_upgrade_andMore => 'and more';

  @override
  String get kyc_upgrade_requirements_title => 'Requirements';

  @override
  String get kyc_upgrade_requirement_idDocument => 'Id documento';

  @override
  String get kyc_upgrade_requirement_selfie => 'Selfie';

  @override
  String get kyc_upgrade_requirement_addressProof => 'Endereço proof';

  @override
  String get kyc_upgrade_requirement_sourceOfFunds => 'Source of funds';

  @override
  String get kyc_upgrade_requirement_videoVerification => 'Video verificação';

  @override
  String get kyc_upgrade_startVerification => 'Começar verificação';

  @override
  String get kyc_upgrade_reason_title => 'Why upgrade?';

  @override
  String get settings_deviceTrustedSuccess => 'Dispositivo marked as trusted';

  @override
  String get settings_deviceTrustError => 'Falhado to trust dispositivo';

  @override
  String get settings_deviceRemovedSuccess =>
      'Dispositivo removed successfully';

  @override
  String get settings_deviceRemoveError => 'Falhado to remover dispositivo';

  @override
  String get settings_help => 'Ajuda & suporte';

  @override
  String get settings_rateApp => 'Rate joonapay';

  @override
  String get settings_rateAppDescription =>
      'Enjoying joonapay? rate us on the app store';

  @override
  String get action_copiedToClipboard => 'Copied to clipboard';

  @override
  String get transfer_successTitle => 'Transferir successful!';

  @override
  String transfer_successMessage(String amount) {
    return 'Your transferir of $amount was successful';
  }

  @override
  String get transactions_transactionId => 'Transação id';

  @override
  String get common_amount => 'Valor';

  @override
  String get transactions_status => 'Estado';

  @override
  String get transactions_completed => 'Concluído';

  @override
  String get transactions_noAccountTitle => 'No Wallet Found';

  @override
  String get transactions_noAccountMessage =>
      'Create your wallet to start tracking your transactions and payment history.';

  @override
  String get transactions_connectionErrorTitle => 'Unable to Load';

  @override
  String get transactions_connectionErrorMessage =>
      'Please check your internet connection and try again.';

  @override
  String get transactions_emptyStateTitle => 'No Transactions Yet';

  @override
  String get transactions_emptyStateMessage =>
      'Once you make your first deposit or transfer, your transaction history will appear here.';

  @override
  String get transactions_emptyStateAction => 'Make First Deposit';

  @override
  String get common_note => 'Note';

  @override
  String get action_shareReceipt => 'Partilhar receipt';

  @override
  String get withdraw_mobileMoney => 'Mobile money';

  @override
  String get withdraw_bankTransfer => 'Bank transferir';

  @override
  String get withdraw_crypto => 'Crypto carteira';

  @override
  String get withdraw_mobileMoneyDesc => 'Levantar to orange money, mtn, wave';

  @override
  String get withdraw_bankDesc => 'Transferir to your bank conta';

  @override
  String get withdraw_cryptoDesc => 'Enviar to external carteira';

  @override
  String get navigation_withdraw => 'Levantar';

  @override
  String get withdraw_method => 'Withdrawal method';

  @override
  String get withdraw_processingInfo => 'A processar times vary by method';

  @override
  String get withdraw_amountLabel => 'Valor to levantar';

  @override
  String get withdraw_mobileNumber => 'Mobile money number';

  @override
  String get withdraw_bankDetails => 'Bank detalhes';

  @override
  String get withdraw_walletAddress => 'Carteira endereço';

  @override
  String get withdraw_networkWarning =>
      'Make sure you are sending to a solana usdc endereço';

  @override
  String get legal_cookiePolicy => 'Política de cookies';

  @override
  String get legal_effectiveDate => 'Effective';

  @override
  String get legal_whatsNew => 'What\'s new';

  @override
  String get legal_contactUs => 'Contacto us';

  @override
  String get legal_cookieContactDescription =>
      'If you have questions sobre our cookie policy, please contacto us:';

  @override
  String get legal_cookieCategories => 'Cookie categories';

  @override
  String get legal_essential => 'Essential';

  @override
  String get legal_functional => 'Functional';

  @override
  String get legal_analytics => 'Analytics';

  @override
  String get legal_required => 'Obrigatório';

  @override
  String get legal_cookiePolicyDescription => 'Ver our cookie usage policy';

  @override
  String get legal_legalDocuments => 'Legal documentos';

  @override
  String get error_loadFailed => 'Falhado to load';

  @override
  String get error_tryAgainLater => 'Please try again later';

  @override
  String get error_timeout =>
      'Tempo limite de pedido excedido. Por favor, tente novamente.';

  @override
  String get error_noInternet =>
      'No internet connection. please check your network and try again.';

  @override
  String get error_requestCancelled => 'Request was cancelado';

  @override
  String get error_sslError => 'Connection segurança erro. please try again.';

  @override
  String get error_otpExpired =>
      'Verificação code has expired. request a new code.';

  @override
  String get error_tooManyOtpAttempts =>
      'Too many falhado attempts. please wait before trying again.';

  @override
  String get error_invalidCredentials =>
      'Inválido credentials. please check and try again.';

  @override
  String get error_accountLocked =>
      'Your conta has been locked. please contacto suporte.';

  @override
  String get error_accountSuspended =>
      'Your conta has been suspended. please contacto suporte for assistance.';

  @override
  String get error_sessionExpired =>
      'Your session has expired. please log in again.';

  @override
  String get error_kycRequired =>
      'Identity verificação obrigatório to continuar. completar verificação in definições.';

  @override
  String get error_kycPending =>
      'Your identity verificação is being reviewed. please wait.';

  @override
  String get error_kycRejected =>
      'Your identity verificação was rejected. please resubmit with válido documentos.';

  @override
  String get error_kycExpired =>
      'Your identity verificação has expired. please verificar again.';

  @override
  String get error_amountTooLow =>
      'Valor is below minimum. please enter a higher valor.';

  @override
  String get error_amountTooHigh =>
      'Valor exceeds maximum. please enter a lower valor.';

  @override
  String get error_dailyLimitExceeded =>
      'Diariamente transação limite reached. try again tomorrow or upgrade your conta.';

  @override
  String get error_monthlyLimitExceeded =>
      'Mensalmente transação limite reached. please wait or upgrade your conta.';

  @override
  String get error_transactionLimitExceeded =>
      'Transação limite exceeded for this operation.';

  @override
  String get error_duplicateTransaction =>
      'This transação was already processed. please check your histórico.';

  @override
  String get error_pinLocked =>
      'Pin locked due to too many incorrect attempts. repor your pin to continuar.';

  @override
  String get error_pinTooWeak =>
      'Pin is too simple. please choose a stronger pin.';

  @override
  String get error_beneficiaryNotFound =>
      'Beneficiary not found. please check and try again.';

  @override
  String get error_beneficiaryLimitReached =>
      'Maximum number of beneficiaries reached. remover one to adicionar a new beneficiary.';

  @override
  String get error_providerUnavailable =>
      'Service provider is currently unavailable. please try again later.';

  @override
  String get error_providerTimeout =>
      'Service provider is not responding. please try again.';

  @override
  String get error_providerMaintenance =>
      'Service provider is under maintenance. please try again later.';

  @override
  String get error_rateLimited =>
      'Too many requests. please slow down and try again in a moment.';

  @override
  String get error_invalidAddress =>
      'Inválido carteira endereço. please check and try again.';

  @override
  String get error_invalidCountry => 'Service not disponível in your país.';

  @override
  String get error_deviceNotTrusted =>
      'This dispositivo is not trusted. please verificar your identity.';

  @override
  String get error_deviceLimitReached =>
      'Maximum number of dispositivos reached. remover a dispositivo to adicionar this one.';

  @override
  String get error_biometricRequired =>
      'Biometric authentication is obrigatório for this action.';

  @override
  String get error_badRequest =>
      'Inválido request. please check your information and try again.';

  @override
  String get error_unauthorized =>
      'Não autorizado. Por favor, inicie sessão novamente.';

  @override
  String get error_accessDenied =>
      'You don\'t have permission to perform this action.';

  @override
  String get error_notFound => 'Recurso não encontrado.';

  @override
  String get error_conflict =>
      'Request conflicts with current state. please atualizar and try again.';

  @override
  String get error_validationFailed =>
      'Please check the information you provided and try again.';

  @override
  String get error_serverError =>
      'Server erro. our team has been notified. please try again later.';

  @override
  String get error_serviceUnavailable =>
      'Service temporarily unavailable. please try again in a few moments.';

  @override
  String get error_gatewayTimeout =>
      'Service is taking too long to respond. please try again.';

  @override
  String get error_authenticationFailed =>
      'Authentication falhado. please try again.';

  @override
  String get error_suggestion_checkConnection =>
      'Check your internet connection';

  @override
  String get error_suggestion_tryAgain => 'Try again';

  @override
  String get error_suggestion_loginAgain => 'Log in again';

  @override
  String get error_suggestion_completeKyc => 'Completar verificação';

  @override
  String get error_suggestion_addFunds => 'Adicionar funds to your carteira';

  @override
  String get error_suggestion_waitOrUpgrade => 'Wait or upgrade your conta';

  @override
  String get error_suggestion_tryLater => 'Try again later';

  @override
  String get error_suggestion_resetPin => 'Repor your pin';

  @override
  String get error_suggestion_slowDown => 'Slow down and wait a moment';

  @override
  String get error_offline_title => 'You\'re offline';

  @override
  String get error_offline_message =>
      'You\'re not connected to the internet. some features may not be disponível.';

  @override
  String get error_offline_retry => 'Tentar novamente connection';

  @override
  String get action_skip => 'Saltar';

  @override
  String get action_next => 'Seguinte';

  @override
  String get onboarding_page1_title => 'Your money, your way';

  @override
  String get onboarding_page1_description =>
      'Store, enviar, and receber usdc securely. your digital carteira built for west africa.';

  @override
  String get onboarding_page1_feature1 => 'Store usdc safely in your carteira';

  @override
  String get onboarding_page1_feature2 => 'Enviar money to anyone instantly';

  @override
  String get onboarding_page1_feature3 => 'Access your funds 24/7';

  @override
  String get onboarding_page2_title => 'Lightning-fast transfers';

  @override
  String get onboarding_page2_description =>
      'Transferir funds to friends and family in seconds. no borders, no delays.';

  @override
  String get onboarding_page2_feature1 => 'Instant transfers within joonapay';

  @override
  String get onboarding_page2_feature2 => 'Enviar to any mobile money conta';

  @override
  String get onboarding_page2_feature3 => 'Real-hora transação updates';

  @override
  String get onboarding_page3_title => 'Easy deposits & withdrawals';

  @override
  String get onboarding_page3_description =>
      'Adicionar money via mobile money. cash out to your local conta anytime.';

  @override
  String get onboarding_page3_feature1 =>
      'Depositar with orange money, mtn, wave';

  @override
  String get onboarding_page3_feature2 => 'Low transação taxas (1%)';

  @override
  String get onboarding_page3_feature3 => 'Levantar anytime to your conta';

  @override
  String get onboarding_page4_title => 'Bank-level segurança';

  @override
  String get onboarding_page4_description =>
      'Your funds are protected with state-of-the-art encryption and biometric authentication.';

  @override
  String get onboarding_page4_feature1 => 'Pin and biometric protection';

  @override
  String get onboarding_page4_feature2 => 'End-to-end encryption';

  @override
  String get onboarding_page4_feature3 => '24/7 fraud monitoring';

  @override
  String welcome_title(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get welcome_subtitle =>
      'Your joonapay carteira is ready. começar sending and receiving money hoje!';

  @override
  String get welcome_addFunds => 'Adicionar funds';

  @override
  String get welcome_exploreDashboard => 'Explore dashboard';

  @override
  String get welcome_stat_wallet => 'Secure carteira';

  @override
  String get welcome_stat_wallet_desc => 'Your funds are safe with us';

  @override
  String get welcome_stat_instant => 'Instant transfers';

  @override
  String get welcome_stat_instant_desc => 'Enviar money in seconds';

  @override
  String get welcome_stat_secure => 'Bank-level segurança';

  @override
  String get welcome_stat_secure_desc => 'Protected by advanced encryption';

  @override
  String get onboarding_deposit_prompt_title =>
      'Get started with your first depositar';

  @override
  String get onboarding_deposit_prompt_subtitle =>
      'Adicionar funds to começar sending and receiving money';

  @override
  String get onboarding_deposit_benefit1 => 'Instant deposits via mobile money';

  @override
  String get onboarding_deposit_benefit2 => 'Only 1% transação taxa';

  @override
  String get onboarding_deposit_benefit3 => 'Funds disponível immediately';

  @override
  String get onboarding_deposit_cta => 'Adicionar money now';

  @override
  String get help_whatIsUsdc => 'What is usdc?';

  @override
  String get help_usdc_title => 'Usdc: digital dollar';

  @override
  String get help_usdc_subtitle => 'The stable digital moeda';

  @override
  String get help_usdc_what_title => 'What is usdc?';

  @override
  String get help_usdc_what_description =>
      'Usdc (usd coin) is a digital moeda that\'s always worth exactly \$1 usd. it combines the stability of the us dollar with the speed and efficiency of blockchain technology.';

  @override
  String get help_usdc_why_title => 'Why use usdc?';

  @override
  String get help_usdc_benefit1_title => 'Stable value';

  @override
  String get help_usdc_benefit1_description =>
      'Always worth \$1 usd - no volatility';

  @override
  String get help_usdc_benefit2_title => 'Secure & transparent';

  @override
  String get help_usdc_benefit2_description =>
      'Backed 1:1 by real us dollars held in reserve';

  @override
  String get help_usdc_benefit3_title => 'Global access';

  @override
  String get help_usdc_benefit3_description =>
      'Enviar money anywhere in the world instantly';

  @override
  String get help_usdc_benefit4_title => '24/7 Availability';

  @override
  String get help_usdc_benefit4_description =>
      'Access your money anytime, anywhere';

  @override
  String get help_usdc_how_title => 'How it works';

  @override
  String get help_usdc_how_description =>
      'When you depositar money, it\'s converted to usdc at a 1:1 rate with usd. you can then enviar usdc to anyone or convert it voltar to your local moeda anytime.';

  @override
  String get help_usdc_safety_title => 'Is it safe?';

  @override
  String get help_usdc_safety_description =>
      'Yes! usdc is issued by circle, a regulated financial institution. every usdc is backed by real us dollars held in reserve accounts.';

  @override
  String get help_howDepositsWork => 'How deposits work';

  @override
  String get help_deposits_header => 'Adding money to your carteira';

  @override
  String get help_deposits_intro =>
      'Depositing funds into your joonapay carteira is quick and easy using mobile money serviços disponível across west africa.';

  @override
  String get help_deposits_steps_title => 'How to depositar';

  @override
  String get help_deposits_step1_title => 'Choose valor';

  @override
  String get help_deposits_step1_description =>
      'Enter how much you want to adicionar to your carteira';

  @override
  String get help_deposits_step2_title => 'Selecionar provider';

  @override
  String get help_deposits_step2_description =>
      'Choose your mobile money provider (orange money, mtn, etc.)';

  @override
  String get help_deposits_step3_title => 'Completar payment';

  @override
  String get help_deposits_step3_description =>
      'Follow the ussd prompt on your telefone to authorize the payment';

  @override
  String get help_deposits_step4_title => 'Funds added';

  @override
  String get help_deposits_step4_description =>
      'Your usdc saldo updates within seconds';

  @override
  String get help_deposits_providers_title => 'Supported providers';

  @override
  String get help_deposits_time_title => 'A processar hora';

  @override
  String get help_deposits_time_description =>
      'Most deposits are processed within 1-2 minutes';

  @override
  String get help_deposits_faq_title => 'Common questions';

  @override
  String get help_deposits_faq1_question => 'What\'s the minimum depositar?';

  @override
  String get help_deposits_faq1_answer =>
      'The minimum depositar is 1,000 xof (approximately \$1.60 usd)';

  @override
  String get help_deposits_faq2_question => 'Are there taxas?';

  @override
  String get help_deposits_faq2_answer =>
      'Yes, there\'s a 1% transação taxa on deposits';

  @override
  String get help_deposits_faq3_question => 'What if my depositar fails?';

  @override
  String get help_deposits_faq3_answer =>
      'Your money will be automatically refunded to your mobile money conta within 24 hours';

  @override
  String get help_transactionFees => 'Transação taxas';

  @override
  String get help_fees_no_hidden_title => 'No hidden taxas';

  @override
  String get help_fees_no_hidden_description =>
      'We believe in transparency. here\'s exactly what you pay.';

  @override
  String get help_fees_breakdown_title => 'Taxa breakdown';

  @override
  String get help_fees_internal_transfers => 'Transfers to joonapay users';

  @override
  String get help_fees_free => 'Free';

  @override
  String get help_fees_internal_description =>
      'Enviar money to outro joonapay users with zero taxas';

  @override
  String get help_fees_deposits => 'Mobile money deposits';

  @override
  String get help_fees_deposits_amount => '1%';

  @override
  String get help_fees_deposits_description =>
      '1% taxa when adding funds via mobile money';

  @override
  String get help_fees_withdrawals => 'Withdrawals to mobile money';

  @override
  String get help_fees_withdrawals_amount => '1%';

  @override
  String get help_fees_withdrawals_description =>
      '1% taxa when cashing out to mobile money';

  @override
  String get help_fees_external_transfers => 'External crypto transfers';

  @override
  String get help_fees_external_amount => 'Network taxa';

  @override
  String get help_fees_external_description =>
      'Blockchain network taxa applies (varies by network)';

  @override
  String get help_fees_why_title => 'Why do we charge taxas?';

  @override
  String get help_fees_why_description => 'Our taxas ajuda us:';

  @override
  String get help_fees_why_point1 =>
      'Maintain secure infrastructure and compliance';

  @override
  String get help_fees_why_point2 => 'Provide 24/7 customer suporte';

  @override
  String get help_fees_why_point3 => 'Cover mobile money provider charges';

  @override
  String get help_fees_why_point4 => 'Continuar improving our serviços';

  @override
  String get help_fees_comparison_title => 'How we compare';

  @override
  String get help_fees_comparison_description =>
      'Our taxas are significantly lower than traditional money transferir serviços:';

  @override
  String get help_fees_comparison_traditional => 'Traditional serviços';

  @override
  String get help_fees_comparison_joonapay => 'Korido';

  @override
  String get offline_banner_title => 'You\'re offline';

  @override
  String offline_banner_last_sync(String time) {
    return 'Last synced $time';
  }

  @override
  String get offline_banner_syncing => 'Syncing pendente operations...';

  @override
  String get offline_banner_reconnected => 'Voltar online! todos synced.';

  @override
  String get state_otpExpired => 'OTP code has expired';

  @override
  String get state_otpExpiredDescription =>
      'Your one-time password has expired. Please request a new code.';

  @override
  String get state_tokenRefreshing => 'Refreshing your access...';

  @override
  String get state_accountLocked => 'Account locked';

  @override
  String get state_accountLockedDescription =>
      'Your account has been locked due to multiple failed attempts. Please try again later.';

  @override
  String get state_accountSuspended => 'Account suspended';

  @override
  String get state_accountSuspendedDescription =>
      'Your account has been suspended. Please contact support for more information.';

  @override
  String get state_walletFrozen => 'Wallet frozen';

  @override
  String get state_walletFrozenDescription =>
      'Your wallet has been frozen for security reasons. Please contact support.';

  @override
  String get state_walletUnderReview => 'Wallet under review';

  @override
  String get state_walletUnderReviewDescription =>
      'Your wallet is currently under review. Transactions are temporarily restricted.';

  @override
  String get state_walletLimited => 'Wallet limited';

  @override
  String get state_walletLimitedDescription =>
      'Your wallet has reached its transaction or balance limit. Upgrade your account to increase limits.';

  @override
  String get state_kycExpired => 'KYC verification expired';

  @override
  String get state_kycExpiredDescription =>
      'Your identity verification has expired. Please update your information to continue.';

  @override
  String get state_kycManualReview => 'KYC manual review pending';

  @override
  String get state_kycManualReviewDescription =>
      'Your identity verification is being manually reviewed. This may take 24-48 hours.';

  @override
  String get state_kycUpgrading => 'KYC level upgrading';

  @override
  String get state_kycUpgradingDescription =>
      'Your identity verification level is being upgraded. Please wait.';

  @override
  String get state_biometricPrompt => 'Biometric authentication required';

  @override
  String get state_biometricPromptDescription =>
      'Please use your fingerprint or face to authenticate.';

  @override
  String get state_deviceChanged => 'Device verification required';

  @override
  String get state_deviceChangedDescription =>
      'This appears to be a new device. Please verify your identity to continue.';

  @override
  String get state_sessionConflict => 'Another session is active';

  @override
  String get state_sessionConflictDescription =>
      'You are logged in on another device. Please log out there or continue here.';

  @override
  String get auth_lockedReason =>
      'Your account has been temporarily locked due to multiple failed attempts';

  @override
  String get auth_accountLocked => 'Account Temporarily Locked';

  @override
  String get auth_tryAgainIn => 'Try again in';

  @override
  String get common_backToLogin => 'Back to Login';

  @override
  String get auth_suspendedReason =>
      'Your account has been suspended. Please contact support for more information.';

  @override
  String get auth_accountSuspended => 'Account Suspended';

  @override
  String get auth_suspendedUntil => 'Suspended until';

  @override
  String get auth_contactSupport => 'Need Help?';

  @override
  String get auth_suspendedContactMessage =>
      'If you believe this is a mistake, please contact our support team for assistance.';

  @override
  String get common_contactSupport => 'Contact Support';

  @override
  String get biometric_authenticateReason => 'Authenticate to continue';

  @override
  String get biometric_promptReason =>
      'Please use your fingerprint or face to authenticate';

  @override
  String get biometric_promptTitle => 'Biometric Authentication';

  @override
  String get biometric_tryAgain => 'Try Again';

  @override
  String get biometric_usePinInstead => 'Use PIN Instead';

  @override
  String get auth_otpExpired => 'OTP Code Expired';

  @override
  String get auth_otpExpiredMessage =>
      'Your verification code has expired. Please request a new code.';

  @override
  String get session_locked => 'Session Locked';

  @override
  String get session_lockedMessage =>
      'Your session has been locked. Please enter your PIN to continue.';

  @override
  String get session_enterPinToUnlock => 'Enter PIN to Unlock';

  @override
  String get session_useBiometric => 'Use Biometric';

  @override
  String get session_unlockReason => 'Unlock your session to continue';

  @override
  String get session_expiring => 'Session Expiring';

  @override
  String session_expiringMessage(int seconds) {
    return 'Your session will expire in $seconds seconds due to inactivity.';
  }

  @override
  String get session_stayLoggedIn => 'Stay Logged In';

  @override
  String get device_newDeviceDetected => 'New Device Detected';

  @override
  String get device_verificationRequired =>
      'We detected a new device. Please verify your identity to continue using JoonaPay.';

  @override
  String get device_deviceId => 'Device ID';

  @override
  String get device_verificationOptions => 'Verification Options';

  @override
  String get device_verificationOptionsDesc =>
      'Choose how you\'d like to verify this device';

  @override
  String get device_verifyWithOtp => 'Verify with SMS Code';

  @override
  String get device_verifyWithEmail => 'Verify with Email';

  @override
  String get session_conflict => 'Active Session Detected';

  @override
  String get session_conflictMessage =>
      'You are currently logged in on another device. You can continue here, which will log you out from the other device.';

  @override
  String get session_otherDevice => 'Other Device';

  @override
  String get session_forceLogoutWarning =>
      'Continuing here will end your session on the other device.';

  @override
  String get session_continueHere => 'Continue Here';

  @override
  String get wallet_frozenReason =>
      'Your wallet has been frozen. Please contact support for more information.';

  @override
  String get wallet_frozen => 'Wallet Frozen';

  @override
  String get wallet_frozenTitle => 'Wallet Temporarily Frozen';

  @override
  String get wallet_frozenUntil => 'Frozen until';

  @override
  String get wallet_frozenContactSupport => 'Contact Support';

  @override
  String get wallet_frozenContactMessage =>
      'Our support team can help you understand why your wallet was frozen and what steps to take next.';

  @override
  String get common_backToHome => 'Back to Home';

  @override
  String get wallet_underReviewReason =>
      'Your wallet is under compliance review. You\'ll be notified once the review is complete.';

  @override
  String get wallet_underReview => 'Under Review';

  @override
  String get wallet_underReviewTitle => 'Wallet Under Review';

  @override
  String get wallet_reviewStatus => 'Review Status';

  @override
  String get wallet_reviewStarted => 'Started';

  @override
  String get wallet_estimatedTime => 'Estimated Time';

  @override
  String get wallet_reviewEstimate => '24-48 hours';

  @override
  String get wallet_whileUnderReview => 'While Under Review';

  @override
  String get wallet_reviewRestriction1 => 'Deposits are temporarily disabled';

  @override
  String get wallet_reviewRestriction2 =>
      'Withdrawals are temporarily disabled';

  @override
  String get wallet_reviewRestriction3 =>
      'You can view your balance and transaction history';

  @override
  String get wallet_checkStatus => 'Check Status';

  @override
  String get kyc_expired => 'KYC Expired';

  @override
  String get kyc_expiredTitle => 'Identity Documents Expired';

  @override
  String get kyc_expiredMessage =>
      'Your identity verification documents have expired. Please renew them to continue using all features.';

  @override
  String get kyc_expiredOn => 'Expired on';

  @override
  String get kyc_renewalRequired => 'Renewal Required';

  @override
  String get kyc_renewalMessage =>
      'To restore full access to your wallet, please update your identity documents.';

  @override
  String get kyc_currentRestrictions => 'Current Restrictions';

  @override
  String get kyc_restriction1 => 'Limited transaction amounts';

  @override
  String get kyc_restriction2 => 'Some features may be unavailable';

  @override
  String get kyc_restriction3 => 'Withdrawals may be restricted';

  @override
  String get kyc_renewDocuments => 'Renew Documents';

  @override
  String get kyc_remindLater => 'Remind Me Later';

  @override
  String get action_backToHome => 'Back to Home';

  @override
  String get action_checkStatus => 'Check Status';

  @override
  String get action_ok => 'OK';

  @override
  String get common_errorTryAgain => 'Something went wrong. Please try again.';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_unknownError => 'An unknown error occurred';

  @override
  String get deposit_amount => 'Amount';

  @override
  String get deposit_approveOnPhone =>
      'Approve the payment on your phone by entering your PIN';

  @override
  String get deposit_balanceUpdated => 'Your balance has been updated';

  @override
  String get deposit_cardPaymentComingSoon => 'Card payment coming soon';

  @override
  String get deposit_choosePaymentMethod => 'Choose Payment Method';

  @override
  String get deposit_dialUSSD => 'Dial the USSD code below to get your OTP';

  @override
  String get deposit_enterOTP => 'Enter OTP';

  @override
  String deposit_errorReason(String reason) {
    return 'Error: $reason';
  }

  @override
  String get deposit_failedDesc => 'Your deposit could not be completed';

  @override
  String get deposit_failedTitle => 'Deposit Failed';

  @override
  String get deposit_noDepositData => 'No deposit data available';

  @override
  String get deposit_noProvidersAvailable => 'No Providers Available';

  @override
  String get deposit_noProvidersAvailableDesc =>
      'No deposit providers are currently available. Please try again later.';

  @override
  String get deposit_openInWave => 'Open in Wave';

  @override
  String get deposit_orScanQR => 'Or scan the QR code below';

  @override
  String get deposit_payment => 'Payment';

  @override
  String get deposit_processingDesc =>
      'We are processing your deposit. This may take a moment.';

  @override
  String get deposit_processingSubtitle =>
      'Please wait while we verify your payment';

  @override
  String get deposit_processingTitle => 'Processing Deposit';

  @override
  String get deposit_scanQRCode => 'Scan QR Code';

  @override
  String get deposit_selectHowToDeposit => 'Select how you want to deposit';

  @override
  String get deposit_submitOTP => 'Submit OTP';

  @override
  String get deposit_successDesc =>
      'Your deposit has been completed successfully';

  @override
  String get deposit_successTitle => 'Deposit Successful';

  @override
  String get deposit_waitingForApproval => 'Waiting for approval on your phone';

  @override
  String get deposit_waitingForPayment => 'Waiting for payment';

  @override
  String get deposit_youPay => 'You Pay';

  @override
  String get deposit_youReceive => 'You Receive';
}
