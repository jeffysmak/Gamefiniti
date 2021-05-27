import 'package:flutter/material.dart';
import 'package:indianapp/models/Result.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/login/signup/EmailScreen.dart';

class NameScreen extends StatefulWidget {
  @override
  _NameScreenState createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  AppUser _registeringUser = AppUser.empty();

  @override
  void initState() {
    super.initState();
    _registeringUser.name = '';
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
                          'Enter you name',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Please enter your correct name here to continue creating your account',
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
                              _registeringUser.name = value;
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
                onPressed: _registeringUser.name.length >= 3
                    ? () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) =>
                              EmailScreen(_registeringUser)));
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
}