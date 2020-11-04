# jsqr_flutter

jsqr wrapper and widget for flutter web

NOTE: Flutter web only.

## Usage

Add this to `web/index.html`:

```html
<script src="https://cdn.jsdelivr.net/npm/jsqr@1.3.1/dist/jsQR.min.js"></script>
```

Then in your code:

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

See /example for full usage.

You can also capture an image too by passing in `clickToCapture: true`, see /example for how.


