import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

class AuthFrame extends StatelessWidget {
  const AuthFrame({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [Color(0xFFFFF1F5), Colors.white],
          stops: [0, .42],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            height: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: const BoxDecoration(
              color: Color(0xF8FFFFFF),
              border: Border.symmetric(
                vertical: BorderSide(color: AppColors.border),
              ),
            ),
            child: child,
          ),
        ),
      ),
    ),
  );
}
