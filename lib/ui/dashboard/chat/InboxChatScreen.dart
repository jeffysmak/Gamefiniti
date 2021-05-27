import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/ChatHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/ChatMessage.dart';
import 'package:indianapp/models/ChatRoomModel.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/Bubble.dart';

class InboxChatScreen extends StatefulWidget {
  ChatRoomModel chatRoomModel;
  bool newConversation;

  InboxChatScreen({this.chatRoomModel, this.newConversation});

  @override
  _InboxChatScreenState createState() => _InboxChatScreenState();
}

class _InboxChatScreenState extends State<InboxChatScreen> {
  TextEditingController _msgController;
  ChatRoomModel _chatRoomModel;

  AppUser otherUser;

  @override
  void initState() {
    super.initState();
    _chatRoomModel = widget.chatRoomModel;
    _msgController = TextEditingController();
    if (widget.newConversation != null) {
      initOtherUser();
    } else {
      otherUser = _chatRoomModel.otherUser;
    }
  }

  void initOtherUser() async {
    DocumentSnapshot user = await FirebaseFirestore.instance.collection(FirestoreHelper.KEY_USERS).doc(_chatRoomModel.users[1]).get();
    otherUser = AppUser.fromMap(user.data());
    setState(() {});
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
                otherUser != null ? otherUser.name : '',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            // chat messages list
            Expanded(
              child: Container(
                child: _chatRoomModel.chatID != null
                    ? StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(ChatHelper.KEYCHATROOM)
                            .doc(_chatRoomModel.chatID)
                            .collection(ChatHelper.KEY_MESSAGES)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          return ListView.builder(
                            itemBuilder: (ctx, index) {
                              DocumentSnapshot docSnap = snapshot.data.docs[index];
                              ChatMessage message = ChatMessage.fromMap(docSnap.data);
                              return Bubble(
                                fromGroup: false,
                                isMe: isMe(message),
                                time: Common.convertTimestamp(message.timestamp),
                                message: message.message,
                              );
                            },
                            physics: BouncingScrollPhysics(),
                            reverse: true,
                            itemCount: snapshot.data.docs.length,
                          );
                        },
                      )
                    : Container(),
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
//                  IconButton(icon: Icon(Icons.location_on), onPressed: () {}),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: TextField(
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

  bool isMe(ChatMessage message) {
    return message.sender == Common.signedInUser.email;
  }

  sendMessage() {
    if (_msgController.text.length > 0) {
      if (widget.newConversation != null) {
        ChatHelper.createChatRoom(
          _chatRoomModel,
          (String roomId) {
            // create engagement with chat room id
            ChatHelper.createEngagement([_chatRoomModel.users[0], otherUser.email], roomId);
            _chatRoomModel.chatID = roomId;
            _chatRoomModel.otherUser = otherUser;

            ChatHelper.sendMessage(
                ChatMessage('${_msgController.text}', _chatRoomModel.users[0], DateTime.now().millisecondsSinceEpoch, 1), _chatRoomModel);

//            setState(() {
            _msgController.clear();
//            });
          },
          () {
            // some error
          },
        );
      } else {
        ChatMessage message = ChatMessage(_msgController.text, Common.signedInUser.email, DateTime.now().millisecondsSinceEpoch, 1);
        ChatHelper.sendMessage(message, _chatRoomModel);
//        setState(() {
        _msgController.clear();
//        });
      }
    }
  }
}
