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
        return SimpleDialog(
        title: const Text('Scan QR Code'),
        children: <Widget>[
            SizedBox(height: 300, child: Scanner()),
        ],
        );
    });
```
