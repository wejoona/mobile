// Core
export 'package:usdc_wallet/services/api/api_client.dart';
export 'package:usdc_wallet/services/api/cache_interceptor.dart';
export 'package:usdc_wallet/services/api/deduplication_interceptor.dart';
export 'package:usdc_wallet/services/api/performance_utils.dart';

// SDK - Unified entry point
export 'package:usdc_wallet/services/sdk/usdc_wallet_sdk.dart';

// Individual services
export 'package:usdc_wallet/services/auth/auth_service.dart';
export 'package:usdc_wallet/services/user/user_service.dart';
export 'package:usdc_wallet/services/wallet/wallet_service.dart' hide KycStatusResponse;
export 'package:usdc_wallet/services/transactions/transactions_service.dart';
export 'package:usdc_wallet/services/transfers/transfers_service.dart';
export 'package:usdc_wallet/services/notifications/notifications_service.dart';
export 'package:usdc_wallet/services/notifications/rich_notification_helper.dart';
export 'package:usdc_wallet/services/notifications/push_notification_service.dart';
export 'package:usdc_wallet/services/notifications/notification_handler.dart';
export 'package:usdc_wallet/services/notifications/local_notification_service.dart';
export 'package:usdc_wallet/services/preferences/notification_preferences_service.dart';
export 'package:usdc_wallet/services/referrals/referrals_service.dart';

// Bill Payments
export 'package:usdc_wallet/services/bill_payments/bill_payments_service.dart';

// Financial services
export 'package:usdc_wallet/services/deposit/deposit_service.dart';
export 'package:usdc_wallet/services/recurring_transfers/recurring_transfers_service.dart';
export 'package:usdc_wallet/services/bulk_payments/bulk_payments_service.dart';
export 'package:usdc_wallet/services/cards/cards_service.dart';
export 'package:usdc_wallet/services/bank_linking/bank_linking_service.dart';
export 'package:usdc_wallet/services/kyc/kyc_service.dart';

// Device services
export 'package:usdc_wallet/services/contacts/contacts_service.dart';
export 'package:usdc_wallet/services/biometric/biometric_service.dart';

// Security
export 'package:usdc_wallet/services/pin/pin_service.dart';
export 'package:usdc_wallet/services/security/certificate_pinning.dart';
export 'package:usdc_wallet/services/security/device_security.dart';
export 'package:usdc_wallet/services/security/device_attestation.dart';
export 'package:usdc_wallet/services/security/security_gate.dart';
export 'package:usdc_wallet/services/security/screenshot_protection.dart';
export 'package:usdc_wallet/services/security/whitelisted_address_service.dart';

// Legal
export 'package:usdc_wallet/services/legal/legal_documents_service.dart';

// Session management
export 'package:usdc_wallet/services/session/session_service.dart';
export 'package:usdc_wallet/services/session/session_manager.dart';

// Feature flags
export 'package:usdc_wallet/services/feature_flags/feature_flags_service.dart';

// Analytics & Crash Reporting
export 'package:usdc_wallet/services/analytics/analytics_service.dart';
export 'package:usdc_wallet/services/analytics/crash_reporting_service.dart';

// Performance Monitoring
export 'package:usdc_wallet/services/performance/performance_service.dart';
export 'package:usdc_wallet/services/performance/performance_observer.dart';
export 'package:usdc_wallet/services/performance/api_performance_interceptor.dart';
export 'package:usdc_wallet/services/performance/firebase_performance_service.dart';

// App Review
export 'package:usdc_wallet/services/app_review/app_review_service.dart';
