import 'package:age/age.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/AgeFactor.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/models/onboardmodel.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/custom/models/RadioItem.dart';
import 'package:indianapp/ui/dashboard/explore/DetailedProfileCard.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class Common {
  static AppUser signedInUser;
  static Coordinates coordinates;

  static final String GoogleSignIn = 'Email/Google';
  static final String FacebookSignIn = 'Email/Facebook';
  static final String PhoneSignIn = 'Email/Google';
  static final String RegularSignin = 'Email/Pass';

  static final String SPORTSMONKAPIKEY = 'ycZYrjeJaFSu2gseRQczbL1t33bpWpjwstqXuURhSNtYem2FtNWXj4HzzepH';

  static Future<LocationData> getUserCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled) {
      return await location.getLocation();
    } else {
      serviceEnabled = await location.requestService();
      if (serviceEnabled) {
        return await location.getLocation();
      }
    }
    return null;
  }

  static List<String> CommunityGroupsApis() {
    List<String> grps = List();
    grps.add('Cricket');
    grps.add('Football');
    grps.add('Basketball');
    return grps;
  }

//  https://cricket.sportmonks.com/api/v2.0/livescores?api_token=YOURTOKEN

  // method to get hours list left from now on
  static List<TimeOfDay> getHursLeftFromNowOn() {
    List<TimeOfDay> hoursList = List();
    TimeOfDay timeOfDay = TimeOfDay.now();
    TimeOfDay maxTimeLeftToday = TimeOfDay(hour: 23, minute: 0);

    int td = maxTimeLeftToday.hour.toInt() - timeOfDay.hour.toInt();

    for (int i = 0; i <= td; i++) {
      int a = timeOfDay.hour + (i + 1);
      hoursList.add(TimeOfDay(hour: a, minute: 0));
    }
    return hoursList;
  }

  // gender

  // date parser
  static String getAgeFromDateTime(DateTime dateTime) {
    AgeDuration age = Age.dateDifference(fromDate: dateTime, toDate: DateTime.now());
    return age.years.toString();
  }

  static String formatDate(DateTime dt) {
    final DateFormat formatter = DateFormat('MMM,dd - yyyy');
    final String formatted = formatter.format(dt);
    return formatted;
  }

  static String formatTime(TimeOfDay t) {
    final TimeOfDayFormat formatter = TimeOfDayFormat.HH_dot_mm;
//    final String formatted = formatter.format(t);
//    return formatted;
  }

  static int getTimeDateInMilist(DateTime dt, TimeOfDay td) {
    DateTime choosenDateTime = DateTime(dt.year, dt.month, dt.day, td.hour, td.minute);
    return choosenDateTime.millisecondsSinceEpoch;
  }

  static List<String> genderOptions() {
    List<String> genderOptions = List();
    genderOptions.add('Male');
    genderOptions.add('Female');
    genderOptions.add('Both');
    genderOptions.add('Prefer not to say');
    return genderOptions;
  }

  static List<RadioModel> genderChoiceOptions() {
    List<RadioModel> genderOptions = List();
    genderOptions.add(RadioModel(false, 'Male', 'Male', true));
    genderOptions.add(RadioModel(false, 'Female', 'Female', true));
    genderOptions.add(RadioModel(false, 'Both', 'Both', true));
    genderOptions.add(RadioModel(false, 'Prefer not to say', 'Prefer not to say', true));
    return genderOptions;
  }

  static List<RadioModel> languageChoiceOptions() {
    List<RadioModel> genderOptions = List();
    genderOptions.add(RadioModel(false, 'English', 'English', true));
    genderOptions.add(RadioModel(false, 'Hindi', 'Hindi', true));
    genderOptions.add(RadioModel(false, 'Any', 'Any', true));
    return genderOptions;
  }

  static List<AgeFactor> defaultAgeFactorsList() {
    List<AgeFactor> a = List();
    a.add(AgeFactor(16, 19, false, value: 0));
    a.add(AgeFactor(20, 23, false, value: 1));
    a.add(AgeFactor(24, 27, false, value: 2));
    a.add(AgeFactor(28, 31, false, value: 3));
    a.add(AgeFactor.optional(32, 4, false));
    return a;
  }

  static List<String> languagePreference() {
    List<String> op = List();
    op.add('English');
    op.add('Hindi');
    op.add('Any');
    return op;
  }

  static List<Duration> getDuration() {
    List<Duration> durations = List();
    durations.add(Duration(hours: 2));
    durations.add(Duration(hours: 3));
    durations.add(Duration(hours: 4));
    durations.add(Duration(hours: 5));
    return durations;
  }

  static String convertTimeInMilisToDate(int milis) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milis);
    DateFormat f = DateFormat('dd MMM, yyyy - hh:mm a');
    return f.format(dateTime);
  }

  static String convertTimestamp(int milis) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milis);
    DateTime dateTimenow = DateTime.now();
    String datePattern = 'dd MMM, yyyy - hh:mm a';
    if (dateTimenow.month == dateTime.month && dateTime.day == dateTimenow.day) {
      // hh:mm a
      datePattern = 'hh:mm a';
    } else {
      if (dateTimenow.day != dateTime.day) {
        // dd MMM - hh:mm a
        datePattern = 'dd MMM - hh:mm a';
      } else {
        // dd MMM, yyyy - hh:mm a
        datePattern = 'dd MMM, yyyy - hh:mm a';
      }
    }
    DateFormat f = DateFormat(datePattern);
    return f.format(dateTime);
  }

  static navigateToView(BuildContext context, var map) async {
    var view = map['view'];
    if (view != null) {
      if (view == 'user-found') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => DetailedProfileCard(
              null,
              fromNotification: true,
            ),
          ),
        );
      }
      if (view == 'group-joining') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => DetailedProfileCard(
              null,
              fromNotification: true,
            ),
          ),
        );
      }
    }
  }

  static String GenereateGroupInviteCode(String groupID) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < groupID.length; i++) {
      if (i % 3 == 0) {
        if (groupID.characters.elementAt(i) != null) {
          buffer.write(groupID.characters.elementAt(i));
        }
      }
    }
    return buffer.toString().toUpperCase();
  }

  static Future<String> coordinatesToAddress(GeoPoint locationData, int what) async {
    String httpRequest =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${locationData.latitude},${locationData.longitude}&key=AIzaSyA6GOAzQpJQAu1weK5ggGWiQKY93c2e2yI";
    List<Address> addresses = List();
    addresses = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(locationData.latitude, locationData.longitude))
        .catchError(
      (e) {
        // fetch from network....
      },
    );
    return what == 0 ? addresses[0].addressLine : '${addresses[0].locality}, ${addresses[0].adminArea}';
  }

  static List<OnBoardModel> getOnboardingItems() {
    List<OnBoardModel> list = List();
    list.add(OnBoardModel('assets/images/img1.png', 'Getting Bored', 'Are you getting bored and doing your stuff alone'));
    list.add(OnBoardModel(
        'assets/images/img2.png', 'Our KhelBuddy App', 'Use our khelbuddy app and post a request of your interest'));
    list.add(OnBoardModel('assets/images/img3.png', 'Interested Partners',
        'Find a nearby user with same interest and do your stuff together'));
    return list;
  }
}
