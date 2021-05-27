import 'package:flutter/material.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class GroupTile extends StatelessWidget {
  Group e;

  GroupTile(this.e);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      width: MediaQuery.of(context).size.width - 100,
      child: ClipRRect(
        child: Stack(
          children: [
            Positioned(
              child: Container(
                child: Image.network(
                  e.imageURL,
                  fit: BoxFit.cover,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.black45,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            Align(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0), Colors.black.withOpacity(0.5), Colors.black.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              alignment: Alignment.bottomCenter,
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                child: e.community
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/vip.png', height: 40),
                          SizedBox(width: 8),
                          TitleText(
                            text: '${e.title} Community',
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height * 0.025,
                          ),
                        ],
                      )
                    : TitleText(
                        text: e.title,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.height * 0.025,
                      ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}
