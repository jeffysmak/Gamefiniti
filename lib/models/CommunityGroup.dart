class CommunityGroup {
  String title;
  String groupID;
  String image;

  CommunityGroup(this.title);

  CommunityGroup.fromMap(Map<String, dynamic> map, {String id}) {
    this.title = map['title'];
    this.image = map['imageURL'];
    if (id != null) {
      this.groupID = id;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['title'] = title;
    return map;
  }
}
