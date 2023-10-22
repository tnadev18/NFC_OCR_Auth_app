import 'package:auth/pages/login_page.dart';
import 'package:auth/pages/register_pages.dart';
import 'package:flutter/material.dart';

class LoinOrRegisterPage extends StatefulWidget {
  const LoinOrRegisterPage({super.key});

  @override
  State<LoinOrRegisterPage> createState() => _LoinOrRegisterPageState();
}

class _LoinOrRegisterPageState extends State<LoinOrRegisterPage> {
  //initially show login page
  bool showLoginPage = true;

  //toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages ,
      );
    }
  }
}
