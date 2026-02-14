import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Run 355: Search bar widget for finding send recipients
class RecipientSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onScanQR;
  final String hintText;

  const RecipientSearchBar({
    super.key,
    required this.onChanged,
    this.onScanQR,
    this.hintText = 'Rechercher un contact...',
  });

  @override
  State<RecipientSearchBar> createState() => _RecipientSearchBarState();
}

class _RecipientSearchBarState extends State<RecipientSearchBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Recherche de destinataire',
      textField: true,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.elevated,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: AppSpacing.lg),
              child: Icon(Icons.search, color: context.colors.textTertiary, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() => _hasText = value.isNotEmpty);
                  widget.onChanged(value);
                },
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: context.colors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                ),
              ),
            ),
            if (_hasText)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  setState(() => _hasText = false);
                  widget.onChanged('');
                },
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Icon(Icons.close, color: context.colors.textTertiary, size: 18),
                ),
              ),
            if (widget.onScanQR != null && !_hasText)
              GestureDetector(
                onTap: widget.onScanQR,
                child: Semantics(
                  button: true,
                  label: 'Scanner un code QR',
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Icon(Icons.qr_code_scanner, color: context.colors.gold, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
