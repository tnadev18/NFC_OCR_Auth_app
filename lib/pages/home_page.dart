import 'dart:ui';

import 'package:auth/services/ocr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:auth/services/nfc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic> userData = {};
  List<dynamic> recivedData = [];
  late Timer dataRefreshTimer;

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

  Widget _buildUserData() {
    return Container(
      height: 230,
      width: 1000,
      decoration: BoxDecoration(
        color: Colors.grey[350],
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
      ),
      child: Center(
        child: Column(
          children: [
            if (userData.isEmpty)
              Container(
                margin: EdgeInsets.symmetric(vertical: 70),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0), // Add margin between containers
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white, // Background color for each user container
            borderRadius: BorderRadius.circular(15),
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
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(cardData['pic_url']),
            ),
            title: Text(cardData['Name']),
            subtitle: Text(cardData['Company Name']),
            // Add more details here if needed
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
        backgroundColor: Colors.grey[600],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout_outlined),
          )
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildUserData(), // Display user data
            const SizedBox(height: 20), // Add spacing between user data and received cards
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return Nfc(); // Replace with the actual name of your NFC page
            }),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.grey[600], // Change the FAB's background color
      ),
    );
  }
}
