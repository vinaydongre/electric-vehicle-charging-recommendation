import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController emailControl;
  late final TextEditingController passControl;

  @override
  void initState() {
    emailControl = TextEditingController();
    passControl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailControl.dispose();
    passControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailControl,
          enableSuggestions: false,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(hintText: 'Email: abc@example.com'),
        ),
        TextField(
          controller: passControl,
          obscureText: true,
          enableSuggestions: false,
          decoration: const InputDecoration(hintText: 'Password'),
        ),
        TextButton(
          onPressed: () async {
            final email = emailControl.text;
            final password = passControl.text;
            try {
              final userCredentail = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: email, password: password);
              print(userCredentail);
            } on FirebaseAuthException catch (e) {
              print(e.code);
            }
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}
