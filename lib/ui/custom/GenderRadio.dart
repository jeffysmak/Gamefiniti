import 'package:flutter/material.dart';
import 'package:indianapp/ui/custom/models/RadioItem.dart';

class GenderRadioWidget extends StatelessWidget {
  final RadioModel _item;

  GenderRadioWidget(this._item);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.call_made, size: 16, color: _item.isSelected ? Colors.white : Colors.orange.withOpacity(0.5)),
            SizedBox(width: 8),
            Text(_item.buttonText,
                style: new TextStyle(color: _item.isSelected ? Colors.white : Colors.black87, fontSize: 18.0)),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: new BoxDecoration(
        color: _item.isSelected ? Colors.orange.withOpacity(0.6) : Colors.transparent,
        border: new Border.all(width: 1.0, color: _item.isSelected ? Colors.orange : Colors.black45),
        borderRadius: const BorderRadius.all(const Radius.circular(32.0)),
      ),
    );
  }
}
