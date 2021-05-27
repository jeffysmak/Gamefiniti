import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/ChatHelper.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/ChatMessage.dart';
import 'package:indianapp/models/ChatRoomModel.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/GroupMember.dart';
import 'package:indianapp/models/GroupPost.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/chat/InboxChatScreen.dart';
import 'package:indianapp/ui/dashboard/group/CreateGroupPost.dart';
import 'package:indianapp/ui/dashboard/group/GroupDiscussionScreen.dart';
import 'package:indianapp/ui/splash/PastGroupPostWidget.dart';
import 'package:indianapp/ui/widgets/GroupPostWidget.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:share/share.dart';

class GroupDetailScreen extends StatefulWidget {
  Group group;
  AppUser signedInUser;

  GroupDetailScreen(this.group, this.signedInUser);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  Group group;
  AppUser signedInUser;
  AppUser groupAdmin;
  InterestModel groupInterest;

  List<GroupMember> groupMembers;

  @override
  void initState() {
    super.initState();
    this.group = widget.group;
    this.signedInUser = widget.signedInUser;
    _initGroupAdmin();
    _initGroupInteres();
  }

  _initGroupAdmin() async {
    DocumentSnapshot adminSnap = await FirebaseFirestore.instance.collection(FirestoreHelper.KEY_USERS).doc(group.admin).get();
    setState(() {
      this.groupAdmin = AppUser.fromMap(adminSnap.data());
    });
  }

  _initGroupInteres() async {
    DocumentSnapshot interestSnap = await FirebaseFirestore.instance.collection('Interests').doc(group.interestID).get();
    setState(() {
      groupInterest = InterestModel.fromMap(interestSnap.data());
    });
  }

  void shareGroupRefCode() {
    Share.share(
        'Hey! Checkout this Khel Buddy app, join our ${groupInterest.title} group and start doing things together.\nGroup Code : ${group.inviteCode}',
        subject: 'Khel Buddy Group Invite Code');
  }

  Widget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      actions: [
        IconButton(icon: Icon(Icons.share), onPressed: groupInterest != null ? shareGroupRefCode : null),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => CreateNewGroupPost(
                  group: group,
                  signedInUser: signedInUser,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Image.network(
                            group.imageURL,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          child: Text('Member of ${group.title}'),
                          margin: EdgeInsets.all(16),
                        ),
                        Container(
                          child: TitleText(
                            text: group.title,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          height: 80,
                          child: StreamBuilder(
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData || snapshot.data.docs.length == 0) {
                                return SizedBox();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (ctx, position) {
                                        GroupMember member = GroupMember.fromMap(snapshot.data.docs[position]);
                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          child: CircleImageInkWell(image: NetworkImage(member.image), onPressed: null, size: 45),
                                        );
                                      },
                                      itemCount: snapshot.data.docs.length,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    child: Text('${snapshot.data.docs.length} Members'),
                                  ),
                                ],
                              );
                            },
                            stream: FirestoreHelper.getGroupMembersStream(signedInUser, group),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: CircleImageInkWell(
                            image: groupAdmin != null ? NetworkImage(groupAdmin.displayPictureUrl) : AssetImage('assets/images/loading_card.gif'),
                            onPressed: () {},
                            size: 50,
                          ),
                          title: Text('Admin'),
                          subtitle: Row(
                            children: [
                              Expanded(child: TitleText(text: groupAdmin != null ? groupAdmin.name : '')),
                            ],
                          ),
                          trailing: ifMeAdmin(group, signedInUser)
                              ? SizedBox()
                              : IconButton(
                                  onPressed: () async {
                                    var model = await ChatHelper.checkRoomAlreadyExist(signedInUser, groupAdmin);
                                    if (model != null) {
                                      model.otherUser = groupAdmin;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => InboxChatScreen(
                                            chatRoomModel: model,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ChatRoomModel model = ChatRoomModel([signedInUser.email, group.admin]);
                                      ChatHelper.createChatRoom(
                                        model,
                                        (String roomId) {
                                          // complete callback
                                          // create engagement with chat room id
                                          ChatHelper.createEngagement([signedInUser.email, group.admin], roomId);
                                          model.chatID = roomId;
                                          model.otherUser = groupAdmin;

                                          ChatHelper.sendMessage(
                                              ChatMessage('Hi there...', signedInUser.email, DateTime.now().millisecondsSinceEpoch, 1), model);

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
                                    }
                                  },
                                  icon: Icon(Icons.message),
                                ),
                        ),
                        Divider(),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TitleText(text: 'Upcoming Matches'),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(FirestoreHelper.KEY_Groups)
                                .doc(group.groupID)
                                .collection('Posts')
                                .where('when', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
                                .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData || snapshot.data.docs.length == 0) {
                                return Container(
                                  child: Center(
                                    child: TitleText(
                                      text: 'No upcoming match',
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemBuilder: (ctx, position) {
                                  GroupPost post = GroupPost.fromMap(snapshot.data.docs[position].data(), postID: snapshot.data.docs[position].id);
                                  return Container(
                                    width: MediaQuery.of(context).size.width - 100,
                                    child: GroupPostWidget(group, post, signedInUser),
                                  );
                                },
                                itemCount: snapshot.data.docs.length,
                                scrollDirection: Axis.horizontal,
                              );
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TitleText(
                            text: 'Past Matches',
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(FirestoreHelper.KEY_Groups)
                                .doc(group.groupID)
                                .collection('Posts')
                                .where('when', isLessThan: DateTime.now().millisecondsSinceEpoch)
                                .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData || snapshot.data.docs.length == 0) {
                                return Container(
                                  child: Center(
                                    child: TitleText(
                                      text: 'No past matches',
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemBuilder: (ctx, position) {
                                  GroupPost post = GroupPost.fromMap(snapshot.data.docs[position].data(), postID: snapshot.data.docs[position].id);
                                  return PastGroupPostWidget(group, post, signedInUser);
                                  return Container(
                                    width: MediaQuery.of(context).size.width - 100,
                                    child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TitleText(text: '${post.title} Match'),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text(
                                              Common.convertTimestamp(post.when),
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text(
                                              '${post.matchLocation.longitude}',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text(
                                              '10 people went',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: snapshot.data.docs.length,
                                scrollDirection: Axis.horizontal,
                              );
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          height: 56,
                          child: FlatButton(
                            color: Colors.orange.withOpacity(0.5),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => GroupDiscussionScreen(group, signedInUser)));
                            },
                            child: Row(
                              children: [
                                Icon(Icons.chat_bubble_outline),
                                SizedBox(width: 12),
                                Text('Open Group Discussion'),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool ifMeAdmin(Group group, AppUser user) {
    if (group == null || user == null) {
      return false;
    } else {
      return group.admin == user.email;
    }
  }
}
