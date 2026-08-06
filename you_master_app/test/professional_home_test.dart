import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/features/professional_home/data/professional_home_repository.dart';
import 'package:you_master_app/features/professional_home/presentation/professional_home_page.dart';
import 'package:you_master_app/features/professional_home/presentation/state/professional_home_controller.dart';

void main() {
  testWidgets('professional home shows operational dashboard', (tester) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          professionalHomeRepositoryProvider.overrideWithValue(
            const MockProfessionalHomeRepository(delay: Duration.zero),
          ),
        ],
        child: const MaterialApp(home: ProfessionalHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Привет, Екатерина!'), findsOneWidget);
    expect(find.text('8 записей'), findsOneWidget);
    expect(find.text('Ближайшая запись'), findsOneWidget);
    expect(find.text('Анна Петрова'), findsAtLeastNWidgets(1));
    expect(find.text('Быстрые действия'), findsOneWidget);
    expect(find.text('Статистика'), findsOneWidget);
    expect(find.text('Записи сегодня'), findsOneWidget);
  });
}
