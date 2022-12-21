import 'package:click_it/pages/booking_page.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:click_it/utlis/constants.dart';
import 'dart:convert';
import 'package:click_it/widgets/show_alert.dart';

class BookingCalender extends StatefulWidget {
  final Map data;
  const BookingCalender({Key? key, this.data = const {}}) : super(key: key);

  @override
  State<BookingCalender> createState() => _BookingCalenderState();
}

class _BookingCalenderState extends State<BookingCalender> {
  var unSelectableDates = [
    DateTime(2022, 07, 21),
    DateTime(2022, 07, 22),
    DateTime(2022, 07, 23),
    DateTime(2022, 07, 24)
  ];

  var selectedDates = [];

  bool booking = false;

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    selectedDates = args.value;
    setState(() {});
  }

  book() async {
    if (Constants.prefs!.getString("auth-token") != null) {
      booking = true;
      setState(() {});
      var bookingUrl = Uri.parse('${constants.apiBaseUrl}/booking/book');
      var res = await http.post(bookingUrl,
          headers: {
            "Content-Type": "application/json",
            "auth-token": Constants.prefs!.getString("auth-token")!
          },
          body: json.encode({
            "booked_userId": widget.data['_id'],
            "booked_name": widget.data['name'],
            "dates_booked": selectedDates.map((e) => e.toString()).toList(),
          }));
      var status = res.statusCode;
      booking = false;
      setState(() {});
      if (status == 400) {
        return showAlertDialog(
            context, "Error 400", "${jsonDecode(res.body)['message']}");
      }
      if (status != 200) {
        return showAlertDialog(context, "Error Status: $status",
            "Something went wrong maybe internet connection try restarting the app and checking your net connection");
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookingPage(booking: jsonDecode(res.body)['booking']),
          ),
          (r) => false);
    } else {
      return showAlertDialog(context, "Access Denied", "Auth token missing");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SfDateRangePicker(
          selectableDayPredicate: (DateTime dateTime) {
            if (unSelectableDates.contains(dateTime)) {
              return false;
            }
            return true;
          },
          selectionColor: Colors.green,
          selectionTextStyle: const TextStyle(color: Colors.white),
          selectionMode: DateRangePickerSelectionMode.multiple,
          minDate: DateTime.now(),
          monthViewSettings: DateRangePickerMonthViewSettings(
            blackoutDates: [
              DateTime(2022, 07, 21),
            ],
            specialDates: [
              DateTime(2022, 07, 22),
              DateTime(2022, 07, 23),
              DateTime(2022, 07, 24)
            ],
          ),
          monthCellStyle: DateRangePickerMonthCellStyle(
            specialDatesDecoration: BoxDecoration(
                color: Colors.red,
                border: Border.all(color: const Color(0xFFF44436), width: 1),
                shape: BoxShape.circle),
            blackoutDatesDecoration: BoxDecoration(
                color: const Color(0xFFDFDFDF),
                border: Border.all(color: const Color(0xFFB6B6B6), width: 1),
                shape: BoxShape.circle),
            specialDatesTextStyle: const TextStyle(
                color: Colors.white, decoration: TextDecoration.lineThrough),
            blackoutDateTextStyle: const TextStyle(color: Colors.black),
          ),
          onSelectionChanged: _onSelectionChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [Text("🔘 Blocked"), Text("🔴 Booked")],
        ),
        const SizedBox(
          height: 20,
        ),
        booking
            ? const CircularProgressIndicator(
                color: Color(0xFFfe7f28),
              )
            : MaterialButton(
                onPressed: () {
                  if (selectedDates.isEmpty) {
                    showAlertDialog(context, "Select some Dates",
                        "Please Select some dates to book");
                    return;
                  }
                  book();
                },
                color: const Color(0xFFfe7f28),
                child:
                    const Text('Book', style: TextStyle(color: Colors.white)),
              ),
      ],
    );
  }
}
