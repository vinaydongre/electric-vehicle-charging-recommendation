import 'package:evscrs/login_view.dart';
import 'package:evscrs/register_view.dart';
import 'package:evscrs/verify_email_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "package:flutter_map/flutter_map.dart";
import 'package:latlong2/latlong.dart';
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
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const Evrv();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const VerifyEmailView()),
                );
              }
            } else {
              return const LoginView();
            }
            return const Text('done');
          default:
            return const Text('Loading..');
        }
      },
    );
  }
}

enum MenuAction { logout }

class Evrv extends StatefulWidget {
  const Evrv({Key? key}) : super(key: key);

  @override
  State<Evrv> createState() => _EvrvState();
}

class _EvrvState extends State<Evrv> {
  final String apiKey = "QPJ5jAA5c7FCvLxltXvV5QXKmSdZGuFW";
  @override
  Widget build(BuildContext context) {
    final tomtomHQ = new LatLng(52.376372, 4.908066);
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVRV'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text('Logout'))
              ];
            },
          ),
        ],
      ),
      body: Center(
          child: Stack(
        children: <Widget>[
          FlutterMap(
            options: new MapOptions(center: tomtomHQ, zoom: 13.0),
            layers: [
              new TileLayerOptions(
                urlTemplate: "https://api.tomtom.com/map/1/tile/basic/main/"
                    "{z}/{x}/{y}.png?key={apiKey}",
                additionalOptions: {"apiKey": apiKey},
              )
            ],
          )
        ],
      )),
    );
  }
}
