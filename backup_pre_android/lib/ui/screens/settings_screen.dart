import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/fake_call_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/development_controls.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings & Safety', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        physics: const BouncingScrollPhysics(),
        children: const [
          FakeCallSection(),
          SizedBox(height: AppTheme.spacingXLarge),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
            child: Text(
              'Development & Testing',
              style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
            ),
          ),
          DevelopmentControls(),
        ],
      ),
    );
  }
}

class FakeCallSection extends ConsumerWidget {
  const FakeCallSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fakeCallControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Fake-Call Protection', style: AppTheme.titleStyle),
        const SizedBox(height: AppTheme.spacingSmall),
        const Text(
          'Simulate an incoming phone call to help escape unsafe situations. Excessive usage will lock the feature to prevent abuse and encourage real SOS activation.',
          style: AppTheme.captionStyle,
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
            side: BorderSide(color: state.isBlocked ? AppTheme.errorColor.withValues(alpha: 0.3) : AppTheme.textSecondary.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attempts Used:',
                      style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${state.attemptsUsed} / ${FakeCallState.threshold}',
                      style: AppTheme.headingStyle.copyWith(
                        color: state.isBlocked ? AppTheme.errorColor : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (state.isBlocked) ...[
                  const SizedBox(height: AppTheme.spacingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 20),
                        const SizedBox(width: AppTheme.spacingSmall),
                        Expanded(
                          child: Text(
                            'BLOCKED UNTIL PROTOTYPE RESET. Excessive fake-call usage detected. If you are in real danger, please use the RAHBAR SOS.',
                            style: AppTheme.captionStyle.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLarge),
                ElevatedButton.icon(
                  onPressed: state.isBlocked
                      ? null
                      : () async {
                          final success = await ref.read(fakeCallControllerProvider.notifier).triggerFakeCall();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Incoming Call Simulated...'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('TRIGGER FAKE CALL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                ),
                if (state.history.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingLarge),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingSmall),
                  const Text('Prototype History:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppTheme.spacingSmall),
                  ...state.history.map((attempt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${attempt.timestamp.hour}:${attempt.timestamp.minute.toString().padLeft(2, '0')}',
                            style: AppTheme.captionStyle,
                          ),
                          Text(
                            attempt.status,
                            style: AppTheme.captionStyle.copyWith(color: AppTheme.safeColor),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: AppTheme.spacingMedium),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(fakeCallControllerProvider.notifier).resetPrototype();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reset Prototype History'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
