import 'package:cloud_firestore/cloud_firestore.dart';

class GroupPost {
  String createdBy;
  int timestamp;
  String title;
  int when;
  GeoPoint matchLocation;
  String postID;

  GroupPost(this.createdBy, this.timestamp, this.title, this.when, this.postID);

  GroupPost.empty();

  GroupPost.fromMap(var Map, {String postID}) {
    this.createdBy = Map['createdBy'];
    this.timestamp = Map['timestamp'];
    this.title = Map['title'];
    this.when = Map['when'];
    this.matchLocation = GeoPoint(Map['lat'], Map['lon']);
    if (postID != null) {
      this.postID = postID;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> m = Map();
    m['createdBy'] = createdBy;
    m['timestamp'] = timestamp;
    m['title'] = title;
    m['when'] = when;
    m['lat'] = matchLocation.latitude;
    m['lon'] = matchLocation.longitude;
    return m;
  }
}
