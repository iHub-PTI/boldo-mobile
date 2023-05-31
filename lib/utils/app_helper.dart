import 'package:boldo/app_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<bool> checkUpdated() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if(isVersionGreaterThan(appConfig.LAST_AVAILABLE_VERSION,packageInfo.version))
    return true;
  return false;
}

Future<bool> checkRequiredUpdated() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if(isVersionGreaterThan(appConfig.LAST_STABLE_VERSION,packageInfo.version))
    return true;
  return false;
}

bool isVersionGreaterThan(String newVersion, String currentVersion){
  List<String> currentV = currentVersion.split(".");
  List<String> newV = newVersion.split(".");
  bool a = false;
  for (var i = 0 ; i <= 2; i++){
    a = int.parse(newV[i]) > int.parse(currentV[i]);
    if(int.parse(newV[i]) != int.parse(currentV[i])) break;
  }
  return a;
}