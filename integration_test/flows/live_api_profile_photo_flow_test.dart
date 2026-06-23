import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:image_picker_ios/src/messages.g.dart' as ios_picker;
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

import '../helpers/korido_flow_driver.dart';
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await KoridoFlowDriver.clearPersistentState();
  });

  tearDown(() {
    TestHelpers.clearMockImagePicker();
    _clearMockIosImagePicker();
    _clearMockImageAnalysis();
  });

  testWidgets(
    'uploads, persists, displays, and removes a profile photo with the live API',
    (tester) async {
      final imagePath = await TestHelpers.createTestImage(
        filename: 'korido_profile_photo_live.jpg',
      );
      TestHelpers.setupMockImagePicker(imagePath);
      _setupMockIosImagePicker(imagePath);
      _setupMockImageAnalysis();

      final driver = KoridoFlowDriver(tester);
      await driver.launchApp();
      await driver.startRegistrationFromIntro();
      final phone = _uniqueIvorianPhone();
      await driver.submitPhone(phone);
      await driver.enterOtp(await _resolveOtp(phone));

      await driver.pumpUntil(
        () => driver.hasAnyText([
          'Tell us about yourself',
          'Parlez-nous de vous',
        ]),
        reason: 'profile setup screen',
        timeout: const Duration(seconds: 25),
      );
      await driver.submitProfile();

      await driver.pumpUntil(
        () => driver.hasAnyText(['Create your PIN', 'Créez votre PIN']),
        reason: 'PIN setup screen',
        timeout: const Duration(seconds: 25),
      );
      await driver.enterPinTwice(KoridoFlowDriver.defaultPin);

      await driver.pumpUntil(
        () => driver.hasAnyText([
          'Verify your identity',
          'Vérifiez votre identité',
        ]),
        reason: 'KYC prompt screen',
        timeout: const Duration(seconds: 25),
      );
      await driver.tapText(['Maybe Later', 'Peut-être plus tard']);

      await driver.pumpUntil(
        () =>
            driver.hasAnyText(['Welcome to Korido!', 'Bienvenue sur Korido!']),
        reason: 'onboarding success screen',
        timeout: const Duration(seconds: 25),
      );
      await driver.tapText([
        'Start Using Korido',
        'Commencer à utiliser Korido',
      ]);
      await driver.waitForHome();

      await driver.goToRoute('/settings/profile/edit');
      await driver.pumpUntil(
        () => find.byIcon(Icons.camera_alt).evaluate().isNotEmpty,
        reason: 'profile photo action',
        timeout: const Duration(seconds: 25),
      );

      await tester.tap(find.byIcon(Icons.camera_alt).last);
      await tester.pump(const Duration(milliseconds: 350));
      await driver.pumpUntil(
        () => driver.hasAnyText([
          'Choose from Gallery',
          'Choose from gallery',
          'Choisir depuis la galerie',
        ]),
        reason: 'profile photo source sheet',
      );
      await driver.tapText([
        'Choose from Gallery',
        'Choose from gallery',
        'Choisir depuis la galerie',
      ]);

      await driver.pumpUntil(
        () => find.byType(AppButton).evaluate().isNotEmpty,
        reason: 'profile edit save button after image selection',
      );
      await driver.tapText(['Save', 'Enregistrer']);

      await driver.pumpUntil(
        () => driver.hasAnyText([
          'Profile updated successfully',
          'Profil mis à jour avec succès',
        ]),
        reason: 'profile photo upload confirmation',
        timeout: const Duration(seconds: 60),
      );
      await tester.pump(const Duration(seconds: 1));

      final api = await _authenticatedLiveApi(tester);
      String? avatarUrl;
      try {
        final profile = await api.get<Map<String, dynamic>>('/user/profile');
        expect(profile.statusCode, 200);
        final profileData = _payload(profile.data);
        avatarUrl = profileData['avatarUrl']?.toString();
        debugPrint('Live avatar profile payload: $profileData');
        expect(avatarUrl, startsWith('/user/avatar/'));

        final resolvedAvatarUrl = _resolveApiUrl(avatarUrl!);
        final image = await api.get<List<int>>(
          resolvedAvatarUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        debugPrint(
          'Live avatar fetch: url=$resolvedAvatarUrl status=${image.statusCode} '
          'bytes=${image.data?.length ?? 0}',
        );
        expect(
          image.statusCode,
          200,
          reason: 'Avatar URL from profile must serve uploaded image bytes',
        );
        expect(image.data?.length, greaterThan(0));

        await driver.goToRoute('/settings/profile');
        await driver.pumpUntil(
          () => driver.hasAnyText(['Awa']) && driver.hasAnyText(['Kone']),
          reason: 'profile screen after avatar upload',
          timeout: const Duration(seconds: 25),
        );
        driver.expectNoAuthOrUnexpectedError();
      } finally {
        if (avatarUrl != null) {
          final delete = await api.delete<void>('/user/avatar');
          expect(delete.statusCode, anyOf(200, 204));
        }
      }
    },
  );
}

String _uniqueIvorianPhone() {
  final seed = DateTime.now().millisecondsSinceEpoch.toString();
  return '07${seed.substring(seed.length - 8)}';
}

Future<String> _resolveOtp(String localPhone) async {
  // ignore: do_not_use_environment
  const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://korido-api.joonapay.com/api/v1',
  );
  final e164Phone = '+225${localPhone.replaceAll(RegExp(r'\D'), '')}';

  try {
    final response = await Dio(
      BaseOptions(
        baseUrl: baseUrl,
        validateStatus: (_) => true,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    ).get<Map<String, dynamic>>('/dev/otp/$e164Phone');
    final data = response.data?['data'];
    if (response.statusCode == 200 &&
        data is Map<String, dynamic> &&
        data['otp'] != null) {
      return data['otp'].toString();
    }
  } on Object {
    // VerifyHQ dev stacks can be configured with a fixed OTP and no /dev/otp.
  }

  return '123456';
}

Future<Dio> _authenticatedLiveApi(WidgetTester tester) async {
  // ignore: do_not_use_environment
  const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://korido-api.joonapay.com/api/v1',
  );
  final context = tester.element(find.byType(Scaffold).last);
  final container = ProviderScope.containerOf(context);
  final storage = container.read(secureStorageProvider);
  final token = await storage.read(key: StorageKeys.accessToken);
  expect(token, isNotNull, reason: 'live profile test requires auth token');

  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Authorization': 'Bearer $token'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (_) => true,
    ),
  );
}

Map<String, dynamic> _payload(Map<String, dynamic>? data) {
  final raw = data?['data'] ?? data;
  expect(raw, isA<Map<String, dynamic>>());
  return raw! as Map<String, dynamic>;
}

String _resolveApiUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  // ignore: do_not_use_environment
  const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://korido-api.joonapay.com/api/v1',
  );
  final normalizedBase = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  final normalizedPath = url.startsWith('/') ? url : '/$url';
  return '$normalizedBase$normalizedPath';
}

void _setupMockIosImagePicker(String imagePath) {
  const channel = BasicMessageChannel<Object?>(
    'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickImage',
    ios_picker.ImagePickerApi.pigeonChannelCodec,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<Object?>(
        channel,
        (_) async => <Object?>[imagePath],
      );
}

void _clearMockIosImagePicker() {
  const channel = BasicMessageChannel<Object?>(
    'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickImage',
    ios_picker.ImagePickerApi.pigeonChannelCodec,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<Object?>(channel, null);
}

void _setupMockImageAnalysis() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.joonapay.usdc_wallet/image_analysis'),
        (call) async {
          if (call.method == 'detectFaces') {
            return <String, Object?>{'faceCount': 1, 'available': true};
          }
          return null;
        },
      );
}

void _clearMockImageAnalysis() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.joonapay.usdc_wallet/image_analysis'),
        null,
      );
}
