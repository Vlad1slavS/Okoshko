import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';
import 'package:you_master_app/features/auth/presentation/widgets/auth_frame.dart';
import 'package:you_master_app/features/auth/presentation/widgets/auth_logo.dart';
import 'package:you_master_app/design_system/widgets/app_toast.dart';

class PhoneAuthPage extends ConsumerStatefulWidget {
  const PhoneAuthPage({super.key});
  @override
  ConsumerState<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends ConsumerState<PhoneAuthPage> {
  final _phone = TextEditingController();
  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      AppToast.warning(
        context,
        title: 'Проверьте номер телефона',
        message: 'Введите 10 цифр после +7, чтобы продолжить.',
      );
      return;
    }
    final ok = await ref
        .read(authControllerProvider.notifier)
        .requestOtp('+7$digits');
    if (!mounted) return;
    if (ok) {
      AppToast.success(
        context,
        title: 'Готово!',
        message:
            'Код отправлен на номер +7 ${digits.substring(0, 3)} ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8)}',
      );
      final returnTo = GoRouterState.of(
        context,
      ).uri.queryParameters['returnTo'];
      context.go(AppRoutes.withReturnTo(AppRoutes.authOtp, returnTo));
    } else {
      final message = ref.read(authControllerProvider).error;
      AppToast.error(
        context,
        title: 'Не удалось отправить код',
        message:
            message ??
            'Проверьте подключение к интернету и попробуйте ещё раз.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthFrame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Небольшой верхний отступ.
                    const Spacer(flex: 2),

                    const AuthLogo(),
                    const SizedBox(height: 32),

                    Text(
                      'Добро пожаловать!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Введите номер телефона,\n'
                      'чтобы войти или зарегистрироваться',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 42),

                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Номер телефона',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Center(
                            widthFactor: 1,
                            child: Text('+7', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.loading ? null : _submit,
                        child: state.loading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Продолжить',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Мы бережно храним ваши данные',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),

                    // Нижняя часть получает больше свободного пространства.
                    const Spacer(flex: 3),

                    const Padding(
                      padding: EdgeInsets.only(bottom: 28),
                      child: Text(
                        'Продолжая, вы соглашаетесь с\n'
                        'Политикой конфиденциальности и '
                        'Пользовательским соглашением',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
