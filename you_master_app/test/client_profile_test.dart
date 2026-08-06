import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/features/client_profile/presentation/client_profile_page.dart';

void main() {
  testWidgets('client profile shows account sections', (tester) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ClientProfilePage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Пользователь'), findsOneWidget);
    expect(find.text('Мои записи'), findsOneWidget);
    expect(find.text('Избранное'), findsOneWidget);
    expect(find.text('Уведомления'), findsOneWidget);
    expect(find.text('Помощь и поддержка'), findsOneWidget);
  });
}
