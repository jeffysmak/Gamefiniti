import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/ChatHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/ChatRoomModel.dart';
import 'package:indianapp/models/Notification.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/dashboard/chat/InboxChatScreen.dart';
import 'package:indianapp/ui/dashboard/chat/NotificationScreens.dart';

class InboxListScreen extends StatefulWidget {
  AppUser _user;

  InboxListScreen(this._user);

  @override
  _InboxListScreenState createState() => _InboxListScreenState();
}

class _InboxListScreenState extends State<InboxListScreen> {
  List<NotificationModel> notifications = List();
  AppUser _user;
  List<ChatRoomModel> myChatsList = List();

  bool _isFetching = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = widget._user;
    _getnotifications();
    _initChatRooms();
  }

  void _getnotifications() async {
    FirestoreHelper.getNotificationList(
      _user,
      (NotificationModel notification) {
        setState(() {
          notifications.add(notification);
        });
      },
      newest: true,
    );
  }

  void _initChatRooms() async {
    FirestoreHelper.getMyChats(
      (ChatRoomModel model) async {
        if (model != null) {
          AppUser otherUser = await FirestoreHelper.getUserDataForRequest(_getOtherUserId(model.users));
          model.otherUser = otherUser;
          myChatsList.add(model);
//          myChatsList.insert(0, model);
          setState(() {});
        }
      },
      () {
        setState(() {
          _isFetching = false;
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
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inbox',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(_user.email)
                        .collection('notifications')
                        .where('seen', isEqualTo: false)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data) {
                      if (!data.hasData) {
                        return IconButton(
                          icon: Icon(Icons.notifications_none),
                          onPressed: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (ctx) => NotificationScreen(_user, notifications)));
                          },
                        );
                      }
                      if (data.data.docs.length > 0) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications_none),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (ctx) => NotificationScreen(_user, notifications)));
                              },
                            ),
                            Positioned(
                                child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                                top: 12,
                                right: 12),
                          ],
                        );
                      }
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_none),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (ctx) => NotificationScreen(_user, notifications)));
                            },
                          ),
                          Container(width: 12, height: 12),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: myChatsList.length > 0
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (ctx, position) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white60),
                          child: ListTile(
                            leading: CircleImageInkWell(
                              onPressed: () {
                                print('onPressed');
                              },
                              size: 50,
                              image: NetworkImage(myChatsList[position].otherUser.displayPictureUrl),
                              splashColor: Colors.white24,
                            ),
                            title: Text(
                              myChatsList[position].otherUser.name,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: MediaQuery.of(context).size.height * 0.02),
                            ),
                            subtitle: Text(myChatsList[position].lastMessage.message),
                            isThreeLine: true,
                            trailing: Text(
                              Common.convertTimestamp(myChatsList[position].lastMessage.timestamp),
                              style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.01),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => InboxChatScreen(
                                    chatRoomModel: myChatsList[position],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      itemCount: myChatsList.length,
                      scrollDirection: Axis.vertical,
                    )
                  : _isFetching
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(100),
                              child: Image.asset('assets/images/emptyinbox.png'),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOtherUserId(List<String> users) {
    if (users[0].toString() == _user.email) {
      return users[1];
    } else {
      return users[0];
    }
  }
}
