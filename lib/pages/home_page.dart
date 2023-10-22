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

  @override
  void initState() {
    super.initState();
    // Call the registerData function when the widget initializes
    registerData().then((message) {
      print("Registration result: $message");
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: signUserOut,
          icon: Icon(Icons.logout_outlined),
        )
      ]),
      body: Center(
        child: Text(
          "Logged in AS: " + user.email! + " " + user.uid,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}