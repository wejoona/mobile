import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';

/// Loading skeleton for card list.
class CardLoadingState extends StatelessWidget {
  const CardLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const ShimmerLoading(height: 200, borderRadius: 16),
          const SizedBox(height: 24),
          ...List.generate(3, (_) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: ShimmerLoading(height: 56, borderRadius: 12),
            );
          }),
        ],
      ),
    );
  }
}
