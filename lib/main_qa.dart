import 'package:boldo/firebase_options_qa.dart';
import 'package:boldo/flavors.dart';
import 'package:boldo/main.dart';

Future<void> main() async {
  await mainCommon(
    flavor: Flavors.qa,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}