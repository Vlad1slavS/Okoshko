import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/client_profile/domain/client_profile.dart';

final clientProfileControllerProvider =
    NotifierProvider<ClientProfileController, ClientProfile>(
      ClientProfileController.new,
    );

class ClientProfileController extends Notifier<ClientProfile> {
  @override
  ClientProfile build() {
    return const ClientProfile(
      name: 'Екатерина Иванова',
      phone: '+7 ••• •••-12-34',
      email: 'ekaterina@example.com',
      avatarAsset: 'assets/images/home/ekaterina.webp',
      isPhoneVerified: true,
      upcomingAppointments: 2,
      favoriteCount: 7,
      notificationsEnabled: true,
    );
  }

  void updateProfile({required String name, required String email}) {
    state = state.copyWith(name: name.trim(), email: email.trim());
  }

  void setNotificationsEnabled(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }
}
