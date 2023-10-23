// import 'dart:js_util';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

class AddUserCard extends StatefulWidget {
  @override
  _AddUserCardState createState() => _AddUserCardState();
}

class _AddUserCardState extends State<AddUserCard> {
  String parsedtext = '';
  String filepath = '';
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await _cameraController.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> captureImageAndPerformOCR() async {
    if (_cameraController.value.isTakingPicture) {
      return;
    }
    final XFile imageFile = await _cameraController.takePicture();
    if (imageFile == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(), // Loader widget
        );
      },
    );

    try {
      var bytes = File(imageFile.path).readAsBytesSync();
      String img64 = base64Encode(bytes);

      var url = 'https://api.ocr.space/parse/image';
      var payload = {
        "base64Image": "data:image/jpg;base64,${img64.toString()}",
        "language": "eng"
      };
      var header = {"apikey": "K86070579388957"};

      var post =
          await http.post(Uri.parse(url), body: payload, headers: header);
      var result = jsonDecode(post.body);
      var rawText = result['ParsedResults'][0]['ParsedText'];

      final url1 = Uri.parse(
          'https://getcode-ndef-api.vercel.app/process_raw_data?raw_data=${rawText}');

      final response = await http.get(url1);

      final data = json.decode(response.body);
      String message = data['data'].toString();
      final address = data['data']['Address'];
      final company_name = data['data']['Company Name'];
      final Email = data['data']['Email'];
      final Phone = data['data']['Phone'];

      print("128" + message);

      Navigator.pop(context); // Close the loader

      // Navigate to a new screen with the captured image and extracted text.
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CapturedScreen(
              imagePath: imageFile.path,
              // extractedText: message,
              address: address,
              phone: Phone),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close the loader
      print('103 Error: $e');
    }
  }

  // Future<void> parsethetext(ImageSource source) async {
  //   final pickedFile = await ImagePicker().getImage(source: source);
  //   if (pickedFile == null) return;

  //   try {
  //     setState(() {
  //       filepath = pickedFile.path;
  //       parsedtext = 'OCR in progress...';
  //     });

  //     var bytes = File(pickedFile.path.toString()).readAsBytesSync();
  //     String img64 = base64Encode(bytes);

  //     var url = 'https://api.ocr.space/parse/image';
  //     var payload = {
  //       "base64Image": "data:image/jpg;base64,${img64.toString()}",
  //       "language": "eng"
  //     };
  //     var header = {"apikey": "K86070579388957"};

  //     var post =
  //         await http.post(Uri.parse(url), body: payload, headers: header);
  //     var result = jsonDecode(post.body);
  //     var rawText = result['ParsedResults'][0]['ParsedText'];
  //     String message = "";

  //     if (rawText!) {
  //       final url = Uri.parse(
  //           'https://getcode-ndef-api.vercel.app/process_raw_data?raw_data=${rawText}');

  //       try {
  //         final response = await http.get(url);
  //         if (response.statusCode == 200) {
  //           final data = json.decode(response.body);
  //           String message = data['data'];
  //           print("128"+message);
  //         } else {
  //           print( "Failed to load data");
  //         }
  //       } catch (e) {
  //         print( "Failed to load data: $e");
  //       }
  //     }

  //     // Navigate to a new screen with the captured image and extracted text.
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => CapturedScreen(
  //           imagePath: pickedFile.path,
  //           extractedText:"/*/*/*message",
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('OCR APP'),
      ),
      body: Stack(
        children: <Widget>[
          if (_cameraController.value.isInitialized)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraController.value.aspectRatio,
                child: CameraPreview(_cameraController),
              ),
            ),
          Positioned(
            bottom: 30,
            left: 0, // Centered horizontally
            right: 0, // Centered horizontally
            child: IconButton(
              onPressed: () {
                if (parsedtext.isEmpty) {
                  if (_cameraController.value.isTakingPicture) {
                    return;
                  }
                  captureImageAndPerformOCR();
                }
              },
              icon: Icon(Icons.camera_alt_sharp, size: 48),
              color: Colors.white,
            ),
          ),
          if (parsedtext.isNotEmpty)
            Container(
              width: 200,
              height: 200,
              margin: EdgeInsets.all(10.0),
              child: Image.file(File(filepath), fit: BoxFit.cover),
            ),
          if (parsedtext.isNotEmpty)
            Container(
              margin: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Text(
                    "The extracted text is",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    parsedtext,
                    style: GoogleFonts.montserrat(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CapturedScreen extends StatefulWidget {
  final String imagePath;
  final String address;
  final String phone;

  CapturedScreen({
    required this.imagePath,
    required this.address,
    required this.phone,
  });

  @override
  _CapturedScreenState createState() => _CapturedScreenState();
}

class _CapturedScreenState extends State<CapturedScreen> {
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial values for the input fields using the variables
    addressController.text = widget.address;
    phoneController.text = widget.phone;
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Captured Image and Text'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 400,
              height: 400,
              margin: EdgeInsets.all(10.0),
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
            Text(
              "The extracted text is",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Input field for address
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              style: GoogleFonts.montserrat(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Input field for phone
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              style: GoogleFonts.montserrat(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

