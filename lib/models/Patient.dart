class Patient {
  Patient({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.password,
    this.phone,
  });
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String password;
  final String phone;

  Patient copyWith({
    String id,
    String username,
    String firstName,
    String lastName,
    String email,
    String gender,
    String password,
    String phone,
  }) =>
      Patient(
        id: id ?? this.id,
        username: username ?? this.username,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email,
        gender: gender ?? this.gender,
        password: password ?? this.password,
        phone: phone ?? this.phone,
      );

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json["id"],
        username: json["username"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        gender: json["gender"],
        password: json["password"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "gender": gender,
        "password": password,
        "phone": phone,
      };
}
