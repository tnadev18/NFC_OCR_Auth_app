import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String hardcodedURL = 'https://example.com';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'QR Code for the static URL:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            child: QrImageView(
              data: hardcodedURL,
              padding: const EdgeInsets.all(0),
              embeddedImage: const AssetImage('assets/icon.png'),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: const Size(50, 50),
              ),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
