import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white, // Set the background color to white
          alignment: Alignment.center,
          child: QrImageView(
            padding: const EdgeInsets.all(0),
            data:'https://getcode-eight.vercel.app/${user.uid}',
            gapless: true,
            size: 320,
            embeddedImage: AssetImage(''),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size(80, 80),
            ),
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
