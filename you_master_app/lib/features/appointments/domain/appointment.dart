import 'package:flutter/foundation.dart';

enum AppointmentsTab {
  upcoming('Предстоящие'),
  completed('Прошедшие'),
  cancelled('Отменённые');

  const AppointmentsTab(this.label);

  final String label;
}

enum AppointmentStatus {
  awaitingConfirmation('Ожидает подтверждения'),
  confirmed('Подтверждена'),
  completed('Завершена'),
  cancelledByClient('Отменена вами'),
  cancelledByProfessional('Отменена мастером');

  const AppointmentStatus(this.label);

  final String label;
}

@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.professionalId,
    required this.professionalName,
    required this.professionalImageAsset,
    required this.serviceName,
    required this.dateLabel,
    required this.timeLabel,
    required this.durationLabel,
    required this.price,
    required this.address,
    required this.status,
    this.reviewed = false,
  });

  final String id;
  final String professionalId;
  final String professionalName;
  final String professionalImageAsset;
  final String serviceName;
  final String dateLabel;
  final String timeLabel;
  final String durationLabel;
  final int price;
  final String address;
  final AppointmentStatus status;
  final bool reviewed;
}
