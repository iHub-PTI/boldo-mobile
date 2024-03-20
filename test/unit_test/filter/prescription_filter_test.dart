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
       doctors: [doctor1, doctor2],
     );

     PrescriptionFilter _prescriptionFilter2 = PrescriptionFilter(
       start: DateTime(2022,10,3),
       doctors: [doctor2, doctor1],
     );

      expect(_prescriptionFilter1 == _prescriptionFilter2, true);
    });


  });


}