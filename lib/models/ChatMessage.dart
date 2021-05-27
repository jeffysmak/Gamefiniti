import 'package:indianapp/models/User.dart';

class ChatMessage {
  String message;
  String sender;
  int timestamp;
  int type;

  ChatMessage(this.message, this.sender, this.timestamp, this.type);

  ChatMessage.fromMap(var map) {
    this.message = map['message'];
    this.sender = map['sender'];
    this.timestamp = map['timestamp'];
    this.type = map['type'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['message'] = message;
    map['sender'] = sender;
    map['timestamp'] = timestamp;
    map['type'] = type;
    return map;
  }
}
