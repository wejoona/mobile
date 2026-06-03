import 'package:flutter/widgets.dart';
import 'package:usdc_wallet/features/contacts/views/contacts_list_screen.dart';

/// Backwards-compatible alias for the maintained contacts experience.
///
/// Keep this wrapper so older imports still render the permission-aware,
/// hashed-sync contact flow instead of a stale duplicate implementation.
class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) => const ContactsListScreen();
}
