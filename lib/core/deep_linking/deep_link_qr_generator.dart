import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../design/tokens/colors.dart';

/// QR Code generator for deep links
/// Supports payment requests, receive money, and payment links
class DeepLinkQrGenerator {
  /// Generate payment request QR code data
  static String generatePaymentRequest({
    required String phoneNumber,
    double? amount,
    String? note,
  }) {
    final uri = Uri(
      scheme: 'joonapay',
      path: 'send',
      queryParameters: {
        'to': phoneNumber,
        if (amount != null) 'amount': amount.toString(),
        if (note != null) 'note': note,
      },
    );
    return uri.toString();
  }

  /// Generate receive money QR code data
  static String generateReceiveRequest({
    required String userPhoneNumber,
    double? requestedAmount,
  }) {
    final uri = Uri(
      scheme: 'joonapay',
      path: 'send',
      queryParameters: {
        'to': userPhoneNumber,
        if (requestedAmount != null) 'amount': requestedAmount.toString(),
      },
    );
    return uri.toString();
  }

  /// Generate payment link QR code data (use universal link for web fallback)
  static String generatePaymentLink({
    required String linkCode,
    bool useUniversalLink = true,
  }) {
    if (useUniversalLink) {
      return 'https://app.joonapay.com/pay/$linkCode';
    }
    return 'joonapay://pay/$linkCode';
  }

  /// Generate transaction share QR code data
  static String generateTransactionLink({
    required String transactionId,
    bool useUniversalLink = true,
  }) {
    if (useUniversalLink) {
      return 'https://app.joonapay.com/transaction/$transactionId';
    }
    return 'joonapay://transaction/$transactionId';
  }

  /// Generate referral QR code data
  static String generateReferralLink({
    required String referralCode,
    bool useUniversalLink = true,
  }) {
    if (useUniversalLink) {
      return 'https://app.joonapay.com/referrals?code=$referralCode';
    }
    return 'joonapay://referrals?code=$referralCode';
  }
}

/// Styled QR Code widget for JoonaPay deep links
class DeepLinkQrCode extends StatelessWidget {
  const DeepLinkQrCode({
    super.key,
    required this.data,
    this.size = 280,
    this.showLogo = true,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String data;
  final double size;
  final bool showLogo;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: foregroundColor ?? AppColors.obsidian,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: foregroundColor ?? AppColors.obsidian,
      ),
      embeddedImage: showLogo
          ? const AssetImage('assets/logo_qr.png')
          : null,
      embeddedImageStyle: showLogo
          ? const QrEmbeddedImageStyle(
              size: Size(60, 60),
            )
          : null,
    );
  }
}

/// Payment Request QR widget
class PaymentRequestQrCode extends StatelessWidget {
  const PaymentRequestQrCode({
    super.key,
    required this.phoneNumber,
    this.amount,
    this.note,
    this.size = 280,
  });

  final String phoneNumber;
  final double? amount;
  final String? note;
  final double size;

  @override
  Widget build(BuildContext context) {
    final qrData = DeepLinkQrGenerator.generatePaymentRequest(
      phoneNumber: phoneNumber,
      amount: amount,
      note: note,
    );

    return DeepLinkQrCode(
      data: qrData,
      size: size,
    );
  }
}

/// Receive Money QR widget
class ReceiveMoneyQrCode extends StatelessWidget {
  const ReceiveMoneyQrCode({
    super.key,
    required this.userPhoneNumber,
    this.requestedAmount,
    this.size = 280,
  });

  final String userPhoneNumber;
  final double? requestedAmount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final qrData = DeepLinkQrGenerator.generateReceiveRequest(
      userPhoneNumber: userPhoneNumber,
      requestedAmount: requestedAmount,
    );

    return DeepLinkQrCode(
      data: qrData,
      size: size,
    );
  }
}

/// Payment Link QR widget
class PaymentLinkQrCode extends StatelessWidget {
  const PaymentLinkQrCode({
    super.key,
    required this.linkCode,
    this.size = 280,
    this.useUniversalLink = true,
  });

  final String linkCode;
  final double size;
  final bool useUniversalLink;

  @override
  Widget build(BuildContext context) {
    final qrData = DeepLinkQrGenerator.generatePaymentLink(
      linkCode: linkCode,
      useUniversalLink: useUniversalLink,
    );

    return DeepLinkQrCode(
      data: qrData,
      size: size,
    );
  }
}

/// QR Code with branded styling (gold accents)
class BrandedDeepLinkQrCode extends StatelessWidget {
  const BrandedDeepLinkQrCode({
    super.key,
    required this.data,
    this.size = 280,
    this.title,
    this.subtitle,
  });

  final String data;
  final double size;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold500,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.silver,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DeepLinkQrCode(
              data: data,
              size: size,
              foregroundColor: AppColors.obsidian,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 16,
                color: AppColors.silver,
              ),
              const SizedBox(width: 8),
              Text(
                'Scan with JoonaPay',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.silver,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Example usage widget
class DeepLinkQrCodeExamples extends StatelessWidget {
  const DeepLinkQrCodeExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Example 1: Simple receive QR
        const Text(
          'Receive Money QR',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: ReceiveMoneyQrCode(
            userPhoneNumber: '+2250701234567',
          ),
        ),
        const SizedBox(height: 32),

        // Example 2: Payment request with amount
        const Text(
          'Payment Request QR (50 USDC)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: PaymentRequestQrCode(
            phoneNumber: '+2250701234567',
            amount: 50.00,
            note: 'Lunch payment',
          ),
        ),
        const SizedBox(height: 32),

        // Example 3: Branded payment link QR
        const Text(
          'Payment Link QR (Branded)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: BrandedDeepLinkQrCode(
            data: DeepLinkQrGenerator.generatePaymentLink(
              linkCode: 'ABCD1234',
            ),
            title: 'Invoice #123',
            subtitle: 'Scan to pay 50.00 USDC',
          ),
        ),
        const SizedBox(height: 32),

        // Example 4: Referral QR
        const Text(
          'Referral QR Code',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: BrandedDeepLinkQrCode(
            data: DeepLinkQrGenerator.generateReferralLink(
              referralCode: 'JOHN2024',
            ),
            title: 'Join JoonaPay',
            subtitle: 'Use my referral code: JOHN2024',
            size: 240,
          ),
        ),
      ],
    );
  }
}
