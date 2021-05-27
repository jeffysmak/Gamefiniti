class MyDeviceToken {
  String token;

  MyDeviceToken(this.token);

  MyDeviceToken.fromMap(var map) {
    this.token = map['deviceToken'];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['deviceToken'] = token;
    return map;
  }
}
