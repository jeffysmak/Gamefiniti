import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/profile/AboutApp.dart';
import 'package:indianapp/ui/dashboard/profile/Help.dart';
import 'package:indianapp/ui/dashboard/profile/EditProfile.dart';
import 'package:indianapp/ui/dashboard/profile/PrivacyPolicy.dart';
import 'package:indianapp/ui/dashboard/profile/Settings.dart';
import 'package:indianapp/ui/login/LoginScreen.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class UserProfileScreen extends StatefulWidget {
  AppUser signedInUser;

  UserProfileScreen(this.signedInUser);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  AppUser signedInUser;
  List<InterestModel> interestModel = List();

  @override
  void initState() {
    super.initState();
    signedInUser = widget.signedInUser;
    _initInterest();
  }

  void _initInterest() async {
    FirestoreHelper.getMyInterests(signedInUser, (model) {
      setState(() {
        interestModel.add(model);
      });
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
              leading: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Text(
                'Profile',
                style: TextStyle(color: Colors.black87),
              ),
              actions: [
//                PopupMenuButton<int>(
//                  onSelected: (int selectedValue) {
//                    _handleAppBarActionsMenuItemClick(selectedValue);
//                  },
//                  icon: Icon(
//                    Icons.more_vert,
//                    color: Colors.black87,
//                  ),
//                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
//                    const PopupMenuItem<int>(
//                      value: 0,
//                      child: Text('Profile Settings'),
//                    ),
//                    const PopupMenuItem<int>(
//                      value: 1,
//                      child: Text('Help'),
//                    ),
//                    const PopupMenuItem<int>(
//                      value: 2,
//                      child: Text('About App'),
//                    ),
//                    const PopupMenuItem<int>(
//                      value: 3,
//                      child: Text('Logout'),
//                    ),
//                  ],
//                ),
              ],
            ),
            // body
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleImageInkWell(
                                onPressed: null,
                                size: 100,
                                image: NetworkImage(signedInUser.displayPictureUrl),
                                splashColor: Colors.white24,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      signedInUser.name,
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.0275),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(signedInUser.city,
                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: MediaQuery.of(context).size.height * 0.02)),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 40,
                                      child: RaisedButton(
                                        elevation: 0,
                                        highlightElevation: 0,
                                        hoverElevation: 0,
                                        focusElevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (ctx) => EditProfileScreen(signedInUser)));
                                        },
                                        padding: const EdgeInsets.all(12),
                                        color: Colors.orange,
                                        child: Text('EDIT PROFILE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey[100], thickness: 4),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: const Text('Interests', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: interestModel.length > 0
                              ? Wrap(
                                  children: interestModel
                                      .map(
                                        (InterestModel model) => Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: ChoiceChip(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            selected: false,
                                            label: Text(model.title),
                                            backgroundColor: Colors.orange.withOpacity(0.6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                              side: BorderSide(width: 1, color: Colors.orange),
                                            ),
                                            onSelected: (bool value) {
                                              print("selected");
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                        Divider(color: Colors.grey[100], thickness: 4),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: TitleText(
                                  text: 'Help & Support',
                                  fontSize: MediaQuery.of(context).size.height * 0.0235,
                                ),
                                subtitle: Text(
                                  'Help center & legal support',
                                  style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.0175),
                                ),
                                leading: Icon(Icons.help_outline),
                                onTap: () {
                                  _handleAppBarActionsMenuItemClick(1);
                                },
                              ),
                              ListTile(
                                title: TitleText(
                                  text: 'Privacy Policy',
                                  fontSize: MediaQuery.of(context).size.height * 0.0235,
                                ),
                                subtitle: Text(
                                  'Our privacy policy & terms of use',
                                  style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.0175),
                                ),
                                leading: Icon(Icons.security),
                                onTap: () {
                                  _handleAppBarActionsMenuItemClick(2);
                                },
                              ),
                              ListTile(
                                title: TitleText(
                                  text: 'Logout',
                                  fontSize: MediaQuery.of(context).size.height * 0.0235,
                                ),
                                leading: Icon(Icons.exit_to_app),
                                onTap: () {
                                  _handleAppBarActionsMenuItemClick(3);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAppBarActionsMenuItemClick(int position) {
    switch (position) {
      case 0:
        // profile settings
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => ProfileSettings()));
        break;
      case 1:
        // navigate to help screen
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => HelpScreen()));
        break;
      case 2:
        // navigate to about app screen
//        Navigator.push(context, MaterialPageRoute(builder: (ctx) => AboutAppScreen()));
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => PrivacyPolicy()));
        break;
      case 3:
        // Logout the user
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Logout'),
            content: Padding(
              padding: EdgeInsets.all(12),
              child: Text('Are you sure you want to signout from Khel Buddy ?'),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut().whenComplete(() {
                      if (Common.signedInUser.provider == Common.GoogleSignIn) {
                        GoogleSignIn(signInOption: SignInOption.standard).signOut().whenComplete(() {
                          Common.signedInUser = null;
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) => LoginScreen()), (route) => false);
                        });
                      } else {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) => LoginScreen()), (route) => false);
                      }
                    });
                  },
                  child: Text('Logout')),
              FlatButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ],
          ),
        );
        break;
    }
  }
}
