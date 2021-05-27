import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:indianapp/models/AgeFactor.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';

class PostActivity {
  int dateTimeInMilis;
  int duration;
  int gender;
  int languagePrefered;
  Coordinates currentCoordinates;
  List<InterestModel> choosenInterestList;
  String interests;
  List<String> gendersList;
  List<String> languageList;
  List<AgeFactor> ageFactor;
  String agesSelected;

  AppUser user;
  String requestD;

  PostActivity(this.dateTimeInMilis, this.duration, this.gender, this.languagePrefered, this.ageFactor, this.currentCoordinates,
      this.choosenInterestList, this.choosenDateTime, this.timeChoosen, this.interests);

  DateTime choosenDateTime;
  TimeOfDay timeChoosen;

  PostActivity.empty();

  bool isNotNull() {
    return dateTimeInMilis != null &&
        duration != null &&
        ageFactor != null &&
        currentCoordinates != null &&
        gendersList != null &&
        languageList != null &&
        choosenInterestList != null;
  }

  PostActivity.fromMap(Map<String, dynamic> mapped, {String id}) {
    interests = mapped['interests'];
//    ageFactor = AgeFactor(mapped['ageFactor']['minAge'], mapped['ageFactor']['maxAge'], false);
    agesSelected = mapped['ageFactor'];
    gendersList = _gendersListFromMap(mapped['genders']);
    languageList = _languageList(mapped['languages']);
    currentCoordinates = Coordinates.fromMap(mapped['currentLocation']);
    dateTimeInMilis = mapped['happensAt'];
    duration = mapped['duration'];
    user = AppUser.empty();
    user.email = mapped['userID'];
    if (id != null) {
      this.requestD = id;
    }
  }

  Map<String, dynamic> toMap() {
//    mapped['gender'] = gender;
//    mapped['language'] = languagePrefered;
    Map<String, dynamic> mapped = Map();
    choosenInterestList.map((e) => e.interestID).toList();
    mapped['currentLocation'] = currentCoordinates.toMap();
    mapped['happensAt'] = dateTimeInMilis;
    mapped['duration'] = duration;
    mapped['ageFactor'] = _getAgesFromList();
    mapped['interests'] = _getInterestFromList();
    mapped['languages'] = _getLanguagesFromList();
    mapped['genders'] = _getGendersFromList();
    return mapped;
  }

  String _getInterestFromList() {
    StringBuffer interestBuilder = StringBuffer();
    choosenInterestList.forEach((e) {
      debugPrint('${e.interestID}');
      interestBuilder.write('${e.interestID},');
    });
    return interestBuilder.toString().substring(0, interestBuilder.toString().lastIndexOf(','));
  }

  String _getAgesFromList() {
    StringBuffer interestBuilder = StringBuffer();
    ageFactor.forEach((AgeFactor element) {
      if (element.maxAge != null) {
        int dif = element.maxAge - element.minAge;
        for (int i = 0; i <= dif; i++) {
          interestBuilder.write('${element.minAge + i},');
        }
      } else {
        interestBuilder.write('${element.minAge},');
      }
    });
    return interestBuilder.toString().substring(0, interestBuilder.toString().lastIndexOf(','));
  }

  String _getLanguagesFromList() {
    StringBuffer interestBuilder = StringBuffer();
    languageList.forEach((e) {
      interestBuilder.write('$e,');
    });
    return interestBuilder.toString().substring(0, interestBuilder.toString().lastIndexOf(','));
  }

  String _getGendersFromList() {
    StringBuffer interestBuilder = StringBuffer();
    gendersList.forEach((e) {
      interestBuilder.write('$e,');
    });
    return interestBuilder.toString().substring(0, interestBuilder.toString().lastIndexOf(','));
  }

  List<String> _gendersListFromMap(String map) {
    List<String> genders = List();
    if (map.contains(',')) {
      genders = map.split(',');
    } else {
      genders.add(map);
    }
    return genders;
  }

  List<String> _languageList(String map) {
    List<String> languages = List();
    if (map.contains(',')) {
      languages = map.split(',');
    } else {
      languages.add(map);
    }
    return languages;
  }
}
