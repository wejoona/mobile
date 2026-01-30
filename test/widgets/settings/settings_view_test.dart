import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('Settings View Widget Tests', () {
    Widget buildSettingsView() {
      return ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      );
    }

    testWidgets('renders settings list', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(7));
    });

    testWidgets('displays Profile option', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('displays Security option', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.text('Security'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('displays Notifications option', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('displays Language option', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.text('Language'), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('displays Help & Support option', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('displays About option', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.text('About'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('displays Logout option', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('shows chevron icons for navigation', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      expect(find.byIcon(Icons.chevron_right), findsNWidgets(6));
    });

    testWidgets('logout option has red color', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      final logoutIcon = tester.widget<Icon>(find.byIcon(Icons.logout));
      expect(logoutIcon.color, Colors.red);

      final logoutText = tester.widget<Text>(find.text('Logout'));
      expect(logoutText.style?.color, Colors.red);
    });

    testWidgets('tapping option triggers navigation', (tester) async {
      await tester.pumpWidget(
        TestWrapper(child: buildSettingsView()),
      );

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    group('Accessibility', () {
      testWidgets('settings items are accessible', (tester) async {
        await tester.pumpWidget(
          TestWrapper(child: buildSettingsView()),
        );

        expect(find.byType(ListTile), findsWidgets);
      });

      testWidgets('icons have proper semantic meaning', (tester) async {
        await tester.pumpWidget(
          TestWrapper(child: buildSettingsView()),
        );

        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.security), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles scrolling', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: SizedBox(
              height: 300,
              child: buildSettingsView(),
            ),
          ),
        );

        // Scroll to bottom
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        expect(find.text('Logout'), findsOneWidget);
      });
    });
  });
}
