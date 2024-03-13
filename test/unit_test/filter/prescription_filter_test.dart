import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/filters/PrescriptionFilter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group("prescription filter comparing", () {

    test('compare filter wit unordered list of doctors', () {

      Doctor doctor1 = Doctor(
        id: '1',
      );

      Doctor doctor2 = Doctor(
        id: '2',
      );

     PrescriptionFilter _prescriptionFilter1 = PrescriptionFilter(
       start: DateTime(2022,10,3),
       doctors: [doctor1.id, doctor2.id],
     );

     PrescriptionFilter _prescriptionFilter2 = PrescriptionFilter(
       start: DateTime(2022,10,3),
       doctors: [doctor2.id, doctor1.id],
     );

      expect(_prescriptionFilter1 == _prescriptionFilter2, true);
    });


  });


}