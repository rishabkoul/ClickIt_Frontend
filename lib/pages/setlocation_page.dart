import 'dart:convert';

import 'package:click_it/widgets/logout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_api_headers/google_api_headers.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
import "package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart";
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:google_api_headers/google_api_headers.dart';
import 'package:click_it/utlis/constants.dart';

import '../widgets/drawer.dart';
import '../widgets/show_alert.dart';
import '../constants.dart' as constants;
import 'package:http/http.dart' as http;

class SetLocationPage extends StatefulWidget {
  const SetLocationPage({Key? key}) : super(key: key);

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

const kGoogleApiKey = 'YOUR_GOOGLE_API_KEY';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SetLocationPageState extends State<SetLocationPage> {
  late GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;
  var street = "";
  var subLocality = "";
  var locality = "";
  var postalCode = "";
  var country = "";
  var latitude = 0.0;
  var longitude = 0.0;

  static const CameraPosition initialPosition =
      CameraPosition(target: LatLng(28.559830, 77.046112), zoom: 15.0);

  Set<Marker> markers = {};

  bool fetchingLocation = false;
  bool editingLocation = false;

  void setCurrentLocation() async {
    fetchingLocation = true;
    setState(() {});
    Position position = await _determinePosition();

    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0)));
    markers.clear();
    markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(position.latitude, position.longitude)));
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    street = place.street!;
    subLocality = place.subLocality!;
    locality = place.locality!;
    postalCode = place.postalCode!;
    country = place.country!;
    latitude = position.latitude;
    longitude = position.longitude;
    fetchingLocation = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    if (Constants.prefs!.getString("name") == null ||
        Constants.prefs!.getString("name") == "") {
      goToEditProfilePage();
      return;
    }

    setCurrentLocation();
  }

  goToEditProfilePage() {
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/editprofile', (Route<dynamic> route) => false);
    });
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
          body: json.encode({
            "lat": latitude,
            "lon": longitude,
            "address": "$street $subLocality $locality $postalCode $country"
          }));
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
      Constants.prefs!.setDouble("latitude", latitude);
      Constants.prefs!.setDouble("longitude", longitude);

      Navigator.pushNamedAndRemoveUntil(
          context, "/photographers", (route) => false);
    } else {
      return showAlertDialog(context, "Access Denied", "Auth token missing");
    }
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
              Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: GoogleMap(
                      initialCameraPosition: initialPosition,
                      markers: markers,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) {
                        googleMapController = controller;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                        onPressed: _handleSearchPress,
                        color: const Color(0xFF268476),
                        child: const Text('Search Location',
                            style: TextStyle(color: Colors.white))),
                  ),
                  if (fetchingLocation)
                    SizedBox(
                        height: MediaQuery.of(context).size.height / 2.5,
                        child: const Center(
                            child: CircularProgressIndicator(
                          color: Color(0xFF268476),
                        )))
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Street: $street",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text("Sublocality: $subLocality",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text("Locality: $locality",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text("Postal Code : $postalCode",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text("Country: $country",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
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
        onPressed: setCurrentLocation,
        child: const Icon(
          Icons.gps_fixed,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF268476),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanantly denied");
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  Future<void> _handleSearchPress() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
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
        apiHeaders: await const GoogleApiHeaders().getHeaders());
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks[0];
    street = place.street!;
    subLocality = place.subLocality!;
    locality = place.locality!;
    postalCode = place.postalCode!;
    country = place.country!;
    latitude = lat;
    longitude = lng;

    markers.clear();
    markers.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));
    setState(() {});

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.0));
    fetchingLocation = false;
    setState(() {});
  }
}
