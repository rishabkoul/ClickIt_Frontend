import 'package:click_it/widgets/show_alert.dart';
import 'package:flutter/material.dart';
import '../constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:click_it/utlis/constants.dart';
import 'dart:convert';
import 'package:flutter/scheduler.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({Key? key}) : super(key: key);

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool agreed = false;
  bool checkingAcceptance = false;
  bool acceptingagreement = false;

  hasacceptedAgreement() async {
    if (Constants.prefs!.getString("auth-token") != null) {
      var acceptedAgreenentUrl =
          Uri.parse('${constants.apiBaseUrl}/agreement/acceptedagreement');
      var res = await http.get(acceptedAgreenentUrl, headers: {
        "Content-Type": "application/json",
        "auth-token": Constants.prefs!.getString("auth-token")!
      });
      var status = res.statusCode;
      return status;
    } else {
      return (400);
    }
  }

  @override
  void initState() {
    super.initState();
    hasAcceptedAgreementLocalVariable();
    if (Constants.prefs!.getBool("agreement-accepted") != true) {
      getHasAcceptedAgreement();
    }
  }

  hasAcceptedAgreementLocalVariable() {
    if (Constants.prefs!.getBool("agreement-accepted") == true) {
      SchedulerBinding.instance!.addPostFrameCallback((_) async {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/permissions', (Route<dynamic> route) => false);
      });
    }
  }

  getHasAcceptedAgreement() async {
    checkingAcceptance = true;
    setState(() {});
    var hasAcceptedAgreement = await hasacceptedAgreement();
    checkingAcceptance = false;
    setState(() {});
    if (hasAcceptedAgreement != 400) {
      Constants.prefs!.setBool("agreement-accepted", true);
      Navigator.pushNamedAndRemoveUntil(context, "/permissions", (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: checkingAcceptance
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 200),
                  const Text("Accept ClikIt's Terms & Review Privacy notice.",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text(
                      "By Selecting 'I Agree' Below, I have reviewed and",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Text("agree to the terms of use and acknowledge",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Text("the privacy notice.",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text("I am atleast 18 years of age",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: agreed,
                        onChanged: (bool? value) {
                          setState(() {
                            agreed = value!;
                          });
                        },
                      ),
                      const Text("I agree",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 200),
                  acceptingagreement
                      ? const CircularProgressIndicator()
                      : ButtonTheme(
                          minWidth: 250,
                          child: MaterialButton(
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                    color: Color(0xFF3cb0d4), fontSize: 18),
                              ),
                              shape: const RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: Colors.grey, width: 2)),
                              onPressed: () async {
                                if (agreed == true) {
                                  if (Constants.prefs!
                                          .getString("auth-token") !=
                                      null) {
                                    acceptingagreement = true;
                                    setState(() {});
                                    var acceptAgreementUrl = Uri.parse(
                                        '${constants.apiBaseUrl}/agreement/accept');
                                    var res = await http
                                        .post(acceptAgreementUrl, headers: {
                                      "Content-Type": "application/json",
                                      "auth-token": Constants.prefs!
                                          .getString("auth-token")!
                                    });
                                    var status = res.statusCode;
                                    var data = jsonDecode(res.body);
                                    acceptingagreement = false;
                                    setState(() {});
                                    if (status == 400) {
                                      showAlertDialog(
                                          context, "Error", data["message"]);
                                    } else {
                                      Constants.prefs!
                                          .setBool("agreement-accepted", true);
                                      Navigator.pushNamed(
                                          context, "/permissions");
                                    }
                                  } else {
                                    showAlertDialog(context, "Error!",
                                        "Auth Token not present");
                                  }
                                } else {
                                  showAlertDialog(
                                      context, "Error!", "Agree to continue!");
                                }
                              }),
                        )
                ],
              ),
      )),
    );
  }
}
