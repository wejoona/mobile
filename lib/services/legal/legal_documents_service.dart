import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../../utils/logger.dart';

/// Legal document types
enum LegalDocumentType {
  termsOfService,
  privacyPolicy,
  cookiePolicy,
}

/// Represents a versioned legal document
class LegalDocument {
  final String id;
  final LegalDocumentType type;
  final String version;
  final String title;
  final String content;
  final String contentHtml;
  final DateTime effectiveDate;
  final DateTime? lastUpdated;
  final String? summary; // Short summary of changes
  final String locale;

  const LegalDocument({
    required this.id,
    required this.type,
    required this.version,
    required this.title,
    required this.content,
    required this.contentHtml,
    required this.effectiveDate,
    this.lastUpdated,
    this.summary,
    this.locale = 'en',
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    LegalDocumentType docType;
    switch (json['type']) {
      case 'terms_of_service':
        docType = LegalDocumentType.termsOfService;
        break;
      case 'cookie_policy':
        docType = LegalDocumentType.cookiePolicy;
        break;
      default:
        docType = LegalDocumentType.privacyPolicy;
    }
    return LegalDocument(
      id: json['id'] as String,
      type: docType,
      version: json['version'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      contentHtml: json['content_html'] as String? ?? json['content'] as String,
      effectiveDate: DateTime.parse(json['effective_date'] as String),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
      summary: json['summary'] as String?,
      locale: json['locale'] as String? ?? 'en',
    );
  }

  String get typeString {
    switch (type) {
      case LegalDocumentType.termsOfService:
        return 'terms_of_service';
      case LegalDocumentType.privacyPolicy:
        return 'privacy_policy';
      case LegalDocumentType.cookiePolicy:
        return 'cookie_policy';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': typeString,
        'version': version,
        'title': title,
        'content': content,
        'content_html': contentHtml,
        'effective_date': effectiveDate.toIso8601String(),
        'last_updated': lastUpdated?.toIso8601String(),
        'summary': summary,
        'locale': locale,
      };

  /// Check if this version is newer than another
  bool isNewerThan(String otherVersion) {
    final thisParts = version.split('.').map(int.parse).toList();
    final otherParts = otherVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < thisParts.length && i < otherParts.length; i++) {
      if (thisParts[i] > otherParts[i]) return true;
      if (thisParts[i] < otherParts[i]) return false;
    }
    return thisParts.length > otherParts.length;
  }
}

/// User's consent record
class LegalConsent {
  final String documentId;
  final String documentVersion;
  final LegalDocumentType documentType;
  final DateTime consentedAt;
  final String? ipAddress;
  final String? deviceId;

  const LegalConsent({
    required this.documentId,
    required this.documentVersion,
    required this.documentType,
    required this.consentedAt,
    this.ipAddress,
    this.deviceId,
  });

  factory LegalConsent.fromJson(Map<String, dynamic> json) {
    LegalDocumentType docType;
    switch (json['document_type']) {
      case 'terms_of_service':
        docType = LegalDocumentType.termsOfService;
        break;
      case 'cookie_policy':
        docType = LegalDocumentType.cookiePolicy;
        break;
      default:
        docType = LegalDocumentType.privacyPolicy;
    }
    return LegalConsent(
      documentId: json['document_id'] as String,
      documentVersion: json['document_version'] as String,
      documentType: docType,
      consentedAt: DateTime.parse(json['consented_at'] as String),
      ipAddress: json['ip_address'] as String?,
      deviceId: json['device_id'] as String?,
    );
  }

  String get documentTypeString {
    switch (documentType) {
      case LegalDocumentType.termsOfService:
        return 'terms_of_service';
      case LegalDocumentType.privacyPolicy:
        return 'privacy_policy';
      case LegalDocumentType.cookiePolicy:
        return 'cookie_policy';
    }
  }

  Map<String, dynamic> toJson() => {
        'document_id': documentId,
        'document_version': documentVersion,
        'document_type': documentTypeString,
        'consented_at': consentedAt.toIso8601String(),
        'ip_address': ipAddress,
        'device_id': deviceId,
      };
}

/// Legal documents service - handles fetching and consent tracking
class LegalDocumentsService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  // Cache
  LegalDocument? _cachedTerms;
  LegalDocument? _cachedPrivacy;
  LegalDocument? _cachedCookiePolicy;
  DateTime? _lastFetch;

  static const _consentKey = 'legal_consent_';
  static const _cacheDuration = Duration(hours: 24);

  LegalDocumentsService(this._dio, this._storage);

  /// Fetch latest Terms of Service
  Future<LegalDocument> getTermsOfService({String locale = 'en'}) async {
    return _fetchDocument(LegalDocumentType.termsOfService, locale);
  }

  /// Fetch latest Privacy Policy
  Future<LegalDocument> getPrivacyPolicy({String locale = 'en'}) async {
    return _fetchDocument(LegalDocumentType.privacyPolicy, locale);
  }

  /// Fetch Cookie Policy
  Future<LegalDocument> getCookiePolicy({String locale = 'en'}) async {
    return _fetchDocument(LegalDocumentType.cookiePolicy, locale);
  }

  /// Fetch both documents
  Future<(LegalDocument terms, LegalDocument privacy)> getAllDocuments({
    String locale = 'en',
  }) async {
    final results = await Future.wait([
      getTermsOfService(locale: locale),
      getPrivacyPolicy(locale: locale),
    ]);
    return (results[0], results[1]);
  }

  /// Check if user needs to accept new versions
  Future<bool> needsConsentUpdate() async {
    try {
      final (terms, privacy) = await getAllDocuments();

      final termsConsent = await _getStoredConsent(LegalDocumentType.termsOfService);
      final privacyConsent = await _getStoredConsent(LegalDocumentType.privacyPolicy);

      // No consent recorded = needs consent
      if (termsConsent == null || privacyConsent == null) {
        return true;
      }

      // Check if documents have newer versions
      if (terms.isNewerThan(termsConsent.documentVersion)) {
        return true;
      }
      if (privacy.isNewerThan(privacyConsent.documentVersion)) {
        return true;
      }

      return false;
    } catch (e) {
      AppLogger('Error checking consent').error('Error checking consent', e);
      return false;
    }
  }

  /// Record user consent for a document
  Future<void> recordConsent({
    required LegalDocument document,
    String? deviceId,
  }) async {
    final consent = LegalConsent(
      documentId: document.id,
      documentVersion: document.version,
      documentType: document.type,
      consentedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Store locally
    await _storeConsent(consent);

    // Send to API (fire and forget, don't block on failure)
    _sendConsentToApi(consent).catchError((e) {
      AppLogger('Failed to send consent to API').error('Failed to send consent to API', e);
    });
  }

  /// Record consent for both documents
  Future<void> recordAllConsents({
    required LegalDocument terms,
    required LegalDocument privacy,
    String? deviceId,
  }) async {
    await Future.wait([
      recordConsent(document: terms, deviceId: deviceId),
      recordConsent(document: privacy, deviceId: deviceId),
    ]);
  }

  /// Get the user's consent history
  Future<List<LegalConsent>> getConsentHistory() async {
    final termsConsent = await _getStoredConsent(LegalDocumentType.termsOfService);
    final privacyConsent = await _getStoredConsent(LegalDocumentType.privacyPolicy);

    return [
      if (termsConsent != null) termsConsent,
      if (privacyConsent != null) privacyConsent,
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<LegalDocument> _fetchDocument(
    LegalDocumentType type,
    String locale,
  ) async {
    // Check cache first
    if (_isCacheValid()) {
      LegalDocument? cached;
      switch (type) {
        case LegalDocumentType.termsOfService:
          cached = _cachedTerms;
          break;
        case LegalDocumentType.privacyPolicy:
          cached = _cachedPrivacy;
          break;
        case LegalDocumentType.cookiePolicy:
          cached = _cachedCookiePolicy;
          break;
      }
      if (cached != null && cached.locale == locale) {
        return cached;
      }
    }

    try {
      String endpoint;
      switch (type) {
        case LegalDocumentType.termsOfService:
          endpoint = '/legal/terms';
          break;
        case LegalDocumentType.privacyPolicy:
          endpoint = '/legal/privacy';
          break;
        case LegalDocumentType.cookiePolicy:
          endpoint = '/legal/cookies';
          break;
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: {'locale': locale},
      );

      final document = LegalDocument.fromJson(response.data as Map<String, dynamic>);

      // Update cache
      switch (type) {
        case LegalDocumentType.termsOfService:
          _cachedTerms = document;
          break;
        case LegalDocumentType.privacyPolicy:
          _cachedPrivacy = document;
          break;
        case LegalDocumentType.cookiePolicy:
          _cachedCookiePolicy = document;
          break;
      }
      _lastFetch = DateTime.now();

      return document;
    } catch (e) {
      AppLogger('Failed to fetch legal document').error('Failed to fetch legal document', e);
      // Return fallback/cached version
      return _getFallbackDocument(type, locale);
    }
  }

  bool _isCacheValid() {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheDuration;
  }

  LegalDocument _getFallbackDocument(LegalDocumentType type, String locale) {
    // Return minimal fallback document
    switch (type) {
      case LegalDocumentType.termsOfService:
        return LegalDocument(
          id: 'tos-fallback',
          type: LegalDocumentType.termsOfService,
          version: '1.0.0',
          title: locale == 'fr' ? 'Conditions d\'utilisation' : 'Terms of Service',
          content: locale == 'fr' ? _fallbackTermsContentFr : _fallbackTermsContent,
          contentHtml: locale == 'fr' ? _fallbackTermsContentFr : _fallbackTermsContent,
          effectiveDate: DateTime(2024, 1, 1),
          locale: locale,
        );
      case LegalDocumentType.privacyPolicy:
        return LegalDocument(
          id: 'privacy-fallback',
          type: LegalDocumentType.privacyPolicy,
          version: '1.0.0',
          title: locale == 'fr' ? 'Politique de confidentialite' : 'Privacy Policy',
          content: locale == 'fr' ? _fallbackPrivacyContentFr : _fallbackPrivacyContent,
          contentHtml: locale == 'fr' ? _fallbackPrivacyContentFr : _fallbackPrivacyContent,
          effectiveDate: DateTime(2024, 1, 1),
          locale: locale,
        );
      case LegalDocumentType.cookiePolicy:
        return LegalDocument(
          id: 'cookie-fallback',
          type: LegalDocumentType.cookiePolicy,
          version: '1.0.0',
          title: locale == 'fr' ? 'Politique de cookies' : 'Cookie Policy',
          content: locale == 'fr' ? _fallbackCookiePolicyContentFr : _fallbackCookiePolicyContent,
          contentHtml: locale == 'fr' ? _fallbackCookiePolicyContentFr : _fallbackCookiePolicyContent,
          effectiveDate: DateTime(2024, 1, 1),
          locale: locale,
        );
    }
  }

  Future<void> _storeConsent(LegalConsent consent) async {
    String suffix;
    switch (consent.documentType) {
      case LegalDocumentType.termsOfService:
        suffix = 'terms';
        break;
      case LegalDocumentType.privacyPolicy:
        suffix = 'privacy';
        break;
      case LegalDocumentType.cookiePolicy:
        suffix = 'cookies';
        break;
    }
    final key = _consentKey + suffix;
    await _storage.write(
      key: key,
      value: consent.toJson().toString(),
    );
  }

  Future<LegalConsent?> _getStoredConsent(LegalDocumentType type) async {
    String suffix;
    switch (type) {
      case LegalDocumentType.termsOfService:
        suffix = 'terms';
        break;
      case LegalDocumentType.privacyPolicy:
        suffix = 'privacy';
        break;
      case LegalDocumentType.cookiePolicy:
        suffix = 'cookies';
        break;
    }
    final key = _consentKey + suffix;
    final data = await _storage.read(key: key);
    if (data == null) return null;

    try {
      // Parse stored JSON string
      final jsonStr = data.replaceAll(RegExp(r"(\w+):"), '"\$1":');
      return LegalConsent.fromJson(
        Map<String, dynamic>.from(
          Uri.splitQueryString(jsonStr),
        ),
      );
    } catch (e) {
      AppLogger('Failed to parse stored consent').error('Failed to parse stored consent', e);
      return null;
    }
  }

  Future<void> _sendConsentToApi(LegalConsent consent) async {
    await _dio.post(
      '/legal/consent',
      data: consent.toJson(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FALLBACK CONTENT
  // ═══════════════════════════════════════════════════════════════════════════

  static const _fallbackTermsContent = '''
JOONAPAY TERMS OF SERVICE

Last Updated: January 2024

1. ACCEPTANCE OF TERMS
By accessing or using JoonaPay, you agree to be bound by these Terms of Service.

2. DESCRIPTION OF SERVICE
JoonaPay provides a mobile wallet for sending, receiving, and storing USDC stablecoin.

3. ELIGIBILITY
You must be at least 18 years old and capable of forming a binding contract.

4. ACCOUNT REGISTRATION
You must provide accurate information and keep your account secure.

5. PROHIBITED ACTIVITIES
You may not use JoonaPay for illegal activities, money laundering, or fraud.

6. FEES
Transaction fees may apply. Current fees are displayed before each transaction.

7. LIMITATION OF LIABILITY
JoonaPay is not liable for losses due to market fluctuations or unauthorized access.

8. GOVERNING LAW
These terms are governed by applicable laws.

For the complete Terms of Service, please visit our website or contact support.
''';

  static const _fallbackPrivacyContent = '''
JOONAPAY PRIVACY POLICY

Last Updated: January 2024

1. INFORMATION WE COLLECT
- Personal information (name, phone number, email)
- Transaction data
- Device information

2. HOW WE USE YOUR INFORMATION
- To provide and improve our services
- To verify your identity (KYC)
- To comply with legal requirements

3. INFORMATION SHARING
We do not sell your personal data. We may share information with:
- Payment processors
- Regulatory authorities (when required)
- Service providers

4. DATA SECURITY
We use industry-standard encryption and security measures.

5. YOUR RIGHTS
You have the right to access, correct, or delete your personal data.

6. CONTACT US
For privacy concerns, contact: privacy@joonapay.com

For the complete Privacy Policy, please visit our website.
''';

  static const _fallbackCookiePolicyContent = '''
JOONAPAY COOKIE POLICY

Last Updated: January 2024

1. WHAT ARE COOKIES?
Cookies are small text files stored on your device when you use our services.

2. ESSENTIAL COOKIES
We use essential cookies for:
- Authentication and session management
- Security (CSRF protection)
- Device identification

3. FUNCTIONAL COOKIES
Optional cookies that remember your preferences:
- Language preference
- Theme (dark/light mode)
- Display currency

4. HOW TO MANAGE COOKIES
You can manage cookie preferences in your device settings.
Essential cookies cannot be disabled as they are required for the app to function.

5. DATA SECURITY
All cookies use secure, encrypted storage on your device.

6. CONTACT US
For questions about cookies: privacy@joonapay.com

For the complete Cookie Policy, please visit our website.
''';

  static const _fallbackCookiePolicyContentFr = '''
POLITIQUE DE COOKIES JOONAPAY

Derniere mise a jour: Janvier 2024

1. QU'EST-CE QU'UN COOKIE?
Les cookies sont de petits fichiers texte stockes sur votre appareil lorsque vous utilisez nos services.

2. COOKIES ESSENTIELS
Nous utilisons des cookies essentiels pour:
- Authentification et gestion de session
- Securite (protection CSRF)
- Identification de l'appareil

3. COOKIES FONCTIONNELS
Cookies optionnels qui memorisent vos preferences:
- Preference de langue
- Theme (mode sombre/clair)
- Devise d'affichage

4. GESTION DES COOKIES
Vous pouvez gerer les preferences de cookies dans les parametres de votre appareil.
Les cookies essentiels ne peuvent pas etre desactives car ils sont necessaires au fonctionnement de l'application.

5. SECURITE DES DONNEES
Tous les cookies utilisent un stockage securise et chiffre sur votre appareil.

6. NOUS CONTACTER
Pour toute question sur les cookies: privacy@joonapay.com

Pour la politique complete des cookies, veuillez visiter notre site web.
''';

  static const _fallbackTermsContentFr = '''
CONDITIONS D'UTILISATION JOONAPAY

Derniere mise a jour: Janvier 2024

1. ACCEPTATION DES CONDITIONS
En accedant ou en utilisant JoonaPay, vous acceptez d'etre lie par ces Conditions d'utilisation.

2. DESCRIPTION DU SERVICE
JoonaPay fournit un portefeuille mobile pour envoyer, recevoir et stocker des USDC stablecoin.

3. ELIGIBILITE
Vous devez avoir au moins 18 ans et etre capable de conclure un contrat.

4. INSCRIPTION
Vous devez fournir des informations exactes et garder votre compte securise.

5. ACTIVITES INTERDITES
Vous ne pouvez pas utiliser JoonaPay pour des activites illegales, le blanchiment d'argent ou la fraude.

6. FRAIS
Des frais de transaction peuvent s'appliquer. Les frais actuels sont affiches avant chaque transaction.

7. LIMITATION DE RESPONSABILITE
JoonaPay n'est pas responsable des pertes dues aux fluctuations du marche ou aux acces non autorises.

8. LOI APPLICABLE
Ces conditions sont regies par les lois applicables.

Pour les Conditions d'utilisation completes, veuillez visiter notre site web ou contacter le support.
''';

  static const _fallbackPrivacyContentFr = '''
POLITIQUE DE CONFIDENTIALITE JOONAPAY

Derniere mise a jour: Janvier 2024

1. INFORMATIONS COLLECTEES
- Informations personnelles (nom, numero de telephone, email)
- Donnees de transaction
- Informations sur l'appareil

2. UTILISATION DE VOS INFORMATIONS
- Pour fournir et ameliorer nos services
- Pour verifier votre identite (KYC)
- Pour se conformer aux exigences legales

3. PARTAGE D'INFORMATIONS
Nous ne vendons pas vos donnees personnelles. Nous pouvons partager des informations avec:
- Les processeurs de paiement
- Les autorites reglementaires (si requis)
- Les prestataires de services

4. SECURITE DES DONNEES
Nous utilisons le chiffrement et des mesures de securite aux normes de l'industrie.

5. VOS DROITS
Vous avez le droit d'acceder, de corriger ou de supprimer vos donnees personnelles.

6. NOUS CONTACTER
Pour les questions de confidentialite, contactez: privacy@joonapay.com

Pour la Politique de confidentialite complete, veuillez visiter notre site web.
''';
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

final legalDocumentsServiceProvider = Provider<LegalDocumentsService>((ref) {
  return LegalDocumentsService(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});

/// Provider for Terms of Service
final termsOfServiceProvider = FutureProvider<LegalDocument>((ref) async {
  final service = ref.watch(legalDocumentsServiceProvider);
  return service.getTermsOfService();
});

/// Provider for Privacy Policy
final privacyPolicyProvider = FutureProvider<LegalDocument>((ref) async {
  final service = ref.watch(legalDocumentsServiceProvider);
  return service.getPrivacyPolicy();
});

/// Provider to check if consent update is needed
final needsConsentUpdateProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(legalDocumentsServiceProvider);
  return service.needsConsentUpdate();
});

/// Provider for Cookie Policy
final cookiePolicyProvider = FutureProvider<LegalDocument>((ref) async {
  final service = ref.watch(legalDocumentsServiceProvider);
  return service.getCookiePolicy();
});
