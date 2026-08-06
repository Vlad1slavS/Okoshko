import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';
import 'package:you_master_app/features/auth/presentation/widgets/auth_frame.dart';
import 'package:you_master_app/features/auth/presentation/widgets/auth_logo.dart';

class OtpAuthPage extends ConsumerStatefulWidget {
  const OtpAuthPage({super.key});
  @override
  ConsumerState<OtpAuthPage> createState() => _OtpAuthPageState();
}

class _OtpAuthPageState extends ConsumerState<OtpAuthPage> {
  final _code = TextEditingController();
  Timer? _timer;
  int _seconds = 60;
  bool _submitted = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _seconds > 0) setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify(String value) async {
    if (value.length != 6 || _submitted) return;
    _submitted = true;
    final ok = await ref.read(authControllerProvider.notifier).verifyOtp(value);
    _submitted = false;
    if (ok && mounted) {
      final user = ref.read(authControllerProvider).session?.user;
      context.go(
        user?.hasClientProfile == true
            ? AppRoutes.clientHome
            : AppRoutes.authProfile,
      );
    }
  }

  Future<void> _resend() async {
    final phone = ref.read(authControllerProvider).phone;
    if (phone == null) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .requestOtp(phone);
    if (ok && mounted) setState(() => _seconds = 60);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    if (state.phone == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.authPhone);
      });
    }
    final timer = '00:${_seconds.toString().padLeft(2, '0')}';
    return AuthFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.go(AppRoutes.authPhone),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const AuthLogo(),
            const SizedBox(height: 38),
            Text(
              'Введите код из SMS',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Мы отправили код на номер\n${_prettyPhone(state.phone ?? '')}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 38),
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    final value = index < _code.text.length
                        ? _code.text[index]
                        : '';
                    return Container(
                      width: 48,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: index == _code.text.length
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ),
                Opacity(
                  opacity: .01,
                  child: SizedBox(
                    width: 330,
                    child: TextField(
                      controller: _code,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (value) {
                        setState(() {});
                        _verify(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (state.devCode != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Код для локальной разработки: ${state.devCode}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            const SizedBox(height: 36),
            _seconds > 0
                ? Text(
                    'Получить новый код можно через $timer',
                    style: const TextStyle(color: AppColors.textSecondary),
                  )
                : TextButton(
                    onPressed: state.loading ? null : _resend,
                    child: const Text('Получить новый код'),
                  ),
            const SizedBox(height: 72),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 38,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Это безопасно',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Мы используем шифрование и не передаём код третьим лицам.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _prettyPhone(String phone) => phone.length == 12
      ? '${phone.substring(0, 2)} (${phone.substring(2, 5)}) ${phone.substring(5, 8)}-${phone.substring(8, 10)}-${phone.substring(10)}'
      : phone;
}
