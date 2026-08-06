import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/design_system/widgets/app_toast.dart';

void main() {
  testWidgets('AppToast shows message above the current screen and dismisses', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => AppToast.error(
              context,
              title: 'Не удалось отправить код',
              message: 'Попробуйте ещё раз',
            ),
            child: const Text('Показать'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Показать'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text('Не удалось отправить код'), findsOneWidget);
    expect(find.text('Попробуйте ещё раз'), findsOneWidget);

    await tester.tap(find.byTooltip('Закрыть уведомление'));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось отправить код'), findsNothing);
  });
}
