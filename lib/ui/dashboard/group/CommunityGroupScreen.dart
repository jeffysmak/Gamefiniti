import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/ChatHelper.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/GroupChatMessage.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/GroupChatBubble.dart';
import 'package:indianapp/ui/widgets/ChatImageBubble.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class CommunityGroupScreen extends StatefulWidget {
  Group group;
  AppUser user;

  CommunityGroupScreen(this.group, this.user);

  @override
  _CommunityGroupScreenState createState() => _CommunityGroupScreenState();
}

class _CommunityGroupScreenState extends State<CommunityGroupScreen> {
  TextEditingController _msgController;
  String message = '';

  Group group;
  AppUser user;
  File selectedImageFile;

  void handleImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        selectedImageFile = image; //File(image.path);
      } else {
        selectedImageFile = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.group = widget.group;
    this.user = widget.user;
    _msgController = TextEditingController(
      text: message,
    );
  }

  Widget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TitleText(
        text: '${group.communityGroup.title} Community',
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black87,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
//          Common.CommunityGroupsApis().contains(group.title) ? scoresWidgets() : SizedBox(),
          Expanded(
            child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('CommunityGroups')
                    .doc(group.groupID)
                    .collection('chatting')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data) {
                  if (!data.hasData) {
                    return Container(child: Center(child: CircularProgressIndicator()));
                  }
                  return ListView.builder(
                    itemBuilder: (ctx, index) {
                      DocumentSnapshot docSnap = data.data.docs[index];
                      GroupChatMessage message = GroupChatMessage.fromMap(docSnap.data());
                      return message.type == 0
                          ? GroupChatBubble(
                              fromGroup: true,
                              isMe: isMe(message),
                              time: Common.convertTimestamp(message.timestamp),
                              message: message,
                            )
                          : ImageChatBubble(
                              fromGroup: true,
                              isMe: isMe(message),
                              time: Common.convertTimestamp(message.timestamp),
                              message: message,
                            );
                    },
                    physics: BouncingScrollPhysics(),
                    reverse: true,
                    itemCount: data.data.docs.length,
                  );
                },
              ),
            ),
          ),
          selectedImageFile != null
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      Container(
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 8, right: 8),
                              child: Image.file(
                                selectedImageFile,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ),
                            ),
                            Positioned(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImageFile = null;
                                  });
                                },
                                child: Icon(Icons.cancel, color: Colors.redAccent),
                              ),
                              top: 0,
                              right: 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))
              : SizedBox(),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {
                      handleImagePicker();
                    }),
                SizedBox(width: 8),
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
    );
  }

  Widget scoresWidgets() {
    return Container(
      margin: EdgeInsets.all(6),
      child: Card(
        child: Column(
          children: [
            SizedBox(height: 6),
            TitleText(text: 'Currently Live Matches'),
          ],
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.175,
      width: MediaQuery.of(context).size.width,
    );
  }

  sendMessage() {
    if (selectedImageFile != null || _msgController.text.length > 0) {
      GroupChatMessage message =
          GroupChatMessage(_msgController.text, user.email, user.displayPictureUrl, user.name, DateTime.now().millisecondsSinceEpoch);

      message.type = selectedImageFile == null ? 0 : 1;
      if (selectedImageFile != null) {
        message.file = selectedImageFile;
      }

      ChatHelper.sendCommunityGroupMessage(message, group);
      setState(() {
        _msgController.clear();
        selectedImageFile = null;
      });
    }
  }

  bool isMe(GroupChatMessage message) {
    return message.sender == user.email;
  }
}
