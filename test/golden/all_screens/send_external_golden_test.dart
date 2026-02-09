// Golden tests for Send External (blockchain) feature
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/send_external/views/address_input_screen.dart';
import 'package:usdc_wallet/features/send_external/views/external_amount_screen.dart';
import 'package:usdc_wallet/features/send_external/views/external_confirm_screen.dart';
import 'package:usdc_wallet/features/send_external/views/external_result_screen.dart';
import 'package:usdc_wallet/features/send_external/views/scan_address_qr_screen.dart';
import 'package:usdc_wallet/features/send_external/providers/external_transfer_provider.dart';
import 'package:usdc_wallet/features/send_external/models/external_transfer_request.dart';

import '../helpers/golden_test_helper.dart';

/// Mock notifier for ExternalTransferState with pre-set data
class MockExternalTransferNotifier extends Notifier<ExternalTransferState>
    implements ExternalTransferNotifier {
  final ExternalTransferState initialState;

  MockExternalTransferNotifier(this.initialState);

  @override
  ExternalTransferState build() => initialState;

  @override
  Future<void> loadBalance() async {}

  @override
  void setAddress(String address) {}

  @override
  void setAddressFromQr(String qrData) {}

  @override
  Future<void> setAmount(double amount) async {}

  @override
  Future<void> setNetwork(NetworkOption network) async {}

  @override
  Future<bool> executeTransfer() async => true;

  @override
  void reset() {}

  @override
  void clearError() {}
}

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('AddressInputScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: AddressInputScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/address_input/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: AddressInputScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/address_input/default_dark.png'),
      );
    });
  });

  group('ExternalAmountScreen Golden Tests', () {
    // State with valid address so screen renders properly
    final amountScreenState = ExternalTransferState(
      address: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
      addressValidation: AddressValidationResult.valid(),
      availableBalance: 1000.0,
      selectedNetwork: NetworkOption.polygon,
      estimatedFee: 0.01,
    );

    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            externalTransferProvider.overrideWith(
              () => MockExternalTransferNotifier(amountScreenState),
            ),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: ExternalAmountScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/amount/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            externalTransferProvider.overrideWith(
              () => MockExternalTransferNotifier(amountScreenState),
            ),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: ExternalAmountScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/amount/default_dark.png'),
      );
    });
  });

  group('ExternalConfirmScreen Golden Tests', () {
    // State with valid address and amount so screen renders properly
    final confirmScreenState = ExternalTransferState(
      address: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
      addressValidation: AddressValidationResult.valid(),
      amount: 100.0,
      availableBalance: 1000.0,
      selectedNetwork: NetworkOption.polygon,
      estimatedFee: 0.01,
    );

    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            externalTransferProvider.overrideWith(
              () => MockExternalTransferNotifier(confirmScreenState),
            ),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: ExternalConfirmScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/confirm/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            externalTransferProvider.overrideWith(
              () => MockExternalTransferNotifier(confirmScreenState),
            ),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: ExternalConfirmScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/confirm/default_dark.png'),
      );
    });
  });

  group('ExternalResultScreen Golden Tests', () {
    // State with transfer result
    final resultScreenState = ExternalTransferState(
      address: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
      addressValidation: AddressValidationResult.valid(),
      amount: 100.0,
      availableBalance: 1000.0,
      selectedNetwork: NetworkOption.polygon,
      estimatedFee: 0.01,
      result: ExternalTransferResult(
        transactionId: 'tx_12345',
        txHash: '0xabc123def456789012345678901234567890abcdef1234567890abcdef12345678',
        status: 'pending',
        fee: 0.01,
        network: NetworkOption.polygon,
        timestamp: DateTime(2025, 1, 15, 10, 30),
      ),
    );

    testWidgets('success light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            externalTransferProvider.overrideWith(
              () => MockExternalTransferNotifier(resultScreenState),
            ),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: ExternalResultScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/result/success_light.png'),
      );
    });

    testWidgets('success dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            externalTransferProvider.overrideWith(
              () => MockExternalTransferNotifier(resultScreenState),
            ),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: ExternalResultScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/result/success_dark.png'),
      );
    });
  });

  group('ScanAddressQrScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: ScanAddressQrScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/scan_qr/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: ScanAddressQrScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/send_external/scan_qr/default_dark.png'),
      );
    });
  });
}
