import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/ChatHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/ChatMessage.dart';
import 'package:indianapp/models/ChatRoomModel.dart';
import 'package:indianapp/models/Notification.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/chat/InboxChatScreen.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:indianapp/helpers/DistanceTo.dart';

class SwapItem extends StatefulWidget {
  PostActivity activityRequest;
  AppUser currentSigninUser;
  bool fromNotification;
  NotificationModel model;

  SwapItem(this.activityRequest, {this.currentSigninUser, this.fromNotification, this.model});

  @override
  _SwapItemState createState() => _SwapItemState();
}

class _SwapItemState extends State<SwapItem> {
  PostActivity request;
  bool fromNotification;
  NotificationModel model;
  List<InterestModel> interestModel = List();
  AppUser user;

  ValueNotifier isBusyNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fromNotification = widget.fromNotification;
    user = widget.currentSigninUser;
    if (fromNotification) {
      this.model = widget.model;
      debugPrint(model.toString());
      _getRequest();
      // set as seen
      FirestoreHelper.setNotificationAsSeen(model);
    } else {
      this.request = widget.activityRequest;
      initInterests();
    }
  }

  void _getRequest() async {
    request = await FirestoreHelper.getActivityRequest(model.requestID);
    initInterests();
    setState(() {});
  }

  void initInterests() async {
    if (request.interests.contains(",")) {
      List<String> interestIDs = request.interests.split(",");
      interestIDs.forEach((element) async {
        debugPrint(element);
        String id = element.contains(" ") ? element.replaceAll(" ", "") : element;
        DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('Interests').doc(id).get();
        debugPrint(docSnap.data.toString());
        interestModel.add(InterestModel.fromMap(docSnap.data()));
        setState(() {});
      });
    } else {
      DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('Interests').doc(request.interests).get();
      debugPrint(docSnap.data.toString());
      interestModel.add(InterestModel.fromMap(docSnap.data()));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          (!fromNotification)
              ? (request != null && interestModel.length > 0)
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(request.user.displayPictureUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                        child: new Container(
                                          decoration: new BoxDecoration(color: Colors.orange.withOpacity(0.2)),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          margin: EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 32),
                                              CircleImageInkWell(
                                                onPressed: () {},
                                                size: MediaQuery.of(context).size.height * 0.2,
                                                image: NetworkImage(request.user.displayPictureUrl),
                                                splashColor: Colors.white24,
                                              ),
                                              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                              TitleText(
                                                  text: request.user.name, fontSize: MediaQuery.of(context).size.height * 0.04, color: Colors.white),
                                              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 32),
                                                child: Column(
                                                  children: [
                                                    TitleText(
                                                      text: 'Interested',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white,
                                                    ),
                                                    TitleText(
                                                      text: interestModel.length > 0 ? interestModel[0].title : '',
                                                      fontSize: MediaQuery.of(context).size.height * 0.03,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                                    TitleText(
                                                      text: 'Time',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      Common.convertTimeInMilisToDate(request.dateTimeInMilis),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w800,
                                                          fontSize: MediaQuery.of(context).size.height * 0.0175),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                                    TitleText(
                                                      text: 'Distance',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      calculateDistance(),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w800,
                                                          fontSize: MediaQuery.of(context).size.height * 0.0275),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TitleText(
                                      text: '${Common.genderOptions()[request.user.gender - 1]}, ${Common.getAgeFromDateTime(
                                        DateTime.fromMillisecondsSinceEpoch(request.user.dateofbirth),
                                      )} Years',
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          },
                                          padding: EdgeInsets.all(12),
                                          color: Colors.redAccent,
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                        width: 50,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          height: 56,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(56),
                                            ),
                                            onPressed: () {
                                              startConversation();
                                            },
                                            padding: EdgeInsets.all(12),
                                            color: Colors.orange,
                                            child: Text(
                                              'Say Hi',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Container(
                                        height: 50,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          onPressed: () async {
                                            startCustomConversation();
                                          },
                                          padding: EdgeInsets.all(12),
                                          color: Colors.blue,
                                          child: Icon(
                                            Icons.message,
                                            color: Colors.white,
                                          ),
                                        ),
                                        width: 50,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(child: Center(child: CircularProgressIndicator()))
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(request.user.displayPictureUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                    child: new Container(
                                      decoration: new BoxDecoration(color: Colors.orange.withOpacity(0.2)),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      margin: EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 32),
                                          CircleImageInkWell(
                                            onPressed: () {},
                                            size: MediaQuery.of(context).size.height * 0.2,
                                            image: NetworkImage(request.user.displayPictureUrl),
                                            splashColor: Colors.white24,
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                          TitleText(
                                              text: request.user.name, fontSize: MediaQuery.of(context).size.height * 0.04, color: Colors.white),
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 32),
                                            child: Column(
                                              children: [
                                                TitleText(
                                                  text: 'Interested',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                                TitleText(
                                                  text: interestModel.length > 0 ? interestModel[0].title : '',
                                                  fontSize: MediaQuery.of(context).size.height * 0.03,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                                TitleText(
                                                  text: 'Time',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  Common.convertTimeInMilisToDate(request.dateTimeInMilis),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: MediaQuery.of(context).size.height * 0.0175),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                                TitleText(
                                                  text: 'Distance',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  calculateDistance(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: MediaQuery.of(context).size.height * 0.0275),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TitleText(
                                  text: '${Common.genderOptions()[request.user.gender - 1]}, ${Common.getAgeFromDateTime(
                                    DateTime.fromMillisecondsSinceEpoch(request.user.dateofbirth),
                                  )} Years',
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    height: 50,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                      padding: EdgeInsets.all(12),
                                      color: Colors.redAccent,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                    width: 50,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      height: 56,
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(56),
                                        ),
                                        onPressed: () {
                                          startConversation();
                                        },
                                        padding: EdgeInsets.all(12),
                                        color: Colors.orange,
                                        child: Text(
                                          'Say Hi',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Container(
                                    height: 50,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      onPressed: () async {
                                        startCustomConversation();
                                      },
                                      padding: EdgeInsets.all(12),
                                      color: Colors.blue,
                                      child: Icon(
                                        Icons.message,
                                        color: Colors.white,
                                      ),
                                    ),
                                    width: 50,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ValueListenableBuilder(
            valueListenable: isBusyNotifier,
            builder: (_, value, __) {
              if (value == false) {
                return SizedBox();
              } else {
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: Colors.grey.withOpacity(0.8)),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void startConversation() async {
    isBusyNotifier.value = true;
    var model = await ChatHelper.checkRoomAlreadyExist(widget.currentSigninUser, request.user);
    if (model != null) {
      model.otherUser = request.user;
      isBusyNotifier.value = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => InboxChatScreen(
            chatRoomModel: model,
          ),
        ),
      );
    } else {
      ChatRoomModel model = ChatRoomModel([widget.currentSigninUser.email, request.user.email]);
      ChatHelper.createChatRoom(
        model,
        (String roomId) {
          // complete callback
          // create engagement with chat room id
          ChatHelper.createEngagement([widget.currentSigninUser.email, request.user.email], roomId);
          model.chatID = roomId;
          model.otherUser = request.user;
          isBusyNotifier.value = false;
          ChatHelper.sendMessage(ChatMessage('Hi there...', widget.currentSigninUser.email, DateTime.now().millisecondsSinceEpoch, 1), model);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => InboxChatScreen(
                chatRoomModel: model,
              ),
            ),
          );
        },
        () {
          // some error
          isBusyNotifier.value = false;
        },
      );
    }
  }

  void startCustomConversation() async {
    debugPrint('${widget.currentSigninUser.email} ${request.user.email}');
    isBusyNotifier.value = true;
    var model = await ChatHelper.checkRoomAlreadyExist(widget.currentSigninUser, request.user);

    if (model != null) {
      // exist krta hae ....
      isBusyNotifier.value = false;
      model.otherUser = request.user;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => InboxChatScreen(
            chatRoomModel: model,
          ),
        ),
      );
    } else {
      isBusyNotifier.value = false;
      ChatRoomModel model = ChatRoomModel([widget.currentSigninUser.email, request.user.email]);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => InboxChatScreen(
            chatRoomModel: model,
            newConversation: true,
          ),
        ),
      );
    }
  }

  String calculateDistance() {
    return '${((distanceTo.distanceBetween(Common.signedInUser.latitude, Common.signedInUser.longitude, request.user.latitude, request.user.longitude)) / 1000).toStringAsFixed(1)} KM'; // KM\nAway from you';
  }
}
