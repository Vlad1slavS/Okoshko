import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientLocationProvider =
    NotifierProvider<ClientLocationController, String>(
      ClientLocationController.new,
    );

class ClientLocationController extends Notifier<String> {
  @override
  String build() => 'Чита';

  void selectCity(String city) {
    state = city;
  }
}
