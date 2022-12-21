import 'package:click_it/widgets/show_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../constants.dart' as constants;
import '../utlis/constants.dart';
import '../utlis/photographertype.dart';

List<PhotographerType> _photographertypes =
    constants.photographerTypes.map((e) => PhotographerType(type: e)).toList();

class PhotographerSearchForm extends StatefulWidget {
  final ArgumentCallback<bool>? getProfiles;
  const PhotographerSearchForm({Key? key, this.getProfiles}) : super(key: key);

  @override
  State<PhotographerSearchForm> createState() => _PhotographerSearchFormState();
}

class _PhotographerSearchFormState extends State<PhotographerSearchForm> {
  // DateTimeRange dateRange =
  //     DateTimeRange(start: DateTime.now(), end: DateTime.now());

  final TextEditingController _distancecontroller = TextEditingController();
  final TextEditingController _maxratecontroller = TextEditingController();
  final TextEditingController _querycontroller = TextEditingController();

  bool sortByRateAscending = false;

  final __photographertypeitems = _photographertypes
      .map((phtographertype) => MultiSelectItem<PhotographerType>(
          phtographertype, phtographertype.type))
      .toList();

  List<String> categories = [];
  List<PhotographerType> _initialphotographers = [];

  @override
  void initState() {
    var initcategories = Constants.prefs!.getStringList('categories') ?? [];
    _initialphotographers = _photographertypes
        .where((element) => initcategories.contains(element.type))
        .toList();

    _distancecontroller.text =
        Constants.prefs!.getDouble('maxdistance').toString();
    if (_distancecontroller.text == 'null') {
      _distancecontroller.text = '';
    }

    _maxratecontroller.text = Constants.prefs!.getDouble('maxrate').toString();
    if (_maxratecontroller.text == 'null') {
      _maxratecontroller.text = '';
    }

    sortByRateAscending =
        Constants.prefs!.getBool('sortByRateAscending') ?? false;
    super.initState();

    _querycontroller.text = Constants.prefs!.getString('query').toString();
    if (_querycontroller.text == 'null') {
      _querycontroller.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // final startDate = dateRange.start;
    // final endDate = dateRange.end;
    return Form(
        child: Column(children: [
      MultiSelectDialogField<PhotographerType>(
        items: __photographertypeitems,
        initialValue: _initialphotographers,
        onConfirm: (values) {
          setState(() {
            categories = [];
            for (var val in values) {
              categories.add(val.type);
            }
            _initialphotographers = values;
          });
        },
        listType: MultiSelectListType.LIST,
        chipDisplay: MultiSelectChipDisplay(
            chipColor: const Color(0xFFfe7f28),
            textStyle: const TextStyle(color: Colors.white)),
        decoration: BoxDecoration(
          color: const Color(0xFFfe7f28),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          border: Border.all(
            color: const Color(0xFFfe7f28),
            width: 2,
          ),
        ),
        buttonIcon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
        ),
        buttonText: const Text(
          "Select Type of Photographer to Filter ...",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        title: const Text("Categories"),
        selectedColor: const Color(0xFFfe7f28),
        searchable: true,
      ),
      const SizedBox(
        height: 20,
      ),
      TextFormField(
          controller: _distancecontroller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              hintText: 'Enter Max Distance in meters',
              labelText: 'Max Distance',
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
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            side: const BorderSide(width: 1.5, color: Color(0xFFfe7f28)),
            activeColor: const Color(0xFFfe7f28),
            value: sortByRateAscending,
            onChanged: (bool? value) {
              setState(() {
                sortByRateAscending = value!;
              });
            },
          ),
          const Text(
            'Sort ascending by rate per day',
            style: TextStyle(fontSize: 18),
          )
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      TextFormField(
          controller: _maxratecontroller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              hintText: 'Enter Max Rate per day in ₹',
              labelText: 'Max Rate per day',
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
      TextFormField(
          controller: _querycontroller,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
              hintText: 'Search by name or kit',
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
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //   children: [
      //     const Text('From: '),
      //     MaterialButton(
      //         color: const Color(0xFFfe7f28),
      //         child: Text(
      //           '${startDate.year}/${startDate.month}/${startDate.day}',
      //           style: const TextStyle(color: Colors.white),
      //         ),
      //         onPressed: pickDateRange),
      //     const Text('To: '),
      //     MaterialButton(
      //         color: const Color(0xFFfe7f28),
      //         child: Text(
      //           '${endDate.year}/${endDate.month}/${endDate.day}',
      //           style: const TextStyle(color: Colors.white),
      //         ),
      //         onPressed: pickDateRange)
      //   ],
      // ),
      // const SizedBox(
      //   height: 20,
      // ),
      ButtonTheme(
        minWidth: 150,
        child: MaterialButton(
            color: const Color(0xFFfe7f28),
            child: const Text(
              'Search',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (double.tryParse(_distancecontroller.text) == null) {
                if (_distancecontroller.text != '') {
                  showAlertDialog(
                      context, 'Error!', 'Distance should be a Decimal');
                  return;
                }
              }
              if (_distancecontroller.text != '') {
                Constants.prefs!.setDouble(
                    'maxdistance', double.parse(_distancecontroller.text));
                Constants.prefs!.setBool('filterwithmaxdistance', true);
              } else {
                Constants.prefs!.setBool('filterwithmaxdistance', false);
              }

              if (double.tryParse(_maxratecontroller.text) == null) {
                if (_maxratecontroller.text != '') {
                  showAlertDialog(
                      context, 'Error!', 'Max Rate should be a Decimal');
                  return;
                }
              }
              if (_maxratecontroller.text != '') {
                Constants.prefs!.setDouble(
                    'maxrate', double.parse(_maxratecontroller.text));
                Constants.prefs!.setBool('filterwithmaxrate', true);
              } else {
                Constants.prefs!.setBool('filterwithmaxrate', false);
              }
              Constants.prefs!.setString('query', _querycontroller.text);
              Constants.prefs!.setStringList('categories', categories);
              Constants.prefs!
                  .setBool('sortByRateAscending', sortByRateAscending);
              widget.getProfiles!(true);
            }),
      )
    ]));
  }

  // Future pickDateRange() async {
  //   var date = DateTime.now();
  //   DateTimeRange? newDateRange = await showDateRangePicker(
  //     context: context,
  //     initialDateRange: dateRange,
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(date.year + 1, date.month, date.day),
  //     builder: (BuildContext context, child) {
  //       return Theme(
  //         data: ThemeData.dark().copyWith(
  //           colorScheme: const ColorScheme.light(
  //             primary: Color(0xFFfe7f28),
  //             surface: Color(0xFFfe7f28),
  //             onSurface: Color(0xFFfe7f28),
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (newDateRange == null) {
  //     return;
  //   }

  //   setState(() {
  //     dateRange = newDateRange;
  //   });
  // }
}
