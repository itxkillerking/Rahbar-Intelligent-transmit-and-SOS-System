import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/guardian_controller.dart';
import '../../domain/models/guardian.dart';
import '../theme/app_theme.dart';

class GuardianScreen extends ConsumerWidget {
  const GuardianScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardianState = ref.watch(guardianControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Family Safety', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: guardianState.isLoading && guardianState.guardians.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Your trusted safety network', style: AppTheme.captionStyle),
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  _buildSummaryCard(guardianState.guardians.length),
                  const SizedBox(height: AppTheme.spacingXLarge),

                  _buildPrimaryGuardian(guardianState.guardians),
                  const SizedBox(height: AppTheme.spacingLarge),

                  _buildGuardianNetwork(context, guardianState.guardians),
                  const SizedBox(height: AppTheme.spacingXLarge),

                  _buildAddGuardianAction(context, ref),
                  const SizedBox(height: AppTheme.spacingXLarge),

                  const Text('Safety Sharing', style: AppTheme.titleStyle),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildSafetySharing(),
                  const SizedBox(height: AppTheme.spacingXLarge),

                  _buildEmergencyConnection(),
                  const SizedBox(height: AppTheme.spacingLarge),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(int count) {
    return Card(
      color: AppTheme.safeColor.withValues(alpha: 0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        side: BorderSide(color: AppTheme.safeColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_rounded, color: AppTheme.safeColor),
                const SizedBox(width: AppTheme.spacingSmall),
                Text('Network Active', style: AppTheme.titleStyle.copyWith(color: AppTheme.safeColor)),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryStat('$count', 'Connected'),
                Container(height: 30, width: 1, color: AppTheme.safeColor.withValues(alpha: 0.2)),
                _buildSummaryStat('Available', 'Primary'),
                Container(height: 30, width: 1, color: AppTheme.safeColor.withValues(alpha: 0.2)),
                _buildSummaryStat('Ready', 'Support'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTheme.headingStyle.copyWith(fontSize: 20)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.captionStyle),
      ],
    );
  }

  Widget _buildPrimaryGuardian(List<Guardian> guardians) {
    final primary = guardians.where((g) => g.isPrimary).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Primary Guardian', style: AppTheme.titleStyle),
        const SizedBox(height: AppTheme.spacingMedium),
        if (primary == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Text(
                'No primary guardian set.',
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Card(
            elevation: 4,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
              side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.star_rounded, color: AppTheme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(primary.name, style: AppTheme.titleStyle),
                        const SizedBox(height: 2),
                        Text(primary.relationship, style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                  _buildVerificationBadge(primary.isVerified),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGuardianNetwork(BuildContext context, List<Guardian> guardians) {
    final others = guardians.where((g) => !g.isPrimary).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Your Guardians', style: AppTheme.titleStyle),
        const SizedBox(height: AppTheme.spacingMedium),
        if (others.isEmpty)
          Card(
            elevation: 0,
            color: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
              side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
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
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: others.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSmall),
            itemBuilder: (context, index) {
              final g = others[index];
              return Card(
                elevation: 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    child: Text(
                      g.name.isNotEmpty ? g.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(g.name, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text(g.relationship, style: AppTheme.captionStyle),
                  trailing: _buildVerificationBadge(g.isVerified),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildVerificationBadge(bool isVerified) {
    if (!isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.5)),
        ),
        child: const Text('PENDING', style: TextStyle(color: AppTheme.warningColor, fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.safeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.safeColor.withValues(alpha: 0.5)),
      ),
      child: const Text('VERIFIED', style: TextStyle(color: AppTheme.safeColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAddGuardianAction(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        _showAddGuardianDialog(context, ref);
      },
      icon: const Icon(Icons.person_add_rounded),
      label: const Text('ADD GUARDIAN'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.secondaryColor,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
      ),
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
          title: const Text('Invite Guardian', style: AppTheme.titleStyle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add a trusted contact to your prototype safety network.', style: AppTheme.captionStyle),
                const SizedBox(height: AppTheme.spacingMedium),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                TextField(
                  controller: relationController,
                  decoration: const InputDecoration(labelText: 'Relationship', border: OutlineInputBorder()),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
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
                }
              },
              child: const Text('Invite'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSafetySharing() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildSharingRow(Icons.notification_important_rounded, 'Emergency Alerts', 'Guardians are notified when SOS is triggered.'),
          const Divider(height: 1),
          _buildSharingRow(Icons.location_on_rounded, 'Location During Emergency', 'Location is securely shared only during active emergencies.'),
          const Divider(height: 1),
          _buildSharingRow(Icons.folder_shared_rounded, 'Evidence Availability', 'Captured emergency media becomes available for review.'),
        ],
      ),
    );
  }

  Widget _buildSharingRow(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTheme.captionStyle),
    );
  }

  Widget _buildEmergencyConnection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Text(
              'When an emergency is activated, your trusted guardians can be notified through the RAHBAR emergency protocol. (Prototype functionality)',
              style: AppTheme.bodyStyle.copyWith(color: AppTheme.primaryColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
