import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/helpers/authentications/AccountLinking.dart';
import 'package:indianapp/helpers/authentications/EmailPassAuthentication.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/GenderRadio.dart';
import 'package:indianapp/ui/custom/models/RadioItem.dart';
import 'package:indianapp/ui/login/PermissionScreen.dart';

class SignupScreen extends StatefulWidget {
  AppUser signedInUser;

  SignupScreen({this.signedInUser});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // gender widget list
  List<RadioModel> _genderRadioList = List();

  // form key
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // User Model
  AppUser _registeringUser;

  // scaffold key
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // datetime => age controller
  TextEditingController _nameFieldController;
  TextEditingController _emailFieldController;
  TextEditingController _passwordFieldController;
  TextEditingController _phoneFieldController;
  TextEditingController _ageFieldController;

  // phone number field focus node
  FocusNode phoneFieldFocusNode = FocusNode();
  String prefixCode = '+92';

  bool isBusy = false;

  bool passVisible = true;

  @override
  void initState() {
    super.initState();
    _genderRadioList.add(RadioModel(false, 'Male', 'Male', true));
    _genderRadioList.add(RadioModel(false, 'Female', 'Female', true));
    _registeringUser = widget.signedInUser != null ? widget.signedInUser : AppUser.empty();

    _nameFieldController = TextEditingController();
    _emailFieldController = TextEditingController();
    _passwordFieldController = TextEditingController();
    _phoneFieldController = TextEditingController();
    _ageFieldController = TextEditingController();

    if (widget.signedInUser != null) {
      if (_registeringUser.provider == 'Phone') {
        _phoneFieldController.text = _registeringUser.phone;
        prefixCode = '';
      } else {
        _emailFieldController.text = _registeringUser.email;
        phoneFieldFocusNode.addListener(() {
          setState(() {
            if (phoneFieldFocusNode.hasFocus) {
              prefixCode = '+92';
            } else {
              if (_phoneFieldController.text.length == 0) {
                prefixCode = '';
              }
            }
          });
        });
      }
    } else {
      _registeringUser.provider = 'Email/Pass';
    }
  }

  @override
  void dispose() {
    phoneFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: SafeArea(
        child: Form(
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
                      'assets/images/applogo.png',
                      width: 140,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      controller: _nameFieldController,
                      onChanged: (String value) {
                        setState(() {
                          _registeringUser.name = value;
                        });
                      },
                      validator: validatorNameField,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: 'Your Name',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        icon: Icon(
                          Icons.person_outline,
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
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      controller: _emailFieldController,
                      validator: validatorEmailField,
                      onChanged: (String value) {
                        _registeringUser.email = value;
                      },
                      readOnly: (_registeringUser.provider == 'Email/Google' || _registeringUser.provider == 'Email/Facebook'),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: 'Email Address',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        icon: Icon(
                          Icons.alternate_email,
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
                      validator: validatorPasswordField,
                      keyboardType: TextInputType.visiblePassword,
                      autofocus: false,
                      controller: _passwordFieldController,
                      onChanged: (String value) {
                        setState(() {
                          _registeringUser.password = value;
                        });
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: 'Password',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        icon: Icon(
                          Icons.lock_outline,
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
                      validator: validatorPhoneField,
                      controller: _phoneFieldController,
                      keyboardType: TextInputType.phone,
                      autofocus: false,
                      readOnly: _registeringUser.provider == 'Phone',
                      focusNode: phoneFieldFocusNode,
                      onChanged: (String value) {
                        _registeringUser.phone = value;
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: 'Phone',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        prefixText: prefixCode,
                        icon: Icon(Icons.local_phone, color: Colors.black87),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      readOnly: true,
                      validator: validatorAgeField,
                      controller: _ageFieldController,
                      autofocus: false,
                      onTap: handleDateTimeAge,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: 'Your age',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.black87,
                        ),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.merge_type),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 8),
                            child: Row(
                              children: _genderRadioList
                                  .map(
                                    (e) => Expanded(
                                      child: Container(
                                        child: InkWell(
                                          child: GenderRadioWidget(e),
                                          onTap: () {
                                            setState(() {
                                              _genderRadioList.forEach((element) {
                                                element.isSelected = false;
                                              });
                                              e.isSelected = true;
                                              _registeringUser.gender = _genderRadioList.indexOf(e) + 1;
                                            });
                                          },
                                          borderRadius: BorderRadius.all(Radius.circular(32)),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: isBusy ? null : handleRegistration,
                        padding: EdgeInsets.all(12),
                        color: Colors.lightBlueAccent,
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    isBusy ? CircularProgressIndicator() : SizedBox(),
                  ],
                ),
              ),
            ),
          ),
          key: formKey,
        ),
      ),
    );
  }

  String validatorNameField(String value) {
    if (value != null && value.length > 0) {
      if (value.length >= 3) {
        if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
          return 'Not a valid name';
        } else {
          return null;
        }
      } else {
        return 'Not a valid name';
      }
    } else {
      return 'Name couldn\'t be empty';
    }
  }

  String validatorEmailField(String value) {
    if (value != null && value.length > 0) {
      if (value.contains('@')) {
        return null;
      } else {
        return 'Not a valid email address';
      }
    } else {
      return 'Please enter your email address';
    }
  }

  String validatorPasswordField(String value) {
    if (value != null && value.length > 0) {
      if (value.length < 6) {
        return 'Password should be minimum of six characters';
      } else {
        return null;
      }
    } else {
      return 'Password couldn\'t be empty';
    }
  }

  String validatorPhoneField(String value) {
    if (_registeringUser.provider == 'Phone') {
      return null;
    } else {
      if (value != null && value.length > 0) {
        if (value.length != 10) {
          return 'Enter 10 digits phone number';
        } else {
          return null;
        }
      } else {
        return 'Phone number couldn\'t be empty';
      }
    }
  }

  String validatorAgeField(String value) {
    if (value != null && value.length > 0) {
      return null;
    } else {
      return 'Please select your date of birth';
    }
  }

  // handle date time and age
  void handleDateTimeAge() async {
    DateTime dateTime = DateTime.now();
    final DateTime picked =
        await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1990, 8), lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        _ageFieldController.text = Common.getAgeFromDateTime(picked) + ' Years';
        _registeringUser.dateofbirth = picked.millisecondsSinceEpoch;
      });
  }

  // validate the fields
  bool validate() {
    bool a = true;
    if (_nameFieldController.text.length < 3) {
      a = false;
    }

    if (!_emailFieldController.text.contains("@") || !_emailFieldController.text.contains(".com")) {
      a = false;
    }

    if (_passwordFieldController.text.length < 6) {
      a = false;
    }

    if (_registeringUser.provider != 'Phone') {
      if (_registeringUser.phone.length != 10) {
        a = false;
      }
    }
    if (_registeringUser.gender == 0) {
      a = false;
      showSnackBar('Please choose gender', false);
    }
    return a;
  }

  void setBusy(bool busy) {
    setState(() {
      isBusy = busy;
    });
  }

  void showSnackBar(String message, bool success) {
    var errorSnackbar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    _scaffoldKey.currentState.showSnackBar(errorSnackbar);
  }

  // handle registration process
  void handleRegistration() async {
    if (formKey.currentState.validate()) {
      if (validate()) {
        setBusy(true);
        // checking for existing user
        FirestoreHelper.checkUserAlreadyExist(
          _registeringUser,
          (bool existing) async {
            if (existing) {
              showSnackBar('User with email already exists !', false);
              setBusy(false);
            } else {
              if (_registeringUser.provider != 'Phone') {
                _registeringUser.phone = prefixCode + _phoneFieldController.text;
                switch (_registeringUser.provider) {
                  case 'Email/Google':
                  case 'Email/Facebook':
                    // insert to database
                    // AccountLinking.linkAccountWith(_registeringUser);
                    FirestoreHelper.createUserInDatabase(_registeringUser, onCompleteCallbacks, merge: false);
                    break;
                  default:
                    // email password signin
                    // sign up the user with provide as email/pass
                    UserCredential result = await EmailPassAuthentication.signUpWithEmail(user: _registeringUser);
                    if (result != null && result.user != null) {
                      // signup success
                      // insert user to database
                      FirestoreHelper.createUserInDatabase(_registeringUser, onCompleteCallbacks, merge: false);
                    }
                    break;
                }
              } else {
                // link provided email with phone authenticated user !
                // EmailPassAuthentication.linkWithEmalPass(_registeringUser);
                FirestoreHelper.createUserInDatabase(_registeringUser, onCompleteCallbacks, merge: false);
              }
              setBusy(false);
            }
          },
          FirestoreHelper.QUERY_EMAIL,
        );
      }
    }
  }

  void onCompleteCallbacks() {
    continueRegistration();
  }

  void continueRegistration() {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => PermissionScreen(registeringUser: _registeringUser)));
  }
}
