import 'package:auth/components/my_button.dart';
import 'package:auth/components/my_textfield.dart';
import 'package:auth/components/square_tile.dart';
import 'package:auth/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controller
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in
  void signUserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try signing in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
      //pop the circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop the circle
      Navigator.pop(context);
      //show error message
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.orange[300],
          title: Center(
              child: Text(
            message,
            style: const TextStyle(color: Colors.black),
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 50),

                //welcome Back, you'he been missed!
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                //username
                MyTextField(
                  controller: usernameController,
                  hintText: 'username',
                  obscureText: false,
                ),

                const SizedBox(
                  height: 10,
                ),

                //password
                MyTextField(
                  controller: passwordController,
                  hintText: 'password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // forget password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot passord?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                //signin Button
                MyButton(
                  text:"Sign in",
                  onTap: signUserIn),

                const SizedBox(height: 40),

                //or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1.0,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or Continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1.0,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                //goole and apple
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google
                    SquareTile(
                        onTap: () => AuthService().signInWithGoogle(),
                        imagePath: 'lib/images/Google__G__Logo.svg.webp'),

                    SizedBox(width: 20),

                    //apple
                    SquareTile(
                      onTap: (){},
                      imagePath: 'lib/images/apple-logo.png')
                  ],
                ),

                const SizedBox(height: 50),

                //if you r not a member register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Register now',
                        style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
        ));
  }
}
