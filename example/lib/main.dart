import 'package:flutter/material.dart';
import 'package:jsqr/scanner.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String code;
  // Future<List<dynamic>> sourcesF;
  Future<bool> camAvailableF;
  html.ImageElement img;

  @override
  void initState() {
    super.initState();
    // sourcesF = navigator.mediaDevices.getSources();
    camAvailableF = Scanner.cameraAvailable();
  }

  void _openScan() async {
    var code = await showDialog(
        context: context,
        builder: (BuildContext context) {
          // var height = MediaQuery.of(context).size.height;
          // var width = MediaQuery.of(context).size.width;
          return AlertDialog(
            insetPadding: EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: const Text('Scan QR Code'),
            content: Container(
                // height: height - 20,
                width: 640,
                height: 480,
                child: Scanner()),
          );
        });
    print("CODE: $code");
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      this.code = code;
      _counter++;
    });
  }

  void _captureImage() async {
    var dataUrl = await showDialog(
        context: context,
        builder: (BuildContext context) {
          // var height = MediaQuery.of(context).size.height;
          // var width = MediaQuery.of(context).size.width;
          return AlertDialog(
            insetPadding: EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: const Text('Scan QR Code'),
            content: Container(
                // height: height - 20,
                width: 640,
                height: 480,
                child: Scanner(
                  clickToCapture: true,
                )),
          );
        });
    print("IMG URL: $dataUrl");
    html.DivElement vidDiv =
        html.DivElement(); // need a global for the registerViewFactory

    // ignore: UNDEFINED_PREFIXED_NAME
    ui.platformViewRegistry.registerViewFactory("cap", (int id) => vidDiv);

    img = new html.ImageElement();
    img.src = dataUrl;
    vidDiv.children = [img];
    // html.document.body.children.add(img);
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // this.code = code;
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<bool>(
              future: camAvailableF,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("ERROR: ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  if (snapshot.data) {
                    return (Text("Camera is available"));
                  }
                  return (Text("No camera available"));
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$code',
              style: Theme.of(context).textTheme.headline4,
            ),
            // FutureBuilder<List<dynamic>>(
            //   future: sourcesF,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasError) {
            //       return Text("ERROR: ${snapshot.error}");
            //     }
            //     if (snapshot.hasData) {
            //       List<Widget> children = [];
            //       for (final e in snapshot.data) {
            //         children.add(Text(e.toString()));
            //       }
            //       return Center(child: Column(children: children));
            //     } else {
            //       // We can show the loading view until the data comes back.
            //       return CircularProgressIndicator();
            //     }
            //   },
            // )
            SizedBox(height: 10),
            RaisedButton(
              child: Text("Scan QR Code"),
              onPressed: _openScan,
            ),
            SizedBox(height: 10),
            RaisedButton(
              child: Text("Capture Image"),
              onPressed: _captureImage,
            ),
            SizedBox(height: 10),
            if (img != null)
              SizedBox(
                  width: 640,
                  height: 480,
                  child: HtmlElementView(viewType: "cap")),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _openScan,
      //   tooltip: 'Scan',
      //   child: Icon(Icons.camera_alt),
      // ),
    );
  }
}
