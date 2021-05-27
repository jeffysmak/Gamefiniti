import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/helpers/authentications/PhoneAuthentication.dart';
import 'package:indianapp/models/Result.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/dashboard/Dashboard.dart';
import 'package:indianapp/ui/login/signup/SignupScreen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneScreen extends StatefulWidget {
  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  AppUser _registeringUser;
  bool isBusy = false;
  String prefix = '+92';

  @override
  void initState() {
    super.initState();
    _registeringUser = AppUser.empty();
    _registeringUser.phone = '';
  }

  void setBusy(bool busy) {
    setState(() {
      isBusy = busy;
    });
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
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(
                    context,
                    AuthenticationResult(_registeringUser, AuthenticationResult.RESULT_CANCELED),
                  );
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter you phone number',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please enter your valid phone number here to continue',
                          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          onChanged: (String value) {
                            setState(() {
                              _registeringUser.phone = value;
                            });
                          },
                          autofocus: true,
                          decoration: InputDecoration(hintText: '1234567890', prefix: Text(prefix)),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: isPhoneNumberValid()
                    ? () async {
                        _registeringUser.phone = prefix + _registeringUser.phone;
                        _registeringUser.provider = 'Phone';
                        setBusy(true);

                        // otp code verification
                        showDialog(
                          context: context,
                          builder: (ctx) => CodeInputDialog(
                            onTimerCompelete: () {},
                            onVerify: (UserCredential result) {
                              // dismiss the opt code dialog
                              Navigator.pop(context);

                              // detect is it new user or existing
                              FirestoreHelper.checkUserAlreadyExist(
                                _registeringUser,
                                (bool exist) async {
                                  setBusy(false);
                                  if (exist) {
                                    // user already signedup with this phone number
                                    // get profile data and navigate to dashboard
                                    AppUser user = await FirestoreHelper.getUserFromData(result.user);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => DashboardScreen(user),
                                        ),
                                        (route) => false);
                                  } else {
                                    // complete signup
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => SignupScreen(
                                          signedInUser: _registeringUser,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                FirestoreHelper.QUERY_PHONE,
                              );
                            },
                            user: _registeringUser,
                          ),
                          barrierDismissible: false,
                        );
                      }
                    : null,
                padding: EdgeInsets.all(12),
                color: Colors.orangeAccent,
                child: Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              width: MediaQuery.of(context).size.width,
            ),
            isBusy ? LinearProgressIndicator() : SizedBox(),
          ],
        ),
      ),
    );
  }

  bool isPhoneNumberValid() {
    bool a = true;
    if (_registeringUser.phone.length != 10) {
      a = false;
    }
    return a;
  }
}

class CodeInputDialog extends StatefulWidget {
  AppUser user;
  Function onTimerCompelete;
  Function onVerify;

  CodeInputDialog({this.user, this.onTimerCompelete, this.onVerify});

  @override
  _CodeInputDialogState createState() => _CodeInputDialogState();
}

class _CodeInputDialogState extends State<CodeInputDialog> {
  AppUser _user;
  Function onTimerCompelete;
  Function onVerify;

  String CODE = '';

  bool isValidating = false;

  String verificationId;
  int forceRecesendingToken;

  Timer _timer;
  int _start = 60;

  void startTimer() {
    const onesecond = const Duration(seconds: 1);
    _start = 60;
    _timer = new Timer.periodic(
      onesecond,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    onTimerCompelete = widget.onTimerCompelete;
    onVerify = widget.onVerify;
    startTimer();
    handlePhoneAuth(false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      content: Wrap(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code sent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'Please enter the code\nthat was sent to ${_user.phone}',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey),
                ),
                SizedBox(
                  height: 16,
                ),
                PinCodeTextField(
                  length: 6,
                  appContext: context,
                  animationType: AnimationType.scale,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                    activeColor: Colors.black45,
                    inactiveColor: Colors.black45,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    selectedColor: Colors.black45,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  enableActiveFill: true,
                  onCompleted: (v) {},
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      CODE = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return false;
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'resend code in\n$_start',
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 34,
                  ),
                  child: FlatButton(
                    onPressed: _timer.isActive
                        ? null
                        : () {
                            // resend code =>
                            handlePhoneAuth(true);
                            startTimer();
                          },
                    child: Text('resend code'),
                  ),
                  width: MediaQuery.of(context).size.width,
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: CODE.length == 6
                        ? () async {
                            setState(() {
                              isValidating = true;
                            });
                            UserCredential res = await PhoneAuthentication.signInWithAuthIdOtp(verificationId, CODE);
                            if (res != null && res.user != null) {
                              if (_timer.isActive || _start < 1) {
                                // stop the time
                                _timer.cancel();
                              }
                              onVerify.call(res);
                            } else {
                              setState(() {
                                isValidating = false;
                              });
                            }
                          }
                        : null,
                    padding: EdgeInsets.all(12),
                    color: Colors.orangeAccent,
                    child: Text(
                      'Verify',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                ),
              ],
            ),
            margin: EdgeInsets.all(20),
          ),
          Container(
            child: isValidating ? LinearProgressIndicator() : SizedBox(),
          ),
        ],
      ),
    );
  }

  // phone auth methods
  void handlePhoneAuth(bool resend) {
    final PhoneCodeSent codeSent = (String vid, [int forceResendingToken]) async {
      verificationId = vid;
      forceRecesendingToken = forceResendingToken;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String vid) {
      this.verificationId = vid;
    };

    final PhoneVerificationFailed verificationFailed = (authException) {
      debugPrint('auth message -> ${authException.message}');
    };

    final PhoneVerificationCompleted verificationCompleted = (AuthCredential auth) async {
      UserCredential result = await PhoneAuthentication.signInWithAuthCredentials(auth);

      if (result != null && result.user != null) {
        // successfuly signedin
        if (_timer.isActive || _start < 1) {
          // stop the time
          _timer.cancel();
        }
        onVerify.call(result);
      } else {
        // invalid credentials
        setState(() {
          isValidating = false;
        });
      }
    };

    // authenticate
    PhoneAuthentication.authenticateUserWithPhone(
        _user, verificationCompleted, verificationFailed, codeSent, codeAutoRetrievalTimeout, resend, forceRecesendingToken);
  }
}
