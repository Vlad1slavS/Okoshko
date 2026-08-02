import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/app/bootstrap.dart';

void main() {
  testWidgets('opens both role shells', (tester) async {
    bootstrap();
    await tester.pumpAndSettle();

    expect(find.text('YouMaster'), findsOneWidget);
    expect(find.text('Продолжить как клиент'), findsOneWidget);

    await tester.tap(find.text('Продолжить как клиент'));
    await tester.pumpAndSettle();

    expect(find.text('Главная'), findsWidgets);
    expect(find.text('Поиск'), findsOneWidget);
    expect(find.text('Избранное'), findsOneWidget);
  });

  testWidgets('client home loads popular professionals by category', (
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

    await tester.tap(find.byKey(const Key('category-manicure')));
    await tester.pump();

    expect(
      find.byKey(const Key('popular-professional-skeleton')),
      findsNWidgets(3),
    );

    await tester.pumpAndSettle();

    expect(find.text('Екатерина Смирнова'), findsOneWidget);
    expect(find.text('Glamour Haven'), findsNothing);
  });

  testWidgets('client tabs preserve their branch state', (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bootstrap();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продолжить как клиент'));
    await tester.pumpAndSettle();

    final searchField = find.byKey(const Key('home-search-field'));
    await tester.enterText(searchField, 'Екатерина');
    await tester.pump();

    await tester.tap(find.text('Избранное').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Главная').last);
    await tester.pumpAndSettle();

    expect(searchField, findsOneWidget);
    expect(tester.widget<TextField>(searchField).controller?.text, 'Екатерина');
    expect(find.text('Екатерина Смирнова'), findsOneWidget);
  });

  testWidgets('favorites show saved professionals and support removal', (
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

    await tester.tap(find.byKey(const Key('favorite-glamour-haven')));
    await tester.pump();
    await tester.tap(find.text('Избранное').last);
    await tester.pumpAndSettle();

    expect(find.text('Glamour Haven'), findsOneWidget);

    await tester.tap(find.byKey(const Key('favorite-glamour-haven')));
    await tester.pumpAndSettle();

    expect(find.text('Пока ничего не добавлено'), findsOneWidget);
    expect(find.byKey(const Key('favorites-open-search')), findsOneWidget);
  });

  testWidgets('home transfers query once and search stays independent', (
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

    final homeSearchField = find.byKey(const Key('home-search-field'));
    await tester.enterText(homeSearchField, 'Екатерина');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    final searchField = find.byKey(const Key('client-search-field'));
    expect(tester.widget<TextField>(searchField).controller?.text, 'Екатерина');

    await tester.enterText(searchField, 'Анна');
    await tester.pump();

    expect(find.text('Анна Иванова'), findsOneWidget);
    expect(find.text('Glamour Haven'), findsNothing);

    await tester.tap(find.text('Главная').last);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('home-search-field')))
          .controller
          ?.text,
      'Екатерина',
    );
  });

  testWidgets('show all opens the search tab', (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bootstrap();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продолжить как клиент'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('show-all-professionals')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('client-search-field')), findsOneWidget);
    expect(find.text('Найдено: 3'), findsOneWidget);
  });
}
