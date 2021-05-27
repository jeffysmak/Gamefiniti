import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/ChatHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/GroupChatMessage.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/Bubble.dart';
import 'package:indianapp/ui/custom/GroupChatBubble.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class GroupDiscussionScreen extends StatefulWidget {
  Group group;
  AppUser user;

  GroupDiscussionScreen(this.group, this.user);

  @override
  _GroupDiscussionScreenState createState() => _GroupDiscussionScreenState();
}

class _GroupDiscussionScreenState extends State<GroupDiscussionScreen> {
  List<String> messages = ['fine and you', 'How are you', 'Hi', 'Hello'];
  TextEditingController _msgController;
  String message = '';

  Group group;
  AppUser user;

  @override
  void initState() {
    super.initState();
    this.group = widget.group;
    this.user = widget.user;
    _msgController = TextEditingController(
      text: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Text(
                group.title + ' Chat',
                style: TextStyle(color: Colors.black87),
              ),
//              actions: [
//                PopupMenuButton<int>(
//                  onSelected: (int selectedValue) {
////                    _handleAppBarActionsMenuItemClick(selectedValue);
//                  },
//                  icon: Icon(
//                    Icons.more_vert,
//                    color: Colors.black87,
//                  ),
//                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
//                    const PopupMenuItem<int>(
//                      value: 0,
//                      child: Text('Archive Conversation'),
//                    ),
//                    const PopupMenuItem<int>(
//                      value: 1,
//                      child: Text('Block'),
//                    ),
//                    const PopupMenuItem<int>(
//                      value: 2,
//                      child: Text('Report'),
//                    ),
//                  ],
//                ),
//              ],
            ),
            // chat messages list
            Expanded(
              child: Container(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(FirestoreHelper.KEY_Groups)
                      .doc(group.groupID)
                      .collection('Chatting')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(child: Center(child: CircularProgressIndicator()));
                    }
                    return ListView.builder(
                      itemBuilder: (ctx, index) {
                        DocumentSnapshot docSnap = snapshot.data.docs[index];
                        GroupChatMessage message = GroupChatMessage.fromMap(docSnap.data());
                        return GroupChatBubble(
                          fromGroup: true,
                          isMe: isMe(message),
                          time: Common.convertTimestamp(message.timestamp),
                          message: message,
                        );
                      },
                      physics: BouncingScrollPhysics(),
                      reverse: true,
                      itemCount: snapshot.data.docs.length,
                    );
                  },
                ),
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.scatter_plot), onPressed: () {}),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (String msg) {
                        setState(() {
                          message = msg;
                        });
                      },
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'type message here..',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isMe(GroupChatMessage message) {
    return message.sender == user.email;
  }

  sendMessage() {
    if (_msgController.text.length > 0) {
      GroupChatMessage message =
          GroupChatMessage(_msgController.text, user.email, user.displayPictureUrl, user.name, DateTime.now().millisecondsSinceEpoch);

      ChatHelper.sendGroupMessage(message, group);
      setState(() {
        _msgController.clear();
      });
    }
  }
}
