import 'package:evscrs/login_view.dart';
import 'package:evscrs/register_view.dart';
import 'package:evscrs/routing.dart';
import 'package:evscrs/verify_email_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:flutter_map/flutter_map.dart";
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'firebase_options.dart';
import "package:http/http.dart" as http;
import "dart:convert" as convert;
import "package:geolocator/geolocator.dart";

LatLng tomtomHQ = LatLng(30.89, 78.58);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    themeMode: ThemeMode.dark,
    title: 'evrvs',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      '/login/': (context) => const LoginView(),
      '/register/': (context) => const RegisterView(),
      '/verify/': (context) => const VerifyEmailView(),
      '/evrv/': (context) => const Evrv(),
      '/route/': (context) => const MapSample(),
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
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

enum MenuAction { logout, route }

class Evrv extends StatefulWidget {
  const Evrv({Key? key}) : super(key: key);

  @override
  State<Evrv> createState() => _EvrvState();
}

class _EvrvState extends State<Evrv> {
  final String apiKey = "QPJ5jAA5c7FCvLxltXvV5QXKmSdZGuFW";
  final List<Marker> markers = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    _getUserLocation() async {
      Position position =
          await GeolocatorPlatform.instance.getCurrentPosition();
      setState(() {
        tomtomHQ = LatLng(position.latitude, position.longitude);
        return;
      });
    }

    _getUserLocation();
    final initialMarker = new Marker(
      width: 80.0,
      height: 80.0,
      point: tomtomHQ,
      builder: (BuildContext context) => const Icon(
        Icons.location_on,
        size: 80.0,
        color: Colors.red,
      ),
    );
    markers.add(initialMarker);

    getAdresses(value, lat, lon) async {
      final Map<String, String> queryParameters = {'key': '$apiKey'};
      queryParameters['lat'] = '$lat';
      queryParameters['lon'] = '$lon';
      var response = await http.get(Uri.https(
          'api.tomtom.com', '/search/2/search/$value.json', queryParameters));
      var jsonData = convert.jsonDecode(response.body);
      print('$jsonData');
      var results = jsonData['results'];
      for (var element in results) {
        var position = element['position'];
        var marker = new Marker(
          //builder: (BuildContext context) => const Icon(
          //      Icons.location_on,
          //      size: 80.0,
          //      color: Colors.blue,
          //    ),
          point: new LatLng(position['lat'], position['lon']),
          width: 50.0,
          height: 50.0,
          builder: (BuildContext context) => ElevatedButton.icon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Location Update'),
                        content: Text('latitude' +
                            lat.toString() +
                            'longitude' +
                            lon.toString() +
                            results[1]['address']['freeformAddress']),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ));
            },
            icon: const Icon(
              Icons.location_on,
              size: 10.0,
              color: Colors.blue,
            ),
            label: const Text(''),
          ),
        );
        markers.add(marker);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EVRV'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (_) => false);
                  }
                  break;
                case MenuAction.route:
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/route/', (_) => false);
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                    value: MenuAction.route, child: Text('Route')),
                const PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text('Logout')),
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
              ),
              new MarkerLayerOptions(
                markers: markers,
              ),
              new MarkerLayerOptions(
                markers: [
                  new Marker(
                    width: 80.0,
                    height: 80.0,
                    point: tomtomHQ,
                    builder: (BuildContext context) => const Icon(
                        Icons.location_on,
                        size: 60.0,
                        color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.topRight,
              child: TextField(
                onSubmitted: (value) {
                  print(value);
                  getAdresses(value, tomtomHQ.latitude, tomtomHQ.longitude);
                },
              ))
        ],
      )),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('LogOut'),
          content: const Text('Are you sure you wanna LogOut!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('LogOut'),
            )
          ],
        );
      }).then((value) => value ?? false);
}
