import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/app/router/app_router.dart';
import 'package:you_master_app/design_system/theme/app_theme.dart';

class YouMasterApp extends ConsumerWidget {
  const YouMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Окошко - найди своего мастера',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
