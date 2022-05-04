import 'package:boldo/screens/family/tabs/defined_relationship_screen.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../main.dart';
import 'familyConnectTransition.dart';

class QRScanner extends StatefulWidget {
  QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {

  MobileScannerController? cameraController;
  String? code;

  @override
  void initState() {
    cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    super.initState();
  }

  @override
  void dispose() {
    cameraController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) async {
              code = barcode.rawValue;
              final QrImage qrImage = QrImage(
                data: code!,
                size: 200,
                embeddedImage: const AssetImage('assets/images/logo.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                ),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: Colors.black,
                ),
              );
              cameraController!.stop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoadingHelper(
                      qrImage: qrImage,
                    )),
              );
              user.identifier = code;
              user.isNew = false;
              await Navigator.pushNamed(context, '/familyTransition');
            },
          )
        ],
      ),
    );
  }

}