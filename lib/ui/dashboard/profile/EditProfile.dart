import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirebaseStorageHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/dashboard/profile/ViewPicture.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  AppUser user;

  EditProfileScreen(this.user);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  AppUser user;

  // new user display picture
  File ImageFile;

  // input fields controller
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.user = widget.user;

    _nameController.text = user.name;
    _locationAddressController.text = user.address;
  }

  // App bar
  Widget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black87,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Edit Profile',
        style: TextStyle(color: Colors.black87),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.check,
            color: Colors.black87,
          ),
          onPressed: () {
            // update the profile
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // Display Picture
  Widget _displayPicture() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: ImageFile != null
          ? Container(
              width: MediaQuery.of(context).size.height * 0.175,
              height: MediaQuery.of(context).size.height * 0.175,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : CircleImageInkWell(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  builder: (ctx) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      height: MediaQuery.of(context).size.height * 0.11,
                      child: Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                              onPressed: () {
                                // navigates to view photo screen
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (ctx) => ViewPictureScreen(user.displayPictureUrl)));
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text('View Picture'),
                            ),
                          ),
                          VerticalDivider(),
                          Expanded(
                            child: FlatButton(
                              onPressed: () {
                                // navigates to capture new photo screen
                                Navigator.pop(context);
                                _handleImagePicker();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text('Change Picture'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              size: MediaQuery.of(context).size.height * 0.175,
              image: NetworkImage(user.displayPictureUrl),
              splashColor: Colors.white24,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Center(
                    child: Column(
                      children: [
                        _displayPicture(),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            dense: true,
                            onTap: _showNameDialog,
                            leading: Icon(Icons.person_outline),
                            title: Text(
                              'Name',
                            ),
                            subtitle: Text(
                              user.name,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Divider(),
//                         ?
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: Icon(Icons.alternate_email),
                            title: Text('Email'),
                            dense: true,
//                            trailing: Text(
//                                (user.provider == 'Email/Pass' || user.provider == 'Phone')
//                                    ? 'not verified'
//                                    : 'verified',
//                                style: GoogleFonts.abel(
//                                    fontSize: 14,
//                                    fontWeight: FontWeight.w800,
//                                    color: Colors.grey,
//                                    fontStyle: FontStyle.italic)),
                            subtitle: Text(
                              user.email,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Divider(),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.phone),
                            title: Text('Phone'),
//                            trailing: Text((user.provider == 'Phone') ? 'verified' : 'not verified',
//                                style: GoogleFonts.abel(
//                                    fontSize: 14,
//                                    fontWeight: FontWeight.w800,
//                                    color: Colors.grey,
//                                    fontStyle: FontStyle.italic)),
                            subtitle: Text(user.phone, style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        Divider(),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.location_on),
                            title: Text('Address'),
                            subtitle: Text(
                              user.address,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Divider(),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.date_range),
                            title: Text('Age'),
                            subtitle: Text(
                              '${Common.getAgeFromDateTime(DateTime.fromMillisecondsSinceEpoch(user.dateofbirth))} years',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Divider(thickness: 4, color: Colors.black12.withOpacity(0.1)),
//                        Container(
//                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                          child: Column(
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: [
//                              Text(
//                                'Privacy',
//                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//                              ),
//                              SizedBox(
//                                height: 16,
//                              ),
//                              ListTile(
//                                title: Text('Show groups on profile'),
//                                trailing: Switch(
//                                  value: true,
//                                  onChanged: (bool value) {},
//                                ),
//                              ),
//                              ListTile(
//                                title: Text('Show interests on profile'),
//                                trailing: Switch(
//                                  value: true,
//                                  onChanged: (bool value) {},
//                                ),
//                              ),
//                            ],
//                          ),
//                        ),
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

  void _showNameDialog() {
    TextEditingController c = TextEditingController();
    c.text = user.name;
    var dialog = AlertDialog(
      title: Text('Update your name'),
      content: TextField(
        decoration: new InputDecoration(hintText: "Update Info"),
        controller: c,
      ),
      actions: [
        new FlatButton(
          child: new Text("Close"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        new FlatButton(
          child: new Text("Update"),
          onPressed: () {
            setState(() {
              user.name = c.text;
            });
            FirestoreHelper.updateName(user, () {
              Navigator.pop(context);
            });
          },
        ),
      ],
    );
    // showDialog(context: context, child: dialog);
  }

  void _handleImagePicker() async {
    ImageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (ImageFile != null) {
      setState(() {});
      uploadPicture();
    }
  }

  void uploadPicture() async {
    FirebaseStorageHelper.uploadUserSelfieToStorage(
      user,
      File(ImageFile.path),
      (String URL) {
        // upload success
        user.displayPictureUrl = URL;
        FirestoreHelper.updateName(
          user,
          () {
            setState(() {
              ImageFile = null;
              Common.signedInUser = user;
            });
          },
        );
      },
      () {},
    );
  }
}
