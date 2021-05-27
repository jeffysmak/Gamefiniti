import 'package:indianapp/models/User.dart';

class GroupMember {
  int joined;
  String memberID;
  String name;
  String image;

  GroupMember(this.joined, this.memberID, this.name, this.image);

  GroupMember.fromMap(var map) {
    this.joined = map['joined'];
    this.memberID = map['memberID'];
    this.name = map['name'];
    this.image = map['image'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['joined'] = joined;
    map['memberID'] = memberID;
    map['name'] = name;
    map['image'] = image;
    return map;
  }
}
