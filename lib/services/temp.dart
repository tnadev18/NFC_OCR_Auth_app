// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class QRGenerate extends StatelessWidget {
//   const QRGenerate({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("QR Code App"),
//           backgroundColor: Colors.green.shade700,
//           centerTitle: true,
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Generate QR Code'),
//               Tab(text: 'Scan QR Code'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             QRCodeGenerator(),
//             QRCodeScanner(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class QRCodeGenerator extends StatefulWidget {
//   const QRCodeGenerator({Key? key}) : super(key: key);

//   @override
//   _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
// }

// class _QRCodeGeneratorState extends State<QRCodeGenerator> {
//   String initialUrl = 'https://example.com';

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(30),
//       child: Column(
//         children: [
//           TextField(
//             onChanged: (val) {
//               setState(() {
//                 initialUrl = val;
//               });
//             },
//             decoration: const InputDecoration(
//               labelText: 'Type your link',
//             ),
//           ),
//           const SizedBox(height: 30),
//           const Text(
//             'QR Code for the entered URL:',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           QrImageView(
//             data: initialUrl,
//             padding: const EdgeInsets.all(0),
//             // embeddedImage: const AssetImage('assets/icon.png'),
//             embeddedImageStyle: QrEmbeddedImageStyle(
//               size: const Size(50, 50),
//             ),
//             eyeStyle: const QrEyeStyle(
//               eyeShape: QrEyeShape.circle,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class QRCodeScanner extends StatefulWidget {
//   const QRCodeScanner({Key? key}) : super(key: key);

//   @override
//   _QRCodeScannerState createState() => _QRCodeScannerState();
// }

// class _QRCodeScannerState extends State<QRCodeScanner> {
//   final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

//   QRViewController? _controller;
//   String? _scannedData;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Expanded(
//           child: QRView(
//             key: _qrKey,
//             onQRViewCreated: _onQRViewCreated,
//           ),
//         ),
//         Text('Scanned Data: ${_scannedData ?? "None"}'),
//       ],
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this._controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         _scannedData = scanData.code; // Extract the code from Barcode
//       });
//     });
//   }
// }
