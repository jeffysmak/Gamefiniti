import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:indianapp/helpers/DistanceTo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/InterestGridItem.dart';
import 'package:indianapp/ui/custom/Swapping.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/postactivity/PostInterest.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  Function onRequestPosted;
  AppUser signedInUser;

  HomeScreen({this.onRequestPosted, this.signedInUser});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController _mapsController;
  PanelController _panelController;
  Location location;
  String _mapStyle;
  LocationData _currentLocation;

  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = Set();

  bool lastRequestStatus = true;

  List<InterestModel> _interestsList = List();

  // custom markers
  BitmapDescriptor customIcon;

  // selected interest list
  List<InterestModel> _selectedInterestModel = List();

  // nearby requests
  List<PostActivity> nearbyRequests = List();

  void setCustomMapPin() async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 3.0), 'assets/current.png').then((onValue) {
      setState(() {
        pinLocationIcon = onValue;
        Marker m = Marker(
          markerId: MarkerId('a'),
          position: LatLng(_currentLocation.latitude, _currentLocation.longitude),
          icon: pinLocationIcon,
        );
        setState(() {
          _markers.add(m);
        });
      });
    });
  }

  void _decodeCustomMarkerImages() async {}

  void initMyInterests() async {
    FirestoreHelper.getMyInterests(widget.signedInUser, (model) {
      setState(() {
        _interestsList.add(model);
      });
    });
  }

  static final CameraPosition _kLake = CameraPosition(target: LatLng(30.3753, 69.3451), zoom: 18);

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();
    rootBundle.loadString('assets/mapstyle.txt').then((string) {
      _mapStyle = string;
    });
    _moveCameraToUserLocation();
    initMyInterests();

//    _fetchInterest();
//    _checkMyLastRequestStatus();
  }

  void fetchNearbyRequests() async {
    FirestoreHelper.getNearByRequestsByKm(
      widget.signedInUser,
      2000000000000,
      Coordinates(_currentLocation.latitude, _currentLocation.longitude),
      (PostActivity request) {
        setState(() {
          nearbyRequests.add(request);
        });
        // request marker
        BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), getImageNameByInterest(request.interests)).then((onValue) {
          setState(() {
            BitmapDescriptor pinLocationIcon = onValue;
            Marker m = Marker(
              markerId: MarkerId('${DateTime.now().millisecondsSinceEpoch}'),
              position: LatLng(request.currentCoordinates.latitude, request.currentCoordinates.longitude),
              icon: pinLocationIcon,
              onTap: () {
                double distanceBewteen = distanceTo.distanceBetween(
                    _currentLocation.latitude, _currentLocation.longitude, request.currentCoordinates.latitude, request.currentCoordinates.longitude);
                if (distanceBewteen <= 5000) {
                  // less than 5km
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => SwapItem(request, currentSigninUser: widget.signedInUser, fromNotification: false),
                    ),
                  );
                }
              },
            );
            setState(() {
              _markers.add(m);
            });
            debugPrint('${_markers.length}');
          });
        });
      },
    );
  }

  void _checkMyLastRequestStatus() async {
    this.lastRequestStatus = await FirestoreHelper.isMyLastRequestActive(Common.signedInUser);
    setState(() {
      lastRequestStatus ? _panelController.hide() : _panelController.show();
    });
  }

  void _fetchInterest() async {
    _interestsList = await FirestoreHelper.getInterest();
    setState(() {});
  }

  void _moveCameraToUserLocation() async {
    _currentLocation = await Common.getUserCurrentLocation();
    if (_currentLocation != null) {
      Common.coordinates = Coordinates(_currentLocation.latitude, _currentLocation.longitude);
      _mapsController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
            zoom: 17,
          ),
        ),
      );
      setCustomMapPin();
      fetchNearbyRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SlidingUpPanel(
        controller: _panelController,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
        panelBuilder: (ScrollController sc) {
          return Container(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 56),
                Expanded(
                  child: GridView.count(
                    scrollDirection: Axis.vertical,
                    controller: sc,
                    crossAxisCount: 4,
                    children: _interestsList
                        .map(
                          (InterestModel model) => InterestItemWidget(
                            model,
                            () {
                              setState(
                                () {
                                  model.isSelected ? _selectedInterestModel.remove(model) : _selectedInterestModel.add(model);
                                  model.isSelected ? model.isSelected = false : model.isSelected = true;

                                  _interestsList.forEach(
                                    (InterestModel loopedelement) {
                                      if (_selectedInterestModel.length == 3) {
                                        if (!loopedelement.isSelected) {
                                          loopedelement.isDisabled = true;
                                        }
                                      } else {
                                        loopedelement.isDisabled = false;
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            context,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(8),
                    height: 46.0,
                    child: RaisedButton(
                      elevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      color: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      onPressed: _selectedInterestModel.length > 0 ? proceedToPostingInterest : null,
                      child: const Text('Continue', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            margin: const EdgeInsets.all(12.0),
          );
        },
        borderRadius: BorderRadius.only(topLeft: const Radius.circular(16.0), topRight: const Radius.circular(16.0)),
        minHeight: 60,
        header: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: const Radius.circular(16.0), topRight: const Radius.circular(16.0)),
          ),
          padding: const EdgeInsets.only(top: 16.0),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.format_align_center,
                color: Colors.black87,
                size: MediaQuery.of(context).size.height * 0.025,
              ),
              const SizedBox(width: 8),
              Text(
                'Choose From Your Interests',
                style: TextStyle(color: Colors.black87, fontSize: MediaQuery.of(context).size.height * 0.02, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              padding: /*lastRequestStatus*/
                  /*? EdgeInsets.symmetric(vertical: 150, horizontal: 16)
                  : */
                  EdgeInsets.symmetric(vertical: 200, horizontal: 16),
              tiltGesturesEnabled: false,
              compassEnabled: false,
              markers: _markers,
              initialCameraPosition: _kLake,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapsController = controller;
                _mapsController.setMapStyle(_mapStyle);
              },
              myLocationEnabled: false,
              zoomControlsEnabled: false,
            ),
          ],
        ),
      ),
    );
  }

  void proceedToPostingInterest() async {
    // implement navigate to code verification screen
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PostNewInterest(
          selectedInterest: _selectedInterestModel,
        ),
      ),
    );
    if (result != null) {
//      _checkMyLastRequestStatus();
      widget.onRequestPosted.call();
    }
  }

  String getImageNameByInterest(String interestID) {
    String a = interestID.contains(',') ? interestID.split(',')[0] : interestID;
    switch (a) {
      case '1':
        return 'assets/markers/m7.png';
      case '2':
        return 'assets/markers/m8.png';
      case '3':
        return 'assets/markers/m3.png';
      case '4':
        return 'assets/markers/m4.png';
      case '5':
        return 'assets/markers/m9.png';
      case '6':
        return 'assets/markers/m1.png';
      case '7':
        return 'assets/markers/m13.png';
      case '8':
        return 'assets/markers/m6.png';
      case '9':
        return 'assets/markers/m12.png';
      case '10':
        return 'assets/markers/m5.png';
      case '11':
        return 'assets/markers/m2.png';
      case '12':
        return 'assets/markers/m14.png';
      case '13':
        return 'assets/markers/m10.png';
      case '14':
        return 'assets/markers/m11.png';
      case '15':
        return 'assets/markers/m15.png';
    }
  }
}
