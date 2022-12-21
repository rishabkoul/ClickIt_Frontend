import 'package:click_it/pages/agreement_page.dart';
import 'package:click_it/pages/bookings_page.dart';
import 'package:click_it/pages/editprofile_page.dart';
import 'package:click_it/pages/login_page.dart';
import 'package:click_it/pages/permissions_page.dart';
import 'package:click_it/pages/photgraphers_page.dart';
import 'package:click_it/pages/setlocation_page.dart';
import 'package:click_it/pages/signup_page.dart';
import 'package:click_it/utlis/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart' as constants;
import 'package:http/http.dart' as http;

hasAccess() async {
  if (Constants.prefs!.getString("auth-token") != null) {
    var hasAccessUrl =
        Uri.parse('${constants.apiBaseUrl}/nongrouproutes/hasaccess');
    var res = await http.get(hasAccessUrl, headers: {
      "Content-Type": "application/json",
      "auth-token": Constants.prefs!.getString("auth-token")!
    });
    var status = res.statusCode;
    return status;
  } else {
    return (400);
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Constants.prefs = await SharedPreferences.getInstance();

  var access = await hasAccess();

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ClickIt",
      home: access != 400 ? const AgreementPage() : const SignUpPage(),
      theme: ThemeData(primarySwatch: Colors.grey),
      routes: {
        "/signup": (context) => const SignUpPage(),
        "/agreement": (context) => const AgreementPage(),
        "/permissions": ((context) => const PermissionsPage()),
        "/setlocation": ((context) => const SetLocationPage()),
        "/photographers": (context) => const PhotographersPage(),
        "/login": ((context) => const LoginPage()),
        "/editprofile": ((context) => const EditProfilePage()),
        "/bookings": ((context) => const BookingsPage())
      }));
}
