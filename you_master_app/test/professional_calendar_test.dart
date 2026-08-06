import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/features/professional_calendar/data/professional_calendar_repository.dart';
import 'package:you_master_app/features/professional_calendar/domain/professional_calendar.dart';
import 'package:you_master_app/features/professional_calendar/presentation/professional_calendar_page.dart';
import 'package:you_master_app/features/professional_calendar/presentation/state/professional_calendar_controller.dart';

void main() {
  testWidgets('professional calendar displays appointments for selected day', (
    tester,
  ) async {
    final today = DateTime.now();
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          professionalCalendarRepositoryProvider.overrideWithValue(
            _CalendarRepository(today),
          ),
        ],
        child: const MaterialApp(home: ProfessionalCalendarPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Расписание'), findsOneWidget);
    expect(find.text('Маникюр с покрытием'), findsOneWidget);
    expect(find.text('Анна Петрова'), findsOneWidget);
    expect(find.text('10:00 – 11:30'), findsOneWidget);
    expect(find.text('Добавить перерыв'), findsOneWidget);
  });
}

class _CalendarRepository implements ProfessionalCalendarRepository {
  const _CalendarRepository(this.today);
  final DateTime today;

  @override
  Future<ProfessionalCalendar> getMonth({
    required String professionalId,
    required DateTime month,
  }) async {
    return ProfessionalCalendar(
      professionalId: professionalId,
      timezone: 'Asia/Chita',
      appointments: [
        CalendarAppointment(
          id: 'appointment-1',
          clientName: 'Анна Петрова',
          serviceName: 'Маникюр с покрытием',
          date: DateTime(today.year, today.month, today.day),
          startTime: '10:00',
          endTime: '11:30',
          status: CalendarAppointmentStatus.confirmed,
          priceMinor: 220000,
          currency: 'RUB',
        ),
      ],
    );
  }
}
