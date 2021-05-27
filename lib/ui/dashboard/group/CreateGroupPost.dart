import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/GroupPost.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/dashboard/group/MatchLcationPicker.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class CreateNewGroupPost extends StatefulWidget {
  AppUser signedInUser;
  Group group;

  CreateNewGroupPost({this.signedInUser, this.group});

  @override
  _CreateNewGroupPostState createState() => _CreateNewGroupPostState();
}

class _CreateNewGroupPostState extends State<CreateNewGroupPost> {
  AppUser signedInUser;
  Group group;
  final GlobalKey<FormState> formKey = GlobalKey();
  GroupPost post = GroupPost.empty();
  TextEditingController fieldDateTimeController = TextEditingController();
  TextEditingController fieldLocationController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    signedInUser = widget.signedInUser;
    group = widget.group;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: ListView(
                  children: [
                    Padding(
                      child: TitleText(
                        text: ' Write a match title',
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                      ),
                      padding: EdgeInsets.only(top: 16, left: 16),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        validator: _matchTitleValidator,
                        onSaved: (String value) {
                          this.post.title = value;
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
                        text: ' When your match will be held',
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                      ),
                      padding: EdgeInsets.only(top: 16, left: 16),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        validator: _matchDateTimePicker,
                        readOnly: true,
                        onTap: handleDateTimePicker,
                        controller: fieldDateTimeController,
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
                        text: 'Set Match Location',
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
                      padding: EdgeInsets.only(top: 16, left: 16),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8, left: 20, right: 20),
                      child: TextFormField(
                        readOnly: true,
                        controller: fieldLocationController,
                        validator: _locationValidator,
                        onTap: () async {
                          LocationData result =
                              await Navigator.push(context, MaterialPageRoute(builder: (ctx) => MatchLocationpicker()));
                          if (result != null) {
                            setState(() {
                              fieldLocationController.text = result.latitude.toString();
                              post.matchLocation = GeoPoint(result.latitude, result.longitude);
                              setAddressFromLatLon();
                            });
                          }
                        },
                        decoration: InputDecoration(
                            icon: Icon(Icons.location_on), border: InputBorder.none, hintText: 'Pick Match Location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(12),
              height: 46.0,
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
                  if (formKey.currentState.validate()) {
                    formKey.currentState.save();
                    createPost(post);
                  }
                },
                child: Text(
                  'SUBMIT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createPost(GroupPost post) async {
    post.createdBy = signedInUser.email;
    post.timestamp = DateTime.now().millisecondsSinceEpoch;
    FirestoreHelper.createGroupPost(group, post, () {
      Navigator.pop(context, true);
    });
  }

  Widget _appBar() {
    return AppBar(
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
    );
  }

  void setAddressFromLatLon() async {
    fieldLocationController.text = await Common.coordinatesToAddress(post.matchLocation, 0);
    setState(() {});
  }

  void handleDateTimePicker() async {
    final dateTime = await _selecteDateTime(context);
    if (dateTime != null) {
      final timeSelected = await selectTime(context);
      if (timeSelected != null) {
        DateTime dt = DateTime(dateTime.year, dateTime.month, dateTime.day, timeSelected.hour, timeSelected.minute);
        post.when = dt.millisecondsSinceEpoch;
        setState(() {
          fieldDateTimeController.text = DateFormat('hh:mm a - MMM dd, yyyy').format(dt);
        });
      }
    }
  }

  Future<TimeOfDay> selectTime(BuildContext context) => showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

  Future<DateTime> _selecteDateTime(BuildContext context) => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

  String _matchTitleValidator(String value) {
    if (value != null && value.length > 3) {
      return null;
    } else {
      return 'Enter a valid name';
    }
  }

  String _matchDateTimePicker(String value) {
    if (value != null && value.length > 3 && post.when != null) {
      return null;
    } else {
      return 'Please select your match date and time when it was played';
    }
  }

  String _locationValidator(String value) {
    if (value != null && post.matchLocation != null) {
      return null;
    } else {
      return 'Please select your match location';
    }
  }
}
