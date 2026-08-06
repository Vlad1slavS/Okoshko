import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';

class AuthGatePage extends ConsumerStatefulWidget {
  const AuthGatePage({super.key});
  @override
  ConsumerState<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends ConsumerState<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final restored = await ref
          .read(authControllerProvider.notifier)
          .restoreSession();
      if (!mounted) return;
      if (!restored) {
        context.go(AppRoutes.authPhone);
        return;
      }
      final user = ref.read(authControllerProvider).session?.user;
      context.go(
        user?.hasClientProfile == true
            ? AppRoutes.clientHome
            : AppRoutes.authProfile,
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
  );
}
