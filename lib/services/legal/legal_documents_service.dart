import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

/// Legal document types
enum LegalDocumentType {
  termsOfService,
  privacyPolicy,
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
    return LegalDocument(
      id: json['id'] as String,
      type: json['type'] == 'terms_of_service'
          ? LegalDocumentType.termsOfService
          : LegalDocumentType.privacyPolicy,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type == LegalDocumentType.termsOfService
            ? 'terms_of_service'
            : 'privacy_policy',
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
    return LegalConsent(
      documentId: json['document_id'] as String,
      documentVersion: json['document_version'] as String,
      documentType: json['document_type'] == 'terms_of_service'
          ? LegalDocumentType.termsOfService
          : LegalDocumentType.privacyPolicy,
      consentedAt: DateTime.parse(json['consented_at'] as String),
      ipAddress: json['ip_address'] as String?,
      deviceId: json['device_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'document_id': documentId,
        'document_version': documentVersion,
        'document_type': documentType == LegalDocumentType.termsOfService
            ? 'terms_of_service'
            : 'privacy_policy',
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
  DateTime? _lastFetch;

  static const _cacheKey = 'legal_documents_cache';
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
      debugPrint('Error checking consent: $e');
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
      debugPrint('Failed to send consent to API: $e');
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
      final cached = type == LegalDocumentType.termsOfService
          ? _cachedTerms
          : _cachedPrivacy;
      if (cached != null && cached.locale == locale) {
        return cached;
      }
    }

    try {
      final endpoint = type == LegalDocumentType.termsOfService
          ? '/legal/terms'
          : '/legal/privacy';

      final response = await _dio.get(
        endpoint,
        queryParameters: {'locale': locale},
      );

      final document = LegalDocument.fromJson(response.data as Map<String, dynamic>);

      // Update cache
      if (type == LegalDocumentType.termsOfService) {
        _cachedTerms = document;
      } else {
        _cachedPrivacy = document;
      }
      _lastFetch = DateTime.now();

      return document;
    } catch (e) {
      debugPrint('Failed to fetch legal document: $e');
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
    if (type == LegalDocumentType.termsOfService) {
      return LegalDocument(
        id: 'tos-fallback',
        type: LegalDocumentType.termsOfService,
        version: '1.0.0',
        title: 'Terms of Service',
        content: _fallbackTermsContent,
        contentHtml: _fallbackTermsContent,
        effectiveDate: DateTime(2024, 1, 1),
        locale: locale,
      );
    } else {
      return LegalDocument(
        id: 'privacy-fallback',
        type: LegalDocumentType.privacyPolicy,
        version: '1.0.0',
        title: 'Privacy Policy',
        content: _fallbackPrivacyContent,
        contentHtml: _fallbackPrivacyContent,
        effectiveDate: DateTime(2024, 1, 1),
        locale: locale,
      );
    }
  }

  Future<void> _storeConsent(LegalConsent consent) async {
    final key = _consentKey +
        (consent.documentType == LegalDocumentType.termsOfService
            ? 'terms'
            : 'privacy');
    await _storage.write(
      key: key,
      value: consent.toJson().toString(),
    );
  }

  Future<LegalConsent?> _getStoredConsent(LegalDocumentType type) async {
    final key = _consentKey +
        (type == LegalDocumentType.termsOfService ? 'terms' : 'privacy');
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
      debugPrint('Failed to parse stored consent: $e');
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
