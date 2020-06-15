import 'package:flutter/material.dart';
import 'package:googlepaystripe/home/google_payment.dart';
import 'package:googlepaystripe/splash/splash.dart';

void main() {
  runApp(GooglePayStripe());
}

class GooglePayStripe extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPay With Stripe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashPage(),
        '/gpay': (context) => GooglePaymentPage(),
      },
    );
  }
}
