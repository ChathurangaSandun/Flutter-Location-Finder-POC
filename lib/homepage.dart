import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttergooglemapsapp/positions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:google_maps_webservice/places.dart';

import 'dataclass.dart';
import 'position.dart';

const kGoogleApiKey = "AIzaSyASAMIzHi3CzuhpH8qM-CQa1NM71fFwfDw";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();
  var positions = DataModels.positions;
  Set<Marker> makers = new Set();
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  String placeName = "Choose a location";

  @override
  void initState() {
    super.initState();
    log("start application ----------" + this.positions.length.toString());
  }

  Future<Positions> fetchLocations(double lat, double long, String name) async {
    print(
        'https://locationfinderapi20191118010544.azurewebsites.net/api/Locations/' +
            lat.toString() +
            '/' +
            long.toString() +
            '?count=3');

    final response = await http.get(
        'https://locationfinderapi20191118010544.azurewebsites.net/api/Locations/' +
            lat.toString() +
            '/' +
            long.toString() +
            '?count=3');

    print(response.body);

    if (response.statusCode == 200) {
      var a = Positions.fromJson(json.decode(response.body));
      setState(() {
        positions = a.positionList;
        print(positions);
        makers.clear();
        positions.forEach((position) {
          makers.add(Marker(
              markerId:
                  MarkerId(position.name.replaceAll(' ', '').toLowerCase()),
              position:
                  LatLng(position.point.latitude, position.point.longitude),
              infoWindow: InfoWindow(title: position.name),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              )));
        });
      });
      return a;
    } else {
      throw Exception('Failed to load post');
    }
  }

  double zoomVal = 5.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(placeName),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.search),
            onPressed: () => searchNearestLocations('colombo'),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(context),
          _zoomminusfunction(),
          _zoomplusfunction(),
          _buildContainer(),
        ],
      ),
    );
  }

  Future searchNearestLocations(String city) async {
    Prediction prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.overlay,
    );
    print('start search');
    print(prediction);

    if (prediction != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(prediction.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      final name = detail.result.name;

      setState(() {
        placeName = name;
      });

      _gotoLocation(lat, lng);

      fetchLocations(lat, lng, name);
    }

    // var a = fetchLocations(city);
    // print(a);
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Widget _zoomminusfunction() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchMinus, color: Color(0xff6200ee)),
          onPressed: () {
            zoomVal--;
            _minus(zoomVal);
          }),
    );
  }

  Widget _zoomplusfunction() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchPlus, color: Color(0xff6200ee)),
          onPressed: () {
            zoomVal++;
            _plus(zoomVal);
          }),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(6.917700, 79.851744), zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(6.917700, 79.851744), zoom: zoomVal)));
  }

  Widget _buildContainer() {
    List<Widget> details = [];
    this.positions.forEach((position) => {
          details.add(SizedBox(width: 10.0)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _boxes(position.imageUrl, position.point.latitude,
                position.point.longitude, position.name, position.mobileNumber, position.address),
          )
        });

    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            ...positions.map((position) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _boxes(
                    position.imageUrl,
                    position.point.latitude,
                    position.point.longitude,
                    position.name,
                    position.mobileNumber,
                    position.address),
              );
            }).toList()
          ],
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String name,
      String mobileNumber, String address) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(name, mobileNumber, address),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String name, String mobileNumber, String address) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            child: Text(
              name == null ? '' : name,
              style: TextStyle(
                  color: Color(0xff6200ee),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
         SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            child: Text(
              mobileNumber == null ? '' : mobileNumber,              
              style: TextStyle(
                  color:  Colors.black54,
                  fontSize: 22.0,
                  fontWeight: FontWeight.normal,
                  ),
            ),
          ),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Text(
           address == null ? '' : address,          
          style: TextStyle(
            color: Colors.black54,
            fontSize: 22.0,
          ),
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          "",
          style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
            CameraPosition(target: LatLng(6.917700, 79.851744), zoom: 14),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: this.makers,
      ),
    );
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}

Marker gramercyMarker = Marker(
  markerId: MarkerId('personone'),
  position: LatLng(6.911847, 79.855947),
  infoWindow: InfoWindow(title: 'Person one'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);

Marker bernardinMarker = Marker(
  markerId: MarkerId('persontwo'),
  position: LatLng(6.912305, 79.851516),
  infoWindow: InfoWindow(title: 'Person two'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);
Marker blueMarker = Marker(
  markerId: MarkerId('personthree'),
  position: LatLng(6.915681, 79.854563),
  infoWindow: InfoWindow(title: "Person three"),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);

Marker newyork1Marker = Marker(
  markerId: MarkerId('personfour'),
  position: LatLng(6.930226, 79.857346),
  infoWindow: InfoWindow(title: 'Person four'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);
Marker newyork2Marker = Marker(
  markerId: MarkerId('personfive'),
  position: LatLng(6.890798, 79.901278),
  infoWindow: InfoWindow(title: 'Person five'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);
Marker newyork3Marker = Marker(
  markerId: MarkerId('personsix'),
  position: LatLng(6.874288, 79.869645),
  infoWindow: InfoWindow(title: 'Person six'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);
