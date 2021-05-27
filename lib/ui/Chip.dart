import 'package:flutter/material.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';

class CustomChip extends StatelessWidget {
  InterestModel model;
  Function onSelect;

  CustomChip(this.model, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: model.isSelected,
      label: Text(
        model.title,
        style: TextStyle(color: model.isSelected ? Colors.black87 : Colors.black54),
      ),
      backgroundColor: model.isSelected ? Colors.orange : Colors.orange.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        side: BorderSide(width: 1, color: model.isSelected ? Colors.orange : Colors.grey.withOpacity(0.6)),
      ),
      onSelected: model.isDisabled ? null : (bool value) {
        onSelect.call(model);
      },
    );
  }
}
