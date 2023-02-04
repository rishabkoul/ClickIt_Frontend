import 'package:flutter/material.dart';
import 'package:click_it/utlis/constants.dart';
import '../constants.dart' as constants;

class DrawerWidget extends StatelessWidget {
  const DrawerWidget(
      {Key? key, this.drawerHeaderColor = const Color(0xFF7291bf)})
      : super(key: key);

  final Color drawerHeaderColor;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          if (Constants.prefs!.getString("name") != "" &&
              Constants.prefs!.getString("name") != null)
            DrawerHeader(
              decoration: BoxDecoration(
                color: drawerHeaderColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 11,
                        backgroundImage: const NetworkImage(
                            "${constants.imageProxyUrl}https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZSUyMHBpY3R1cmUlMjBtYW58ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60"),
                      ),
                      MaterialButton(
                        child: Row(
                          children: const [
                            Icon(
                              Icons.help,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Help", style: TextStyle(color: Colors.white))
                          ],
                        ),
                        onPressed: () {},
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    Constants.prefs!.getString("name")!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(Constants.prefs!.getString("email")!,
                      style: const TextStyle(color: Colors.white)),
                  Text(Constants.prefs!.getInt("phone")!.toString(),
                      style: const TextStyle(color: Colors.white))
                ],
              ),
            ),
          if (Constants.prefs!.getString("name") == "" ||
              Constants.prefs!.getString("name") == null)
            const SizedBox(
              height: 40,
            ),
          if (Constants.prefs!.getString("auth-token") != "" &&
              Constants.prefs!.getString("auth-token") != null)
            ListTile(
              leading: const Icon(
                Icons.edit,
              ),
              title: const Text('Edit Profile Page'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/editprofile", (r) => false);
              },
            ),
          if (Constants.prefs!.getString("auth-token") != "" &&
              Constants.prefs!.getString("auth-token") != null)
            ListTile(
              leading: const Icon(
                Icons.location_on,
              ),
              title: const Text('Set Location Page'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/setlocation", (r) => false);
              },
            ),
          if (Constants.prefs!.getString("name") != "" &&
              Constants.prefs!.getString("name") != null &&
              Constants.prefs!.getDouble("latitude") != null &&
              Constants.prefs!.getDouble("longitude") != null)
            ListTile(
              leading: const Icon(
                Icons.camera,
              ),
              title: const Text('Photographers Page'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/photographers", (r) => false);
              },
            ),
          if (Constants.prefs!.getString("name") != "" &&
              Constants.prefs!.getString("name") != null &&
              Constants.prefs!.getDouble("latitude") != null &&
              Constants.prefs!.getDouble("longitude") != null)
            ListTile(
              leading: const Icon(
                Icons.book,
              ),
              title: const Text('Your Bookings'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/bookings", (r) => false);
              },
            ),
          if (Constants.prefs!.getString("auth-token") == "" ||
              Constants.prefs!.getString("auth-token") == null)
            ListTile(
              leading: const Icon(
                Icons.login,
              ),
              title: const Text('Login'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (r) => false);
              },
            ),
          if (Constants.prefs!.getString("auth-token") == "" ||
              Constants.prefs!.getString("auth-token") == null)
            ListTile(
              leading: const Icon(
                Icons.app_registration_rounded,
              ),
              title: const Text('Signup'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/signup", (r) => false);
              },
            ),
        ],
      ),
    );
  }
}
