import 'package:flutter/material.dart';
import '../../design/tokens/index.dart';
import '../../design/components/primitives/index.dart';

/// Run 345: Mock data management view for dev/QA testing
class MockDataView extends StatelessWidget {
  const MockDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const AppText('Donnees Mock', style: AppTextStyle.headingSmall),
        backgroundColor: AppColors.backgroundSecondary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AlertBanner(
            message: 'Mode developpement: les donnees mock sont actives.',
            variant: AlertVariant.warning,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _MockScenarioTile(
            title: 'Portefeuille vide',
            description: 'Simule un nouveau compte sans historique',
            icon: Icons.account_balance_wallet_outlined,
          ),
          _MockScenarioTile(
            title: 'Utilisateur verifie KYC',
            description: 'Compte avec KYC complet et limites elevees',
            icon: Icons.verified_user_outlined,
          ),
          _MockScenarioTile(
            title: 'Compte bloque',
            description: 'Simule un compte suspendu',
            icon: Icons.block,
          ),
          _MockScenarioTile(
            title: 'Erreurs reseau',
            description: 'Active les erreurs reseau aleatoires',
            icon: Icons.wifi_off,
          ),
          _MockScenarioTile(
            title: 'Latence elevee',
            description: 'Ajoute 2-5s de delai aux requetes',
            icon: Icons.hourglass_bottom,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Reinitialiser les donnees',
            variant: AppButtonVariant.danger,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _MockScenarioTile extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;

  const _MockScenarioTile({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  State<_MockScenarioTile> createState() => _MockScenarioTileState();
}

class _MockScenarioTileState extends State<_MockScenarioTile> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTileCard(
        leading: Icon(widget.icon, color: AppColors.gold),
        title: widget.title,
        subtitle: widget.description,
        trailing: AppToggle(
          value: _active,
          onChanged: (v) => setState(() => _active = v),
        ),
        onTap: () => setState(() => _active = !_active),
      ),
    );
  }
}
