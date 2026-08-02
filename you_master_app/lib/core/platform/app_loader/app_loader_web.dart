import 'dart:js_interop';

@JS('removeFlutterLoader')
external void _removeFlutterLoader();

void removePlatformLoader() {
  _removeFlutterLoader();
}
