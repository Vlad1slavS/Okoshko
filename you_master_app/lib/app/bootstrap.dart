import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/app/you_master_app.dart';

void bootstrap() {
  runApp(const ProviderScope(child: YouMasterApp()));
}
