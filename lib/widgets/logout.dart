import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout extends StatelessWidget {
  const Logout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.clear();
        Navigator.pushNamedAndRemoveUntil(context, "/signup", (r) => false);
      },
      child: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
    );
  }
}
