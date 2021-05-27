import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indianapp/helpers/FirebaseStorageHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/login/ChooseInterest.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:location/location.dart';

import 'SelfieScreen.dart';

class DocumentScreen extends StatefulWidget {
  AppUser registeringUser;

  DocumentScreen({this.registeringUser});

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  AppUser registeringUser;
  File documentCaptured;
  bool isBusy = false;
  bool clickOnce = false;

  @override
  void initState() {
    super.initState();
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
                        text: 'Upload Your ID or Proof',
                        fontSize: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Container(
                        child: documentCaptured == null
                            ? Image.asset(
                                'assets/images/idproof.png',
                                height: MediaQuery.of(context).size.height * 0.2,
                              )
                            : Image.file(
                                File(documentCaptured.path),
                                height: MediaQuery.of(context).size.height * 0.2,
                              ),
                        margin: EdgeInsets.symmetric(vertical: 32),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        'We need to have any Govt. issue\nid or document to verify your identity',
                        style: TextStyle(color: Colors.black87, fontSize: MediaQuery.of(context).size.height * 0.02),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              documentCaptured != null
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: RaisedButton(
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        onPressed: () {
                          capturePhoto();
                        },
                        color: Colors.grey[200],
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('RETRY', style: TextStyle(color: Colors.black87)),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    )
                  : SizedBox(),
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
                    documentCaptured != null
                        ? !isBusy
                            ? navigate()
                            : null
                        : capturePhoto();
                  },
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      documentCaptured != null ? 'CONTINUE' : 'CAPTURE PHOTO',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              isBusy ? LinearProgressIndicator() : SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  void setBusy(bool busy) {
    setState(() {
      isBusy = busy;
    });
  }

  void navigate() {
    setBusy(true);
    FirebaseStorageHelper.uploadUserDocumentToStorage(
      registeringUser,
      File(documentCaptured.path),
      (String url) {
        if (url != null) {
          registeringUser.documentPath = url;
          // update image to database
          FirestoreHelper.createUserInDatabase(registeringUser, () {
            setBusy(false);
            // updated image url to database

            // move to dashboard
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => ChooseInterests(registeringUser)));
          }, merge: true);
        }
      },
      () {
        // on error callback
        setState(() {
          clickOnce = false;
        });
        setBusy(false);
      },
    );
  }

  void capturePhoto() async {
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        documentCaptured = file;
      });
    }
  }
}
