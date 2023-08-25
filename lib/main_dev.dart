import 'package:boldo/firebase_options_dev.dart';
import 'package:boldo/flavors.dart';
import 'package:boldo/main.dart';

Future<void> main() async {
  await mainCommon(
    flavor: Flavors.dev,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}