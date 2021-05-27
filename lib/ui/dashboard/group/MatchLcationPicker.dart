import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indianapp/Common.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;

class MatchLocationpicker extends StatefulWidget {
  @override
  _MatchLocationpickerState createState() => _MatchLocationpickerState();
}

class _MatchLocationpickerState extends State<MatchLocationpicker> {
  LocationData locationData;
  String _mapStyle;
  GoogleMapController _mapsController;
  static final CameraPosition _kLake = CameraPosition(target: LatLng(30.3753, 69.3451), zoom: 18);
  LatLng choosenLocation;
  bool isBusy = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.loadString('assets/mapstyle.txt').then((string) {
      _mapStyle = string;
    });
    initLocation();
  }

  void initLocation() async {
    locationData = await Common.getUserCurrentLocation();
    setState(() {});
    _moveCameraToUserLocation();
  }

  void _moveCameraToUserLocation() async {
    if (locationData != null) {
      _mapsController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationData.latitude, locationData.longitude),
            zoom: 17,
          ),
        ),
      );
      setState(() {
        isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Pick match location'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.symmetric(vertical: 100, horizontal: 16),
            tiltGesturesEnabled: false,
            compassEnabled: false,
//            markers: _markers,
            initialCameraPosition: _kLake,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapsController = controller;
              _mapsController.setMapStyle(_mapStyle);
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            onCameraIdle: () {
              getCenteredLocation();
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 56,
              width: 56,
              child: !isBusy
                  ? Image.asset(
                      'assets/images/marker.gif',
                    )
                  : SizedBox(),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -10,
            right: -10,
            child: Card(
              child: Container(
                margin: EdgeInsets.all(24),
                child: RaisedButton(
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: () {
                    Navigator.pop(context, locationData);
                  },
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getCenteredLocation() async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double middleX = screenWidth / 2;
    double middleY = screenHeight / 2;

    choosenLocation = await _mapsController.getLatLng(ScreenCoordinate(x: middleX.round(), y: middleY.round()));
  }
}
