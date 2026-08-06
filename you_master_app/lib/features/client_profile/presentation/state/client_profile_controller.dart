import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';
import 'package:you_master_app/features/client_profile/domain/client_profile.dart';

final clientProfileControllerProvider =
    NotifierProvider<ClientProfileController, ClientProfile>(
      ClientProfileController.new,
    );

class ClientProfileController extends Notifier<ClientProfile> {
  @override
  ClientProfile build() {
    final user = ref.watch(authControllerProvider).session?.user;
    return ClientProfile(
      name: user?.displayName ?? 'Пользователь',
      phone: _maskPhone(user?.phone),
      email: user?.email,
      isPhoneVerified: user != null,
      upcomingAppointments: 0,
      favoriteCount: 0,
      notificationsEnabled: true,
    );
  }

  void setNotificationsEnabled(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  String _maskPhone(String? phone) {
    if (phone == null || phone.length < 4) return '';
    final lastFour = phone.substring(phone.length - 4);
    return '+7 ••• •••-${lastFour.substring(0, 2)}-${lastFour.substring(2)}';
  }
}
