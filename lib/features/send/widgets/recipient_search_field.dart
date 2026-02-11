import 'package:flutter/material.dart';
import '../../../design/components/primitives/search_bar.dart';
import '../../../domain/entities/contact.dart';
import '../../../design/components/primitives/contact_tile.dart';

/// Recipient search field with contact suggestions.
class RecipientSearchField extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final List<Contact> suggestions;
  final ValueChanged<Contact> onContactSelected;
  final VoidCallback? onScanQr;

  const RecipientSearchField({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.suggestions,
    required this.onContactSelected,
    this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppSearchBar(
                hintText: 'Search name or phone...',
                onChanged: onQueryChanged,
                autofocus: true,
              ),
            ),
            if (onScanQr != null) ...[
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onScanQr,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
              ),
            ],
          ],
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text('Contacts', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 4),
          ...suggestions.take(5).map((contact) => ContactTile(
                contact: contact,
                onTap: () => onContactSelected(contact),
              )),
        ],
      ],
    );
  }
}
