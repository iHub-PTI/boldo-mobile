class PositionEntity {

  String? title;
  String? subtitle;

  double latitude;
  double longitude;

  String? get label {

    String? _label;
    if(title != null){
      _label = title?.trimLeft().trimRight();
    }
    if(_label != null){
      _label = _label + ' ' + (subtitle?.trimLeft().trimRight()?? '');
    }else{
      _label = subtitle?.trimLeft().trimRight();
    }

    return _label;
  } 

  PositionEntity({
    this.latitude = 0.0, 
    this.longitude = 0.0,
    this.title,
    this.subtitle,
  });

  factory PositionEntity.fromJson(Map<String, dynamic> json) => PositionEntity(
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

}