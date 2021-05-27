import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/LightColor.dart';
import 'package:indianapp/helpers/DistanceTo.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class CardProdileItem extends StatelessWidget {
  PostActivity request;
  Coordinates _coordinates;

  CardProdileItem(this.request, this._coordinates);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0xfff8f8f8), blurRadius: 15, spreadRadius: 10),
        ],
      ),
      width: MediaQuery.of(context).size.width - 165,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                  margin: EdgeInsets.all(6), padding: EdgeInsets.all(6), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                margin: EdgeInsets.all(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.grey.shade500, size: MediaQuery.of(context).size.height * 0.0155),
                    Text(
                      (' ${((distanceTo.distanceBetween(_coordinates.latitude, _coordinates.longitude, request.currentCoordinates.latitude, request.currentCoordinates.longitude)) / 1000).toStringAsFixed(1)} KM'),
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.014, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: LightColor.orange.withAlpha(40),
                    ),
                    CircleImageInkWell(
                      onPressed: () {},
                      size: MediaQuery.of(context).size.height * 0.165,
                      image: NetworkImage(request.user.displayPictureUrl),
                      splashColor: Colors.white24,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TitleText(text: request.user.name, fontSize: MediaQuery.of(context).size.height * 0.0175),
                const SizedBox(height: 8),
                TitleText(
                  text: Common.convertTimeInMilisToDate(request.dateTimeInMilis),
                  fontSize: MediaQuery.of(context).size.height * 0.014,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
