import 'package:click_it/widgets/drawer.dart';
import 'package:click_it/widgets/logout.dart';
import 'package:flutter/material.dart';
import 'package:click_it/utlis/constants.dart';
import '../constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:click_it/widgets/show_alert.dart';
import 'dart:convert';

import '../widgets/booking_search_form.dart';
import '../widgets/bookingslist.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List data = [];
  int page = 1;
  bool isLoading = true;
  int totalPages = 0;
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    getYourBookings(false);
  }

  getYourBookings(bool search) async {
    if (Constants.prefs!.getString("auth-token") != null) {
      if (search == true) {
        isLoading = true;
        data.clear();
        page = 1;
        setState(() {});
      }
      var query = Constants.prefs!.getString("your-bookings-query") ?? '';
      var bookedDatesFilter =
          Constants.prefs!.getStringList('your-bookings-booked-dates-filter') ??
              [];
      var bookedDatesFilterConverted = jsonEncode(bookedDatesFilter);
      var getYourBookingsUrlString =
          '${constants.apiBaseUrl}/booking/getyourbookings?page=$page&limit=10&query=$query&dates_booked=$bookedDatesFilterConverted';

      var getYourBookingsUrl = Uri.parse(getYourBookingsUrlString);

      var res = await http.get(
        getYourBookingsUrl,
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
      final bookings = jsonDecode(res.body);
      setState(() {
        data.addAll(bookings['bookings']);
        totalPages = bookings['totalPages'];
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
        title:
            const Text("Your Bookings", style: TextStyle(color: Colors.white)),
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
              getYourBookings(false);
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
                          BookingSearchForm(
                            getBookings: getYourBookings,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      )
                    : Container(),
                BookingsList(
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
