import 'dart:async';
import 'dart:core';
import 'dart:html' as html;
import 'dart:js_util';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'jsqr.dart';
import 'media.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();

  static html.DivElement vidDiv =
      html.DivElement(); // need a global for the registerViewFactory

  static Future<bool> cameraAvailable() async {
    List<dynamic> sources =
        await html.window.navigator.mediaDevices.enumerateDevices();
    print("sources:");
    // List<String> vidIds = [];
    bool hasCam = false;
    for (final e in sources) {
      print(e);
      if (e.kind == 'videoinput') {
        // vidIds.add(e['deviceId']);
        hasCam = true;
      }
    }
    return hasCam;
  }
}

class _ScannerState extends State<Scanner> {
  html.MediaStream _localStream;
  html.CanvasElement canvas;
  html.CanvasRenderingContext2D ctx;
  bool _inCalling = false;
  bool _isTorchOn = false;
  html.MediaRecorder _mediaRecorder;
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
    video = html.VideoElement();
    // canvas = new html.CanvasElement(width: );
    // ctx = canvas.context2D;
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
    await _makeCall();
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
    // instead of periodic, which seems to have some timing issues, going to call timer AFTER the capture.
  }

  void cancel() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  @override
  void dispose() {
    print("Scanner.dispose");
    cancel();
    if (_inCalling) {
      _stopStream();
    }
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _makeCall() async {
    if (_localStream != null) {
      return;
    }

    try {
      var constraints = UserMediaOptions(
          // audio: false,
          video: VideoOptions(
        facingMode: (front ? "user" : "environment"),
      ));
      // dart style, not working properly:
      // var stream =
      //     await html.window.navigator.mediaDevices.getUserMedia(constraints);
      // straight JS:
      var stream = await promiseToFuture(getUserMedia(constraints));
      _localStream = stream;
      video.srcObject = _localStream;
      video.setAttribute("playsinline",
          'true'); // required to tell iOS safari we don't want fullscreen
      await video.play();
    } catch (e) {
      print("error on getUserMedia: ${e.toString()}");
      cancel();
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

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    html.CanvasElement canvas =
        new html.CanvasElement(width: width.toInt(), height: height.toInt());
    html.CanvasRenderingContext2D ctx = canvas.context2D;
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
