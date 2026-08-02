import 'package:flutter/foundation.dart';

@immutable
class ClientProfile {
  const ClientProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.avatarAsset,
    required this.isPhoneVerified,
    required this.upcomingAppointments,
    required this.favoriteCount,
    required this.notificationsEnabled,
  });

  final String name;
  final String phone;
  final String email;
  final String avatarAsset;
  final bool isPhoneVerified;
  final int upcomingAppointments;
  final int favoriteCount;
  final bool notificationsEnabled;

  ClientProfile copyWith({
    String? name,
    String? email,
    bool? notificationsEnabled,
  }) {
    return ClientProfile(
      name: name ?? this.name,
      phone: phone,
      email: email ?? this.email,
      avatarAsset: avatarAsset,
      isPhoneVerified: isPhoneVerified,
      upcomingAppointments: upcomingAppointments,
      favoriteCount: favoriteCount,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
