import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/CommunityGroup.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/Notification.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/Swapping.dart';
import 'package:indianapp/ui/dashboard/explore/DetailedProfileCard.dart';
import 'package:indianapp/ui/dashboard/group/CommunityGroupScreen.dart';
import 'package:indianapp/ui/dashboard/profile/AboutApp.dart';
import 'package:indianapp/ui/dashboard/profile/Help.dart';
import 'package:indianapp/ui/dashboard/profile/EditProfile.dart';
import 'package:indianapp/ui/dashboard/profile/Settings.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class NotificationScreen extends StatefulWidget {
  AppUser signedInUser;
  List<NotificationModel> _notifications;

  NotificationScreen(this.signedInUser, this._notifications);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  AppUser signedInUser;
  List<NotificationModel> _notifications = List();

  @override
  void initState() {
    super.initState();
    signedInUser = widget.signedInUser;
    initNotifications();
  }

  void initNotifications() async {
    FirestoreHelper.getNotificationList(signedInUser, (NotificationModel model) {
      setState(() {
        _notifications.add(model);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text('Notifications', style: TextStyle(color: Colors.black87)),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(signedInUser.email)
                    .collection('notifications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data) {
                  if (!data.hasData) {
                    return Container(child: Center(child: CircularProgressIndicator()));
                  }
                  return ListView.builder(
                    itemCount: data.data.docs.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int position) {
                      NotificationModel notification = NotificationModel.fromMap(
                        data.data.docs[position].data(),
                        dID: data.data.docs[position].id,
                      );
                      return Card(
                        margin: EdgeInsets.all(16),
                        elevation: 6,
                        child: ListTile(
                          title: TitleText(
                            text: notification.message,
                            fontWeight: notification.seen ? FontWeight.normal : FontWeight.w800,
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            color: notification.seen ? Colors.grey : Colors.green,
                          ),
                          onTap: () async {
                            if (notification.ENUM == NotificationModel.NotificationType1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => SwapItem(
                                    null,
                                    currentSigninUser: signedInUser,
                                    fromNotification: true,
                                    model: notification,
                                  ),
                                ),
                              );
                            } else {
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(signedInUser.email)
                                  .collection('notifications')
                                  .doc(notification.docID)
                                  .set({'seen': true});
                              DocumentSnapshot snap = await FirebaseFirestore.instance.collection('CommunityGroups').doc(notification.groupID).get();
                              Group grp = Group.communityFromMap(snap.data(), snap.id, true, CommunityGroup.fromMap(snap.data()));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => CommunityGroupScreen(grp, signedInUser),
                                ),
                              );
                            }
                          },
                          leading: Icon(Icons.sim_card_alert),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // body
//            Expanded(
//              child: ListView(
//                scrollDirection: Axis.vertical,
//                physics: BouncingScrollPhysics(),
//                shrinkWrap: true,
//                children: _notifications
//                    .map(
//                      (e) => Container(
//                        margin: EdgeInsets.symmetric(vertical: 8),
//                        child: GestureDetector(
//                          child: Center(
//                            child: Text(e.docID + " " + e.seen.toString()),
//                          ),
//                          onTap: () {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                builder: (ctx) => DetailedProfileCard(
//                                  null,
//                                  fromNotification: true,
//                                  model: e,
//                                ),
//                              ),
//                            );
//                          },
//                        ),
//                      ),
//                    )
//                    .toList(),
//              ),
//            ),
          ],
        ),
      ),
    );
  }
}
