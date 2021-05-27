import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indianapp/models/CommunityGroup.dart';

class Group {
  String admin;
  String description;
  String title;
  String imageURL;
  String interestID;
  GeoPoint geoPoint;
  String groupID;
  String inviteCode;

  bool community;
  CommunityGroup communityGroup;

  Group.empty();

  Group.invite(this.inviteCode);

  Group(this.admin, this.description, this.title, this.imageURL, this.interestID, this.geoPoint);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['createdBY'] = admin;
    map['description'] = description;
    map['imageURL'] = imageURL;
    map['interests'] = interestID;
    map['location'] = geoPoint;
    map['title'] = title;
    map['inviteCode'] = inviteCode;
    map['community'] = false;
    return map;
  }

  Group.fromMap(Map<String, dynamic> map, String grpID) {
    this.admin = map['createdBY'];
    this.description = map['description'];
    this.imageURL = map['imageURL'];
    this.interestID = map['interests'];
    this.geoPoint = map['location'];
    this.title = map['title'];
    this.groupID = grpID;
    this.community = false;
    if (map['inviteCode'] != null) {
      this.inviteCode = map['inviteCode'];
    }
  }

  Group.communityFromMap(Map<String, dynamic> map, String grpID, bool community, CommunityGroup communityGroup){
    this.title = map['title'];
    this.imageURL = map['imageURL'];
    this.groupID = grpID;
    this.communityGroup = communityGroup;
    this.community = community;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Group && runtimeType == other.runtimeType && inviteCode == other.inviteCode;

  @override
  int get hashCode => inviteCode.hashCode;
}
