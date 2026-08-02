import 'package:flutter/widgets.dart';
import 'package:you_master_app/app/bootstrap.dart';
import 'package:you_master_app/core/platform/app_loader/app_loader.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  bootstrap();

  binding.addPostFrameCallback((_) {
    removeAppLoader();
  });
}
