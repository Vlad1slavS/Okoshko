import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/features/professional_details/presentation/professional_details_page.dart';

void main() {
  testWidgets('loads professional details and selected service', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfessionalDetailsPage(professionalId: 'ekaterina-smirnova'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Екатерина Смирнова'), findsWidgets);
    expect(find.text('Выберите услугу'), findsOneWidget);
    expect(find.text('Маникюр с покрытием'), findsWidgets);
    expect(find.byKey(const Key('choose-booking-time')), findsOneWidget);
  });
}
