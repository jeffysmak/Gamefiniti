class AgeFactor {
  int minAge;
  int maxAge;
  int value;
  bool isSelected;

  AgeFactor(this.minAge, this.maxAge, this.isSelected, {this.value});

  AgeFactor.optional(this.minAge, this.value, this.isSelected);

  AgeFactor.fromMap(Map<String, dynamic> map) {
    this.minAge = map['minAge'];
    this.maxAge = map['maxAge'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['minAge'] = minAge;
    map['maxAge'] = maxAge;
    return map;
  }

  String format() {
    return maxAge != null ? '$minAge - $maxAge' : '$minAge+';
  }
}
