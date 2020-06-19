import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googlepaystripe/utils/constants/constants.dart';
import 'package:googlepaystripe/utils/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isLoggedIn = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  SharedPreferences sharedPreferences;

  void initState() {
    super.initState();
    navigateToPaymentPage();
  }

  //Set Navigation From SplashScreen To PaymentScreen
  void navigateToPaymentPage() async {
    Future.delayed(const Duration(milliseconds: 3000), () {
      setState(() {
        NavigationUtils.push(context, routePayment);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlutterLogo(
            size: 100.0,
          ),
        ],
      )),
    );
  }
}
