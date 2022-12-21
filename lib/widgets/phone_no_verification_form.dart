import 'dart:convert';

import 'package:click_it/utlis/constants.dart';
import 'package:click_it/widgets/show_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as constants;

class PhoneNoVerificationForm extends StatefulWidget {
  final String title;
  final String buttonText;
  final String todo;
  const PhoneNoVerificationForm(
      {Key? key,
      this.title = "Phone Number Verification Form",
      this.buttonText = "Submit",
      this.todo = "Verify"})
      : super(key: key);

  @override
  State<PhoneNoVerificationForm> createState() =>
      _PhoneNoVerificationFormState();
}

class _PhoneNoVerificationFormState extends State<PhoneNoVerificationForm> {
  final TextEditingController _phonenocontroller = TextEditingController();
  final TextEditingController _otpcontroller = TextEditingController();
  var phoneno = 0;
  var otp = 0;
  var sendingOtp = false;
  var verifyingPhone = false;
  var logingIn = false;

  sendOtp() async {
    sendingOtp = true;
    setState(() {});
    var sendOtpUrl = Uri.parse('${constants.apiBaseUrl}/user/sendphoneotp');
    var res = await http.post(sendOtpUrl,
        body: json.encode({"phone": phoneno}),
        headers: {"Content-Type": "application/json"});
    var status = res.statusCode;
    var data = jsonDecode(res.body);
    sendingOtp = false;
    setState(() {});
    if (status == 400) {
      return showAlertDialog(context, "Error!", data['message']);
    }
    showAlertDialog(context, "Message!", data['message']);
  }

  verifyPhone() async {
    verifyingPhone = true;
    setState(() {});
    var verifyPhoneUrl = Uri.parse('${constants.apiBaseUrl}/user/verifyphone');
    var res = await http.post(verifyPhoneUrl,
        body: json.encode({"phone": phoneno, "phoneOtp": otp}),
        headers: {"Content-Type": "application/json"});
    var status = res.statusCode;
    var data = jsonDecode(res.body);
    verifyingPhone = false;
    setState(() {});
    if (status == 400) {
      return showAlertDialog(context, "Error!", data['message']);
    }
    Constants.prefs!.setInt("phone", phoneno);
    Constants.prefs!.setInt("phoneOtp", otp);
    showAlertDialog(context, "Message!", data['message']);
  }

  login() async {
    logingIn = true;
    setState(() {});
    var loginUrl = Uri.parse('${constants.apiBaseUrl}/user/loginphone');
    var res = await http.post(loginUrl,
        body: json.encode({
          "phone": phoneno,
          "phoneOtp": otp,
        }),
        headers: {"Content-Type": "application/json"});
    var status = res.statusCode;
    var data = jsonDecode(res.body);

    if (status != 400) {
      Constants.prefs!.setString("auth-token", data['token']);
      if (Constants.prefs!.getString("auth-token") != null) {
        var getProfileUrl =
            Uri.parse('${constants.apiBaseUrl}/profile/getprofile');
        var res = await http.get(getProfileUrl, headers: {
          "Content-Type": "application/json",
          "auth-token": Constants.prefs!.getString("auth-token")!
        });
        var status = res.statusCode;
        if (status != 200) {
          return showAlertDialog(context, "Error Status: $status",
              "Something went wrong maybe internet connection try restarting the app and checking your net connection");
        }
        var data = jsonDecode(res.body);
        if (data['profile']['name'] != null) {
          Constants.prefs!.setString("name", data['profile']['name']);
        }
        if (data['profile']['email'] != null) {
          Constants.prefs!.setString("email", data['profile']['email']);
        }
        if (data['profile']['phone'] != null) {
          Constants.prefs!.setInt("phone", data['profile']['phone']);
        }
        if (data['profile']['location']['coordinates'][1] != null) {
          Constants.prefs!.setDouble(
              "latitude", data['profile']['location']['coordinates'][1]);
        }
        if (data['profile']['location']['coordinates'][0] != null) {
          Constants.prefs!.setDouble(
              "longitude", data['profile']['location']['coordinates'][0]);
        }
      } else {
        return showAlertDialog(context, "Access Denied", "Auth token missing");
      }
      logingIn = false;
      setState(() {});
      Navigator.pushNamedAndRemoveUntil(context, "/agreement", (r) => false);
    }
    if (status == 400) {
      logingIn = false;
      setState(() {});
      return showAlertDialog(context, "Error!", data['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        Text(widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20.0),
        Row(children: [
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                child: Image.asset(
                  "assets/images/indian_flag.png",
                  fit: BoxFit.contain,
                ),
              )),
          Expanded(
            flex: 8,
            child: TextFormField(
                controller: _phonenocontroller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    hintText: "Enter Phone No",
                    labelText: "Phone No",
                    border: OutlineInputBorder())),
          ),
        ]),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 7,
              child: TextFormField(
                  controller: _otpcontroller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Enter Otp',
                      labelText: 'Otp',
                      border: OutlineInputBorder())),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: !sendingOtp
                  ? MaterialButton(
                      child: const Text('Send Otp'),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey, width: 2)),
                      onPressed: () {
                        if (_phonenocontroller.text == '' ||
                            int.tryParse(_phonenocontroller.text) == null) {
                          showAlertDialog(context, "Enter Phone No!",
                              "Enter a phone no to send otp(only number)");
                          return (null);
                        }
                        phoneno = int.parse(_phonenocontroller.text);
                        setState(() {});
                        sendOtp();
                      })
                  : const CircularProgressIndicator(),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        !verifyingPhone && !logingIn
            ? ButtonTheme(
                minWidth: 200,
                child: MaterialButton(
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(
                          color: Color(0xFF3cb0d4), fontSize: 18),
                    ),
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey, width: 2)),
                    onPressed: () {
                      if (_phonenocontroller.text == '' ||
                          int.tryParse(_phonenocontroller.text) == null) {
                        showAlertDialog(context, "Enter Phone No!",
                            "Enter a phone no to send otp(only number)");
                        return (null);
                      }
                      if (_otpcontroller.text == '' ||
                          int.tryParse(_otpcontroller.text) == null) {
                        showAlertDialog(
                            context, "Enter Otp!", "Enter a Otp(only number)");
                        return (null);
                      }
                      phoneno = int.parse(_phonenocontroller.text);
                      otp = int.parse(_otpcontroller.text);
                      setState(() {});
                      if (widget.todo == "Login") {
                        login();
                      } else {
                        verifyPhone();
                      }
                    }),
              )
            : const CircularProgressIndicator()
      ],
    ));
  }
}
