import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import 'user_avatar.dart';
import 'app_text.dart';
import 'app_card.dart';

/// UserAvatar Component Examples
/// Demonstrates all features and use cases
class UserAvatarExamples extends StatelessWidget {
  const UserAvatarExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const AppText('UserAvatar Examples'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildSection(
              'Sizes',
              'Predefined size constants for consistency',
              [
                _buildRow([
                  _buildExample(
                    'Small (32px)',
                    const UserAvatar(
                      firstName: 'Amadou',
                      lastName: 'Diallo',
                      size: UserAvatar.sizeSmall,
                    ),
                  ),
                  _buildExample(
                    'Medium (48px)',
                    const UserAvatar(
                      firstName: 'Fatou',
                      lastName: 'Traore',
                      size: UserAvatar.sizeMedium,
                    ),
                  ),
                ]),
                _buildRow([
                  _buildExample(
                    'Large (64px)',
                    const UserAvatar(
                      firstName: 'Moussa',
                      lastName: 'Kone',
                      size: UserAvatar.sizeLarge,
                    ),
                  ),
                  _buildExample(
                    'XLarge (96px)',
                    const UserAvatar(
                      firstName: 'Aissata',
                      lastName: 'Bah',
                      size: UserAvatar.sizeXLarge,
                    ),
                  ),
                ]),
              ],
            ),
            SizedBox(height: AppSpacing.xxl),
            _buildSection(
              'With Images',
              'CachedNetworkImage with loading and error states',
              [
                _buildRow([
                  _buildExample(
                    'Valid Image',
                    const UserAvatar(
                      imageUrl: 'https://i.pravatar.cc/150?img=1',
                      firstName: 'John',
                      lastName: 'Doe',
                      size: UserAvatar.sizeLarge,
                    ),
                  ),
                  _buildExample(
                    'Error Fallback',
                    const UserAvatar(
                      imageUrl: 'https://invalid.url/image.jpg',
                      firstName: 'Jane',
                      lastName: 'Smith',
                      size: UserAvatar.sizeLarge,
                    ),
                  ),
                ]),
              ],
            ),
            SizedBox(height: AppSpacing.xxl),
            _buildSection(
              'Borders',
              'Optional borders for premium/verified users',
              [
                _buildRow([
                  _buildExample(
                    'Gold Border',
                    const UserAvatar(
                      firstName: 'Amadou',
                      lastName: 'Diallo',
                      size: UserAvatar.sizeLarge,
                      showBorder: true,
                      borderColor: AppColors.gold500,
                    ),
                  ),
                  _buildExample(
                    'Success Border',
                    const UserAvatar(
                      firstName: 'Fatou',
                      lastName: 'Traore',
                      size: UserAvatar.sizeLarge,
                      showBorder: true,
                      borderColor: AppColors.successBase,
                    ),
                  ),
                ]),
              ],
            ),
            SizedBox(height: AppSpacing.xxl),
            _buildSection(
              'Online Status',
              'Green dot indicator for active users',
              [
                _buildRow([
                  _buildExample(
                    'Online',
                    const UserAvatar(
                      firstName: 'Moussa',
                      lastName: 'Kone',
                      size: UserAvatar.sizeMedium,
                      showOnlineIndicator: true,
                      isOnline: true,
                    ),
                  ),
                  _buildExample(
                    'Offline',
                    const UserAvatar(
                      firstName: 'Aissata',
                      lastName: 'Bah',
                      size: UserAvatar.sizeMedium,
                      showOnlineIndicator: true,
                      isOnline: false,
                    ),
                  ),
                ]),
              ],
            ),
            SizedBox(height: AppSpacing.xxl),
            _buildSection(
              'Initials Variations',
              'Different name combinations and colors',
              [
                _buildRow([
                  _buildExample(
                    'Two Names',
                    const UserAvatar(
                      firstName: 'Amadou',
                      lastName: 'Diallo',
                      size: UserAvatar.sizeMedium,
                    ),
                  ),
                  _buildExample(
                    'First Only',
                    const UserAvatar(
                      firstName: 'Fatou',
                      size: UserAvatar.sizeMedium,
                    ),
                  ),
                ]),
                _buildRow([
                  _buildExample(
                    'Last Only',
                    const UserAvatar(
                      lastName: 'Traore',
                      size: UserAvatar.sizeMedium,
                    ),
                  ),
                  _buildExample(
                    'No Name',
                    const UserAvatar(
                      size: UserAvatar.sizeMedium,
                    ),
                  ),
                ]),
              ],
            ),
            SizedBox(height: AppSpacing.xxl),
            _buildSection(
              'Avatar Group',
              'Multiple overlapping avatars',
              [
                _buildExample(
                  'User Group (3)',
                  UserAvatarGroup(
                    users: const [
                      UserAvatarData(firstName: 'Amadou', lastName: 'Diallo'),
                      UserAvatarData(firstName: 'Fatou', lastName: 'Traore'),
                      UserAvatarData(firstName: 'Moussa', lastName: 'Kone'),
                    ],
                    size: UserAvatar.sizeMedium,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _buildExample(
                  'User Group (5+)',
                  UserAvatarGroup(
                    users: const [
                      UserAvatarData(firstName: 'Amadou', lastName: 'Diallo'),
                      UserAvatarData(firstName: 'Fatou', lastName: 'Traore'),
                      UserAvatarData(firstName: 'Moussa', lastName: 'Kone'),
                      UserAvatarData(firstName: 'Aissata', lastName: 'Bah'),
                      UserAvatarData(firstName: 'Ibrahim', lastName: 'Sow'),
                      UserAvatarData(firstName: 'Mariam', lastName: 'Toure'),
                    ],
                    size: UserAvatar.sizeSmall,
                    maxAvatars: 4,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xxl),
            _buildSection(
              'Real-World Examples',
              'Common usage patterns in the app',
              [
                _buildRealWorldExample(
                  'Transaction List Item',
                  Row(
                    children: [
                      const UserAvatar(
                        imageUrl: 'https://i.pravatar.cc/150?img=2',
                        firstName: 'Amadou',
                        lastName: 'Diallo',
                        size: UserAvatar.sizeSmall,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Amadou Diallo',
                              fontWeight: FontWeight.w600,
                            ),
                            AppText(
                              'Sent you 50,000 XOF',
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _buildRealWorldExample(
                  'Profile Header',
                  Column(
                    children: [
                      UserAvatar(
                        imageUrl: 'https://i.pravatar.cc/150?img=3',
                        firstName: 'Fatou',
                        lastName: 'Traore',
                        size: UserAvatar.sizeXLarge,
                        showBorder: true,
                        borderColor: AppColors.gold500,
                        onTap: () {
                          // Navigate to profile
                        },
                      ),
                      SizedBox(height: AppSpacing.md),
                      const AppText(
                        'Fatou Traore',
                        fontWeight: FontWeight.w600,
                      ),
                      AppText(
                        'Premium Member',
                        color: AppColors.gold500,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _buildRealWorldExample(
                  'Contact List with Status',
                  Row(
                    children: [
                      const UserAvatar(
                        imageUrl: 'https://i.pravatar.cc/150?img=4',
                        firstName: 'Moussa',
                        lastName: 'Kone',
                        size: UserAvatar.sizeMedium,
                        showOnlineIndicator: true,
                        isOnline: true,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const AppText(
                                  'Moussa Kone',
                                  fontWeight: FontWeight.w600,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBase,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const AppText(
                                    'Online',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            AppText(
                              '+225 07 12 34 56 78',
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, List<Widget> children) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: AppSpacing.xs),
          AppText(
            description,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }

  Widget _buildExample(String label, Widget avatar) {
    return Column(
      children: [
        avatar,
        SizedBox(height: AppSpacing.sm),
        AppText(
          label,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRealWorldExample(String label, Widget content) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.sm),
          content,
        ],
      ),
    );
  }
}
