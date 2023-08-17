import 'package:boldo/firebase_options_prod.dart';
import 'package:boldo/flavors.dart';
import 'package:boldo/main.dart';

Future<void> main() async {
  await mainCommon(
    flavor: Flavors.prod,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}