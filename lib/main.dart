import 'package:flutter/material.dart';

import 'utils/constants/constants.dart';
import 'utils/localization/localization.dart';
import 'utils/navigation.dart';

void main() {
  runApp(GooglePayStripe());
}

class GooglePayStripe extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Gpay with Stripe",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: routeSplash,
      onGenerateRoute: NavigationUtils.generateRoute,
      localizationsDelegates: [
        const MyLocalizationsDelegate(),
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
      ],
    );
  }
}
