import 'package:flutter/material.dart';
import 'package:indianapp/LightColor.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class InterestItemWidget extends StatelessWidget {
  InterestModel model;
  Function onSelected;
  BuildContext context;

  InterestItemWidget(this.model, this.onSelected,this.context);

  @override
  Widget build(BuildContext context) {
    return model.isDisabled ? _disabledWidget() : _enabledWidget();
  }

  Widget _enabledWidget() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: model.isSelected ? model.parseColor().withOpacity(0.5) : LightColor.grey.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              model.icon,
              width: MediaQuery.of(context).size.height * 0.05,
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TitleText(
              text: model.title,
              fontSize: MediaQuery.of(context).size.height * 0.012,
              color: model.isSelected ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ),
      onTap: onSelected,
    );
  }

  Widget _disabledWidget() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          shape: BoxShape.rectangle,
          color: Colors.grey.withOpacity(0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              model.icon,
              width: MediaQuery.of(context).size.height * 0.05,
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TitleText(
              text: model.title,
              fontSize: MediaQuery.of(context).size.height * 0.012,
              color: Colors.grey.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
