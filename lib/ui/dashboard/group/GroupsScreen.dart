import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/dashboard/group/CommunityGroupScreen.dart';
import 'package:indianapp/ui/dashboard/group/CreateNewGroup.dart';
import 'package:indianapp/ui/dashboard/group/GroupDetailScreen.dart';
import 'package:indianapp/ui/widgets/CommunityGroupWidget.dart';
import 'package:indianapp/ui/widgets/GroupWidget.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class GroupsScreen extends StatefulWidget {
  AppUser _user;

  GroupsScreen(this._user);

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  AppUser _user;
  List<Group> myGroups = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = widget._user;
    _initializeGroups();
  }

  _initializeGroups() async {
    FirestoreHelper.getMyGroups(
      _user,
      (Group group) {
        setState(() {
          myGroups.add(group);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community Groups',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(_user.email)
                    .collection('Member')
                    .where('community', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data) {
                  if (!data.hasData) {
                    return Container(child: Center(child: CircularProgressIndicator()));
                  }
                  if (data.data.docs.length == 0) {
                    return Container(
                      child: Center(
                        child: TitleText(
                          text: 'Right now you are\nnot a member of any Community',
                          color: Colors.grey,
                          align: TextAlign.center,
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.data.docs.length,
                    itemBuilder: (ctx, position) {
                      String communityGroupID = (data.data.docs[position].data() as Map)['groupID'];
                      return CommunityGroupWidget(communityGroupID);
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Groups',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  InkWell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          'Join Group',
                          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.0155),
                        )),
                    onTap: showJoinGroupSheet,
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: myGroups.length + 1,
                itemBuilder: (ctx, position) {
                  if (position + 1 < myGroups.length + 1) {
                    Group e = myGroups[position];
                    return GestureDetector(
                      child: GroupTile(e),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => GroupDetailScreen(e, _user),
                          ),
                        );
                      },
                    );
                  } else {
                    return Container(
                      margin: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      width: MediaQuery.of(context).size.width - 100,
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: FlatButton(
                        onPressed: () async {
                          bool created = await Navigator.push(context, MaterialPageRoute(builder: (ctx) => CreateNewGroupScreen(_user)));
                          if (created != null) {
                            setState(() {
                              myGroups.clear();
                            });
                            _initializeGroups();
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.grey),
                            Text('Create new group', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showJoinGroupSheet() async {
    int result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return BottomSHeet(myGroups);
        });
    if (result != null) {
      switch (result) {
        case 0:
          setState(() {
            myGroups.clear();
          });
          _initializeGroups();
          break;
        case 1:
          var snackBar = SnackBar(content: Text('No group found'));
          Scaffold.of(context).showSnackBar(snackBar);
          break;
        case 2:
          var snackBar = SnackBar(content: Text('You already joined this group'));
          Scaffold.of(context).showSnackBar(snackBar);
          break;
      }
    }
  }
}

class BottomSHeet extends StatefulWidget {
  List<Group> myGroups;

  BottomSHeet(this.myGroups);

  @override
  _BottomSHeetState createState() => _BottomSHeetState();
}

class _BottomSHeetState extends State<BottomSHeet> {
  // 0 joined
  // 1 not found
  // 2 already joined

  String code = '';
  bool isBusy = false;

  bool isFromMyGroup() {
    return !widget.myGroups.contains(Group.invite(code));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleText(
                    text: 'Have group invite code ?',
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text('Enter invite code and join now.'),
                  Padding(
                    child: TextField(
                      textAlign: TextAlign.center,
                      onChanged: (String value) {
                        code = value;
                      },
                      style: TextStyle(letterSpacing: 6),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'XXXXXXX',
                        hintStyle: TextStyle(
                          letterSpacing: 7,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: MediaQuery.of(context).size.height * 0.015),
                  ),
                  Padding(
                    child: RaisedButton(
                      elevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      color: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: () {
                        if (code.length == 7) {
                          if (isFromMyGroup()) {
                            setState(() {
                              isBusy = true;
                            });
                            FirestoreHelper.findGroupByRefID(
                              Common.signedInUser,
                              code,
                              () {
                                // on not exist
                                Navigator.pop(context, 1);
                              },
                              () {
                                // on joined
                                Navigator.pop(context, 0);
                              },
                            );
                          } else {
                            Navigator.pop(context, 2);
                          }
                        }
                      },
                      child: Text(
                        'JOIN',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: MediaQuery.of(context).size.height * 0.015),
                  ),
                ],
              ),
            ),
            isBusy ? LinearProgressIndicator() : SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
