import 'package:flutter/material.dart';

import '../pages/booking_page.dart';

class BookingsList extends StatefulWidget {
  final List data;
  const BookingsList({Key? key, this.data = const []}) : super(key: key);

  @override
  State<BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<BookingsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var subtitle = '';
        if (widget.data[index]["isConfirmed"]!) {
          subtitle =
              'Confirmed from the photographer please pay the amount to confim this booking';
        } else {
          subtitle = 'Not yet confirmed from the photogrpaher';
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(widget.data[index]["booked_name"]!),
            subtitle: Text(subtitle),
            leading: Image.network(
                "https://cdn2.vectorstock.com/i/1000x1000/20/76/man-avatar-profile-vector-21372076.jpg"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookingPage(booking: widget.data[index]),
                  ),
                  (r) => false);
            },
          ),
        );
      },
      itemCount: widget.data.length,
    );
  }
}
