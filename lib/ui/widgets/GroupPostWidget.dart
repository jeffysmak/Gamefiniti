import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/GroupPost.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class GroupPostWidget extends StatefulWidget {
  GroupPost post;
  Group group;
  AppUser user;

  GroupPostWidget(this.group, this.post, this.user);

  @override
  _GroupPostWidgetState createState() => _GroupPostWidgetState();
}

class _GroupPostWidgetState extends State<GroupPostWidget> {
  GroupPost post;
  Group group;
  bool myStatus = false;
  String address = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    post = widget.post;
    group = widget.group;
    initMyStatus();
    getAddressFromCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText(text: '${post.title} Match', fontSize: MediaQuery.of(context).size.height * 0.02),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(Common.convertTimestamp(post.when), style: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.height * 0.0175)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                '$address',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: MediaQuery.of(context).size.height * 0.0175,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(FirestoreHelper.KEY_Groups)
                    .doc(group.groupID)
                    .collection('Posts')
                    .doc(post.postID)
                    .collection('MembersStatus')
                    .where('going', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData || snapshot.data.docs.length == 0) {
                    return SizedBox();
                  }
                  debugPrint('${snapshot.data.docs.length}');
                  return Text('${snapshot.data.docs.length} people going', style: TextStyle(color: Colors.grey));
                },
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        showSheetInterestView();
      },
    );
  }

  void getAddressFromCoordinates() async {
    address = await Common.coordinatesToAddress(post.matchLocation, 0);
    setState(() {});
  }

  void initMyStatus() async {
    DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection(FirestoreHelper.KEY_Groups)
        .doc(group.groupID)
        .collection('Posts')
        .doc(post.postID)
        .collection('MembersStatus')
        .doc(widget.user.email)
        .get();

    if (docSnap.exists && docSnap != null && docSnap.data != null) {
      myStatus = (docSnap.data() as Map)['going'];
      setState(() {});
    }
  }

  void showSheetInterestView() {
    showBottomSheet(
      context: context,
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey.withOpacity(0.1),
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          children: [
            TitleText(
              text: 'Whats\'s your mood for ${post.title}',
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            DropdownButton<bool>(
              isExpanded: true,
              items: [
                DropdownMenuItem(child: TitleText(text: 'Nopes', color: Colors.red[400]), value: false),
                DropdownMenuItem(child: TitleText(text: 'Going', color: Colors.green), value: true),
              ],
              onChanged: (bool newValue) {
                setState(() {
                  myStatus = newValue;
                  setStatusToFirebase(newValue);
                });
              },
              value: myStatus,
            ),
          ],
        ),
      ),
    );
  }

  void setStatusToFirebase(bool value) {
    FirebaseFirestore.instance
        .collection(FirestoreHelper.KEY_Groups)
        .doc(group.groupID)
        .collection('Posts')
        .doc(post.postID)
        .collection('MembersStatus')
        .doc(widget.user.email)
        .set({'going': value}).whenComplete(() => Navigator.pop(context));
  }
}
