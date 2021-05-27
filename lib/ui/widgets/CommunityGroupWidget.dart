import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/CommunityGroup.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/ui/dashboard/group/CommunityGroupScreen.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class CommunityGroupWidget extends StatefulWidget {
  String groupID;

  CommunityGroupWidget(this.groupID);

  @override
  _CommunityGroupWidgetState createState() => _CommunityGroupWidgetState();
}

class _CommunityGroupWidgetState extends State<CommunityGroupWidget> {
  String groupID;
  Group communityGroup;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.groupID = widget.groupID;
    initCommunityGroup();
  }

  void initCommunityGroup() async {
    DocumentSnapshot group = await FirebaseFirestore.instance.collection(FirestoreHelper.KEY_CommunityGroups).doc(groupID).get();
    communityGroup = Group.communityFromMap(group.data(), group.id, true, CommunityGroup((group.data() as Map)['title'].toString()));
    setState(() {});
  }

  bool isBusy() {
    return communityGroup == null;
  }

  @override
  Widget build(BuildContext context) {
    return isBusy()
        ? Container(
            child: Center(child: CircularProgressIndicator()),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            width: MediaQuery.of(context).size.width - 100,
          )
        : GestureDetector(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
              width: MediaQuery.of(context).size.width - 100,
              child: ClipRRect(
                child: Stack(
                  children: [
                    Positioned(
                      child: Container(
                        child: Image.network(
                          communityGroup.imageURL,
                          fit: BoxFit.cover,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.black45,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    Align(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0), Colors.black.withOpacity(0.5), Colors.black.withOpacity(0.9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/vip.png', height: 40),
                            SizedBox(width: 8),
                            Expanded(
                                child: FittedBox(
                              alignment: Alignment.center,
                              fit: BoxFit.fitWidth,
                              child: TitleText(
                                text: '${communityGroup.title} Community',
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.height * 0.0185,
                              ),
                            )),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => CommunityGroupScreen(communityGroup, Common.signedInUser)));
            },
          );
  }
}
