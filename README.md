# jsqr_flutter

A QR Code Scanner and image capturing library for Flutter. Uses [jsqr](https://github.com/cozmo/jsQR) under the hood for QR codes.

NOTE: Flutter web only.

## Usage

Add this to `web/index.html`:

```html
<script src="https://cdn.jsdelivr.net/npm/jsqr@1.3.1/dist/jsQR.min.js"></script>
```

Add this to pubspec:

```
jsqr: ^0.1.1
```

## Scanning for QR codes

Example code:

```dart
var code = await showDialog(
        context: context,
        builder: (BuildContext context) {
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;
          return AlertDialog(
            insetPadding: EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: const Text('Scan QR Code'),
            content: Container(
                // height: height - 20,
                width: width - 6,
                child: Scanner()),
          );
        });
```

The `code` var will contain the data contained in the QR code. 

See [/example](/example) for full example and usage. 

## Image Capture

You can also capture an image too by passing in `clickToCapture: true`, see [/example](/example) for how to use it.
