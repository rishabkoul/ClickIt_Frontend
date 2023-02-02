import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/show_alert.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({Key? key}) : super(key: key);

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  @override
  void initState() {
    super.initState();
    checkPermissionStatus();
  }

  checkPermissionStatus() async {
    var locationStatus = await Permission.location.status;
    var phoneStatus = await Permission.phone.status;
    if (!locationStatus.isGranted) {
      return (null);
    }
    if (!phoneStatus.isGranted) {
      return (null);
    }

    Navigator.pushNamedAndRemoveUntil(context, "/photographers", (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text('Congratulations..',
                    style: GoogleFonts.dancingScript(
                        textStyle: Theme.of(context).textTheme.headlineMedium,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFd4a177))),
                const SizedBox(
                  height: 100,
                ),
                Text('Welcome To',
                    style: GoogleFonts.dancingScript(
                        textStyle: Theme.of(context).textTheme.headlineMedium,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFd4a177))),
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  "assets/images/clickit.png",
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                    color: const Color(0xFF3f47cd),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text(
                            "Have your hassle-free Booking experience by giving us the following permissions",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          const SizedBox(height: 35),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                Text("GPS",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                                Text("PHONE",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                              ]),
                          const SizedBox(height: 70),
                        ],
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),
                ButtonTheme(
                  minWidth: 250,
                  child: MaterialButton(
                      child: const Text(
                        'Next',
                        style:
                            TextStyle(color: Color(0xFF3cb0d4), fontSize: 18),
                      ),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey, width: 2)),
                      onPressed: () async {
                        var locationStatus = await Permission.location.status;
                        var phoneStatus = await Permission.phone.status;
                        if (!locationStatus.isGranted) {
                          await Permission.location.request();
                        }
                        if (!phoneStatus.isGranted) {
                          await Permission.phone.request();
                        }
                        if (await Permission.location.isGranted &&
                            await Permission.phone.isGranted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/photographers", (r) => false);
                        } else {
                          showAlertDialog(context, "Required all Permissions",
                              "Provide all Permisssions to Continue");
                        }
                      }),
                )
              ],
            ),
          ),
        )),
      ),
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, "/agreement", (r) => false);
        return false;
      },
    );
  }
}
