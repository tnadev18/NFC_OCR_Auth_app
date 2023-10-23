import 'package:auth/services/ocr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
                  child: Column(
                    children: [
                      Text("Address: ${userData['Address'] ?? 'N/A'}"),
                      Text("Company Name: ${userData['Company Name'] ?? 'N/A'}"),
                      // Add more text widgets to display other card details
                    ],
                  ),
                ),
            ],
          ),
        ),
    ));
  }
}
