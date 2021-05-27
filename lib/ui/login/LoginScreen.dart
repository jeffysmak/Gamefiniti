import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/helpers/authentications/EmailPassAuthentication.dart';
import 'package:indianapp/helpers/authentications/FacebookAuthentication.dart';
import 'package:indianapp/helpers/authentications/GoogleAuthentication.dart';
import 'package:indianapp/models/Result.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/dashboard/Dashboard.dart';
import 'package:indianapp/ui/login/signup/PhoneScreen.dart';
import 'package:indianapp/ui/login/signup/SignupScreen.dart';
import 'package:location/location.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'PermissionScreen.dart';
import 'signup/NameScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  AppUser user = AppUser.empty();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            return Form(child: webMaxWidth(context));
          } else if (constraints.maxWidth >= 880 && constraints.maxWidth < 1200) {
            return Form(child: webMidWidth(context));
          } else {
            return Form(child: webMinWidth(context));
          }
        },
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 50),
              margin: EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/khelbuddy-logo.png',
                      width: 140,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 6,
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      onChanged: (String value) {
                        this.user.email = value;
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: 'Email',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.black87),
                        ),
                        icon: Icon(
                          Icons.account_circle,
                          color: Colors.black87,
                        ),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      autofocus: false,
                      obscureText: _obscureText,
                      onChanged: (String value) {
                        this.user.password = value;
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.black87),
                        ),
                        icon: Icon(
                          Icons.lock,
                          color: Colors.black87,
                        ),
                        hintStyle: TextStyle(color: Colors.black87),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            semanticLabel: _obscureText ? 'show password' : 'hide password',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () {
                          // handle signin
                          handleSignIn();
                        },
                        padding: EdgeInsets.all(12),
                        color: Colors.lightBlueAccent,
                        child: Text(
                          'Log In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: Colors.black38,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('OR'),
                          ),
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () async {
                              // authenticate use with google account
                              UserCredential authResult = await GoogleAuthentication.authenticateWithGoogleAccount(
                                user,
                                (String cause) {
                                  showSnackBar(cause, false);
                                },
                              );

                              if (authResult != null && authResult.user != null) {
                                // logged in/registered successfule
                                user.email = authResult.user.email;
                                // check is it existing user or not,
                                FirestoreHelper.checkUserAlreadyExist(
                                  user,
                                  (bool exist) async {
                                    if (exist) {
                                      AppUser u = await FirestoreHelper.getUserFromData(authResult.user);
                                      // navigate the user to dashboard
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => DashboardScreen(u),
                                          ),
                                              (route) => false);
                                    } else {
                                      // navigate the user to signup
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => SignupScreen(signedInUser: user),
                                        ),
                                      );
                                    }
                                  },
                                  FirestoreHelper.QUERY_EMAIL,
                                );
                              }
                            },
                            padding: EdgeInsets.all(12),
                            color: Colors.white,
                            child: Image.asset(
                              'assets/images/google-icon.png',
                            ),
                          ),
                          width: 50,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Container(
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () async {
                              UserCredential result = await FacebookAuthentication.AuthenticateUserWithFacebook(
                                user,
                                (String msg) {
                                  showSnackBar(msg, false);
                                },
                              );
                              if (result != null && result.user != null) {
                                user.email = result.user.email;
                                FirestoreHelper.checkUserAlreadyExist(
                                  user,
                                  (bool exist) async {
                                    if (exist) {
                                      AppUser u = await FirestoreHelper.getUserFromData(result.user);
                                      // navigate the user to dashboard
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => DashboardScreen(u),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => SignupScreen(signedInUser: user),
                                        ),
                                      );
                                    }
                                  },
                                  FirestoreHelper.QUERY_EMAIL,
                                );
                              }
                            },
                            padding: EdgeInsets.all(12),
                            color: Color(0xff3b5998),
                            child: Image.asset(
                              'assets/images/facebook-icon.png',
                            ),
                          ),
                          width: 50,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Container(
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => PhoneScreen()));
                            },
                            padding: EdgeInsets.all(12),
                            color: Colors.orangeAccent,
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                          ),
                          width: 50,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'don\'t have an account ?',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          FlatButton(
                            onPressed: () async {
                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => SignupScreen()));
                            },
                            child: Text('Create One'),
                          ),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _navigate() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (ctx) => DashboardScreen(user),
        ),
        (route) => false);
  }

  void handleSignIn() async {
    if (user.email == null || !user.email.contains("@")) {
      return;
    }
    if (user.password == null || user.password.length < 6) {
      return;
    }
    // now signin
    UserCredential authResult = await EmailPassAuthentication.loginWithEmail(
      // invoked on error
      () {
        showSnackBar('Incorrect email or password !', false);
      },
      email: user.email,
      password: user.password,
    );
    if (authResult != null && authResult.user != null) {
      // user logged in success.
      user = await FirestoreHelper.getUserFromData(authResult.user);
//      showSnackBar('Successfuly Logged in', true);
      _navigate();
    }
  }

  void showSnackBar(String message, bool success) {
    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Something went wrong'),
            content: Text('$message'),
          );
        },
      );
    } else {
      var errorSnackbar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      );
      _scaffoldKey.currentState.showSnackBar(errorSnackbar);
    }
  }

  Widget webMaxWidth(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            margin: EdgeInsets.all(16.0),
            child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/khelbuddy-logo.png',
                          width: 140,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 6,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          autofocus: false,
                          onChanged: (String value) {
                            this.user.email = value;
                          },
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black87),
                            hintText: 'Email',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              borderSide: BorderSide(color: Colors.black87),
                            ),
                            icon: Icon(
                              Icons.account_circle,
                              color: Colors.black87,
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          autofocus: false,
                          obscureText: _obscureText,
                          onChanged: (String value) {
                            this.user.password = value;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              borderSide: BorderSide(color: Colors.black87),
                            ),
                            icon: Icon(
                              Icons.lock,
                              color: Colors.black87,
                            ),
                            hintStyle: TextStyle(color: Colors.black87),
                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                semanticLabel: _obscureText ? 'show password' : 'hide password',
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () {
                              // handle signin
                              handleSignIn();
                            },
                            padding: EdgeInsets.all(12),
                            color: Colors.orange,
                            child: Text(
                              'Log In',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  height: 1,
                                  color: Colors.black38,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text('OR'),
                              ),
                              Expanded(
                                child: Divider(
                                  height: 1,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                onPressed: () async {
                                  // authenticate use with google account
                                  UserCredential authResult = await GoogleAuthentication.authenticateWithGoogleAccount(
                                    user,
                                    (String cause) {
                                      showSnackBar(cause, false);
                                    },
                                  );

                                  if (authResult != null && authResult.user != null) {
                                    // logged in/registered successfule
                                    user.email = authResult.user.email;
                                    // check is it existing user or not,
                                    FirestoreHelper.checkUserAlreadyExist(
                                      user,
                                      (bool exist) async {
                                        if (exist) {
                                          AppUser u = await FirestoreHelper.getUserFromData(authResult.user);
                                          // navigate the user to dashboard
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => DashboardScreen(u),
                                              ),
                                              (route) => false);
                                        } else {
                                          // navigate the user to signup
                                          if (kIsWeb) {
                                            showSnackBar(
                                                'You need to register your selft from KhelBuddy Mobile app.', false);
                                            FirebaseAuth.instance.signOut();
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => SignupScreen(signedInUser: user),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      FirestoreHelper.QUERY_EMAIL,
                                    );
                                  }
                                },
                                padding: EdgeInsets.all(12),
                                color: Colors.white,
                                child: Image.asset(
                                  'assets/images/google-icon.png',
                                ),
                              ),
                              width: 50,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Container(
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                onPressed: () async {
                                  if (kIsWeb) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: Text('Something went wrong'),
                                          content: Text(
                                              'Currently signin with facebook not available, if you already registered with us try to loggin in with your email and password.'),
                                        );
                                      },
                                    );
                                  } else {
                                    UserCredential result = await FacebookAuthentication.AuthenticateUserWithFacebook(
                                      user,
                                      (String msg) {
                                        showSnackBar(msg, false);
                                      },
                                    );
                                    if (result != null && result.user != null) {
                                      user.email = result.user.email;
                                      FirestoreHelper.checkUserAlreadyExist(
                                        user,
                                        (bool exist) async {
                                          if (exist) {
                                            AppUser u = await FirestoreHelper.getUserFromData(result.user);
                                            // navigate the user to dashboard
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (ctx) => DashboardScreen(u),
                                                ),
                                                (route) => false);
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => SignupScreen(signedInUser: user),
                                              ),
                                            );
                                          }
                                        },
                                        FirestoreHelper.QUERY_EMAIL,
                                      );
                                    }
                                  }
                                },
                                padding: EdgeInsets.all(12),
                                color: Color(0xff3b5998),
                                child: Image.asset(
                                  'assets/images/facebook-icon.png',
                                ),
                              ),
                              width: 50,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Container(
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => PhoneScreen()));
                                },
                                padding: EdgeInsets.all(12),
                                color: Colors.orangeAccent,
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                              width: 50,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                elevation: 8),
          ),
        ],
      ),
    );
  }

  Widget webMidWidth(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            margin: EdgeInsets.all(16.0),
            child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/khelbuddy-logo.png', width: 140),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 6,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          autofocus: false,
                          onChanged: (String value) {
                            this.user.email = value;
                          },
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black87),
                            hintText: 'Email',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              borderSide: BorderSide(color: Colors.black87),
                            ),
                            icon: Icon(
                              Icons.account_circle,
                              color: Colors.black87,
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          autofocus: false,
                          obscureText: _obscureText,
                          onChanged: (String value) {
                            this.user.password = value;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              borderSide: BorderSide(color: Colors.black87),
                            ),
                            icon: Icon(
                              Icons.lock,
                              color: Colors.black87,
                            ),
                            hintStyle: TextStyle(color: Colors.black87),
                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                semanticLabel: _obscureText ? 'show password' : 'hide password',
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () async {
                              // handle signin
                              handleSignIn();
                            },
                            padding: EdgeInsets.all(12),
                            color: Colors.orange,
                            child: Text(
                              'Log In',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(height: 1, color: Colors.black38),
                              ),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('OR')),
                              Expanded(
                                child: Divider(height: 1, color: Colors.black38),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                onPressed: () async {
                                  // authenticate use with google account
                                  UserCredential authResult = await GoogleAuthentication.authenticateWithGoogleAccount(
                                    user,
                                    (String cause) {
                                      showSnackBar(cause, false);
                                    },
                                  );

                                  if (authResult != null && authResult.user != null) {
                                    // logged in/registered successfule
                                    user.email = authResult.user.email;
                                    // check is it existing user or not,
                                    FirestoreHelper.checkUserAlreadyExist(
                                      user,
                                      (bool exist) async {
                                        if (exist) {
                                          AppUser u = await FirestoreHelper.getUserFromData(authResult.user);
                                          // navigate the user to dashboard
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => DashboardScreen(u),
                                              ),
                                                  (route) => false);
                                        } else {
                                          // navigate the user to signup
                                          if (kIsWeb) {
                                            showSnackBar(
                                                'You need to register your selft from KhelBuddy Mobile app.', false);
                                            FirebaseAuth.instance.signOut();
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => SignupScreen(signedInUser: user),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      FirestoreHelper.QUERY_EMAIL,
                                    );
                                  }
                                },
                                padding: EdgeInsets.all(12),
                                color: Colors.white,
                                child: Image.asset(
                                  'assets/images/google-icon.png',
                                ),
                              ),
                              width: 50,
                            ),
                            SizedBox(width: 16),
                            Container(
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                onPressed: () async {
                                  if (kIsWeb) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: Text('Something went wrong'),
                                          content: Text(
                                              'Currently signin with facebook not available, if you already registered with us try to loggin in with your email and password.'),
                                        );
                                      },
                                    );
                                  } else {
                                    UserCredential result = await FacebookAuthentication.AuthenticateUserWithFacebook(
                                      user,
                                      (String msg) {
                                        showSnackBar(msg, false);
                                      },
                                    );
                                    if (result != null && result.user != null) {
                                      user.email = result.user.email;
                                      FirestoreHelper.checkUserAlreadyExist(
                                        user,
                                        (bool exist) async {
                                          if (exist) {
                                            AppUser u = await FirestoreHelper.getUserFromData(result.user);
                                            // navigate the user to dashboard
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (ctx) => DashboardScreen(u),
                                                ),
                                                    (route) => false);
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => SignupScreen(signedInUser: user),
                                              ),
                                            );
                                          }
                                        },
                                        FirestoreHelper.QUERY_EMAIL,
                                      );
                                    }
                                  }
                                },
                                padding: EdgeInsets.all(12),
                                color: Color(0xff3b5998),
                                child: Image.asset(
                                  'assets/images/facebook-icon.png',
                                ),
                              ),
                              width: 50,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Container(
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => PhoneScreen()));
                                },
                                padding: EdgeInsets.all(12),
                                color: Colors.orangeAccent,
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                              width: 50,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                elevation: 8),
          ),
        ],
      ),
    );
  }

  Widget webMinWidth(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: EdgeInsets.all(16.0),
        child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/khelbuddy-logo.png',
                      width: 140,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 6,
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      onChanged: (String value) {
                        this.user.email = value;
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: 'Email',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.black87),
                        ),
                        icon: Icon(
                          Icons.account_circle,
                          color: Colors.black87,
                        ),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      autofocus: false,
                      obscureText: _obscureText,
                      onChanged: (String value) {
                        this.user.password = value;
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.black87),
                        ),
                        icon: Icon(
                          Icons.lock,
                          color: Colors.black87,
                        ),
                        hintStyle: TextStyle(color: Colors.black87),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            semanticLabel: _obscureText ? 'show password' : 'hide password',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          // handle signin
                          handleSignIn();
                        },
                        padding: EdgeInsets.all(12),
                        color: Colors.orange,
                        child: Text(
                          'Log In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: Colors.black38,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('OR'),
                          ),
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () async {
                              // authenticate use with google account
                              UserCredential authResult = await GoogleAuthentication.authenticateWithGoogleAccount(
                                user,
                                (String cause) {
                                  showSnackBar(cause, false);
                                },
                              );

                              if (authResult != null && authResult.user != null) {
                                // logged in/registered successfule
                                user.email = authResult.user.email;
                                // check is it existing user or not,
                                FirestoreHelper.checkUserAlreadyExist(
                                  user,
                                  (bool exist) async {
                                    if (exist) {
                                      AppUser u = await FirestoreHelper.getUserFromData(authResult.user);
                                      // navigate the user to dashboard
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => DashboardScreen(u),
                                          ),
                                              (route) => false);
                                    } else {
                                      // navigate the user to signup
                                      if (kIsWeb) {
                                        showSnackBar(
                                            'You need to register your selft from KhelBuddy Mobile app.', false);
                                        FirebaseAuth.instance.signOut();
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => SignupScreen(signedInUser: user),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  FirestoreHelper.QUERY_EMAIL,
                                );
                              }
                            },
                            padding: EdgeInsets.all(12),
                            color: Colors.white,
                            child: Image.asset(
                              'assets/images/google-icon.png',
                            ),
                          ),
                          width: 50,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Container(
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () async {
                              if (kIsWeb) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext ctx) {
                                    return AlertDialog(
                                      title: Text('Something went wrong'),
                                      content: Text(
                                          'Currently signin with facebook not available, if you already registered with us try to loggin in with your email and password.'),
                                    );
                                  },
                                );
                              } else {
                                UserCredential result = await FacebookAuthentication.AuthenticateUserWithFacebook(
                                  user,
                                  (String msg) {
                                    showSnackBar(msg, false);
                                  },
                                );
                                if (result != null && result.user != null) {
                                  user.email = result.user.email;
                                  FirestoreHelper.checkUserAlreadyExist(
                                    user,
                                    (bool exist) async {
                                      if (exist) {
                                        AppUser u = await FirestoreHelper.getUserFromData(result.user);
                                        // navigate the user to dashboard
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (ctx) => DashboardScreen(u),
                                            ),
                                                (route) => false);
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => SignupScreen(signedInUser: user),
                                          ),
                                        );
                                      }
                                    },
                                    FirestoreHelper.QUERY_EMAIL,
                                  );
                                }
                              }
                            },
                            padding: EdgeInsets.all(12),
                            color: Color(0xff3b5998),
                            child: Image.asset(
                              'assets/images/facebook-icon.png',
                            ),
                          ),
                          width: 50,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Container(
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => PhoneScreen()));
                            },
                            padding: EdgeInsets.all(12),
                            color: Colors.orangeAccent,
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                          ),
                          width: 50,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
            ),
            elevation: 8),
      ),
    );
  }
}
