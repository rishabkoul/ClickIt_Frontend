import 'dart:convert';
import 'dart:io';

import 'package:click_it/widgets/show_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:click_it/utlis/constants.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../constants.dart' as constants;
import 'package:http/http.dart' as http;
import '../utlis/photographertype.dart';

List<PhotographerType> _photographertypes =
    constants.photographerTypes.map((e) => PhotographerType(type: e)).toList();

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({Key? key}) : super(key: key);

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _kitcontroller = TextEditingController();
  final TextEditingController _rateperdaycontroller = TextEditingController();
  String name = '';
  int phone = 0;
  String email = '';
  String kit = '';
  double ratePerDay = 0;
  List categories = [];
  List<PhotographerType> _seletedPhotographerType = [];
  bool gettingProfile = false;
  bool editingProfile = false;

  final __photographertypeitems = _photographertypes
      .map((phtographertype) => MultiSelectItem<PhotographerType>(
          phtographertype, phtographertype.type))
      .toList();

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  getProfile() async {
    if (Constants.prefs!.getString("auth-token") != null) {
      gettingProfile = true;
      setState(() {});
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
      name = data['profile']['name'] ?? '';
      email = data['profile']['email'] ?? '';
      phone = data['profile']['phone'] ?? 0;
      kit = data['profile']['kit'] ?? '';
      categories = data['profile']['categories'] ?? [];

      _seletedPhotographerType = _photographertypes;

      _seletedPhotographerType = _seletedPhotographerType
          .where((element) => categories.contains(element.type))
          .toList();

      // for (var category in categories) {
      //   _seletedPhotographerType.add(PhotographerType(type: category));
      // }

      ratePerDay =
          double.tryParse(data['profile']['ratePerDay'].toString()) != null
              ? double.parse(data['profile']['ratePerDay'].toString())
              : 0;
      _namecontroller.text = name;
      _emailcontroller.text = email;
      _phonecontroller.text = phone.toString();
      _kitcontroller.text = kit;
      _rateperdaycontroller.text = ratePerDay.toString();
      gettingProfile = false;
      setState(() {});
    } else {
      return showAlertDialog(context, "Access Denied", "Auth token missing");
    }
  }

  editProfile() async {
    if (Constants.prefs!.getString("auth-token") != null) {
      editingProfile = true;
      setState(() {});
      var editProfileUrl =
          Uri.parse('${constants.apiBaseUrl}/profile/editprofile');
      var res = await http.post(editProfileUrl,
          headers: {
            "Content-Type": "application/json",
            "auth-token": Constants.prefs!.getString("auth-token")!
          },
          body: json.encode({
            "email": email,
            "phone": phone,
            "name": name,
            "kit": kit,
            "ratePerDay": ratePerDay,
            "categories": categories
          }));
      var status = res.statusCode;
      editingProfile = false;
      setState(() {});
      if (status == 400) {
        return showAlertDialog(
            context, "Error 400", "${jsonDecode(res.body)['message']}");
      }
      if (status != 200) {
        return showAlertDialog(context, "Error Status: $status",
            "Something went wrong maybe internet connection try restarting the app and checking your net connection");
      }

      Constants.prefs!.setString("email", email);
      Constants.prefs!.setInt("phone", phone);
      Constants.prefs!.setString("name", name);
      Navigator.pushNamedAndRemoveUntil(
          context, "/setlocation", (route) => false);
    } else {
      return showAlertDialog(context, "Access Denied", "Auth token missing");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomSheetPhoto() {
      return Container(
        height: 100.0,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          const Text(
            "Choose a Profile photo",
            style: TextStyle(fontSize: 20.0),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                child: Row(
                  children: const [
                    Icon(Icons.camera),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Camera"),
                  ],
                ),
              ),
              MaterialButton(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                child: Row(
                  children: const [
                    Icon(Icons.image),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Gallery"),
                  ],
                ),
              )
            ],
          )
        ]),
      );
    }

    return Form(
        child: Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Stack(
          children: [
            CircleAvatar(
              radius: MediaQuery.of(context).size.width / 5,
              backgroundImage: _imageFile == null
                  ? const AssetImage("assets/images/profile_image.jpeg")
                  : Image.file(File(_imageFile!.path)).image,
            ),
            Positioned(
                bottom: MediaQuery.of(context).size.width / 20,
                right: MediaQuery.of(context).size.width / 20,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: ((builder) => bottomSheetPhoto()));
                  },
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF00a3e8),
                  ),
                ))
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: _emailcontroller,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                hintText: "Enter Email",
                labelText: "Email",
                border: OutlineInputBorder())),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: _phonecontroller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                hintText: "Enter Phone No",
                labelText: "Phone No",
                border: OutlineInputBorder())),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: _namecontroller,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
                hintText: "Enter Name",
                labelText: "Name",
                border: OutlineInputBorder())),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: _kitcontroller,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
                hintText: "Enter Kit",
                labelText: "Kit",
                border: OutlineInputBorder())),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: _rateperdaycontroller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                hintText: "Enter Rate Per Day",
                labelText: "Rate Per Day",
                border: OutlineInputBorder())),
        const SizedBox(
          height: 20,
        ),
        gettingProfile
            ? const CircularProgressIndicator()
            : MultiSelectDialogField<PhotographerType>(
                items: __photographertypeitems,
                initialValue: _seletedPhotographerType,
                onConfirm: (values) {
                  // categories = [];
                  // for (Object? val in values) {
                  //   categories.add(
                  //       val.toString().substring(7, val.toString().length - 1));
                  // }
                  categories = [];
                  _seletedPhotographerType = values;
                  for (var photographertype in _seletedPhotographerType) {
                    categories.add(photographertype.type);
                  }
                  setState(() {});
                },
                listType: MultiSelectListType.LIST,
                chipDisplay: MultiSelectChipDisplay(
                    chipColor: const Color(0xFF00a3e8),
                    textStyle: const TextStyle(color: Colors.white)),
                decoration: BoxDecoration(
                  color: const Color(0xFF00a3e8),
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  border: Border.all(
                    color: const Color(0xFF00a3e8),
                    width: 2,
                  ),
                ),
                buttonIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                buttonText: const Text(
                  "Select Your Photographer Category Type",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                title: const Text("Categories"),
                selectedColor: const Color(0xFF00a3e8),
                searchable: true,
              ),
        const SizedBox(
          height: 20,
        ),
        gettingProfile || editingProfile
            ? const CircularProgressIndicator(
                color: Color(0xFF00a3e8),
              )
            : ButtonTheme(
                minWidth: 250,
                child: MaterialButton(
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    color: const Color(0xFF00a3e8),
                    onPressed: () {
                      if (_phonecontroller.text == '' ||
                          int.tryParse(_phonecontroller.text) == null) {
                        showAlertDialog(context, "Enter Phone No!",
                            "Enter a phone no to send otp(only number)");
                        return (null);
                      }
                      phone = int.parse(_phonecontroller.text);
                      email = _emailcontroller.text;
                      name = _namecontroller.text;
                      kit = _kitcontroller.text;
                      if (_rateperdaycontroller.text == '' ||
                          double.tryParse(_rateperdaycontroller.text) == null) {
                        showAlertDialog(context, "Enter Rate per Day!",
                            "Enter Rate per Day(only decimal)");
                        return (null);
                      }
                      ratePerDay = double.parse(_rateperdaycontroller.text);
                      setState(() {});
                      editProfile();
                      // showAlertDialog(context, "Entered Value",
                      //     "$email,$phone,$name,$kit,$ratePerDay");
                    }),
              )
      ],
    ));
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }
}
