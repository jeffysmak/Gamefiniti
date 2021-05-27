import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/LightColor.dart';
import 'package:indianapp/helpers/ChatHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/ChatMessage.dart';
import 'package:indianapp/models/ChatRoomModel.dart';
import 'package:indianapp/models/Notification.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/helpers/DistanceTo.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/dashboard/chat/InboxChatScreen.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class DetailedProfileCard extends StatefulWidget {
  PostActivity request;
  bool fromNotification;
  NotificationModel model;

  DetailedProfileCard(this.request, {this.fromNotification, this.model});

  @override
  _DetailedProfileCardState createState() => _DetailedProfileCardState();
}

class _DetailedProfileCardState extends State<DetailedProfileCard> {
  PostActivity request;
  bool fromNotification;
  NotificationModel model;

  @override
  void initState() {
    super.initState();
    this.request = widget.request;
    this.fromNotification = widget.fromNotification;
    if (fromNotification) {
      this.model = widget.model;
      _getRequest();
      // set as seen
      FirestoreHelper.setNotificationAsSeen(model);
    }
  }

  void _getRequest() async {
    request = await FirestoreHelper.getActivityRequest(model.requestID);
    setState(() {});
  }

  Widget _backgroundBluredImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: request != null
            ? Stack(
                children: [
                  _backgroundBluredImage(),
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
                            fromNotification
                                ? TitleText(
                                    text: 'Congratulations !',
                                    fontSize: 28,
                                    color: Colors.white,
                                  )
                                : Container(),
                            fromNotification
                                ? TitleText(
                                    text: 'You have been matched !',
                                    fontSize: 24,
                                    color: Colors.white,
                                  )
                                : Container(),
                            SizedBox(
                              height: 12,
                            ),
                            TitleText(
                              text: request.user.name,
                              fontSize: 26,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            CircleImageInkWell(
                              onPressed: () {},
                              size: 175,
                              image: NetworkImage(request.user.displayPictureUrl),
                              splashColor: Colors.white24,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                children: [
                                  TitleText(
                                    text: 'Match found for',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                  TitleText(
                                    text: 'Football',
                                    fontSize: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TitleText(
                                    text:
                                        ('${((distanceTo.distanceBetween(Common.signedInUser.latitude, Common.signedInUser.longitude, request.user.latitude, request.user.longitude)) / 1000).toStringAsFixed(1)} KM\nAway from you'),
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TitleText(
                                    text:
                                        'Wants to play at\n' + Common.convertTimeInMilisToDate(request.dateTimeInMilis),
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0), Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              if (fromNotification) {
                                handleStartChat();
                              } else {
                                handleStartChat();
                              }
                            },
                            child: TitleText(
                              text: fromNotification ? 'SEND MESSAGE' : 'SEND INTEREST',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }

  void handleStartChat() {
    AppUser currentSignedInUser = Common.signedInUser;
    AppUser otherUser = request.user;
    ChatRoomModel model = ChatRoomModel([currentSignedInUser.email, otherUser.email]);
    ChatHelper.createChatRoom(
      model,
      (String roomId) {
        // complete callback
        // create engagement with chat room id
        ChatHelper.createEngagement([currentSignedInUser.email, otherUser.email], roomId);
        model.chatID = roomId;
        model.otherUser = otherUser;

        ChatHelper.sendMessage(
            ChatMessage('Hi there, i\'m being matched with you.', currentSignedInUser.email,
                DateTime.now().millisecondsSinceEpoch, 1),
            model);

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
      },
    );
//
//    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => InboxChatScreen()));
  }

  void handleSendInterest() {}
}
