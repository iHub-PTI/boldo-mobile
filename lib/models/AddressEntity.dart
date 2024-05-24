
class AddressEntity {

  String? id,
      addressDescription,
      city,
      cityDisplay,
      state,
      stateDisplay
  ;

  AddressEntity({
    this.id,
    this.addressDescription,
    this.city,
    this.cityDisplay,
    this.state,
    this.stateDisplay,
  });

  factory AddressEntity.fromJson(Map<String, dynamic> json) => AddressEntity(
    id: json['id'],
    addressDescription: json['addressDescription'],
    city: json['city'],
    cityDisplay: json['cityDisplay'],
    state: json['state'],
    stateDisplay: json['stateDisplay'],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['addressDescription'] = addressDescription;
    data['city'] = city;
    data['cityDisplay'] = cityDisplay;
    data['state'] = state;
    data['stateDisplay'] = stateDisplay;
    return data;
  }
}
