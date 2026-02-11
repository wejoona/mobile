import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';

/// Loading skeleton for the wallet screen.
class WalletLoadingState extends StatelessWidget {
  const WalletLoadingState({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ShimmerLoading(height: 180, borderRadius: 20),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (_) => const Column(
                  children: [
                    ShimmerLoading.circle(size: 48),
                    SizedBox(height: 8),
                    ShimmerLoading.line(width: 48, height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    ShimmerLoading.circle(size: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoading.line(width: 120, height: 14),
                          SizedBox(height: 6),
                          ShimmerLoading.line(width: 80, height: 12),
                        ],
                      ),
                    ),
                    ShimmerLoading.line(width: 60, height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
