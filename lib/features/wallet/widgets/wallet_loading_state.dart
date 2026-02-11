import 'package:flutter/material.dart';
import '../../../design/components/primitives/shimmer_loading.dart';

/// Loading skeleton for the wallet screen.
class WalletLoadingState extends StatelessWidget {
  const WalletLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Balance card skeleton
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            // Quick actions skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (_) {
                return Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 48,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 24),
            // Transaction list skeleton
            ...List.generate(4, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 80,
                            height: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Container(width: 60, height: 14, color: Colors.white),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
