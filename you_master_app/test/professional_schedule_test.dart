import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/features/professional_schedule/data/professional_schedule_repository.dart';
import 'package:you_master_app/features/professional_schedule/domain/professional_schedule.dart';
import 'package:you_master_app/features/professional_schedule/presentation/professional_schedule_page.dart';
import 'package:you_master_app/features/professional_schedule/presentation/state/professional_schedule_controller.dart';

void main() {
  testWidgets('master creates start-based schedule with service restrictions', (
    tester,
  ) async {
    final repository = _ScheduleRepository();
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          professionalScheduleRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ProfessionalSchedulePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Создание расписания'), findsOneWidget);
    expect(find.text('09:30'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);
    expect(find.text('Любая услуга'), findsNWidgets(4));
    expect(find.text('Сохранить расписание'), findsOneWidget);
  });
}

class _ScheduleRepository implements ProfessionalScheduleRepository {
  @override
  Future<List<ScheduleServiceOption>> getServices(String professionalId) async {
    return const [ScheduleServiceOption(id: 'service-1', name: 'Наращивание')];
  }

  @override
  Future<void> saveStarts({
    required String professionalId,
    required Set<DateTime> dates,
    required List<EditableAvailabilityStart> starts,
  }) async {}
}
