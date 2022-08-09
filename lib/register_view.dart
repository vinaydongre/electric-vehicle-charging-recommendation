import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 400,
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: 0,
                      height: 400,
                      width: width,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/image2.jpeg'),
                                fit: BoxFit.fill,
                                colorFilter: ColorFilter.mode(
                                    Colors.black45, BlendMode.darken))),
                      )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Register here!",
                    style: TextStyle(
                        color: Color.fromARGB(255, 46, 88, 226),
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(196, 135, 198, .3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ]),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: TextField(
                            controller: emailControl,
                            enableSuggestions: false,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email: abc@example.com",
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: TextField(
                            controller: passControl,
                            obscureText: true,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 60),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Color.fromRGBO(49, 39, 79, 1),
                    ),
                    child: Center(
                        child: TextButton(
                      onPressed: () async {
                        final email = emailControl.text;
                        final password = passControl.text;
                        try {
                          final userCredentail = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email, password: password);
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/menuevrv/', (route) => false);
                        } on FirebaseAuthException catch (e) {
                          print("Something bad happened");
                          print(e.runtimeType);
                          print(e.code);
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login/', (route) => false);
                          },
                          child: Text(
                            "Click here to go back",
                            style: TextStyle(
                                color: Color.fromRGBO(49, 39, 79, .6)),
                          ))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
