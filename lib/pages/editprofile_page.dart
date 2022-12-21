import 'package:click_it/widgets/edit_profile_form.dart';
import 'package:flutter/material.dart';

import '../widgets/drawer.dart';
import '../widgets/logout.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              const Text("Edit Profile", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF00a3e8),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          actions: const [Logout()],
        ),
        drawer: const DrawerWidget(drawerHeaderColor: Color(0xFF00a3e8)),
        body: const SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(8.0),
          child: EditProfileForm(),
        )));
  }
}
