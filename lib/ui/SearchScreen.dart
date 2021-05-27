import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/models/CommunityGroup.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class SearchScreen extends StatefulWidget {
  AppUser signedInUser;

  SearchScreen(this.signedInUser);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  bool isBusy = false;
  TabController controller;
  TextEditingController textEditingController = TextEditingController();

  void setBusy(bool busy) => setState(() => this.isBusy = busy);
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int currentIndex = 0;
  List<Tab> tabs = [Tab('Community Groups', true), Tab('Groups', false)]; //, Tab('Games', false)];

//  List<PostActivity> interestPostedNearbys = List();
  List<CommunityGroup> communityGroups = List();
  List<CommunityGroup> filteredCommunityGroups = List();

  List<Group> regularGroups = List();
  List<Group> filteredRegularGroups = List();

//  List<InterestModel> interests = List();
//  List<PostActivity> filteredInterests = List();

  List<Widget> screens() => [
        ActivitiesSearch(communityGroups: filteredCommunityGroups),
        ActivitiesSearch(regularGroups: filteredRegularGroups),
//        ActivitiesSearch(interests: filteredInterests),
      ];

  void loadEveryThing() async {
    QuerySnapshot cg = await firestore.collection('CommunityGroups').get();
    cg.docs.forEach((element) {
      setState(() {
        communityGroups.add(CommunityGroup.fromMap(element.data(), id: element.id));
      });
    });

    QuerySnapshot rg = await firestore.collection('Groups').get();
    rg.docs.forEach((element) {
      setState(() {
        regularGroups.add(Group.fromMap(element.data(), element.id));
      });
    });

//    QuerySnapshot interstGames = await firestore.collection('Interests').getDocuments();
//    interstGames.documents.forEach((element) {
//      setState(() {
//        interests.add(InterestModel.fromMap(element.data, id: element.documentID));
//      });
//    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);
    loadEveryThing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          autofocus: true,
          controller: textEditingController,
          onChanged: search,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: 'Search something nearby',
          ),
        ),
      ),
      body: isBusy
          ? Container(child: Center(child: CircularProgressIndicator()))
          : textEditingController.text.length > 0
              ? Container(
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: tabs
                              .map(
                                (e) => Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: ChoiceChip(
                                      selected: !e.selected,
                                      label: Text(
                                        e.title,
                                        style: TextStyle(
                                          color: e.selected ? Colors.white : Colors.black45,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: Colors.orange.withOpacity(0.6),
                                      disabledColor: Colors.grey.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          const Radius.circular(16.0),
                                        ),
                                        side: BorderSide(width: 1, color: Colors.orange),
                                      ),
                                      onSelected: (bool value) {
                                        setState(() {
                                          tabs.forEach((element) {
                                            element.selected = false;
                                          });
                                          e.selected = true;
                                          currentIndex = tabs.indexOf(e);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Divider(),
                      Expanded(
                        child: screens()[currentIndex],
                      ),
                    ],
                  ),
                )
              : SizedBox(),
    );
  }

  void search(String value) {
    setBusy(true);
    filteredCommunityGroups.clear();
    filteredRegularGroups.clear();
//    filteredInterests.clear();

    if (communityGroups.length > 0) {
      communityGroups.forEach((element) {
        if (element.title.toLowerCase().contains(value.toLowerCase())) {
          filteredCommunityGroups.add(element);
        }
      });
    }

    if (regularGroups.length > 0) {
      regularGroups.forEach((element) {
        if (element.title.toLowerCase().contains(value.toLowerCase())) {
          filteredRegularGroups.add(element);
        }
      });
    }

//    if (interests.length > 0) {
//      interests.forEach((element) async {
//        if (element.title.toLowerCase().contains(value.toLowerCase())) {
//          QuerySnapshot nearbyrequests = await firestore.collection('KhelBuddyRequests').where('isActive', isEqualTo: true).getDocuments();
//          nearbyrequests.documents.forEach((docSnap) {
//            PostActivity postedActivity = PostActivity.fromMap(docSnap.data, id: docSnap.documentID);
//            if (distanceTo.distanceBetween(widget.signedInUser.latitude, widget.signedInUser.longitude, postedActivity.currentCoordinates.latitude,
//                    postedActivity.currentCoordinates.longitude) <=
//                2000) {
//              filteredInterests.add(postedActivity);
//            }
//          });
//        }
//      });
//    }
    setBusy(false);
  }
}

class ActivitiesSearch extends StatefulWidget {
  List<Group> regularGroups;
  List<CommunityGroup> communityGroups;
  List<PostActivity> interests;

  ActivitiesSearch({this.regularGroups, this.communityGroups, this.interests});

  @override
  _ActivitiesSearchState createState() => _ActivitiesSearchState();
}

class _ActivitiesSearchState extends State<ActivitiesSearch> {
  bool searching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        if (widget.regularGroups != null) {
          return CustomeGroupListTile(group: widget.regularGroups[index]);
        }

//        if (widget.communityGroups != null) {
        return CustomeCommunityGroupListTile(communityGroup: widget.communityGroups[index]);
//        }

//        return NearByInterestPostedListTile(gamePosted: widget.interests[index]);
      },
      itemCount: widget.regularGroups != null
          ? widget.regularGroups.length
          : widget.communityGroups != null
              ? widget.communityGroups.length
              : widget.interests.length,
    );
  }
}

class Tab {
  String title;
  bool selected;

  Tab(this.title, this.selected);
}

class CustomeCommunityGroupListTile extends StatefulWidget {
  CommunityGroup communityGroup;

  CustomeCommunityGroupListTile({this.communityGroup});

  @override
  _CustomeCommunityGroupListTileState createState() => _CustomeCommunityGroupListTileState();
}

class _CustomeCommunityGroupListTileState extends State<CustomeCommunityGroupListTile> {
  int membersCount;
  bool isJoined = false;
  bool bisy = false;

  void setBBusy(bool a) {
    setState(() {
      bisy = a;
    });
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection('CommunityGroups').doc(widget.communityGroup.groupID).collection('Members').get().then((value) {
      setState(() {
        membersCount = value.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(Common.signedInUser.email)
        .collection('Member')
        .doc(widget.communityGroup.groupID)
        .get()
        .then((value) {
      setState(() {
        isJoined = (value.exists && value.data != null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: bisy ? CircularProgressIndicator() : CircleImageInkWell(image: NetworkImage(widget.communityGroup.image), onPressed: null, size: 56),
      title: TitleText(text: '${widget.communityGroup.title} Community Group'),
      subtitle: Text(
        membersCount != null ? 'A community group for all cricket lovers\nAround ${membersCount} members have joined' : '...',
      ),
      trailing: GestureDetector(
        child: Text(
          isJoined ? 'Joined' : 'Join',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: MediaQuery.of(context).size.height * 0.02,
            color: isJoined ? Colors.grey : Colors.orange.shade400,
          ),
        ),
        onTap: isJoined
            ? null
            : () async {
                setBBusy(true);
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(Common.signedInUser.email)
                    .collection('Member')
                    .doc(widget.communityGroup.groupID)
                    .set({'groupID': widget.communityGroup.groupID, 'community': true}).then((value) {
                  FirebaseFirestore.instance.collection('CommunityGroups').doc(widget.communityGroup.groupID).collection('Members').add({
                    'displayPicture': Common.signedInUser.displayPictureUrl,
                    'memberID': Common.signedInUser.email,
                    'name': Common.signedInUser.name,
                  }).then((value) {
                    setState(() {
                      isJoined = true;
                      setBBusy(false);
                      showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.greenAccent),
                                    SizedBox(width: 6),
                                    TitleText(text: 'Successfuly joined'),
                                  ],
                                ),
                                content: Text('Congratulation ! you are now a momber of community group ${widget.communityGroup.title}',
                                    textAlign: TextAlign.center),
                              ));
                    });
                  });
                });
              },
      ),
    );
  }
}

class CustomeGroupListTile extends StatefulWidget {
  Group group;

  CustomeGroupListTile({this.group});

  @override
  _CustomeGroupListTileState createState() => _CustomeGroupListTileState();
}

class _CustomeGroupListTileState extends State<CustomeGroupListTile> {
  int membersCount;
  bool isJoined = false;

  bool bisy = false;

  void setBBusy(bool a) {
    setState(() {
      bisy = a;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection('Groups').doc(widget.group.groupID).collection('Members').get().then((value) {
      setState(() {
        membersCount = value.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(Common.signedInUser.email)
        .collection('Member')
        .doc(widget.group.groupID)
        .get()
        .then((value) {
      setState(() {
        isJoined = (value.exists && value.data != null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: bisy ? CircularProgressIndicator() : CircleImageInkWell(image: NetworkImage(widget.group.imageURL), onPressed: null, size: 56),
      title: TitleText(text: '${widget.group.title}'),
      subtitle: Text(
        membersCount != null ? '${widget.group.description}\nAround ${membersCount} members have joined' : '...',
      ),
      trailing: GestureDetector(
        child: Text(
          isJoined ? 'Joined' : 'Join',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: MediaQuery.of(context).size.height * 0.025,
            color: isJoined ? Colors.grey : Colors.orange.shade400,
          ),
        ),
        onTap: isJoined
            ? null
            : () async {
                setBBusy(true);
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(Common.signedInUser.email)
                    .collection('Member')
                    .doc(widget.group.groupID)
                    .set({'groupID': widget.group.groupID}).then((value) {
                  FirebaseFirestore.instance.collection('Groups').doc(widget.group.groupID).collection('Members').add({
                    'joined': DateTime.now().millisecondsSinceEpoch,
                    'memberID': Common.signedInUser.email,
                  }).then((value) {
                    setState(() {
                      isJoined = true;
                      setBBusy(false);
                      showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.greenAccent),
                                    SizedBox(width: 6),
                                    TitleText(text: 'Successfuly joined'),
                                  ],
                                ),
                                content: Text('Congratulation ! you are now a momber of group ${widget.group.title}', textAlign: TextAlign.center),
                              ));
                    });
                  });
                });
              },
      ),
    );
  }
}

//class NearByInterestPostedListTile extends StatefulWidget {
//  PostActivity gamePosted;
//
//  NearByInterestPostedListTile({this.gamePosted});
//
//  @override
//  _NearByInterestPostedListTileState createState() => _NearByInterestPostedListTileState();
//}
//
//class _NearByInterestPostedListTileState extends State<NearByInterestPostedListTile> {
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      margin: EdgeInsets.all(8),
//      child: ListTile(
//        title: widget.gamePosted,
//      ),
//    );
//  }
//}
