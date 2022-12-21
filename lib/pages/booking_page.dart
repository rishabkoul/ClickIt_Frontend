import 'package:click_it/widgets/drawer.dart';
import 'package:flutter/material.dart';

import '../widgets/logout.dart';

class BookingPage extends StatefulWidget {
  final Map booking;
  const BookingPage({Key? key, this.booking = const {}}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  datesBooked() {
    String datesBooked = '';
    for (int i = 0; i < widget.booking['dates_booked'].length; i++) {
      final dateparsed = DateTime.parse(widget.booking['dates_booked'][i]);
      datesBooked =
          "$datesBooked ${dateparsed.day.toString().padLeft(2, '0')}-${dateparsed.month.toString().padLeft(2, '0')}-${dateparsed.year.toString()},";
    }
    if (datesBooked.isNotEmpty) {
      datesBooked = datesBooked.substring(0, datesBooked.length - 1);
    }
    return datesBooked;
  }

  status() {
    return 'Confirmation Pending from ${widget.booking['booked_name']}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked ${widget.booking['booked_name']}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFfe7f28),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        actions: const [Logout()],
      ),
      drawer: const DrawerWidget(drawerHeaderColor: Color(0xFFfe7f28)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                "You have booked ${widget.booking['booked_name']}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Text('Dates Booked: ${datesBooked()}',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(
                height: 20,
              ),
              Text('Status : ${status()}',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {},
                color: const Color(0xFFfe7f28),
                child: Text("See ${widget.booking['booked_name']}'s profile",
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
