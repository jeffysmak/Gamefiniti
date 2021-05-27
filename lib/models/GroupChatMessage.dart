import 'dart:io';

class GroupChatMessage {
  String message;
  String sender;
  String senderImage;
  String senderName;
  int timestamp;

  int type;
  String messageImage;
  File file;

  GroupChatMessage(this.message, this.sender, this.senderImage, this.senderName, this.timestamp);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['message'] = message;
    map['sender'] = sender;
    map['senderImage'] = senderImage;
    map['senderName'] = senderName;
    map['timestamp'] = timestamp;
    if (type != null) {
      map['type'] = type;
    }
    if (messageImage != null) {
      map['messageImage'] = messageImage;
    }
    return map;
  }

  GroupChatMessage.fromMap(var map) {
    this.message = map['message'];
    this.sender = map['sender'];
    this.senderImage = map['senderImage'];
    this.senderName = map['senderName'];
    this.timestamp = map['timestamp'];
    if (map['type'] != null) {
      this.type = map['type'];
    }
    if (map['messageImage'] != null) {
      this.messageImage = map['messageImage'];
    }
  }
}
