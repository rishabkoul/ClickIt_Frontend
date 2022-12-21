import 'package:click_it/widgets/drawer.dart';
import 'package:click_it/widgets/photgrapher_search_form.dart';
import 'package:flutter/material.dart';

import '../widgets/logout.dart';
import '../widgets/photographers_list.dart';
import 'package:click_it/utlis/constants.dart';
import 'package:flutter/scheduler.dart';

import '../constants.dart' as constants;
import 'package:http/http.dart' as http;

import '../utlis/constants.dart';

import 'dart:convert';

import 'package:click_it/widgets/show_alert.dart';

class PhotographersPage extends StatefulWidget {
  const PhotographersPage({Key? key}) : super(key: key);

  @override
  State<PhotographersPage> createState() => _PhotographersPageState();
}

class _PhotographersPageState extends State<PhotographersPage> {
  List data = [];
  int page = 1;
  bool isLoading = true;
  int totalPages = 0;
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    checkLocation();
    if (Constants.prefs!.getDouble("latitude") == null &&
        Constants.prefs!.getDouble("longitude") == null) {
      return (null);
    }
    getProfiles(false);
  }

  checkLocation() {
    if (Constants.prefs!.getDouble("latitude") == null &&
        Constants.prefs!.getDouble("longitude") == null) {
      SchedulerBinding.instance!.addPostFrameCallback((_) async {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/setlocation', (Route<dynamic> route) => false);
      });
    }
  }

  getProfiles(bool search) async {
    if (Constants.prefs!.getString("auth-token") != null) {
      if (search == true) {
        isLoading = true;
        data.clear();
        page = 1;
        setState(() {});
      }
      var query = Constants.prefs!.getString("query") ?? '';
      var categories = Constants.prefs!.getStringList('categories') ?? [];
      var categoriesConverted = jsonEncode(categories);
      var sortByRateAscending =
          Constants.prefs!.getBool('sortByRateAscending') ?? false;
      var getProfilesUrlString = '';
      if (Constants.prefs!.getBool("filterwithmaxdistance") == null) {
        getProfilesUrlString =
            '${constants.apiBaseUrl}/profile/getallprofiles?page=$page&limit=10&lat=${Constants.prefs!.getDouble("latitude")}&lon=${Constants.prefs!.getDouble("longitude")}&categories=$categoriesConverted&sortRateAscending=$sortByRateAscending&query=$query';
      } else {
        if (Constants.prefs!.getBool("filterwithmaxdistance")!) {
          getProfilesUrlString =
              '${constants.apiBaseUrl}/profile/getallprofiles?page=$page&limit=10&lat=${Constants.prefs!.getDouble("latitude")}&lon=${Constants.prefs!.getDouble("longitude")}&categories=$categoriesConverted&maxDistance=${Constants.prefs!.getDouble("maxdistance")}&sortRateAscending=$sortByRateAscending&query=$query';
        } else {
          getProfilesUrlString =
              '${constants.apiBaseUrl}/profile/getallprofiles?page=$page&limit=10&lat=${Constants.prefs!.getDouble("latitude")}&lon=${Constants.prefs!.getDouble("longitude")}&categories=$categoriesConverted&sortRateAscending=$sortByRateAscending&query=$query';
        }
      }

      if (Constants.prefs!.getBool("filterwithmaxrate") != null) {
        if (Constants.prefs!.getBool("filterwithmaxrate")!) {
          getProfilesUrlString = getProfilesUrlString +
              '&rate=${Constants.prefs!.getDouble("maxrate")}';
        }
      }

      var getProfilesUrl = Uri.parse(getProfilesUrlString);

      var res = await http.get(
        getProfilesUrl,
        headers: {
          "Content-Type": "application/json",
          "auth-token": Constants.prefs!.getString("auth-token")!
        },
      );
      var status = res.statusCode;
      if (status == 400) {
        return showAlertDialog(
            context, "Error 400", "${jsonDecode(res.body)['message']}");
      }
      if (status != 200) {
        return showAlertDialog(context, "Error Status: $status", res.body);
      }
      final profiles = jsonDecode(res.body);
      setState(() {
        data.addAll(profiles['profiles']);
        totalPages = profiles['totalPages'];
        isLoading = false;
      });

      // editingProfile = false;
      // setState(() {});

    } else {
      return showAlertDialog(context, "Access Denied", "Auth token missing");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Photgrapher",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFfe7f28),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        actions: const [Logout()],
      ),
      drawer: const DrawerWidget(drawerHeaderColor: Color(0xFFfe7f28)),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading &&
              (scrollInfo.metrics.maxScrollExtent - scrollInfo.metrics.pixels)
                      .round() <=
                  200 &&
              page != totalPages) {
            setState(() {
              page++;
              getProfiles(false);
              isLoading = true;
            });
          }
          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                showFilters
                    ? ButtonTheme(
                        minWidth: 150,
                        child: MaterialButton(
                            color: const Color(0xFFfe7f28),
                            child: const Text(
                              'Hide Filters',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                showFilters = false;
                              });
                            }),
                      )
                    : ButtonTheme(
                        minWidth: 150,
                        child: MaterialButton(
                            color: const Color(0xFFfe7f28),
                            child: const Text(
                              'Show Filters',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                showFilters = true;
                              });
                            }),
                      ),
                const SizedBox(
                  height: 20,
                ),
                showFilters
                    ? Column(
                        children: [
                          PhotographerSearchForm(
                            getProfiles: getProfiles,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      )
                    : Container(),
                PhotographersList(
                  data: data,
                ),
                SizedBox(
                  height: isLoading ? 50.0 : 0.0,
                  child:
                      const CircularProgressIndicator(color: Color(0xFFfe7f28)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
