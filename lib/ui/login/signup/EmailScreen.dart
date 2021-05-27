import 'package:flutter/material.dart';
import 'package:indianapp/models/Result.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/login/signup/PhoneScreen.dart';

class EmailScreen extends StatefulWidget {
  AppUser registeringUser;

  EmailScreen(this.registeringUser);

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  AppUser _registeringUser;

  @override
  void initState() {
    super.initState();
    _registeringUser = widget.registeringUser;
    _registeringUser.email = '';
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
                    AuthenticationResult(
                        _registeringUser, AuthenticationResult.RESULT_CANCELED),
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
                          'Enter you email',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Please enter your valid email address here to continue settingup your account',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        TextField(
                          onChanged: (String value) {
                            setState(() {
                              _registeringUser.email = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Your name here',
                          ),
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
                onPressed: isEmailValid()
                    ? () {
//                        Navigator.push(context,
//                            MaterialPageRoute(builder: (ctx) => PhoneScreen(_registeringUser)));
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
          ],
        ),
      ),
    );
  }

  bool isEmailValid() {
    bool a = true;
    if (!_registeringUser.email.contains("@")) {
      a = false;
    }
    if (!_registeringUser.email.contains(".com")) {
      a = false;
    }
    return a;
  }
}
