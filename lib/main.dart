import 'package:evscrs/login_view.dart';
import 'package:evscrs/register_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'evrvs',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      '/login/': (context) => const LoginView(),
      '/register/': (context) => const RegisterView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        /* final user = FirebaseAuth.instance.currentUser;
          if (user?.emailVerified ?? false) {
            print("Hello user");
          } else {
            return const VerifyEmailView();
            print("You need to verify the email first");
          }
          return const Text('done'); */
        return const LoginView();
      },
    );
  }
}
