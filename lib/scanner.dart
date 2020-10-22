import 'dart:async';
import 'dart:core';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'jsqr.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  MediaStream _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _isTorchOn = false;
  MediaRecorder _mediaRecorder;
  bool get _isRec => _mediaRecorder != null;
  Timer timer;
  String code;
  String _errorMsg;

  @override
  void initState() {
    super.initState();
    initRenderers();
    Timer(Duration(milliseconds: 500), () {
      start();
    });
  }

  void start() async {
    _makeCall();
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

  @override
  void deactivate() {
    super.deactivate();
    if (timer != null) {
      timer.cancel();
    }
    if (_inCalling) {
      _stopStream();
    }
    _localRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth':
              '600', // Provide your own width, height and frame rate here
          'minHeight': '600',
          'minFrameRate': '24',
        },
        'facingMode': 'environment',
        'optional': [],
      },
      'facingMode': 'environment',
      'optional': [],
    };

    try {
      var stream = await navigator.getUserMedia(mediaConstraints);
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
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

  void _stopStream() async {
    try {
      await _localStream.dispose();
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  void _toggleTorch() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final has = await videoTrack.hasTorch();
    if (has) {
      print('[TORCH] Current camera supports torch mode');
      setState(() => _isTorchOn = !_isTorchOn);
      await videoTrack.setTorch(_isTorchOn);
      print('[TORCH] Torch state is now ${_isTorchOn ? 'on' : 'off'}');
    } else {
      print('[TORCH] Current camera does not support torch mode');
    }
  }

  void _toggleCamera() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await videoTrack.switchCamera();
  }

  Future<dynamic> _captureFrame2() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    var durl = await videoTrack.captureFrame();
    html.CanvasElement canvas = new html.CanvasElement(width: 300, height: 300);
    html.CanvasRenderingContext2D ctx = canvas.context2D;
    var image = html.ImageElement();
    image.addEventListener('load', (event) {
      print("image loaded");
      canvas.width = image.width;
      canvas.height = image.height;
      ctx.drawImage(image, 0, 0);
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
    });
    image.src = durl;
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMsg != null) {
      return Center(child: Text(_errorMsg));
    }
    return SizedBox(
        height: 300,
        width: 300,
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Center(
              child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: RTCVideoView(_localRenderer, mirror: true),
                decoration: BoxDecoration(color: Colors.black54),
              ),
            );
          },
        ));
  }
}
