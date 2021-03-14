import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'jsqrscanner.dart';

class Scanner2 extends StatefulWidget {
  const Scanner2({Key? key}) : super(key: key);

  @override
  _Scanner2State createState() => _Scanner2State();
}

class _Scanner2State extends State<Scanner2> {
  late Completer<String> _completer;
  JsQRScanner? _scanner;
  int _useCamera = -1;
  List<dynamic>? _cameras;

  @override
  void initState() {
    super.initState();
    scan({});
  }

  @override
  void dispose() {
    document.getElementById("scandiv")!.remove();
    super.dispose();
  }

  Future<int> getNumberOfCameras() {
    Completer<int> completer = new Completer<int>();
    _getCameras().then((cameras) => completer.complete(cameras.length));
    return completer.future;
  }

  Future<Iterable<dynamic>> _getCameras() {
    Completer<Iterable<dynamic>> completer = new Completer<Iterable<dynamic>>();
    window.navigator.mediaDevices!.enumerateDevices().then((devices) {
      completer
          .complete(devices.where((device) => device.kind == 'videoinput'));
    }).catchError((error) {
      completer.complete([]);
    });
    return completer.future;
  }

  // Future<Uint8List> callScan(MethodCall call) {
  //   var config;
  //   if (call.arguments is Uint8List) {
  //     var buffer = call.arguments as Uint8List;
  //     config = proto.Configuration.fromBuffer(buffer);
  //   } else {
  //     config = proto.Configuration()..useCamera = -1;
  //   }
  //   return scan(config);
  // }

  Future<String> scan(Map config) {
    _useCamera = 0; // config.useCamera;
    _ensureMediaDevicesSupported();
    // _createCSS();
    // var script = document.createElement('script');
    // script.setAttribute('type', 'text/javascript');
    // document.querySelector('head').append(script);
    // script.setAttribute('src',
    //     'assets/packages/barcode_scan_web/assets/jsqrscanner.nocache.js');
    _createHTML();
    document
        .querySelector('#toolbar p')!
        .addEventListener('click', (event) => _onCloseByUser());
    setProperty(window, 'JsQRScannerReady', allowInterop(this.scannerReady));
    _completer = new Completer<String>();
    return _completer.future;
  }

  void _ensureMediaDevicesSupported() {
    if (window.navigator.mediaDevices == null) {
      throw PlatformException(
          code: 'CAMERA_ACCESS_NOT_SUPPORTED',
          message: "Camera access not supported by browser");
    }
  }

  // void _createCSS() {
  //   var link = document.createElement('link');
  //   link.setAttribute('rel', 'stylesheet');
  //   link.setAttribute(
  //       'href', 'assets/packages/barcode_scan_web/assets/styles.css');
  //   document.querySelector('head').append(link);
  // }

  void _createHTML() {
    var containerDiv = document.createElement('div');
    containerDiv.id = 'scandiv';
    containerDiv.innerHtml = '''
    <div id="toolbar">
      <p>X</p>
      <div id="clear"></div>
    </div>
    <div id="scanner"></div>
    <div id="cover">
      <div id="topleft"></div>
      <div id="lefttop"></div>
      <div id="topright"></div>
      <div id="righttop"></div>
      <div id="bottomleft"></div>
      <div id="leftbottom"></div>
      <div id="bottomright"></div>
      <div id="rightbottom"></div>
    </div>
    ''';
    document.body!.append(containerDiv);
  }

  void onQRCodeScanned(String scannedText) {
    if (!_completer.isCompleted) {
      var scanResult = {
        'type': 'barcode',
        'format': 'qr',
        'data': scannedText,
      };
      _completer.complete(scannedText);
      _close();
    }
  }

  void _onCloseByUser() {
    _close();
    _completer.completeError(PlatformException(
        code: 'USER_CANCELED', message: 'User closed the scan window'));
  }

  void _close() {
    if (_scanner != null) {
      _scanner!.removeFrom(document.getElementById('scanner'));
      _scanner!.stopScanning();
    }
    document.getElementById('container')!.remove();
  }

  void scannerReady() {
    window.navigator.getUserMedia(video: true).then((stream) {
      window.navigator.mediaDevices!.enumerateDevices().then((devices) {
        _cameras =
            devices.where((device) => device.kind == 'videoinput').toList();
        _scanner = JsQRScanner(allowInterop(this.onQRCodeScanned),
            allowInterop(this.provideVideo));
        _scanner!.setSnapImageMaxSize(300);
        var scannerParentElement = document.getElementById('scanner');
        _scanner!.appendTo(scannerParentElement);
      }).catchError((onError) => _reject(onError));
    }).catchError((onError) => _reject(onError));
  }

  Promise<MediaStream> provideVideo() {
    var videoPromise;
    if (_useCamera < 0) {
      videoPromise = getUserMedia(new UserMediaOptions(
          video: new VideoOptions(facingMode: 'environment')));
    } else {
      videoPromise = getUserMedia(new UserMediaOptions(
          video: new VideoOptions(
              deviceId:
                  new DeviceIdOptions(exact: _cameras?[_useCamera].deviceId))));
    }
    videoPromise.then(null, allowInterop(_reject));
    return videoPromise;
  }

  void _reject(reject) {
    _completer.completeError(PlatformException(
        code: 'PERMISSION_NOT_GRANTED', message: reject.toString()));
    _close();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
