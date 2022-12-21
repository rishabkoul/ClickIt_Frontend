import 'package:click_it/widgets/email_verification_form.dart';
import 'package:click_it/widgets/phone_no_verification_form.dart';
import 'package:flutter/material.dart';

import '../widgets/drawer.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Log-In", style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF7291bf),
            centerTitle: true,
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.phone,
                    color: Colors.white,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            )),
        drawer: const DrawerWidget(drawerHeaderColor: Color(0xFF7291bf)),
        body: TabBarView(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: const [
                  SizedBox(
                    height: 140,
                  ),
                  Card(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: PhoneNoVerificationForm(
                        title: "Login using Phone",
                        buttonText: "Login",
                        todo: "Login"),
                  )),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: const [
                  SizedBox(
                    height: 140,
                  ),
                  Card(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: EmailVerificationForm(
                        title: "Login using Email",
                        buttonText: "Login",
                        todo: "Login"),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
