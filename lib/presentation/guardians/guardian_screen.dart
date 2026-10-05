import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/guardian_controller.dart';
import '../../domain/models/guardian.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/shared/components/premium_header.dart';
import 'package:rahbar/presentation/shared/widgets/status_chip.dart';
import 'package:rahbar/presentation/shared/widgets/status_chip.dart';

class GuardianScreen extends ConsumerWidget {
  const GuardianScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardianState = ref.watch(guardianControllerProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: guardianState.isLoading && guardianState.guardians.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPadding),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PremiumHeader(
                    title: 'Family Safety',
                    subtitle: 'Your trusted safety network',
                    showProfileMenu: true,
                    trailing: const StatusChip(
                      label: 'Safety Network Ready',
                      type: StatusChipType.safe,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppTheme.spacingLarge),
                        _buildSummaryCard(guardianState.guardians.length),
                        const SizedBox(height: AppTheme.spacingXLarge),

                        const Text('Primary Guardian', style: AppTheme.titleStyle),
                        const SizedBox(height: AppTheme.spacingMedium),
                        _buildPrimaryGuardian(guardianState.guardians),
                        
                        const SizedBox(height: AppTheme.spacingXLarge),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Your Guardians', style: AppTheme.titleStyle),
                            _buildAddGuardianSmallAction(context, ref),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        _buildGuardianNetwork(context, guardianState.guardians),
                        
                        const SizedBox(height: AppTheme.spacingXLarge),

                        const Text('Safety Sharing', style: AppTheme.titleStyle),
                        const SizedBox(height: AppTheme.spacingMedium),
                        _buildSafetySharing(guardianState.guardians.length),
                        const SizedBox(height: AppTheme.spacingXLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(int count) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryStat('$count', 'Connected'),
          Container(height: 40, width: 1, color: AppTheme.textSecondary.withValues(alpha: 0.2)),
          _buildSummaryStat('Available', 'Primary'),
          Container(height: 40, width: 1, color: AppTheme.textSecondary.withValues(alpha: 0.2)),
          _buildSummaryStat('Ready', 'Support'),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTheme.headingStyle.copyWith(color: AppTheme.primaryColor)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.captionStyle),
      ],
    );
  }

  Widget _buildPrimaryGuardian(List<Guardian> guardians) {
    final primary = guardians.where((g) => g.isPrimary).firstOrNull;

    if (primary == null) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
          border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
          boxShadow: AppTheme.premiumShadow,
        ),
        child: Text(
          'No primary guardian set.',
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              primary.name.isNotEmpty ? primary.name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary.name,
                  style: AppTheme.titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  primary.relationship,
                  style: AppTheme.captionStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          _buildVerificationBadge(primary.isVerified),
        ],
      ),
    );
  }

  Widget _buildAddGuardianSmallAction(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddGuardianDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: AppTheme.accentBlue, size: 16),
            const SizedBox(width: 4),
            Text('Add', style: TextStyle(color: AppTheme.accentBlue, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardianNetwork(BuildContext context, List<Guardian> guardians) {
    final others = guardians.where((g) => !g.isPrimary).toList();

    if (others.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
          border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Build your safety network by adding a trusted guardian.',
              style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: others.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSmall),
      itemBuilder: (context, index) {
        final g = others[index];
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
            boxShadow: AppTheme.premiumShadow,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
                child: Text(
                  g.name.isNotEmpty ? g.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.name,
                      style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      g.relationship,
                      style: AppTheme.captionStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              _buildVerificationBadge(g.isVerified),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerificationBadge(bool isVerified) {
    if (!isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
          border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
        ),
        child: const Text('PENDING', style: TextStyle(color: AppTheme.warningColor, fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.safeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
        border: Border.all(color: AppTheme.safeColor.withValues(alpha: 0.3)),
      ),
      child: const Text('VERIFIED', style: TextStyle(color: AppTheme.safeColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showAddGuardianDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg)),
          title: const Text('Invite Guardian', style: AppTheme.titleStyle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add a trusted contact to your prototype safety network.', style: AppTheme.captionStyle),
                const SizedBox(height: AppTheme.spacingMedium),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm)),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                TextField(
                  controller: relationController,
                  decoration: InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm)),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(guardianControllerProvider.notifier).addMockGuardian(
                        nameController.text,
                        relationController.text,
                        phoneController.text,
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guardian added to prototype network'),
                      backgroundColor: AppTheme.safeColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill)),
              ),
              child: const Text('Invite'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSafetySharing(int count) {
    return Row(
      children: [
        Expanded(
          child: _buildSharingCard(
            Icons.location_on_rounded,
            'Location Sharing',
            'Real-time location shared with your guardians',
            'Enabled',
            AppTheme.safeColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: _buildSharingCard(
            Icons.notifications_active_rounded,
            'Emergency Alerts',
            'Shared with $count guardians during an emergency',
            'Active',
            AppTheme.safeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSharingCard(IconData icon, String title, String subtitle, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(title, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }


}
