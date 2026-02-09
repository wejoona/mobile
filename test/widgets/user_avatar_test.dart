import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joonapay_wallet/design/components/primitives/user_avatar.dart';
import 'package:joonapay_wallet/design/tokens/colors.dart';

void main() {
  group('UserAvatar', () {
    testWidgets('displays initials when no image provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
              lastName: 'Diallo',
            ),
          ),
        ),
      );

      expect(find.text('AD'), findsOneWidget);
    });

    testWidgets('displays single initial for first name only', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('displays single initial for last name only', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              lastName: 'Diallo',
            ),
          ),
        ),
      );

      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('displays person icon when no name provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('applies correct size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
              size: UserAvatar.sizeLarge,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(UserAvatar),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxWidth, UserAvatar.sizeLarge);
      expect(container.constraints?.maxHeight, UserAvatar.sizeLarge);
    });

    testWidgets('shows border when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
              showBorder: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(UserAvatar),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('uses custom border color when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
              showBorder: true,
              borderColor: AppColors.successBase,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(UserAvatar),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect((decoration.border as Border).top.color, AppColors.successBase);
    });

    testWidgets('shows online indicator when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
              showOnlineIndicator: true,
              isOnline: true,
            ),
          ),
        ),
      );

      final positioned = find.descendant(
        of: find.byType(UserAvatar),
        matching: find.byType(Positioned),
      );

      expect(positioned, findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UserAvatar));
      expect(tapped, isTrue);
    });

    testWidgets('generates consistent colors for same name', (tester) async {
      late Color color1;
      late Color color2;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
              lastName: 'Diallo',
            ),
          ),
        ),
      );

      final container1 = tester.widget<Container>(
        find.descendant(
          of: find.byType(UserAvatar),
          matching: find.byType(Container),
        ).at(1), // Inner container with gradient
      );

      final gradient1 = (container1.decoration as BoxDecoration).gradient as LinearGradient;
      color1 = gradient1.colors.first;

      // Rebuild with same name
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              firstName: 'Amadou',
              lastName: 'Diallo',
            ),
          ),
        ),
      );

      final container2 = tester.widget<Container>(
        find.descendant(
          of: find.byType(UserAvatar),
          matching: find.byType(Container),
        ).at(1),
      );

      final gradient2 = (container2.decoration as BoxDecoration).gradient as LinearGradient;
      color2 = gradient2.colors.first;

      expect(color1, color2);
    });
  });

  group('UserAvatarGroup', () {
    testWidgets('displays all avatars when under max', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatarGroup(
              users: [
                UserAvatarData(firstName: 'Amadou', lastName: 'Diallo'),
                UserAvatarData(firstName: 'Fatou', lastName: 'Traore'),
              ],
              maxAvatars: 3,
            ),
          ),
        ),
      );

      expect(find.byType(UserAvatar), findsNWidgets(2));
    });

    testWidgets('displays overflow badge when exceeding max', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatarGroup(
              users: [
                UserAvatarData(firstName: 'Amadou', lastName: 'Diallo'),
                UserAvatarData(firstName: 'Fatou', lastName: 'Traore'),
                UserAvatarData(firstName: 'Moussa', lastName: 'Kone'),
                UserAvatarData(firstName: 'Aissata', lastName: 'Bah'),
                UserAvatarData(firstName: 'Ibrahim', lastName: 'Sow'),
              ],
              maxAvatars: 3,
            ),
          ),
        ),
      );

      // Should show 3 avatars + 1 overflow badge
      expect(find.byType(UserAvatar), findsNWidgets(3));
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatarGroup(
              users: const [
                UserAvatarData(firstName: 'Amadou', lastName: 'Diallo'),
              ],
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UserAvatarGroup));
      expect(tapped, isTrue);
    });
  });

  group('UserAvatarData', () {
    test('creates instance with all fields', () {
      const data = UserAvatarData(
        imageUrl: 'https://example.com/avatar.jpg',
        firstName: 'Amadou',
        lastName: 'Diallo',
      );

      expect(data.imageUrl, 'https://example.com/avatar.jpg');
      expect(data.firstName, 'Amadou');
      expect(data.lastName, 'Diallo');
    });

    test('creates instance with nullable fields', () {
      const data = UserAvatarData();

      expect(data.imageUrl, isNull);
      expect(data.firstName, isNull);
      expect(data.lastName, isNull);
    });
  });
}
