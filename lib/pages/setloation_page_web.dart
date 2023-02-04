import 'dart:convert';

import 'package:click_it/widgets/logout.dart';
import 'package:click_it/widgets/show_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:click_it/utlis/constants.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import '../widgets/drawer.dart';
import 'package:location/location.dart' as locationmodule;
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as constants;
import 'package:google_maps_webservice/places.dart';

class SetLocationPageWeb extends StatefulWidget {
  const SetLocationPageWeb({Key? key}) : super(key: key);

  @override
  State<SetLocationPageWeb> createState() => _SetLocationPageWebState();
}

const kGoogleApiKey = 'AIzaSyBfUeSVUP0vDG89czs1IyfKH4c7SfJ1rJ0';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SetLocationPageWebState extends State<SetLocationPageWeb> {
  final Mode _mode = Mode.overlay;
  var address = "";
  double? latitude = 0.0;
  double? longitude = 0.0;
  bool fetchingLocation = false;
  bool editingLocation = false;

  @override
  void initState() {
    super.initState();

    if (Constants.prefs!.getString("name") == null ||
        Constants.prefs!.getString("name") == "") {
      goToEditProfilePage();
      return;
    }

    _currentLocation();
  }

  goToEditProfilePage() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/editprofile', (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title:
            const Text("Set Location", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF268476),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        actions: const [Logout()],
      ),
      drawer: const DrawerWidget(drawerHeaderColor: Color(0xFF268476)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !fetchingLocation
                  ? Stack(
                      children: [
                        SfMaps(
                          layers: [
                            MapTileLayer(
                              initialFocalLatLng:
                                  MapLatLng(latitude!, longitude!),
                              initialZoomLevel: 15,
                              initialMarkersCount: 1,
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              markerBuilder: (BuildContext context, int index) {
                                return MapMarker(
                                  latitude: latitude!,
                                  longitude: longitude!,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red[800],
                                  ),
                                  size: const Size(20, 20),
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                              onPressed: _handleSearchPress,
                              color: const Color(0xFF268476),
                              child: const Text('Search Location',
                                  style: TextStyle(color: Colors.white))),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Address: $address",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Center(
                child: fetchingLocation || editingLocation
                    ? const CircularProgressIndicator(
                        color: Color(0xFF268476),
                      )
                    : ButtonTheme(
                        minWidth: 200,
                        child: MaterialButton(
                            onPressed: () {
                              editLocation();
                            },
                            color: const Color(0xFF268476),
                            child: const Text('Save',
                                style: TextStyle(color: Colors.white))),
                      ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentLocation,
        child: const Icon(
          Icons.gps_fixed,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF268476),
      ),
    );
  }

  editLocation() async {
    if (Constants.prefs!.getString("auth-token") != null) {
      editingLocation = true;
      setState(() {});
      var editProfileUrl =
          Uri.parse('${constants.apiBaseUrl}/location/editlocation');
      var res = await http.post(editProfileUrl,
          headers: {
            "Content-Type": "application/json",
            "auth-token": Constants.prefs!.getString("auth-token")!
          },
          body: json
              .encode({"lat": latitude, "lon": longitude, "address": address}));
      var status = res.statusCode;
      if (status == 400) {
        return showAlertDialog(
            context, "Error 400", "${jsonDecode(res.body)['message']}");
      }
      if (status != 200) {
        return showAlertDialog(context, "Error Status: $status",
            "Something went wrong maybe internet connection try restarting the app and checking your net connection");
      }

      editingLocation = false;
      setState(() {});
      if (latitude != null) {
        Constants.prefs!.setDouble("latitude", latitude!);
      }
      if (longitude != null) {
        Constants.prefs!.setDouble("longitude", longitude!);
      }

      Navigator.pushNamedAndRemoveUntil(
          context, "/photographers", (route) => false);
    } else {
      return showAlertDialog(context, "Access Denied", "Auth token missing");
    }
  }

  getAddressFromLatLng(context, double? lat, double? lng) async {
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url = '$_host?key=$kGoogleApiKey&language=en&latlng=$lat,$lng';
    if (lat != null && lng != null) {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        String _formattedAddress = data["results"][0]["formatted_address"];
        return _formattedAddress;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<locationmodule.LocationData?> _currentLocation() async {
    fetchingLocation = true;
    setState(() {});
    bool serviceEnabled;
    locationmodule.PermissionStatus permissionGranted;

    locationmodule.Location location = locationmodule.Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == locationmodule.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != locationmodule.PermissionStatus.granted) {
        return null;
      }
    }
    final locationmodule.LocationData locationReturn =
        await location.getLocation();
    latitude = locationReturn.latitude;
    longitude = locationReturn.longitude;
    address = await getAddressFromLatLng(
        context, locationReturn.latitude, locationReturn.longitude);
    fetchingLocation = false;
    setState(() {});
    return locationReturn;
  }

  Future<void> _handleSearchPress() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        headers: {"x-requested-with": "XMLHttpRequest"},
        strictbounds: false,
        types: [""],
        proxyBaseUrl: kIsWeb
            ? 'https://proxy.cors.sh/https://maps.googleapis.com/maps/api'
            : null,
        components: [Component(Component.country, "in")]);

    if (p != null) {
      displayPrediction(p, homeScaffoldKey.currentState);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> displayPrediction(
      Prediction p, ScaffoldState? currentState) async {
    fetchingLocation = true;
    setState(() {});
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: kIsWeb
          ? {"x-requested-with": "XMLHttpRequest"}
          : await const GoogleApiHeaders().getHeaders(),
      baseUrl: kIsWeb
          ? 'https://proxy.cors.sh/https://maps.googleapis.com/maps/api'
          : null,
    );
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    latitude = lat;
    longitude = lng;
    address = await getAddressFromLatLng(context, lat, lng);

    fetchingLocation = false;
    setState(() {});
  }
}
