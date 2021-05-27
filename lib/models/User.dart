import 'package:location/location.dart';

class AppUser {
  String name;
  String email;
  String phone;
  String password;
  String provider;
  int dateofbirth;
  int gender;
  double latitude;
  double longitude;
  String address;
  String city;
  String displayPictureUrl;
  String deviceToken;
  List<String> interests;
  String documentPath;

  AppUser(
    this.name,
    this.email,
    this.phone,
    this.password,
    this.provider,
    this.dateofbirth,
    this.gender,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.displayPictureUrl,
    this.deviceToken,
  );

  AppUser.empty();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> user = Map();
    user['name'] = name;
    user['email'] = email;
    user['phone'] = phone;
    user['password'] = password;
    user['dateofbirth'] = dateofbirth;
    user['gender'] = gender;
    user['provider'] = provider;
    user['latitude'] = latitude;
    user['longitude'] = longitude;
    user['address'] = address;
    user['city'] = city;
    user['displayPictureUrl'] = displayPictureUrl;
    user['interests'] = interests;
    user['document'] = documentPath;
    return user;
  }

  bool isUserCompeleted() {
    return name != null &&
        email != null &&
        phone != null &&
        password != null &&
        dateofbirth != null &&
        gender != null &&
        provider != null &&
        latitude != null &&
        longitude != null &&
        address != null &&
        city != null &&
        displayPictureUrl != null &&
        interests != null;
  }

  AppUser.fromMap(Map<String, dynamic> map) {
    this.name = map['name'];
    this.email = map['email'];
    this.phone = map['phone'];
    this.password = map['password'];
    this.dateofbirth = map['dateofbirth'];
    this.gender = map['gender'];
    this.provider = map['provider'];
    if (map['latitude'] != null) {
      this.latitude = map['latitude'];
    }
    if (map['longitude'] != null) {
      this.longitude = map['longitude'];
    }
    if (map['address'] != null) {
      this.address = map['address'];
    }
    if (map['city'] != null) {
      this.city = map['city'];
    }
    if (map['displayPictureUrl'] != null) {
      this.displayPictureUrl = map['displayPictureUrl'];
    }
    if (map['deviceToken'] != null) {
      this.deviceToken = map['deviceToken'];
    }
    if (map['document'] != null) {
      this.documentPath = map['document'];
    }
    if (map['interests'] != null) {
      interests = List();
      (map['interests'] as List).forEach((element) {
        this.interests.add(element.toString());
      });
    }
  }
}
