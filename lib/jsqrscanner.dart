@JS()
library jsqrscanner;

import 'package:js/js.dart';
import 'dart:html';

@JS("navigator.mediaDevices.getUserMedia")
external Promise<MediaStream> getUserMedia(UserMediaOptions options);

@JS()
@anonymous
class UserMediaOptions {
  external VideoOptions get video;

  external factory UserMediaOptions({VideoOptions? video});
}

@JS()
@anonymous
class VideoOptions {
  external String get facingMode;
  external DeviceIdOptions get deviceId;

  external factory VideoOptions(
      {String? facingMode = null, DeviceIdOptions? deviceId = null});
}

@JS()
@anonymous
class DeviceIdOptions {
  external String get exact;

  external factory DeviceIdOptions({String? exact});
}

@JS()
class JsQRScanner {
  external factory JsQRScanner(Function onQRCodeScanned, Function provideVideo);
  external setSnapImageMaxSize(int maxSize);
  external removeFrom(Element? element);
  external appendTo(Element? element);
  external stopScanning();
}

@JS()
class Promise<T> {
  external Promise(void executor(void resolve(T result), Function reject));
  external Promise then(void onFulfilled(T result), [Function? onRejected]);
}
