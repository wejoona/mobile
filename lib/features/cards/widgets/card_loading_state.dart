import 'package:flutter/material.dart';
import '../../../design/components/primitives/shimmer_loading.dart';

/// Loading skeleton for card list.
class CardLoadingState extends StatelessWidget {
  const CardLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(3, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
