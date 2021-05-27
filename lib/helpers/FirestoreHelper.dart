import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/model.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/ChatHelper.dart';
import 'package:indianapp/helpers/FirebaseStorageHelper.dart';
import 'package:indianapp/models/ChatMessage.dart';
import 'package:indianapp/models/ChatRoomModel.dart';
import 'package:indianapp/models/CommunityGroup.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/GroupMember.dart';
import 'package:indianapp/models/GroupPost.dart';
import 'package:indianapp/models/MyDeviceToken.dart';
import 'package:indianapp/models/Notification.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/helpers/DistanceTo.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';

class FirestoreHelper {
  static final String KEY_USERS = 'Users';
  static final String KEY_KhelBuddy_Requests = 'KhelBuddyRequests';
  static final String KEY_DEVICE_TOKENS = 'DeviceTokens';
  static final String KEY_Notifications = 'notifications';
  static final String KEY_Groups = 'Groups';
  static final String KEY_CommunityGroups = 'CommunityGroups';
  static final String KEY_Interests = 'Interests';

  static final String QUERY_EMAIL = 'email';
  static final String QUERY_PHONE = 'phone';

  // to check user already existance
  static void checkUserAlreadyExist(AppUser user, Function callback, String query) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference USERS_COLLECTION = firestore.collection(KEY_USERS);

    Query q = USERS_COLLECTION.where(query, isEqualTo: query == QUERY_EMAIL ? user.email : user.phone);

    QuerySnapshot qs = await q.get();

    callback.call((qs.docs != null && qs.docs.length > 0));

//    DocumentReference USER_REFRENCE = USERS_COLLECTION.doc(user.provider == 'Phone' ? user.phone : user.email);
//
//    DocumentSnapshot userSnap = await USER_REFRENCE.get();
//
//    callback.call(userSnap.exists);
  }

  static void clearData(AppUser user) async {
    FirebaseFirestore.instance.collection(KEY_USERS).doc(user.email).delete();
  }

  static void updateName(AppUser user, Function callback) async {
    FirebaseFirestore.instance.collection(KEY_USERS).doc(user.email).update(user.toMap()).whenComplete(() => callback.call());
  }

  // insert user to firestore database
  static void createUserInDatabase(AppUser user, Function onCompleteCallback, {bool merge}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference USERS_COLLECTION = firestore.collection(KEY_USERS);

    DocumentReference USER = USERS_COLLECTION.doc(user.email);

    USER.update(user.toMap()).whenComplete(() => onCompleteCallback.call());

    Common.signedInUser = user;
  }

  static void insertInterestsToUserAccount(AppUser user, Function onComplete) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection(KEY_USERS).doc(user.email).set(user.toMap()).whenComplete(() => onComplete.call());
  }

  // read user from firestore database
  static Future<AppUser> getUserFromData(User user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference USERS_COLLECTION = firestore.collection(KEY_USERS);

    DocumentReference USER = USERS_COLLECTION.doc((user.email != null && user.email.length > 0) ? user.email : user.phoneNumber);

    DocumentSnapshot userData = await USER.get();

    AppUser signedInUser = AppUser.fromMap(userData.data());

    Common.signedInUser = signedInUser;

    return signedInUser;
  }

  static void registerDeviceToken(BuildContext context, AppUser user) async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String token = await firebaseMessaging.getToken();
    firestore.collection(KEY_DEVICE_TOKENS).doc(user.email).set(MyDeviceToken(token).toMap());
  }

  // khel buddy new interest request
  static Future postNewKhelBuddyRequest(AppUser user, PostActivity activity, Function onPosted) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference khelBuddyRefrence = firestore.collection(KEY_KhelBuddy_Requests);
    var map = activity.toMap();
    map['userID'] = user.email;
    map['isActive'] = true;
    map['inActiveAt'] = DateTime.now().millisecondsSinceEpoch;

    DocumentReference ref = await khelBuddyRefrence.add(map).whenComplete(() => onPosted.call());
//    firestore
//        .collection(KEY_USERS)
//        .doc(user.email)
//        .collection('ActiveRequest')
//        .doc('activeRequestData')
//        .setData({'requestID': ref.id}).whenComplete(() => onPosted.call());
  }

  // check user last request is active or not
  static Future<bool> isMyLastRequestActive(AppUser user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snap = await firestore.collection(KEY_USERS).doc(user.email).collection('ActiveRequest').doc('activeRequestData').get();

    if (snap != null && snap.data() != null && snap.exists) {
      String requestID = (snap.data() as Map)['requestID'].toString();
      DocumentSnapshot requestSnap = await firestore.collection(KEY_KhelBuddy_Requests).doc(requestID).get();
      if (requestSnap != null && requestSnap.data() != null) {
        return (requestSnap.data() as Map)['isActive'];
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  //
  static Future<List<InterestModel>> getInterest() async {
    List<InterestModel> interestsList = List();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot interests = await firestore.collection('Interests').get();
    interests.docs.forEach(
      (DocumentSnapshot doc) {
        interestsList.add(InterestModel.fromMap(doc.data(), id: doc.id));
      },
    );
    return interestsList;
  }

  static void getMyInterests(AppUser user, Function onAdded) async {
    List<String> myInterestsIds = user.interests;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    myInterestsIds.forEach((element) async {
      DocumentSnapshot interests = await firestore.collection('Interests').doc(element).get();
      onAdded.call(InterestModel.fromMap(interests.data(), id: interests.id));
    });
  }

  static void setNotificationAsSeen(NotificationModel model) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentReference =
        firestore.collection(KEY_USERS).doc(Common.signedInUser.email).collection(KEY_Notifications).doc(model.docID);
    model.seen = true;
    documentReference.set(model.toMap());
  }

//  static Future<List<PostActivity>> getNearByRequestsByKm(
  static Future getNearByRequestsByKm(AppUser signedInUser, double range, Coordinates locationData, Function onAdded) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnaps = await firestore.collection(KEY_KhelBuddy_Requests).where('isActive', isEqualTo: true).get();

    querySnaps.docs.forEach(
      (DocumentSnapshot doc) async {
        debugPrint(doc.data().toString());
        PostActivity request = PostActivity.fromMap(doc.data());

        debugPrint((doc.data() as Map)['userID'].toString());

        if ((doc.data() as Map)['userID'] != signedInUser.email) {
          if (request.interests.contains(",")) {
            List<String> requestInterests = request.interests.split(",");
            for (String interest in requestInterests) {
              if (signedInUser.interests.contains(interest)) {
                String userGender = Common.genderOptions()[signedInUser.gender - 1];
                String age = Common.getAgeFromDateTime(DateTime.fromMillisecondsSinceEpoch(signedInUser.dateofbirth));
                if (request.agesSelected.contains(age)) {
                  if (request.gendersList.contains('Both') || request.gendersList.contains(userGender)) {
                    // proceed
                    double distanceBewteen = distanceTo.distanceBetween(
                        locationData.latitude, locationData.longitude, request.currentCoordinates.latitude, request.currentCoordinates.longitude);
                    if (distanceBewteen <= range) {
                      AppUser userWhoPostedRequest = await getUserDataForRequest(request.user.email);
                      request.user = userWhoPostedRequest;
                      onAdded.call(request);
                      break;
                    } else {
                      debugPrint('Distance Difference');
                    }
                  } else {
                    debugPrint('Gender Difference');
                  }
                } else {
                  debugPrint('Age Difference');
                }
              }
            }
          } else {
            if (signedInUser.interests.contains(request.interests)) {
              String userGender = Common.genderOptions()[signedInUser.gender - 1];
              debugPrint(userGender);
              if (request.gendersList.contains('Both') || request.gendersList.contains(userGender)) {
                String age = Common.getAgeFromDateTime(DateTime.fromMillisecondsSinceEpoch(signedInUser.dateofbirth));
                if (request.agesSelected.contains(age)) {
                  // proceed
                  double distanceBewteen = distanceTo.distanceBetween(
                      locationData.latitude, locationData.longitude, request.currentCoordinates.latitude, request.currentCoordinates.longitude);
                  if (distanceBewteen <= range) {
                    debugPrint('HEREE ${distanceBewteen}');
                    getUserDataForRequest(request.user.email).then((value) => request.user = value).whenComplete(() => onAdded.call(request));
                  } else {
                    debugPrint('Distance Difference');
                  }
                } else {
                  debugPrint('Age Difference');
                }
              } else {
                debugPrint('Gender Difference');
              }
            }
          }
        } else {
          debugPrint('Same User');
        }
      },
    );

//    FirebaseFirestore firestore = FirebaseFirestore.instance;
//    QuerySnapshot querySnaps =
//        await firestore.collection(KEY_KhelBuddy_Requests).where('isActive', isEqualTo: true).get();
//
//    List<DocumentSnapshot> docs = querySnaps.docs;
//
//    docs.forEach(
//      (DocumentSnapshot snap) async {
//        PostActivity request = PostActivity.fromMap(snap.data());
//
//        double distanceBewteen = distanceTo.distanceBetween(locationData.latitude, locationData.longitude,
//            request.currentCoordinates.latitude, request.currentCoordinates.longitude);
//
//        if (distanceBewteen <= range) {
//          getUserDataForRequest(request.user.email).then((value) => request.user = value).whenComplete(
//                () => onAdded.call(request),
//              );
//        }
//      },
//    );
  }

  static Future<AppUser> getUserDataForRequest(String ID) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference USERS_COLLECTION = firestore.collection(KEY_USERS);

    DocumentReference USER = USERS_COLLECTION.doc(ID);

    DocumentSnapshot userData = await USER.get();

    return AppUser.fromMap(userData.data());
  }

  static Future getNotificationList(AppUser user, Function onNotificationCallback, {bool newest}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference notificationRef = firestore.collection(KEY_USERS).doc(user.email).collection(KEY_Notifications);

    debugPrint(user.toString());
    QuerySnapshot snaps;
    if (newest != null) {
      snaps = await notificationRef.where('seen', isEqualTo: false).get();
    } else {
      snaps = await notificationRef.get();
    }

    if (snaps != null && snaps.docs.length > 0) {
      snaps.docs.forEach(
        (DocumentSnapshot element) {
          onNotificationCallback.call(NotificationModel.fromMap(element.data(), dID: element.id));
          debugPrint('eee->' + element.toString());
        },
      );
    }
  }

  static Future<PostActivity> getActivityRequest(String docID) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot docSnapShot = await firestore.collection(KEY_KhelBuddy_Requests).doc(docID).get();
    PostActivity activity = PostActivity.fromMap(docSnapShot.data());

    AppUser user = await getUserDataForRequest(activity.user.email);
    activity.user = user;

    return activity;
  }

  static void getMyChats(Function onAdded, Function onFinished) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot chatsSnapshots = await firestore
        .collection(KEY_USERS)
        .doc(Common.signedInUser.email)
        .collection(ChatHelper.KEY_USER_CHAT)
//        .where('users', arrayContains: Common.signedInUser.email)
        .orderBy('timestamp', descending: false)
        .get();

    if (chatsSnapshots.docs != null && chatsSnapshots.docs.length > 0) {
      chatsSnapshots.docs.forEach(
        (DocumentSnapshot element) async {
          DocumentSnapshot ChatRoomModelSnapShot =
              await FirebaseFirestore.instance.collection(ChatHelper.KEYCHATROOM).doc((element.data() as Map)['roomID']).get();
          QuerySnapshot lastMessageSnap = await FirebaseFirestore.instance
              .collection(ChatHelper.KEYCHATROOM)
              .doc((element.data() as Map)['roomID'])
              .collection(ChatHelper.KEY_MESSAGES)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          ChatMessage msg = ChatMessage.fromMap(lastMessageSnap.docs[0].data());
          ChatRoomModel model = ChatRoomModel.fromMap(ChatRoomModelSnapShot.data(), id: ChatRoomModelSnapShot.id, message: msg);
          onAdded.call(model);
        },
      );
    } else {
      onFinished.call();
    }

//    FirebaseFirestore firestore = FirebaseFirestore.instance;
//    QuerySnapshot chatsSnapshots = await firestore
////        .collection(KEY_USERS)
////        .doc(Common.signedInUser.email)
//        .collection(ChatHelper.KEYCHATROOM)
//        .where('users', arrayContains: Common.signedInUser.email)
////        .orderBy('timestamp', descending: false)
//        .get();
//
//    if (chatsSnapshots.docs != null && chatsSnapshots.docs.length > 0) {
//      chatsSnapshots.docs.forEach(
//        (DocumentSnapshot element) async {
//          QuerySnapshot lastMessageSnap =
//              await element.reference.collection('Messages').orderBy('timestamp', descending: true).limit(1).get();
//          ChatMessage msg = ChatMessage.fromMap(lastMessageSnap.docs[0].data());
//          ChatRoomModel model = ChatRoomModel.fromMap(element.data(), id: element.id, message: msg);
//          onAdded.call(model);
////          DocumentSnapshot ChatRoomModelSnapShot = await FirebaseFirestore.instance.collection(ChatHelper.KEYCHATROOM).doc(element.data()['roomID']).get();
////          QuerySnapshot lastMessageSnap = await FirebaseFirestore.instance
////              .collection(ChatHelper.KEYCHATROOM)
////              .doc(element.data()['roomID'])
////              .collection(ChatHelper.KEY_MESSAGES)
////              .orderBy('timestamp', descending: true)
////              .limit(1)
////              .get();
////
////          ChatMessage msg = ChatMessage.fromMap(lastMessageSnap.docs[0].data());
////          ChatRoomModel model = ChatRoomModel.fromMap(ChatRoomModelSnapShot.data(), id: ChatRoomModelSnapShot.id, message: msg);
////          onAdded.call(model);
//        },
//      );
//    } else {
//      onFinished.call();
//    }
  }

  static void getMyGroups(AppUser user, Function onFetched) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snaps = await firestore.collection(KEY_USERS).doc(user.email).collection('Member').get();

    if (snaps.docs != null && snaps.docs.length > 0) {
      snaps.docs.forEach(
        (DocumentSnapshot element) async {
          String groupID = (element.data() as Map)['groupID'];

          DocumentSnapshot grpsSnap = await FirebaseFirestore.instance.collection(KEY_Groups).doc(groupID).get();

          if (grpsSnap.exists) {
            // if group of regular grouping....
            Group group = Group.fromMap(grpsSnap.data(), grpsSnap.id);
            onFetched.call(group);
          } //else {
          // find in Community Group
          // grpsSnap = await FirebaseFirestore.instance.collection(KEY_CommunityGroups).doc(groupID).get();
          // Group group = Group.communityFromMap(
          //     grpsSnap.data(), grpsSnap.id, true, CommunityGroup(grpsSnap.data()['title'].toString()));
          // onFetched.call(group);
          // }
        },
      );
    }
  }

  static Future<List<GroupMember>> getGroupMembersFromGroup(Group group) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<GroupMember> members = List();
    QuerySnapshot snaps = await firestore.collection(KEY_Groups).doc(group.groupID).collection('Members').get();

    if (snaps.docs != null && snaps.docs.length > 0) {
      snaps.docs.forEach((element) {
        GroupMember member = GroupMember.fromMap(element.data());
        members.add(member);
      });
    }
  }

  static Stream<QuerySnapshot> getGroupMembersStream(AppUser user, Group group) {
    return FirebaseFirestore.instance.collection(KEY_Groups).doc(group.groupID).collection('Members').snapshots();
  }

  static void CreateGroup(AppUser user, Group grp, File imageFile, Function onComplete) async {
    FirebaseStorageHelper.GroupPhotoTask(user, imageFile, (String URL) async {
      grp.admin = user.email;
      LocationData ld = await Common.getUserCurrentLocation();
      grp.geoPoint = GeoPoint(ld.latitude, ld.longitude);
      grp.imageURL = URL;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference cr = firestore.collection(KEY_Groups);
      DocumentReference documentReference = await cr.add(grp.toMap());
      grp.groupID = documentReference.id;
      grp.inviteCode = Common.GenereateGroupInviteCode(documentReference.id);
      _updateInviteCode(grp);

      addGroupMember(grp, GroupMember(DateTime.now().millisecondsSinceEpoch, user.email, user.name, user.displayPictureUrl), () {
        createGroupEngagementWithUser(grp, user, () {
          onComplete.call();
        });
      });
    });
  }

  static void _updateInviteCode(Group group) {
    FirebaseFirestore.instance.collection(KEY_Groups).doc(group.groupID).set(group.toMap());
  }

  static void createGroupEngagementWithUser(Group group, AppUser user, Function onComplete) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection(KEY_USERS).doc(user.email).collection('Member').add({'groupID': group.groupID}).whenComplete(() => onComplete.call());
  }

  static void addGroupMember(Group group, GroupMember member, Function onComplete) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference cr = firestore.collection(KEY_Groups);
    cr.doc(group.groupID).collection('Members').add(member.toMap()).whenComplete(() => onComplete.call());
  }

  static void createGroupPost(Group group, GroupPost post, Function whenComplete) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference cr = firestore.collection(KEY_Groups);

    DocumentReference postRefrence = await cr.doc(group.groupID).collection('Posts').add(post.toMap()).whenComplete(() => whenComplete.call());
  }

  static Future<Group> findGroupByRefID(AppUser user, String code, Function onGroupNotExist, Function onComplete) async {
    QuerySnapshot snaps = await FirebaseFirestore.instance.collection(KEY_Groups).where('inviteCode', isEqualTo: code).get();
    if (snaps != null && snaps.docs != null && snaps.docs.length == 1) {
      String groupID = snaps.docs[0].id;
      Group grp = Group.fromMap(snaps.docs[0].data(), groupID);

      // joining group
      addGroupMember(grp, GroupMember(DateTime.now().millisecondsSinceEpoch, user.email, user.name, user.displayPictureUrl), () {
        createGroupEngagementWithUser(grp, user, () {
          onComplete.call();
        });
      });
    } else {
      onGroupNotExist.call();
    }
  }
}
