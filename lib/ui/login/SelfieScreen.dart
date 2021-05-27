import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/helpers/FirebaseStorageHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/dashboard/Dashboard.dart';
import 'package:indianapp/ui/login/Camera.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/ui/login/ChooseInterest.dart';
import 'package:indianapp/ui/login/IdCardPhoto.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class SelfieScreen extends StatefulWidget {
  AppUser registeringUser;

  SelfieScreen(this.registeringUser);

  @override
  _SelfieScreenState createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  List<CameraDescription> cameras;
  String imagePath;
  bool isBusy = false;
  bool clickOnce = false;

  AppUser registeringUser;

  @override
  void initState() {
    super.initState();
    getCamerasDescription();
    if (widget.registeringUser != null) {
      registeringUser = widget.registeringUser;
    }
  }

  getCamerasDescription() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() {
//    controller?.dispose();
    super.dispose();
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
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: imagePath == null
                    ? Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TitleText(
                                    text: 'Access Your Camera',
                                    fontSize: MediaQuery.of(context).size.height * 0.03,
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 32),
                                    child: CircleImageInkWell(
                                        image: AssetImage('assets/images/selfie.png'),
                                        onPressed: null,
                                        size: MediaQuery.of(context).size.height * 0.3),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    'Please allow us to access\ndevice camera, to capture your selfie.',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: MediaQuery.of(context).size.height * 0.02,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TitleText(
                                    text: 'Access Your Camera',
                                    fontSize: MediaQuery.of(context).size.height * 0.03,
                                  ),
                                  SizedBox(
                                    height: 32,
                                  ),
                                  UsersSelfieWidget(
                                    imagePath: imagePath,
                                    cameras: cameras,
                                    onImageReclick: handleImageClick,
                                  ),
                                  SizedBox(
                                    height: 32,
                                  ),
                                  Text(
                                    'Your picture will be shown as\nyour profile picture.',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: MediaQuery.of(context).size.height * 0.02,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                  onPressed: clickOnce
                      ? null
                      : () async {
                          if (imagePath != null) {
                            // set user profile
                            setBusy(true);
                            handleUserProfileImageUpload();
                            return;
                          }
                          imagePath = null;
                          var path = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => CameraPreviewScreen(
                                cameras: cameras,
                              ),
                            ),
                          );
                          if (path != null) {
                            setState(() {
                              imagePath = path;
                            });
                          }
                        },
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      imagePath == null ? 'CAPTURE SELFIE' : 'CONTINUE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              isBusy ? LinearProgressIndicator() : SizedBox(),
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

  void handleImageClick(var path) {
    if (path != null) {
      setState(() {
        imagePath = null;
        imagePath = path;
      });
    }
  }

  void handleUserProfileImageUpload() {
    setState(() {
      clickOnce = true;
    });
    FirebaseStorageHelper.uploadUserSelfieToStorage(
      registeringUser,
      File(imagePath),
      (String url) {
        if (url != null) {
          registeringUser.displayPictureUrl = url;
          // update image to database
          FirestoreHelper.createUserInDatabase(registeringUser, () {
            setBusy(false);
            // updated image url to database

            // move to dashboard
//            Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => ChooseInterests(registeringUser)));
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (ctx) => DocumentScreen(registeringUser: registeringUser)));
//            Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => DashboardScreen(registeringUser)));
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
}

class UsersSelfieWidget extends StatefulWidget {
  String imagePath;
  List<CameraDescription> cameras;
  Function onImageReclick;

  UsersSelfieWidget({this.imagePath, this.cameras, this.onImageReclick});

  @override
  _UsersSelfieWidgetState createState() => _UsersSelfieWidgetState();
}

class _UsersSelfieWidgetState extends State<UsersSelfieWidget> {
  String imagePath;
  List<CameraDescription> cameras;
  Function onImageReclick;

  @override
  void initState() {
    super.initState();
    this.imagePath = widget.imagePath;
    cameras = widget.cameras;
    onImageReclick = widget.onImageReclick;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleImageInkWell(
            onPressed: () async {
              var path = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => CameraPreviewScreen(
                    cameras: cameras,
                  ),
                ),
              );
              if (path != null) {
                onImageReclick.call(path);
              }
            },
            size: 200,
            image: FileImage(File(imagePath)),
            splashColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
