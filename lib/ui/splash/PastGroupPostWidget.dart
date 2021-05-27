import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/GroupPost.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class PastGroupPostWidget extends StatefulWidget {
  GroupPost post;
  Group group;
  AppUser user;

  PastGroupPostWidget(this.group, this.post, this.user);

  @override
  _PastGroupPostWidgetState createState() => _PastGroupPostWidgetState();
}

class _PastGroupPostWidgetState extends State<PastGroupPostWidget> {
  GroupPost post;
  Group group;
  String address = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    post = widget.post;
    group = widget.group;
    getAddressFromCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 100,
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
                    return Text('No members went to play', style: TextStyle(color: Colors.grey));
                  }
                  return Text(snapshot.data.docs.length > 0 ? '${snapshot.data.docs.length} people went' : 'No members went to play',
                      style: TextStyle(color: Colors.grey));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

//  void numberOfPeoplesWent() async {
//    QuerySnapshot snaps = await Firestore.instance
//        .collection(FirestoreHelper.KEY_Groups)
//        .document(group.groupID)
//        .collection('Posts')
//        .document(post.postID)
//        .collection('MembersStatus')
//        .getDocuments();
//    if (snaps != null && snaps.documents != null) {
//      peoplesCount = snaps.documents.length;
//    }
//  }

  void getAddressFromCoordinates() async {
    address = await Common.coordinatesToAddress(post.matchLocation, 1);
    setState(() {});
  }
}
