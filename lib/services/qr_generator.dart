import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRGenerate extends StatelessWidget {
  const QRGenerate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QRCodeGenerator();
  }
}

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({Key? key}) : super(key: key);

  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  String initialUrl = 'https://example.com';

  @override
  Widget build(BuildContext context) {
    return QrImage(
            data: initialUrl,
            padding: const EdgeInsets.all(0),
            // embeddedImage: const AssetImage('assets/icon.png'),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: const Size(50, 50),
            ),
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.circle,
              color: Colors.black,
            ),
          );,
}
