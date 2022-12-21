import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../utlis/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingSearchForm extends StatefulWidget {
  final ArgumentCallback<bool>? getBookings;
  const BookingSearchForm({Key? key, this.getBookings}) : super(key: key);

  @override
  State<BookingSearchForm> createState() => _BookingSearchFormState();
}

class _BookingSearchFormState extends State<BookingSearchForm> {
  final TextEditingController _querycontroller = TextEditingController();

  List<DateTime> selectedDates = [];

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    selectedDates = args.value;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _querycontroller.text =
        Constants.prefs!.getString('your-bookings-query').toString();
    if (_querycontroller.text == 'null') {
      _querycontroller.text = '';
    }
    selectedDates =
        Constants.prefs!.getStringList('your-bookings-booked-dates-filter') !=
                null
            ? Constants.prefs!
                .getStringList('your-bookings-booked-dates-filter')!
                .map((dateString) => DateTime.parse(dateString))
                .toList()
            : [];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(children: [
      TextFormField(
          controller: _querycontroller,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
              hintText: "Search by booked person's name",
              labelText: 'Search',
              hintStyle: TextStyle(color: Color(0xFFfe7f28)),
              labelStyle: TextStyle(color: Color(0xFFfe7f28)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFfe7f28), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFfe7f28), width: 1.0),
              ))),
      const SizedBox(
        height: 20,
      ),
      SfDateRangePicker(
        initialSelectedDates: selectedDates,
        selectionColor: Colors.green,
        selectionTextStyle: const TextStyle(color: Colors.white),
        selectionMode: DateRangePickerSelectionMode.multiple,
        onSelectionChanged: _onSelectionChanged,
      ),
      const SizedBox(
        height: 20,
      ),
      ButtonTheme(
        minWidth: 150,
        child: MaterialButton(
            color: const Color(0xFFfe7f28),
            child: const Text(
              'Search',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Constants.prefs!
                  .setString('your-bookings-query', _querycontroller.text);
              Constants.prefs!.setStringList(
                  'your-bookings-booked-dates-filter',
                  selectedDates.map((e) => e.toString()).toList());
              widget.getBookings!(true);
            }),
      )
    ]));
  }
}
