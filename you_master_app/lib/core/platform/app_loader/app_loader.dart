import 'app_loader_stub.dart'
    if (dart.library.js_interop) 'app_loader_web.dart';

void removeAppLoader() {
  removePlatformLoader();
}
