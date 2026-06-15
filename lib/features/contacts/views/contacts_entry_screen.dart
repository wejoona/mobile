import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';

class ContactsEntryScreen extends ConsumerStatefulWidget {
  const ContactsEntryScreen({super.key});

  @override
  ConsumerState<ContactsEntryScreen> createState() =>
      _ContactsEntryScreenState();
}

class _ContactsEntryScreenState extends ConsumerState<ContactsEntryScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_routeByPermission());
  }

  Future<void> _routeByPermission() async {
    final hasPermission = await ref
        .read(contactsServiceProvider)
        .hasContactsPermission();
    if (!mounted) {
      return;
    }

    final destination = hasPermission
        ? '/contacts/list'
        : '/contacts/permission';
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colors.gold),
              const SizedBox(height: AppSpacing.md),
              AppText(l10n.contacts_title),
            ],
          ),
        ),
      ),
    );
  }
}
