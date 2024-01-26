import 'package:boldo/models/Doctor.dart';

// int orderByAvailability(OrganizationWithAvailability a, OrganizationWithAvailability b){
//   if (b.nextAvailability == null && a.nextAvailability == null) {
//     return 0;
//   }
//   if (a.nextAvailability == null) {
//     return 1;
//   }
//   if (b.nextAvailability == null) {
//     return -1;
//   }
//   return DateTime.parse(a.nextAvailability!.availability!)
//       .compareTo(DateTime.parse(b.nextAvailability!.availability!));
// }

int orderByAvailabilities(OrganizationWithAvailabilities a, OrganizationWithAvailabilities b){
  if (b.nextAvailability == null && a.nextAvailability == null) {
    return 0;
  }
  if (a.nextAvailability == null) {
    return 1;
  }
  if (b.nextAvailability == null) {
    return -1;
  }
  return DateTime.parse(a.nextAvailability!.availability!)
      .compareTo(DateTime.parse(b.nextAvailability!.availability!));
}

// int orderByOrganizationAvailability(Doctor a, Doctor b){
//   if (b.organizations?.first.nextAvailability == null && a.organizations?.first.nextAvailability == null) {
//     return 0;
//   }
//   if (a.organizations?.first.nextAvailability == null) {
//     return 1;
//   }
//   if (b.organizations?.first.nextAvailability == null) {
//     return -1;
//   }
//   return DateTime.parse(a.organizations!.first.nextAvailability!.availability!)
//       .compareTo(DateTime.parse(b.organizations!.first.nextAvailability!.availability!));
// }