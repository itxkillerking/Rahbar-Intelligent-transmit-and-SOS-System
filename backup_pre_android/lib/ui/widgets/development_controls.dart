import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../data/mocks/mock_platform_trigger_service.dart';
import '../../data/mocks/mock_synchronization_service.dart';
import '../../application/telemetry_controller.dart';

class DevelopmentControls extends ConsumerWidget {
  const DevelopmentControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  final triggerService = ref.read(platformTriggerServiceProvider) as MockPlatformTriggerService;
                  triggerService.simulateNormalTrigger();
                },
                child: const Text('Test Normal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final triggerService = ref.read(platformTriggerServiceProvider) as MockPlatformTriggerService;
                  triggerService.simulateSilentTrigger();
                },
                child: const Text('Test Silent'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  final syncService = ref.read(synchronizationServiceProvider) as MockSynchronizationService;
                  syncService.setOnlineStatus(false);
                  ref.read(telemetryControllerProvider.notifier).setOffline();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulating Offline Mode')));
                },
                child: const Text('Simulate Offline'),
              ),
              ElevatedButton(
                onPressed: () {
                  final syncService = ref.read(synchronizationServiceProvider) as MockSynchronizationService;
                  syncService.setOnlineStatus(true);
                  ref.read(telemetryControllerProvider.notifier).setOnline();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulating Online Mode')));
                },
                child: const Text('Simulate Online'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(telemetryControllerProvider.notifier).addMockTelemetry();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock Telemetry Added')));
                },
                child: const Text('Add Mock Telemetry'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(telemetryControllerProvider.notifier).simulateSync();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync Simulated')));
                },
                child: const Text('Simulate Sync'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
