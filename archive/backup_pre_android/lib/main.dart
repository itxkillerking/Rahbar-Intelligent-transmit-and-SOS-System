import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/shell/app_shell.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RahbarApp(),
    ),
  );
}

class RahbarApp extends StatelessWidget {
  const RahbarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAHBAR',
      theme: AppTheme.lightTheme,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
