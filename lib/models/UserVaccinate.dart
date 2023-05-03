
List<UserVaccinate> userVaccinateFromJson(dynamic str) =>
    List<UserVaccinate>.from(str.map((x) => UserVaccinate.fromJson(x)));

class UserVaccinate {
    UserVaccinate({
        required this.diseaseCode,
        this.vaccineApplicationList,
        required this.version,
    });

    String diseaseCode;
    List<VaccineApplicationList>? vaccineApplicationList;
    int version;

    factory UserVaccinate.fromJson(Map<String, dynamic> json) => UserVaccinate(
        diseaseCode: json["diseaseCode"],
        vaccineApplicationList: List<VaccineApplicationList>.from(json["vaccineApplicationList"].map((x) => VaccineApplicationList.fromJson(x))),
        version: json["version"],
    );
}

class VaccineApplicationList {
    VaccineApplicationList({
        this.diseaseCode,
        this.dose,
       required this.vaccineApplicationDate,
        this.vaccineName,
    });

   String? diseaseCode;
  String? dose;
  DateTime vaccineApplicationDate;
  String? vaccineName;

    factory VaccineApplicationList.fromJson(Map<String, dynamic> json) =>
      VaccineApplicationList(
        diseaseCode: json["diseaseCode"],
        dose: json["dose"].toString(),
        vaccineApplicationDate: DateTime.parse(json["vaccineApplicationDate"]),
        vaccineName: json["vaccineName"],
      );

  Map<String, dynamic> toJson() => {
        "diseaseCode": diseaseCode,
        "dose": dose,
        "vaccineApplicationDate":
            "${vaccineApplicationDate.year.toString().padLeft(4, '0')}-${vaccineApplicationDate.month.toString().padLeft(2, '0')}-${vaccineApplicationDate.day.toString().padLeft(2, '0')}",
        "vaccineName": vaccineName,
      };
}
