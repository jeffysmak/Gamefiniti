import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirebaseStorageHelper.dart';
import 'package:indianapp/models/ChatMessage.dart';
import 'package:indianapp/models/ChatRoomModel.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/GroupChatMessage.dart';
import 'package:indianapp/models/User.dart';
import 'FirestoreHelper.dart';

class ChatHelper {
  static final String KEYCHATROOM = 'ChatRooms';
  static final String KEY_USER_CHAT = 'Chats';
  static final String KEY_MESSAGES = 'Messages';

  static Future<ChatRoomModel> checkRoomAlreadyExist(AppUser user, AppUser otherUser) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snaps = await firestore.collection(KEYCHATROOM).where('users', arrayContains: otherUser.email).get();
    if (snaps.docs != null && snaps.docs.length > 0) {
      for (DocumentSnapshot snap in snaps.docs) {
        if ((snap.data() as Map)['users'].toString().contains(user.email) && (snap.data() as Map)['users'].toString().contains(otherUser.email)) {
          ChatRoomModel model = ChatRoomModel.fromMap(snap.data(), id: snap.id);
          return model;
        }
      }
    }
    return null;
  }

  static void createChatRoom(ChatRoomModel model, Function completeCallback, Function errorCallback) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionReference = firestore.collection(KEYCHATROOM);
    DocumentReference chatRoomRef = await collectionReference.add(model.toMap());
    if (chatRoomRef != null) {
      completeCallback.call(chatRoomRef.id);
    } else {
      errorCallback.call();
    }
  }

  static void createEngagement(List<String> users, String roomID) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionReference = firestore.collection(FirestoreHelper.KEY_USERS);
    users.forEach((String element) {
      DocumentReference userRef = collectionReference.doc(element);
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      userRef.collection(KEY_USER_CHAT).doc(roomID).set({'roomID': roomID, 'timestamp': timestamp});
//      userRef.collection(KEY_USER_CHAT).add({'roomID': roomID, 'timestamp': timestamp});
    });
  }

  static void sendMessage(ChatMessage message, ChatRoomModel model) async {
    FirebaseFirestore.instance.collection(KEYCHATROOM).doc(model.chatID).collection(KEY_MESSAGES).add(message.toMap());
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    FirebaseFirestore.instance
        .collection(FirestoreHelper.KEY_USERS)
        .doc(model.otherUser.email)
        .collection(KEY_USER_CHAT)
        .doc(model.chatID)
        .update({'timestamp': timestamp});
    FirebaseFirestore.instance
        .collection(FirestoreHelper.KEY_USERS)
        .doc(Common.signedInUser.email)
        .collection(KEY_USER_CHAT)
        .doc(model.chatID)
        .update({'timestamp': timestamp});
  }

  static void sendGroupMessage(GroupChatMessage message, Group model) async {
    FirebaseFirestore.instance.collection(FirestoreHelper.KEY_Groups).doc(model.groupID).collection('Chatting').add(message.toMap());
  }

  static void sendCommunityGroupMessage(GroupChatMessage message, Group model) async {
    DocumentReference msgRef =
        await FirebaseFirestore.instance.collection('CommunityGroups').doc(model.groupID).collection('chatting').add(message.toMap());

    if (message.type == 1) {
      String image = await FirebaseStorageHelper.uploadGroupMessageImage(message.file);
      message.messageImage = image;
      FirebaseFirestore.instance.collection('CommunityGroups').doc(model.groupID).collection('chatting').doc(msgRef.id).update(message.toMap());
    }
  }
}
