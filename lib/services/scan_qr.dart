import 'package:auth/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';


class QR extends StatelessWidget {
  const QR({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QRCodeScanner();
  }
}

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({Key? key}) : super(key: key);

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  final user = FirebaseAuth.instance.currentUser!;

  QRViewController? _controller;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        // Text('Scanned Data: ${_scannedData ?? "None"}'),
      ],
    );
  }

  Future<void> addCard(String data) async {
    final url = Uri.parse(
        'https://getcode-ndef-api.vercel.app/store_shared_car?shared_by_uid=${data}&recieved_by_uid=${user.uid}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String message = data['message'];
        print(message);
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print("Failed to load data");
      }
    } catch (e) {
      print("Failed to load data: $e");
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _scannedData = scanData.code; // Extract the code from Barcode
        String scaneddata = scanData.code.toString();
        if (scanData.code != null &&
            scaneddata.contains("getcode-eight.vercel.app/")) {
          // Remove the prefix
          scaneddata = scaneddata.substring("getcode-eight.vercel.app/".length+8);
          print("************************" + scaneddata);
          addCard(scaneddata);
        }
        else{
          Fluttertoast.showToast(
              msg: "Invalid QR",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
        }
        Navigator.of(context).pop(
          MaterialPageRoute(builder: (context) {
            return HomePage();
          }),
        );
      });
    });
  }
}
