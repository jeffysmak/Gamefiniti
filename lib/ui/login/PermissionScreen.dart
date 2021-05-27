import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:location/location.dart';

import 'SelfieScreen.dart';

class PermissionScreen extends StatefulWidget {
  AppUser registeringUser;

  PermissionScreen({this.registeringUser});

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  Location _location;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData userLocation;

  AppUser registeringUser;

  Future<bool> _enableService() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      return _serviceEnabled;
    }
    return _serviceEnabled;
  }

  Future<bool> _requestPermission() async {
    _permissionGranted = await _location.hasPermission();

    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await _location.requestPermission();
      return _permissionGranted == PermissionStatus.GRANTED;
    }
    return _permissionGranted == PermissionStatus.GRANTED;
  }

  void _initUserLocationPermissions() async {
    bool perm = await _requestPermission();
    if (perm) {
      bool servEnb = await _enableService();
      if (servEnb) {
        // get location
        userLocation = await _location.getLocation();

        if (userLocation != null) {
          if (registeringUser != null) {
            // signinup
            registeringUser.latitude = userLocation.latitude;
            registeringUser.longitude = userLocation.longitude;
            Address userAddressFromLocation = await getAddressFromCoordinates(userLocation);
            registeringUser.city = userAddressFromLocation.locality;
            registeringUser.address = userAddressFromLocation.addressLine;
            FirestoreHelper.createUserInDatabase(registeringUser, () {
              // user location and address updated to database, navigate to selfie screen

              Navigator.push(context, MaterialPageRoute(builder: (ctx) => SelfieScreen(registeringUser)));
            }, merge: true);
          }

          // set location to user's model class
          // navigate to id card photo uploade
//          Navigator.push(context, MaterialPageRoute(builder: (ctx) => SelfieScreen(registeringUser)));
        }
      }
    }
  }

  Future<Address> getAddressFromCoordinates(LocationData locationData) async {
    List<Address> addresses = List();
    addresses =
        await Geocoder.local.findAddressesFromCoordinates(Coordinates(locationData.latitude, locationData.longitude));
    return addresses[0];
  }

  @override
  void initState() {
    super.initState();
    _location = Location();

    if (widget.registeringUser != null) {
      registeringUser = widget.registeringUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black87,
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TitleText(
                        text: 'Location Services',
                        fontSize: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Container(
                        child: Image.asset('assets/images/maps.png'),
                        margin: EdgeInsets.symmetric(vertical: 32),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        'We need to know where you are\nin order to scan nearby users',
                        style: TextStyle(color: Colors.black87, fontSize: MediaQuery.of(context).size.height * 0.02),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 45,
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: RaisedButton(
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    _initUserLocationPermissions();
                  },
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'ENABLE LOCATION',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
