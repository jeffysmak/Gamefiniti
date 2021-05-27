import 'package:indianapp/models/ChatMessage.dart';
import 'package:indianapp/models/User.dart';

class ChatRoomModel {
  List<String> users;
  String chatID;
  AppUser otherUser;
  ChatMessage lastMessage;

  ChatRoomModel(this.users);

  ChatRoomModel.fromMap(Map<String, dynamic> map, {String id, message}) {
    users = [map['users'][0], map['users'][1]];
    if (id != null) {
      chatID = id;
    }
    if (message != null) {
      lastMessage = message;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['users'] = users.toList();
    return map;
  }
}
