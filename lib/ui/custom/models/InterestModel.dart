import 'package:flutter/material.dart';

class InterestModel {
  String title;
  String imageUrl;
  String icon;
  String colorCode;
  String interestID;
  bool isSelected;
  bool isDisabled;

  InterestModel(this.imageUrl, this.title, this.colorCode, this.icon, {this.isSelected, this.isDisabled, this.interestID});

  Color parseColor() {
    return Color(int.parse(colorCode));
  }

  InterestModel.fromMap(Map<String, dynamic> mapData, {String id}) {
    this.title = mapData['title'];
    this.imageUrl = mapData['thumbnail'];
    this.icon = mapData['icon'];
    this.colorCode = mapData['colorCode'];
    if (id != null) {
      this.interestID = id;
    }
    this.isSelected = false;
    this.isDisabled = false;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['title'] = title;
    map['thumbnail'] = imageUrl;
    map['icon'] = icon;
    map['colorCode'] = colorCode;
    if (interestID != null) {
      map['interestID'] = interestID;
    }
    return map;
  }
}
