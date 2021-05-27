import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/Notification.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/SearchScreen.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/group/GroupsScreen.dart';
import 'package:indianapp/ui/dashboard/home/HomeScreen.dart';
import 'package:indianapp/ui/dashboard/chat/MessagesScreen.dart';
import 'package:indianapp/ui/dashboard/explore/ExploreScreen.dart';
import 'package:indianapp/ui/dashboard/profile/UserProfile.dart';

class DashboardScreen extends StatefulWidget {
  AppUser signedInUser;

  DashboardScreen(this.signedInUser);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AppUser signedInUser;
  int _currentIndex = 0;
  List<NotificationModel> notifications = List();

  void onRequestSubmittedListener() {
    setState(() {
      _currentIndex = 1;
    });
  }

  List<Widget> subScreens() => [
        HomeScreen(signedInUser: signedInUser, onRequestPosted: onRequestSubmittedListener),
        ExploreScreen(signedInUser),
        InboxListScreen(signedInUser),
        GroupsScreen(signedInUser),
      ];

  List<Widget> WebsubScreens() => [
        ExploreScreen(signedInUser),
        InboxListScreen(signedInUser),
        GroupsScreen(signedInUser),
      ];

  @override
  void initState() {
    super.initState();
    signedInUser = widget.signedInUser;
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      notifications.clear();
    });
    FirestoreHelper.getNotificationList(
      signedInUser,
      (NotificationModel model) {
        setState(() {
          notifications.add(model);
        });
      },
      newest: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return LayoutBuilder(
        builder: (ctx, constraints) {
          if (constraints.maxWidth > 1200) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Card(
                        child: Scaffold(
                          backgroundColor: Colors.white,
                          body: SafeArea(
                            child: Column(
                              children: [
                                // App Bar
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset('assets/images/khelbuddy-logo.png', width: 100),
                                      CircleImageInkWell(
                                        onPressed: () {
                                          print('onPressed');
                                          Navigator.push(context, MaterialPageRoute(builder: (ctx) => UserProfileScreen(signedInUser)));
                                        },
                                        size: 40,
                                        image: NetworkImage(signedInUser.displayPictureUrl),
                                        splashColor: Colors.white24,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: kIsWeb ? WebsubScreens()[_currentIndex] : subScreens()[_currentIndex]),
                              ],
                            ),
                          ),
                          bottomNavigationBar: bottomNavigation(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (constraints.maxWidth > 880 && constraints.maxWidth <= 1200) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                children: [
                  Container(width: MediaQuery.of(context).size.width * 0.15, color: Colors.orange),
                  Expanded(
                    child: Scaffold(
                      backgroundColor: Colors.white,
                      body: SafeArea(
                        child: Column(
                          children: [
                            // App Bar
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset('assets/images/khelbuddy-logo.png', width: 100),
                                  CircleImageInkWell(
                                    onPressed: () {
                                      print('onPressed');
                                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => UserProfileScreen(signedInUser)));
                                    },
                                    size: 40,
                                    image: NetworkImage(signedInUser.displayPictureUrl),
                                    splashColor: Colors.white24,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: kIsWeb ? WebsubScreens()[_currentIndex] : subScreens()[_currentIndex]),
                          ],
                        ),
                      ),
                      bottomNavigationBar: bottomNavigation(),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    // App Bar
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/images/khelbuddy-logo.png', width: 100),
                          CircleImageInkWell(
                            onPressed: () {
                              print('onPressed');
                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => UserProfileScreen(signedInUser)));
                            },
                            size: 40,
                            image: NetworkImage(signedInUser.displayPictureUrl),
                            splashColor: Colors.white24,
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: kIsWeb ? WebsubScreens()[_currentIndex] : subScreens()[_currentIndex]),
                  ],
                ),
              ),
              bottomNavigationBar: bottomNavigation(),
//      bottomNavigationBar: BottomNavigationBar(
//        onTap: onTabTapped,
//        // new
//        selectedItemColor: Colors.orange,
//        type: BottomNavigationBarType.fixed,
//        unselectedItemColor: Colors.black45,
//        currentIndex: _currentIndex,
//        // new
//        items: [
//          new BottomNavigationBarItem(
//            icon: Icon(Icons.home),
//            title: Text('Home'),
//          ),
//          new BottomNavigationBarItem(
//            icon: Icon(Icons.explore),
//            title: Text('Explore'),
//          ),
//          new BottomNavigationBarItem(
//            icon: _currentIndex == 2
//                ? Icon(Icons.mail)
//                : notifications.length > 0
//                    ? Stack(
//                        children: [
//                          Icon(Icons.mail),
//                          Positioned(
//                            child: Container(
//                              width: 8,
//                              height: 8,
//                              decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
//                            ),
//                            top: 0,
//                            right: 0,
//                          ),
//                        ],
//                      )
//                    : Icon(Icons.mail),
//            title: Text('Inbox'),
//          ),
//          new BottomNavigationBarItem(
//            icon: Icon(Icons.group),
//            title: Text('Groups'),
//          ),
//        ],
//      ),
            );
          }
        },
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/khelbuddy-logo.png', width: 100),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => SearchScreen(signedInUser)))),
                              SizedBox(width: 12),
                              CircleImageInkWell(
                                onPressed: () {
                                  print('onPressed');
                                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => UserProfileScreen(signedInUser)));
                                },
                                size: 40,
                                image: NetworkImage(signedInUser.displayPictureUrl),
                                splashColor: Colors.white24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: kIsWeb ? WebsubScreens()[_currentIndex] : subScreens()[_currentIndex]),
                ],
              ),
            ),
            onWillPop: _onBackPressed),
        bottomNavigationBar: bottomNavigation(),
//      bottomNavigationBar: BottomNavigationBar(
//        onTap: onTabTapped,
//        // new
//        selectedItemColor: Colors.orange,
//        type: BottomNavigationBarType.fixed,
//        unselectedItemColor: Colors.black45,
//        currentIndex: _currentIndex,
//        // new
//        items: [
//          new BottomNavigationBarItem(
//            icon: Icon(Icons.home),
//            title: Text('Home'),
//          ),
//          new BottomNavigationBarItem(
//            icon: Icon(Icons.explore),
//            title: Text('Explore'),
//          ),
//          new BottomNavigationBarItem(
//            icon: _currentIndex == 2
//                ? Icon(Icons.mail)
//                : notifications.length > 0
//                    ? Stack(
//                        children: [
//                          Icon(Icons.mail),
//                          Positioned(
//                            child: Container(
//                              width: 8,
//                              height: 8,
//                              decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
//                            ),
//                            top: 0,
//                            right: 0,
//                          ),
//                        ],
//                      )
//                    : Icon(Icons.mail),
//            title: Text('Inbox'),
//          ),
//          new BottomNavigationBarItem(
//            icon: Icon(Icons.group),
//            title: Text('Groups'),
//          ),
//        ],
//      ),
      );
    }
  }

  Widget bottomNavigation() {
    if (kIsWeb) {
      return BottomNavigationBar(
        onTap: onTabTapped,
        // new
        selectedItemColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black45,
        currentIndex: _currentIndex,
        // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            title: Text('Explore'),
          ),
          new BottomNavigationBarItem(
            icon: _currentIndex == 2
                ? Icon(Icons.mail)
                : notifications.length > 0
                    ? Stack(
                        children: [
                          Icon(Icons.mail),
                          Positioned(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                            ),
                            top: 0,
                            right: 0,
                          ),
                        ],
                      )
                    : Icon(Icons.mail),
            title: Text('Inbox'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.group),
            title: Text('Groups'),
          ),
        ],
      );
    } else {
      return BottomNavigationBar(
        onTap: onTabTapped,
        // new
        selectedItemColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black45,
        currentIndex: _currentIndex,
        // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            title: Text('Explore'),
          ),
          new BottomNavigationBarItem(
            icon: _currentIndex == 2
                ? Icon(Icons.mail)
                : notifications.length > 0
                    ? Stack(
                        children: [
                          Icon(Icons.mail),
                          Positioned(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                            ),
                            top: 0,
                            right: 0,
                          ),
                        ],
                      )
                    : Icon(Icons.mail),
            title: Text('Inbox'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.group),
            title: Text('Groups'),
          ),
        ],
      );
    }
  }

  Future<bool> _onBackPressed() {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
    } else {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Do you want to exit from App'),
              actions: <Widget>[
                new FlatButton(onPressed: () => Navigator.of(context).pop(false), child: Text("NO")),
                SizedBox(height: 16),
                new FlatButton(onPressed: () => Navigator.of(context).pop(true), child: Text("YES")),
              ],
            ),
          ) ??
          false;
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _refreshNotifications();
  }
}
