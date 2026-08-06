enum ProfessionalAppointmentStatus { pending, confirmed, completed, cancelled }

class ProfessionalAppointmentSummary {
  const ProfessionalAppointmentSummary({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.startsAt,
    required this.status,
    this.clientAvatarAsset,
  });

  final String id;
  final String clientName;
  final String serviceName;
  final DateTime startsAt;
  final ProfessionalAppointmentStatus status;
  final String? clientAvatarAsset;
}

class ProfessionalDashboard {
  const ProfessionalDashboard({
    required this.professionalName,
    required this.todayAppointmentsCount,
    required this.todayRevenueMinor,
    required this.weekAppointmentsCount,
    required this.weekRevenueMinor,
    required this.newClientsCount,
    required this.appointmentsChangePercent,
    required this.revenueChangePercent,
    required this.newClientsChange,
    required this.todayAppointments,
    this.nextAppointment,
  });

  final String professionalName;
  final int todayAppointmentsCount;
  final int todayRevenueMinor;
  final int weekAppointmentsCount;
  final int weekRevenueMinor;
  final int newClientsCount;
  final int appointmentsChangePercent;
  final int revenueChangePercent;
  final int newClientsChange;
  final ProfessionalAppointmentSummary? nextAppointment;
  final List<ProfessionalAppointmentSummary> todayAppointments;
}
