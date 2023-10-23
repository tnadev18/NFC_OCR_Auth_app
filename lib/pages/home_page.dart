import 'dart:ui';

import 'package:auth/services/ocr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic> userData = {};
  late Timer dataRefreshTimer;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    dataRefreshTimer = Timer.periodic(Duration(seconds: 1000), (Timer timer) {
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
        if (myCard != null) {
          setState(() {
            userData = myCard;
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
            child: Stack(
              children: <Widget>[
                if (userData.isEmpty)
                  Container(
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                  ),
                if (userData.isNotEmpty)
                  Container(
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
                      // Text("Address: ${userData['Company Name'] ?? 'N/A'}"),

                      child: Container(
                        margin: EdgeInsets.only(top: 120, left: 10),
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
                                Text(
                                  " ${userData['Phone'] ?? 'N/A'}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3,),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                ),
                                Text(
                                  " ${userData['Email'] ?? 'N/A'}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3,),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                ),
                                Flexible(child:Text(
                                  " ${userData['Address'] ?? 'N/A'}",
                                  softWrap: true,
                                  overflow: TextOverflow
                                      .ellipsis, // Specify how to handle overflow
                                  maxLines: 2,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ), )
                                
                              ],
                            ),
                          ],
                          // Text("Address: ${userData['Company Name'] ?? 'N/A'}"),
                          // Text("Address: ${userData['Name'] ?? 'N/A'}"),
                        ),
                      )),
                // Add more text widgets to display other card details
              ],
            ),
          ),
        )
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(builder: (context) {
        //         return; // Replace with the actual name of your OCR page
        //       }),
        //     );
        //   },
        //   child: Icon(Icons.add),
        //   backgroundColor: Colors.grey[600], // Change the FAB's background color
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation
        //     .centerFloat, // Position the FAB at the bottom middle
        );
  }
}
