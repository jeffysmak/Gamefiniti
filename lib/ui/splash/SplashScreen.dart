import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/prefsHelper.dart';
import 'package:indianapp/ui/dashboard/Dashboard.dart';
import 'package:indianapp/ui/intro/OnboardingScreen.dart';
import 'package:indianapp/ui/login/LoginScreen.dart';
import 'package:indianapp/ui/login/signup/SignupScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isBusy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedOpacity(
                  // If the widget is visible, animate to 0.0 (invisible).
                  // If the widget is hidden, animate to 1.0 (fully visible).
                  opacity: 1.0,
                  duration: Duration(milliseconds: 1000),
                  // The green box must be a child of the AnimatedOpacity widget.
                  child: Container(
                    width: 200.0,
                    height: 200.0,
                    child: Image.asset('assets/images/applogo.png'),
                  ),
                ),
              ),
            ),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _setBusy(bool busy) {
    setState(() {
      this.isBusy = busy;
    });
  }

  void setupMessaging(BuildContext context) {
    FirebaseMessaging().configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage -> $message');
        return;
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume -> $message');
        Common.navigateToView(context, message);
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch -> $message');
        Common.navigateToView(context, message);
        return;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      () async {
        PrefsHelper().getFirstTimeRunValue().then((int value) {
          if (value == 0) {
            // proceed next to login/dashboard
            proceed();
          } else {
            // proceed to intro
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => OnboardingScreen()));
          }
        });
      },
    );
  }

  void proceed() async {
    User firebaseUser = FirebaseAuth.instance.currentUser;
    _setBusy(true);
    if (firebaseUser != null) {
      // registering device token
      AppUser user = await FirestoreHelper.getUserFromData(firebaseUser);
      if (user.isUserCompeleted()) {
        _setBusy(false);
        if (Platform.isIOS) {
          FirebaseMessaging().onIosSettingsRegistered.listen((event) {
            setupMessaging(context);
          });
          FirebaseMessaging().requestNotificationPermissions(IosNotificationSettings());
        } else {
          if (Platform.isAndroid) {
            setupMessaging(context);
          }
        }
        FirestoreHelper.registerDeviceToken(context, user);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => DashboardScreen(user)));
      } else {
        _setBusy(false);
        FirestoreHelper.clearData(user);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => SignupScreen(signedInUser: user)));
      }
    } else {
      _setBusy(false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => LoginScreen()));
    }
  }
}
