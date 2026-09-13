import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/shell/app_shell.dart';
import 'ui/theme/app_theme.dart';
import 'services/hardware_emergency_trigger_service.dart';
import 'services/widget_communication_service.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // Eagerly initialize background listeners
  container.read(hardwareEmergencyTriggerServiceProvider);
  container.read(widgetCommunicationServiceProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RahbarApp(),
    ),
  );
}

class RahbarApp extends StatelessWidget {
  const RahbarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAHBAR',
      navigatorKey: globalNavigatorKey,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
