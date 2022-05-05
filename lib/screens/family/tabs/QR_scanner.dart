import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/screens/family/tabs/defined_relationship_screen.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _dataLoading = false;
  String? code;
  QrImage? qrImage;

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
      body: BlocListener<PatientBloc, PatientState>(
        listener: (context, state){
          setState(() {
            if(state is Failed){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response!),
                  backgroundColor: Colors.redAccent,
                ),
              );
              _dataLoading = false;
            }
            if(state is Success){
              _dataLoading = false;
            }
            if(state is RedirectNextScreen){
              user.isNew = false;
              Navigator.pushNamed(context, '/familyTransition');
            }
            if(state is RedirectBackScreen){
              Navigator.pop(context);
            }
            if(state is Loading){
              _dataLoading = true;
            }
          });
        },
        child : BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state){
          return Stack(
            children: [
              MobileScanner(
                allowDuplicates: false,
                controller: cameraController,
                onDetect: (barcode, args) async {
                  code = barcode.rawValue;
                  qrImage= QrImage(
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
                  BlocProvider.of<PatientBloc>(context).add(ValidateQr(id: code?? ''));
                  
                },
              ),
              if(_dataLoading)
                Align(
                    alignment: Alignment.center,
                    child: Container(
                        child: LoadingHelper(qrImage: qrImage,)
                    )
                )
            ],
          );
        }
        ),
      ),
    );
  }

}