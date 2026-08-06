import 'package:you_master_app/features/professional_home/domain/professional_dashboard.dart';

abstract interface class ProfessionalHomeRepository {
  Future<ProfessionalDashboard> getDashboard();
}

class MockProfessionalHomeRepository implements ProfessionalHomeRepository {
  const MockProfessionalHomeRepository({
    this.delay = const Duration(milliseconds: 350),
  });

  final Duration delay;

  @override
  Future<ProfessionalDashboard> getDashboard() async {
    await Future<void>.delayed(delay);
    final now = DateTime.now();
    final appointments = [
      ProfessionalAppointmentSummary(
        id: 'appointment-1',
        clientName: 'Анна Петрова',
        serviceName: 'Маникюр + гель-лак',
        startsAt: DateTime(now.year, now.month, now.day, 10),
        status: ProfessionalAppointmentStatus.confirmed,
        clientAvatarAsset: 'assets/images/home/anna.webp',
      ),
      ProfessionalAppointmentSummary(
        id: 'appointment-2',
        clientName: 'Мария Смирнова',
        serviceName: 'Брови + окрашивание',
        startsAt: DateTime(now.year, now.month, now.day, 12, 30),
        status: ProfessionalAppointmentStatus.confirmed,
        clientAvatarAsset: 'assets/images/home/ekaterina.webp',
      ),
      ProfessionalAppointmentSummary(
        id: 'appointment-3',
        clientName: 'Ольга Иванова',
        serviceName: 'Педикюр',
        startsAt: DateTime(now.year, now.month, now.day, 15),
        status: ProfessionalAppointmentStatus.pending,
      ),
    ];

    return ProfessionalDashboard(
      professionalName: 'Екатерина',
      todayAppointmentsCount: 8,
      todayRevenueMinor: 1246000,
      weekAppointmentsCount: 32,
      weekRevenueMinor: 4875000,
      newClientsCount: 7,
      appointmentsChangePercent: 12,
      revenueChangePercent: 9,
      newClientsChange: 3,
      nextAppointment: appointments.first,
      todayAppointments: appointments,
    );
  }
}
