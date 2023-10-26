import 'dart:ui';
import 'package:auth/pages/userdetails.dart';
import 'package:auth/services/ocr.dart';
import 'package:auth/services/qr_generator.dart';
import 'package:auth/services/scan_qr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'package:nfc_manager/nfc_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic> userData = {};
  List<dynamic> recivedData = [];
  late Timer dataRefreshTimer;

  ValueNotifier<dynamic> result = ValueNotifier(null);
  String ndefData = 'NDEF data will be displayed here';

  // dynamic resultValue = result.value;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    dataRefreshTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      fetchUserData(); // Fetch data periodically
    });
    registerData().then((message) {
      print("Registration result: $message");
    });
  }

  Future<void> _refreshData() async {
    // Call fetchUserData when refreshing
    await fetchUserData();
  }

  Future<String> registerData() async {
    final url = Uri.parse(
        'https://getcode-ndef-api.vercel.app/register_user?email=${user.email}&name=${user.displayName}&uid=${user.uid}&pic_url=${user.photoURL}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String message = data['msg'];
        return message;
      } else {
        return "Failed to load data";
      }
    } catch (e) {
      return "Failed to load data: $e";
    }
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse(
        'https://getcode-ndef-api.vercel.app/get_user_data?uid=${user.uid}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final myCard = data['my_card'];
        List<dynamic> recivedCards = data['shared_cards'];
        if (myCard != null || recivedCards != null) {
          setState(() {
            userData = myCard;
            recivedData = recivedCards;
          });
        }
      } else {
        print("Failed to load user data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if the current route is the home page and then fetch data
    if (ModalRoute.of(context)?.settings.name == '/home_page') {
      fetchUserData();
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void addUserCard() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return AddUserCard();
      }),
    );
  }

  Future<String> fetchData(String data) async {
    final url =
        Uri.parse('https://getcode-ndef-api.vercel.app/convert?data=${data}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String message = data['textData'];
        return message;
      } else {
        return "Failed to load data";
      }
    } catch (e) {
      return "Failed to load data: $e";
    }
  }

  void _tagRead() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Reading NDEF Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Display a loading indicator
              SizedBox(height: 16),
              Text('Please hold the NFC card near the device.'),
            ],
          ),
        );
      },
    );

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      Ndef? ndef = Ndef.from(tag);
      if (ndef != null) {
        try {
          NdefMessage message = await ndef.read();
          setState(() {
            ndefData = 'NDEF Data: $message';
          });

          String? ndefData1 = await fetchData(tag.data.toString());
          result.value = ndefData1;
          // print("************************"+result.value);
          if (ndefData1 != null &&
              ndefData1.contains("getcode-eight.vercel.app/")) {
            // Remove the prefix
            ndefData1 =
                ndefData1.substring("getcode-eight.vercel.app/".length + 1);
            print("************************" + ndefData1);
          } else {
            Fluttertoast.showToast(
              msg: "Invalid Card",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
          addCard(ndefData1);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card Read Successfully.'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          setState(() {
            ndefData = 'Error reading NDEF data: $e';
          });
        } finally {
          Navigator.of(context).pop(); // Close the reading dialog
        }
      } else {
        setState(() {
          ndefData = 'NDEF not supported on this tag';
        });
        Navigator.of(context).pop(); // Close the reading dialog
      }
      NfcManager.instance.stopSession();
    });
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

  void _shareLink() {
    Share.share('https://getcode-eight.vercel.app/${user.uid}');
  }

  Widget _buildUserData() {
    return Container(
      height: 230,
      width: 1000,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 2.0, color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(4.0, 4.0),
            blurRadius: 15.0,
            spreadRadius: 1.0,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4.0, -4.0),
            blurRadius: 15.0,
            spreadRadius: 1.0,
          ),
        ],
        image: const DecorationImage(
          image: AssetImage(
              'lib/images/backgroung.jpg'), // Replace with the path to your image asset
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Stack(
          children: [
            if (userData.isEmpty)
              Container(
                margin: EdgeInsets.symmetric(vertical: 70,horizontal: 130.0),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: addUserCard,
                      icon: const Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                    const Text('Scan your card'),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ClipOval(
                          child: Image.network(
                            '${user.photoURL}',
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'lib/images/default_avatar.png',
                                height: 40,
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    " ${userData['Name'] ?? 'N/A'}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: userData['Name'] != null
                                          ? userData['Name'].length > 12
                                              ? 24
                                              : 32
                                          : 32,
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    " ${userData['Company Name'] ?? 'N/A'}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: userData['Company Name'] != null
                                          ? userData['Company Name'].length > 30
                                              ? 14
                                              : 18
                                          : 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50, left: 10),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.call,
                              size: 20,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                " ${userData['Phone'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: userData['Phone'] != null
                                      ? userData['Phone'].length > 12
                                          ? 17
                                          : 17
                                      : 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                " ${userData['Email'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: userData['Email'] != null
                                      ? userData['Email'].length > 12
                                          ? 17
                                          : 17
                                      : 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  " ${userData['Address'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: userData['Address'] != null
                                        ? userData['Address'].length > 30
                                            ? 17
                                            : 17
                                        : 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 35),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 25,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      25), // Adjust the radius to make the corners rounder
                ),
                child: ElevatedButton(
                  onPressed: addUserCard,
                  child: Text(
                    'Edit',
                    style: TextStyle(fontSize: 10),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Colors.orange), // Set the background color to orange
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _recivedCardsList() {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: ListView.builder(
      itemCount: recivedData.length,
      itemBuilder: (context, index) {
        final cardData = recivedData[index];
        return GestureDetector(
          onTap: () {
            // Navigate to a new page for the selected user here
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetails(data: cardData),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(cardData['pic_url'] ?? '[]'),
              ),
              title: Text(cardData['Name'] ?? 'N/A'),
              subtitle: Text(cardData['Company Name'] ?? '[]'),
            ),
          ),
        );
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GET CODE'),
        backgroundColor: Colors.orange[400], // #FFA3FD
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout_outlined),
          )
        ],
      ),
      backgroundColor: Colors.yellow[100], // #191825
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUserData(), // Display user data
              const SizedBox(
                  height:
                      20), // Add spacing between user data and received cards
              const Text(
                'Received Cards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: _recivedCardsList(), // Display the received cards list
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              onPressed: () {
                // Show the modal bottom sheet with two buttons
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.qr_code),
                          title: Text('QR'),
                          onTap: () {
                            // Handle Button 1 logic
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return QRGenerate();
                              }),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.link),
                          title: Text('Link'),
                          onTap: () {
                            _shareLink();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              tooltip: 'Send',
              child: Icon(Icons.send),
              elevation: 6,
              highlightElevation: 12,
              disabledElevation: 0,
              backgroundColor: Colors.orange[400],
            ),
          ),
          SizedBox(width: 100),
          Container(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              onPressed: () {
                // Show the modal bottom sheet with two buttons
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.connect_without_contact),
                          title: Text('NFC Tag'),
                          onTap: () {
                            // Handle Button 1 logic
                            _tagRead();
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.qr_code_scanner),
                          title: Text('QR Scanner'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return QR();
                              }),
                            );
                            // Handle Button 2 logic
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              tooltip: 'Receive',
              child: Icon(Icons.download),
              elevation: 6,
              highlightElevation: 12,
              disabledElevation: 0,
              backgroundColor: Colors.orange[400],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(height: 50),
    );
  }
}
