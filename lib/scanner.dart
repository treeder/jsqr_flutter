import 'dart:async';
import 'dart:core';
import 'dart:html' as html;
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'jsqr.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();

  static DivElement vidDiv =
      DivElement(); // need a global for the registerViewFactory
}

class _ScannerState extends State<Scanner> {
  MediaStream _localStream;
  // final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _isTorchOn = false;
  MediaRecorder _mediaRecorder;
  bool get _isRec => _mediaRecorder != null;
  Timer timer;
  String code;
  String _errorMsg;
  var front = false;
  var video;
  String viewID = "your-view-id";

  @override
  void initState() {
    print("MY SCANNER initState");
    super.initState();
    video = VideoElement();
    Scanner.vidDiv.children = [video];
    // ignore: UNDEFINED_PREFIXED_NAME
    ui.platformViewRegistry
        .registerViewFactory(viewID, (int id) => Scanner.vidDiv);
    // initRenderers();
    Timer(Duration(milliseconds: 500), () {
      start();
    });
  }

  void start() async {
    _makeCall();
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (code != null) {
          timer.cancel();
          Navigator.pop(context, code);
          return;
        }
        _captureFrame2();
        if (code != null) {
          timer.cancel();
          Navigator.pop(context, code);
        }
      });
    }
  }

  @override
  void dispose() {
    print("Scanner.dispose");
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    if (_inCalling) {
      _stopStream();
    }
    // _localRenderer.dispose();
    super.dispose();
  }

  // void initRenderers() async {
  //   await _localRenderer.initialize();
  // }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _makeCall() async {
    if (_localStream != null) {
      return;
    }
    List<dynamic> sources =
        await window.navigator.mediaDevices.enumerateDevices();
    print("sources:");
    List<String> vidIds = [];
    for (final e in sources) {
      print(e);
      // if (e['kind'] == 'videoinput') {
      // vidIds.add(e['deviceId']);
      // }
    }
    // String deviceId = vidIds.length == 1
    //     ? vidIds[0]
    //     : vidIds[vidIds.length - 1]; // I have 2 front and 1 back on my phone
    // TODO I can't get the back camera to work for the life of me
    Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        // 'mandatory': {
        //   'minWidth': 640, // Provide your own width, height and frame rate here
        //   'minHeight': 480,
        //   'minFrameRate': 30,
        // },
        'facingMode': 'environment',
        // 'optional': [
        //   {
        //     'sourceId': vidIds.length == 1
        //         ? vidIds[0]
        //         : vidIds[
        //             vidIds.length - 1] // I have 2 front and 1 back on my phone
        //   }
        // ],
        // 'deviceId': deviceId,
      }
    };

    try {
      var stream = await window.navigator.getUserMedia(
          video: {'facingMode': (front ? "user" : "environment")});
      _localStream = stream;
      video.srcObject = _localStream;
      video.setAttribute("playsinline",
          'true'); // required to tell iOS safari we don't want fullscreen
      await video.play();
    } catch (e) {
      print(e.toString());
      setState(() {
        _errorMsg = e.toString();
      });
      return;
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  void _hangUp() async {
    await _stopStream();
    setState(() {
      _inCalling = false;
    });
  }

  Future<void> _stopStream() async {
    try {
      // await _localStream.dispose();
      _localStream.getTracks().forEach((track) {
        if (track.readyState == 'live') {
          track.stop();
        }
      });
      _localStream = null;
      // _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  // void _toggleTorch() async {
  //   final videoTrack = _localStream
  //       .getVideoTracks()
  //       .firstWhere((track) => track.kind == 'video');
  //   final has = await videoTrack.hasTorch();
  //   if (has) {
  //     print('[TORCH] Current camera supports torch mode');
  //     setState(() => _isTorchOn = !_isTorchOn);
  //     await videoTrack.setTorch(_isTorchOn);
  //     print('[TORCH] Torch state is now ${_isTorchOn ? 'on' : 'off'}');
  //   } else {
  //     print('[TORCH] Current camera does not support torch mode');
  //   }
  // }

  _toggleCamera() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    // await videoTrack.switchCamera();
    videoTrack.stop();
    await _makeCall();
  }

  Future<dynamic> _captureFrame2() async {
    if (_localStream == null) {
      print("localstream is null, can't capture frame");
      return null;
    }
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    // var durl = await videoTrack.captureFrame();

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    html.CanvasElement canvas =
        new html.CanvasElement(width: width.toInt(), height: height.toInt());
    html.CanvasRenderingContext2D ctx = canvas.context2D;
    // var image = html.ImageElement();
    // image.addEventListener('load', (event) {
    //   print("image loaded");
    //   canvas.width = image.width;
    //   canvas.height = image.height;
    //   ctx.drawImage(image, 0, 0);
    //   html.ImageData imgData =
    //       ctx.getImageData(0, 0, canvas.width, canvas.height);
    //   print(imgData);
    //   // resolve(context.getImageData(0, 0, canvas.width, canvas.height));
    //   // view-source:https://cozmo.github.io/jsQR/
    //   var code = jsQR(imgData.data, canvas.width, canvas.height);
    //   print("CODE: $code");
    //   if (code != null) {
    //     print(code.data);
    //     this.code = code.data;
    //   }
    // });
    // image.src = durl;
    canvas.height = video.videoHeight;
    canvas.width = video.videoWidth;
    ctx.drawImage(video, 0, 0);
    html.ImageData imgData =
        ctx.getImageData(0, 0, canvas.width, canvas.height);
    print(imgData);
    // resolve(context.getImageData(0, 0, canvas.width, canvas.height));
    // view-source:https://cozmo.github.io/jsQR/
    var code = jsQR(imgData.data, canvas.width, canvas.height);
    print("CODE: $code");
    if (code != null) {
      print(code.data);
      this.code = code.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMsg != null) {
      return Center(child: Text(_errorMsg));
    }
    if (_localStream == null) {
      // _makeCall();
      return Text("Loading...");
    }
    return Column(children: [
      Expanded(
        child: Container(
            // constraints: BoxConstraints(
            //   maxWidth: 600,
            //   maxHeight: 1000,
            // ),
            child: OrientationBuilder(
          builder: (context, orientation) {
            return Center(
              child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                // width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height,
                child: HtmlElementView(viewType: viewID),
                decoration: BoxDecoration(color: Colors.black54),
              ),
            );
          },
        )),
      ),
      // IconButton(
      //   icon: Icon(Icons.switch_video),
      //   onPressed: _toggleCamera,
      // ),
    ]);
  }
}
