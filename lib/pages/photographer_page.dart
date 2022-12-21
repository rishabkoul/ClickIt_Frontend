import 'package:click_it/widgets/booking_calender.dart';
import 'package:click_it/widgets/drawer.dart';
import 'package:click_it/widgets/photographer_detail.dart';
import 'package:flutter/material.dart';

import '../widgets/logout.dart';

class PhotographerPage extends StatefulWidget {
  final Map data;
  const PhotographerPage({Key? key, this.data = const {}}) : super(key: key);

  @override
  State<PhotographerPage> createState() => _PhotographerPageState();
}

class _PhotographerPageState extends State<PhotographerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['name'],
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
            children: [
              PhotographerDetail(data: widget.data),
              BookingCalender(data: widget.data)
            ],
          ),
        ),
      ),
    );
  }
}
