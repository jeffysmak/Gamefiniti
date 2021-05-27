class NotificationModel {
  static final String NotificationType1 = 'requestResult';
  static final String NotificationType2 = 'groupJoin';

  String requestID;
  String toUser;
  bool seen;
  String docID;
  String groupID;
  String chatID;
  String ENUM;
  String message;
  int timestamp;

  NotificationModel(this.requestID, this.toUser, this.seen, {this.docID});

  NotificationModel.fromMap(Map<String, dynamic> map, {String dID}) {
    this.ENUM = map['enum'];
    this.seen = map['seen'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    if (ENUM == NotificationType1) {
      this.requestID = map['requestID'];
      this.toUser = map['toUser'];
    }
    if (ENUM == NotificationType2) {
      this.groupID = map['groupID'];
    }
    if (dID != null) {
      this.docID = dID;
    }
  }


  @override
  String toString() {
    return 'NotificationModel{requestID: $requestID, toUser: $toUser, seen: $seen, docID: $docID, groupID: $groupID, chatID: $chatID, ENUM: $ENUM, message: $message, timestamp: $timestamp}';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['requestID'] = requestID;
    map['toUser'] = toUser;
    map['seen'] = seen;
    return map;
  }
}
