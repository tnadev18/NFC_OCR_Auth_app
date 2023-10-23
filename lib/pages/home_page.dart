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

  // Sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void addUserCard() {
    print('hi');
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

  // @override
  // void initState() {
  //   // Call the registerData function when the widget initializes
  //   super.initState();
  //   registerData().then((message) {
  //     print("Registration result: $message");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey[600], actions: [
        IconButton(
          onPressed: signUserOut,
          icon: Icon(Icons.logout_outlined),
        )
      ]),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Container(
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
                  )
                ]),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    // Replace Icon with IconButton
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add the action you want to perform when the FAB is pressed
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.grey[600], // Change the FAB's background color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // Position the FAB at the bottom middle
    );
  }
}
