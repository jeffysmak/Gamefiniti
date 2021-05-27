import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/Swapping.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/explore/DetailedProfileCard.dart';
import 'package:indianapp/ui/dashboard/postactivity/PostInterest.dart';
import 'package:indianapp/ui/widgets/CardItem.dart';
import 'package:location/location.dart';

class ExploreScreen extends StatefulWidget {
  AppUser user;

  ExploreScreen(this.user);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  AppUser user;
  List<PostActivity> requestNearby;
  Coordinates coordinates;

  @override
  void initState() {
    super.initState();
    this.user = widget.user;
    coordinates = Common.coordinates;
    _getNearbyKhelBuddyRequests();
  }

  void _getNearbyKhelBuddyRequests() async {
    requestNearby = List();
    FirestoreHelper.getNearByRequestsByKm(
      user,
      2000,
      Coordinates(user.latitude, user.longitude),
      (PostActivity request) {
        setState(() {
          requestNearby.add(request);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Discover nearby',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 2.5,
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: requestNearby.length > 0
                                  ? ListView.builder(
                                      itemBuilder: (ctx, position) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => SwapItem(
                                                  requestNearby[position],
                                                  currentSigninUser: user,
                                                  fromNotification: false,
                                                ),
                                              ),
                                            );
                                          },
                                          child: CardProdileItem(requestNearby[position], coordinates),
                                        );
                                      },
                                      itemCount: requestNearby.length,
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                    )
                                  : Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Image.asset(
                                              'assets/images/no_result.gif',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Explore',
                                style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 16),
                              color: Colors.black87,
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance.collection(FirestoreHelper.KEY_Interests).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    physics: BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
                                    itemBuilder: (BuildContext ctx, int position) {
                                      InterestModel interest = InterestModel.fromMap(
                                        snapshot.data.docs[position].data(),
                                        id: snapshot.data.docs[position].id,
                                      );
                                      return GestureDetector(
                                        child: ClipRRect(
                                          child: Container(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  child: Image.network(
                                                    interest.imageUrl,
                                                    height: MediaQuery.of(context).size.height * 0.25,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.bottomLeft,
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.3),
                                                  ),
                                                  child: Text(
                                                    interest.title,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: MediaQuery.of(context).size.height * 0.02),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (ctx) => PostNewInterest(
                                                selectedInterest: [interest],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    itemCount: snapshot.data.docs.length,
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
