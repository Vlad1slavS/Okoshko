import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/app/router/app_router.dart';
import 'package:you_master_app/design_system/theme/app_theme.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';

class YouMasterApp extends ConsumerStatefulWidget {
  const YouMasterApp({super.key});

  @override
  ConsumerState<YouMasterApp> createState() => _YouMasterAppState();
}

class _YouMasterAppState extends ConsumerState<YouMasterApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Окошко - найди своего мастера',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
