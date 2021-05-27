import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/Notification.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/ChoosingInterestScreen.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/profile/AboutApp.dart';
import 'package:indianapp/ui/dashboard/profile/Help.dart';
import 'package:indianapp/ui/dashboard/profile/Settings.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:location/location.dart';

class CreateNewGroupScreen extends StatefulWidget {
  AppUser _user;

  CreateNewGroupScreen(this._user);

  @override
  _CreateNewGroupScreenState createState() => _CreateNewGroupScreenState();
}

class _CreateNewGroupScreenState extends State<CreateNewGroupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AppUser signedInUser;
  Group newGroup = Group.empty();
  List<InterestModel> interests;
  File ImageFile;
  InterestModel choosenModel;
  TextEditingController interestFieldController = TextEditingController();
  bool isBusy = false;
  LocationData locationData;
  String address;

  @override
  void initState() {
    super.initState();
    signedInUser = widget._user;
    _initIntrerests();
    initCurrentLocation();
  }

  void setBusy(bool busy) {
    setState(() {
      this.isBusy = busy;
    });
  }

  _initIntrerests() async {
    interests = await FirestoreHelper.getInterest();
    setState(() {});
  }

  void initCurrentLocation() async {
    locationData = await Common.getUserCurrentLocation();
    if (locationData != null) {
      address = await Common.coordinatesToAddress(GeoPoint(locationData.latitude, locationData.longitude), 1);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.black87,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'Start a new group',
                style: TextStyle(color: Colors.black87, fontSize: MediaQuery.of(context).size.height * 0.02),
              ),
            ),
            // body
            Expanded(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.25,
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: ImageFile != null
                                        ? Image.file(
                                            ImageFile,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        children: [
                                          CircleImageInkWell(
                                            image: NetworkImage(signedInUser.displayPictureUrl),
                                            onPressed: null,
                                            size: MediaQuery.of(context).size.height * 0.1,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              child: Center(
                                                child: Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                        alignment: Alignment.center,
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      TitleText(
                                        text: 'Start a new khel buddy group',
                                        fontSize: MediaQuery.of(context).size.height * 0.018,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'Find nearby people and play together',
                                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.016),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 4),
                                      child: RaisedButton(
                                        onPressed: () {
                                          _handleImagePicker();
                                        },
                                        color: Colors.white.withOpacity(0.5),
                                        elevation: 0,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                              size: 14,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              'Photo',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            child: TitleText(
                              text: 'Name your group',
                              fontSize: MediaQuery.of(context).size.height * 0.019,
                            ),
                            padding: EdgeInsets.only(top: 16, left: 16),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8, left: 20, right: 20),
                            child: TextFormField(
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.6), width: 0.5),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange[400],
                                  ),
                                ),
                              ),
                              validator: _nameFieldValidator,
                              onSaved: (String value) {
                                this.newGroup.title = value;
                              },
                            ),
                          ),
                          Padding(
                            child: TitleText(
                              text: ' Write a description about your group',
                              fontSize: MediaQuery.of(context).size.height * 0.018,
                            ),
                            padding: EdgeInsets.only(top: 16, left: 16),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
                            child: TextFormField(
                              validator: _descriptionFieldValidator,
                              onSaved: (String value) {
                                this.newGroup.description = value;
                              },
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.6), width: 0.5),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange[400],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            child: TitleText(
                              text: 'Location',
                              fontSize: MediaQuery.of(context).size.height * 0.019,
                            ),
                            padding: EdgeInsets.only(top: 16, left: 16),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8, left: 20, right: 20),
                            child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.location_on),
                                    border: InputBorder.none,
                                    hintText: address != null ? address : 'Fetching location...')),
                          ),
                          Divider(),
                          Padding(
                            child: TitleText(
                              text: 'Interests',
                              fontSize: MediaQuery.of(context).size.height * 0.019,
                            ),
                            padding: EdgeInsets.only(top: 16, left: 16),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8, left: 20, right: 20),
                            child: TextFormField(
                              readOnly: true,
                              validator: _InterestValidator,
                              controller: interestFieldController,
                              onTap: () async {
                                var modelReturned = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => ChoosingInterestScreen(
                                      maxSelection: 1,
                                      interests: interests,
                                    ),
                                  ),
                                );

                                if (modelReturned != null) {
                                  choosenModel = modelReturned;
                                  setState(() {
                                    interestFieldController.text = choosenModel.title;
                                  });
                                }
                              },
                              decoration: InputDecoration(hintText: 'Select few topics', border: InputBorder.none),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // button continue
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(12),
              child: RaisedButton(
                onPressed: isBusy
                    ? null
                    : () {
                        if (formKey.currentState.validate() && ImageFile != null) {
                          formKey.currentState.save();
                          setBusy(true);
                          newGroup.interestID = choosenModel.interestID;
                          FirestoreHelper.CreateGroup(signedInUser, newGroup, ImageFile, () {
                            Navigator.pop(context, true);
                          });
                        }
                      },
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                color: Colors.orange,
                child: Text('Continue', style: TextStyle(color: Colors.white)),
              ),
            ),
            isBusy ? LinearProgressIndicator() : SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  String _nameFieldValidator(String value) {
    if (value != null && value.length > 0) {
      if (value.length <= 3) {
        return 'Not a valid name';
      } else {
        return null;
      }
    } else {
      return 'Name could not be empty';
    }
  }

  String _descriptionFieldValidator(String value) {
    if (value != null && value.length > 0) {
      if (value.length <= 3) {
        return '';
      } else {
        return null;
      }
    } else {
      return 'Description couldn\'t be empty';
    }
  }

  String _InterestValidator(String value) {
    if (value != null && value.length > 0) {
      if (value.length <= 3) {
        return '';
      } else {
        return null;
      }
    } else {
      return 'Description couldn\'t be empty';
    }
  }

  void _handleImagePicker() async {
    ImageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }
}
