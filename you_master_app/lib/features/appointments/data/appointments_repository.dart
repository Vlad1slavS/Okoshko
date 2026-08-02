import 'package:you_master_app/features/appointments/domain/appointment.dart';

class AppointmentsPage {
  const AppointmentsPage({
    required this.items,
    required this.hasNextPage,
    this.nextPage,
  });

  final List<Appointment> items;
  final bool hasNextPage;
  final int? nextPage;
}

abstract interface class AppointmentsRepository {
  Future<AppointmentsPage> getAppointments({
    required AppointmentsTab tab,
    required int page,
    required int pageSize,
  });
}

class MockAppointmentsRepository implements AppointmentsRepository {
  const MockAppointmentsRepository();

  @override
  Future<AppointmentsPage> getAppointments({
    required AppointmentsTab tab,
    required int page,
    required int pageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final allItems = _items[tab] ?? const <Appointment>[];
    final start = (page - 1) * pageSize;
    if (start >= allItems.length) {
      return const AppointmentsPage(items: [], hasNextPage: false);
    }
    final end = (start + pageSize).clamp(0, allItems.length);
    final hasNextPage = end < allItems.length;

    return AppointmentsPage(
      items: allItems.sublist(start, end),
      hasNextPage: hasNextPage,
      nextPage: hasNextPage ? page + 1 : null,
    );
  }
}

const _items = <AppointmentsTab, List<Appointment>>{
  AppointmentsTab.upcoming: [
    Appointment(
      id: 'appointment-1',
      professionalId: 'ekaterina-smirnova',
      professionalName: 'Екатерина Смирнова',
      professionalImageAsset: 'assets/images/home/ekaterina.webp',
      serviceName: 'Маникюр с покрытием',
      dateLabel: 'Сегодня, 24 мая',
      timeLabel: '16:00',
      durationLabel: '1 ч 30 мин',
      price: 2200,
      address: 'Чистопрудный бульвар, 12с1',
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: 'appointment-2',
      professionalId: 'anna-ivanova',
      professionalName: 'Анна Иванова',
      professionalImageAsset: 'assets/images/home/anna.webp',
      serviceName: 'Окрашивание и коррекция бровей',
      dateLabel: '28 мая',
      timeLabel: '12:30',
      durationLabel: '45 мин',
      price: 1200,
      address: 'ул. Покровка, 17',
      status: AppointmentStatus.awaitingConfirmation,
    ),
    Appointment(
      id: 'appointment-3',
      professionalId: 'glamour-haven',
      professionalName: 'Glamour Haven',
      professionalImageAsset: 'assets/images/home/glamour_haven.webp',
      serviceName: 'Укладка волос',
      dateLabel: '3 июня',
      timeLabel: '18:00',
      durationLabel: '1 ч',
      price: 1800,
      address: 'ул. Большая Дмитровка, 9',
      status: AppointmentStatus.confirmed,
    ),
  ],
  AppointmentsTab.completed: [
    Appointment(
      id: 'appointment-4',
      professionalId: 'ekaterina-smirnova',
      professionalName: 'Екатерина Смирнова',
      professionalImageAsset: 'assets/images/home/ekaterina.webp',
      serviceName: 'Маникюр без покрытия',
      dateLabel: '12 мая',
      timeLabel: '14:00',
      durationLabel: '45 мин',
      price: 1200,
      address: 'Чистопрудный бульвар, 12с1',
      status: AppointmentStatus.completed,
    ),
    Appointment(
      id: 'appointment-5',
      professionalId: 'anna-ivanova',
      professionalName: 'Анна Иванова',
      professionalImageAsset: 'assets/images/home/anna.webp',
      serviceName: 'Коррекция бровей',
      dateLabel: '28 апреля',
      timeLabel: '11:30',
      durationLabel: '30 мин',
      price: 800,
      address: 'ул. Покровка, 17',
      status: AppointmentStatus.completed,
      reviewed: true,
    ),
  ],
  AppointmentsTab.cancelled: [],
};
