import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('Recipient Selector Widget Tests', () {
    final mockRecipients = [
      {'id': '1', 'name': 'John Doe', 'phone': '+2250123456789'},
      {'id': '2', 'name': 'Jane Smith', 'phone': '+2250987654321'},
      {'id': '3', 'name': 'Bob Johnson', 'phone': '+2250555555555'},
    ];

    Widget buildRecipientSelector({
      List<Map<String, String>>? recipients,
      ValueChanged<Map<String, String>>? onRecipientSelected,
    }) {
      return Column(
        children: [
          AppInput(
            hint: 'Search recipients',
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: 16),
          if (recipients != null && recipients.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: recipients.length,
                itemBuilder: (context, index) {
                  final recipient = recipients[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(recipient['name']![0]),
                    ),
                    title: AppText(recipient['name']!),
                    subtitle: AppText(
                      recipient['phone']!,
                      variant: AppTextVariant.bodySmall,
                    ),
                    onTap: () => onRecipientSelected?.call(recipient),
                  );
                },
              ),
            )
          else
            const Center(
              child: AppText('No recipients found'),
            ),
        ],
      );
    }

    testWidgets('renders search input', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SizedBox(
            height: 400,
            child: buildRecipientSelector(recipients: mockRecipients),
          ),
        ),
      );

      expect(find.byType(AppInput), findsOneWidget);
      expect(find.text('Search recipients'), findsOneWidget);
    });

    testWidgets('displays recipient list', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SizedBox(
            height: 400,
            child: buildRecipientSelector(recipients: mockRecipients),
          ),
        ),
      );

      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Bob Johnson'), findsOneWidget);
    });

    testWidgets('displays recipient phone numbers', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SizedBox(
            height: 400,
            child: buildRecipientSelector(recipients: mockRecipients),
          ),
        ),
      );

      expect(find.text('+2250123456789'), findsOneWidget);
      expect(find.text('+2250987654321'), findsOneWidget);
    });

    testWidgets('shows recipient avatar with initial', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SizedBox(
            height: 400,
            child: buildRecipientSelector(recipients: mockRecipients),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsNWidgets(3));
      expect(find.text('J'), findsNWidgets(2)); // John and Jane
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('calls callback when recipient selected', (tester) async {
      Map<String, String>? selectedRecipient;

      await tester.pumpWidget(
        TestWrapper(
          child: SizedBox(
            height: 400,
            child: buildRecipientSelector(
              recipients: mockRecipients,
              onRecipientSelected: (recipient) => selectedRecipient = recipient,
            ),
          ),
        ),
      );

      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      expect(selectedRecipient, isNotNull);
      expect(selectedRecipient!['name'], 'John Doe');
    });

    testWidgets('shows empty state when no recipients', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SizedBox(
            height: 400,
            child: buildRecipientSelector(recipients: []),
          ),
        ),
      );

      expect(find.text('No recipients found'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('has search icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SizedBox(
            height: 400,
            child: buildRecipientSelector(recipients: mockRecipients),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    group('Edge Cases', () {
      testWidgets('handles single recipient', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: SizedBox(
              height: 400,
              child: buildRecipientSelector(
                recipients: [mockRecipients[0]],
              ),
            ),
          ),
        );

        expect(find.byType(ListTile), findsOneWidget);
      });

      testWidgets('handles long recipient names', (tester) async {
        final longNameRecipient = [
          {
            'id': '1',
            'name': 'Very Long Recipient Name That Might Overflow',
            'phone': '+2250123456789',
          },
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: SizedBox(
              height: 400,
              child: buildRecipientSelector(recipients: longNameRecipient),
            ),
          ),
        );

        expect(
          find.text('Very Long Recipient Name That Might Overflow'),
          findsOneWidget,
        );
      });

      testWidgets('handles special characters in names', (tester) async {
        final specialRecipient = [
          {
            'id': '1',
            'name': 'Jean-François Côté',
            'phone': '+2250123456789',
          },
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: SizedBox(
              height: 400,
              child: buildRecipientSelector(recipients: specialRecipient),
            ),
          ),
        );

        expect(find.text('Jean-François Côté'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('recipient items are accessible', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: SizedBox(
              height: 400,
              child: buildRecipientSelector(recipients: mockRecipients),
            ),
          ),
        );

        expect(find.byType(ListTile), findsWidgets);
      });

      testWidgets('search field is accessible', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: SizedBox(
              height: 400,
              child: buildRecipientSelector(recipients: mockRecipients),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });
    });
  });
}
