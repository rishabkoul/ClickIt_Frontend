import 'package:click_it/widgets/email_verification_form.dart';
import 'package:click_it/widgets/phone_no_verification_form.dart';
import 'package:click_it/widgets/show_alert.dart';
import 'package:flutter/material.dart';
import 'package:click_it/utlis/constants.dart';
import '../constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/drawer.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var signingUp = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sign-Up", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF7291bf),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
        ),
        drawer: const DrawerWidget(drawerHeaderColor: Color(0xFF7291bf)),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const PhoneNoVerificationForm(),
              const SizedBox(
                height: 10,
              ),
              const EmailVerificationForm(),
              const SizedBox(
                height: 10,
              ),
              const Text("Already have a account?",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              ButtonTheme(
                minWidth: 200,
                child: MaterialButton(
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Color(0xFF3cb0d4), fontSize: 18),
                    ),
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey, width: 2)),
                    onPressed: () {
                      Navigator.pushNamed(context, "/login");
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                  "By Proceeding. You consent to get call, what's App & Messages.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 10,
              ),
              !signingUp
                  ? ButtonTheme(
                      minWidth: 250,
                      child: MaterialButton(
                          child: const Text(
                            'Signup',
                            style: TextStyle(
                                color: Color(0xFF3cb0d4), fontSize: 18),
                          ),
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey, width: 2)),
                          onPressed: () async {
                            signingUp = true;
                            setState(() {});
                            var signUpUrl = Uri.parse(
                                '${constants.apiBaseUrl}/user/signup');
                            var res = await http.post(signUpUrl,
                                body: json.encode({
                                  "phone": Constants.prefs!.getInt("phone"),
                                  "phoneOtp":
                                      Constants.prefs!.getInt("phoneOtp"),
                                  "email": Constants.prefs!.getString("email"),
                                  "emailOtp":
                                      Constants.prefs!.getInt("emailOtp")
                                }),
                                headers: {"Content-Type": "application/json"});
                            var status = res.statusCode;
                            var data = jsonDecode(res.body);
                            signingUp = false;
                            setState(() {
                              if (status != 400) {
                                Constants.prefs!
                                    .setString("auth-token", data['token']);
                                Navigator.pushNamedAndRemoveUntil(
                                    context, "/agreement", (r) => false);
                              }
                            });
                            if (status == 400) {
                              return showAlertDialog(
                                  context, "Error!", data['message']);
                            }
                          }),
                    )
                  : const CircularProgressIndicator(),
            ],
          ),
        )),
      ),
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, "/signup", (r) => false);
        return false;
      },
    );
  }
}
