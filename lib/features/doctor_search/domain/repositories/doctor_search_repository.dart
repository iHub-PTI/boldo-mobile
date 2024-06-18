import 'package:boldo/models/Doctor.dart';

/// Repository for Doctor module
abstract class DoctorRepository {
  /// Change de favorite status of the [Doctor]
  Future<void> putFavoriteStatus({
    required Doctor doctor,
    required bool favoriteStatus,
  });
}
