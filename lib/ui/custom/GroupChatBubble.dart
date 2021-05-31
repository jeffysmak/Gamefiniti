import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/models/GroupChatMessage.dart';

class GroupChatBubble extends StatelessWidget {
  final bool isMe;
  final GroupChatMessage message;
  final String time;
  final bool fromGroup;

  GroupChatBubble({this.message, this.isMe, this.time, this.fromGroup});

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: isMe ? EdgeInsets.only(left: 40) : EdgeInsets.only(right: 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isMe
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: CircleImageInkWell(
                    size: 40,
                    image: NetworkImage(message.senderImage),
                    onPressed: () {},
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    isMe
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              message.senderName,
                              style: TextStyle(color: Colors.grey, fontSize: 12.0),
                            ),
                          ),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.grey.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                        borderRadius: isMe
                            ? BorderRadius.only(
                                topRight: Radius.circular(25),
                                topLeft: Radius.circular(25),
                                bottomRight: Radius.circular(0),
                                bottomLeft: Radius.circular(25),
                              )
                            : BorderRadius.only(
                                topRight: Radius.circular(25),
                                topLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                                bottomLeft: Radius.circular(0),
                              ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(time, style: TextStyle(color: Colors.grey, fontSize: 12.0)),
                                SizedBox(height: 8),
                                Text(message.message, style: TextStyle(color: Colors.black87, fontSize: 16.0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
