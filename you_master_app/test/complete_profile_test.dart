import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/features/auth/presentation/complete_profile_page.dart';

void main() {
  testWidgets('new user profile keeps field validation next to the field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CompleteProfilePage())),
    );

    await tester.tap(find.text('Продолжить'));
    await tester.pump();

    expect(find.text('Укажите имя'), findsOneWidget);
    expect(find.text('Необязательно'), findsOneWidget);
  });
}
