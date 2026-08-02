import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/app/bootstrap.dart';

void main() {
  testWidgets('appointments support tabs, actions and professional profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bootstrap();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продолжить как клиент'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Записи').last);
    await tester.pumpAndSettle();

    expect(find.text('Ближайшая запись'), findsOneWidget);
    expect(find.text('Маникюр с покрытием'), findsOneWidget);
    expect(find.text('Подтверждена'), findsWidgets);

    await tester.tap(find.byKey(const Key('appointments-tab-completed')));
    await tester.pumpAndSettle();

    expect(find.text('Маникюр без покрытия'), findsOneWidget);
    expect(find.text('Повторить'), findsWidgets);
    expect(find.text('Оставить отзыв'), findsOneWidget);

    await tester.tap(find.byKey(const Key('appointments-tab-cancelled')));
    await tester.pumpAndSettle();

    expect(find.text('Здесь пока пусто'), findsOneWidget);
    expect(find.text('У вас нет отменённых записей.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('appointments-tab-upcoming')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('appointment-professional-appointment-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Выберите услугу'), findsOneWidget);
    expect(find.text('Екатерина Смирнова'), findsWidgets);
  });
}
