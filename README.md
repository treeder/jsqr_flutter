# jsqr_flutter

jsqr wrapper and widget for flutter web

NOTE: Flutter web only.

## Usage

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