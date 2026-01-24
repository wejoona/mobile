import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

/// Saved recipient model
class SavedRecipient {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? walletAddress;
  final bool isJoonaPayUser;
  final bool isFavorite;
  final DateTime lastUsed;
  final int transferCount;

  const SavedRecipient({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.walletAddress,
    this.isJoonaPayUser = false,
    this.isFavorite = false,
    required this.lastUsed,
    this.transferCount = 0,
  });
}

// Mock data
final _mockRecipients = [
  SavedRecipient(
    id: '1',
    name: 'Mom',
    phone: '+225 07 12 34 56',
    isJoonaPayUser: true,
    isFavorite: true,
    lastUsed: DateTime.now().subtract(const Duration(days: 2)),
    transferCount: 15,
  ),
  SavedRecipient(
    id: '2',
    name: 'John Doe',
    phone: '+225 05 98 76 54',
    email: 'john@example.com',
    isJoonaPayUser: true,
    isFavorite: true,
    lastUsed: DateTime.now().subtract(const Duration(days: 5)),
    transferCount: 8,
  ),
  SavedRecipient(
    id: '3',
    name: 'Landlord',
    phone: '+225 01 23 45 67',
    isJoonaPayUser: false,
    isFavorite: false,
    lastUsed: DateTime.now().subtract(const Duration(days: 30)),
    transferCount: 12,
  ),
  SavedRecipient(
    id: '4',
    name: 'Crypto Wallet',
    phone: '',
    walletAddress: '0x1234...abcd',
    isJoonaPayUser: false,
    isFavorite: false,
    lastUsed: DateTime.now().subtract(const Duration(days: 60)),
    transferCount: 3,
  ),
  SavedRecipient(
    id: '5',
    name: 'Sister',
    phone: '+225 07 11 22 33',
    isJoonaPayUser: true,
    isFavorite: false,
    lastUsed: DateTime.now().subtract(const Duration(days: 14)),
    transferCount: 6,
  ),
];

class SavedRecipientsView extends ConsumerStatefulWidget {
  const SavedRecipientsView({super.key});

  @override
  ConsumerState<SavedRecipientsView> createState() =>
      _SavedRecipientsViewState();
}

class _SavedRecipientsViewState extends ConsumerState<SavedRecipientsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SavedRecipient> _recipients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecipients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _recipients = List.from(_mockRecipients);
      _isLoading = false;
    });
  }

  List<SavedRecipient> get _filteredRecipients {
    var list = _recipients;

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) {
        return r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.phone.contains(_searchQuery) ||
            (r.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return list;
  }

  List<SavedRecipient> get _favorites =>
      _filteredRecipients.where((r) => r.isFavorite).toList();

  List<SavedRecipient> get _recent {
    final sorted = List<SavedRecipient>.from(_filteredRecipients);
    sorted.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return sorted.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Saved Recipients',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.gold500),
            onPressed: () => _showAddRecipient(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold500,
          labelColor: AppColors.gold500,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: [
            Tab(text: 'All (${_filteredRecipients.length})'),
            Tab(text: 'Favorites (${_favorites.length})'),
            const Tab(text: 'Recent'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipients...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.slate,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold500),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRecipientsList(_filteredRecipients),
                      _buildRecipientsList(_favorites),
                      _buildRecipientsList(_recent),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsList(List<SavedRecipient> recipients) {
    if (recipients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppText(
              'No recipients found',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      itemCount: recipients.length,
      itemBuilder: (context, index) {
        final recipient = recipients[index];
        return _RecipientCard(
          recipient: recipient,
          onTap: () => _sendToRecipient(recipient),
          onFavoriteToggle: () => _toggleFavorite(recipient.id),
          onDelete: () => _deleteRecipient(recipient.id),
        );
      },
    );
  }

  void _sendToRecipient(SavedRecipient recipient) {
    // Navigate to send view with pre-filled recipient
    context.push('/send');
    // TODO: Pass recipient data
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _recipients.indexWhere((r) => r.id == id);
      if (index != -1) {
        final recipient = _recipients[index];
        _recipients[index] = SavedRecipient(
          id: recipient.id,
          name: recipient.name,
          phone: recipient.phone,
          email: recipient.email,
          walletAddress: recipient.walletAddress,
          isJoonaPayUser: recipient.isJoonaPayUser,
          isFavorite: !recipient.isFavorite,
          lastUsed: recipient.lastUsed,
          transferCount: recipient.transferCount,
        );
      }
    });
  }

  void _deleteRecipient(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const Text('Delete Recipient?'),
        content: const Text('This recipient will be removed from your saved list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _recipients.removeWhere((r) => r.id == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recipient removed'),
                  backgroundColor: AppColors.successBase,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.errorBase)),
          ),
        ],
      ),
    );
  }

  void _showAddRecipient() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddRecipientSheet(
          onAdded: (recipient) {
            setState(() {
              _recipients.insert(0, recipient);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recipient added'),
                backgroundColor: AppColors.successBase,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({
    required this.recipient,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  final SavedRecipient recipient;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(recipient.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorBase,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: recipient.isJoonaPayUser
                      ? AppColors.gold500.withValues(alpha: 0.2)
                      : AppColors.slate,
                  shape: BoxShape.circle,
                ),
                child: recipient.walletAddress != null
                    ? const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.textSecondary,
                      )
                    : Center(
                        child: AppText(
                          _getInitials(recipient.name),
                          variant: AppTextVariant.titleMedium,
                          color: recipient.isJoonaPayUser
                              ? AppColors.gold500
                              : AppColors.textSecondary,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                          recipient.name,
                          variant: AppTextVariant.bodyLarge,
                          color: AppColors.textPrimary,
                        ),
                        if (recipient.isJoonaPayUser) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.verified,
                            color: AppColors.gold500,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      recipient.walletAddress ?? recipient.phone,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                    if (recipient.transferCount > 0) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        '${recipient.transferCount} transfers',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      recipient.isFavorite ? Icons.star : Icons.star_border,
                      color: recipient.isFavorite
                          ? AppColors.gold500
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold500,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const AppText(
                      'Send',
                      variant: AppTextVariant.labelSmall,
                      color: AppColors.obsidian,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _AddRecipientSheet extends StatefulWidget {
  const _AddRecipientSheet({required this.onAdded});

  final ValueChanged<SavedRecipient> onAdded;

  @override
  State<_AddRecipientSheet> createState() => _AddRecipientSheetState();
}

class _AddRecipientSheetState extends State<_AddRecipientSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isWalletAddress = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText(
            'Add Recipient',
            variant: AppTextVariant.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Type Toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isWalletAddress = false),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: !_isWalletAddress
                          ? AppColors.gold500
                          : AppColors.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: AppText(
                        'Phone',
                        variant: AppTextVariant.labelMedium,
                        color: !_isWalletAddress
                            ? AppColors.obsidian
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isWalletAddress = true),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _isWalletAddress
                          ? AppColors.gold500
                          : AppColors.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: AppText(
                        'Wallet',
                        variant: AppTextVariant.labelMedium,
                        color: _isWalletAddress
                            ? AppColors.obsidian
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Name
          const AppText(
            'Name',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppInput(
            controller: _nameController,
            hint: 'Enter name',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Phone or Wallet
          AppText(
            _isWalletAddress ? 'Wallet Address' : 'Phone Number',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppInput(
            controller: _phoneController,
            hint: _isWalletAddress ? '0x...' : '+225 XX XX XX XX',
            keyboardType:
                _isWalletAddress ? TextInputType.text : TextInputType.phone,
          ),

          if (!_isWalletAddress) ...[
            const SizedBox(height: AppSpacing.lg),

            // Email (optional)
            const AppText(
              'Email (Optional)',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: _emailController,
              hint: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          // Add Button
          AppButton(
            label: 'Add Recipient',
            onPressed: _canAdd() ? _add : null,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  bool _canAdd() {
    return _nameController.text.isNotEmpty && _phoneController.text.length >= 5;
  }

  void _add() {
    widget.onAdded(SavedRecipient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      phone: _isWalletAddress ? '' : _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      walletAddress: _isWalletAddress ? _phoneController.text : null,
      isJoonaPayUser: false,
      isFavorite: false,
      lastUsed: DateTime.now(),
      transferCount: 0,
    ));
  }
}
