import 'package:boldo/blocs/qr_bloc/qr_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../main.dart';

class QRScanner extends StatefulWidget {
  QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {

  MobileScannerController? cameraController;
  bool _dataLoading = false;
  bool? _showScanner;
  String? code;
  QrImage? qrImage;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    CheckScanner();
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: BlocProvider(
          create: (context) => QrBloc(), // <-- first event,
          child: BlocListener<QrBloc, QrBlocState>(
            listener: (context, state){
              setState(() {
                if(state is Failed){
                  emitSnackBar(
                      context: context,
                      text: state.response,
                      status: ActionStatus.Fail
                  );
                  _dataLoading = false;
                  Navigator.pop(context);
                }
                if(state is Success){
                  _dataLoading = false;
                }
                if(state is QrDecoded){
                  user.isNew = false;
                  Navigator.pushNamedAndRemoveUntil(context, '/familyConnectTransition',
                      ModalRoute.withName('/methods')
                  );
                }
                if(state is Loading){
                  _dataLoading = true;
                }
              });
            },
            child : BlocBuilder<QrBloc, QrBlocState>(
                builder: (context, state){
                  return Stack(
                    children: [
                      if(_showScanner== null)
                        const Center(child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                          backgroundColor: Constants.primaryColor600,
                        ),)
                      else
                        if(_showScanner==true)
                          MobileScanner(
                            allowDuplicates: false,
                            controller: cameraController,
                            onDetect: (Barcode barcode, MobileScannerArguments){
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
                              BlocProvider.of<QrBloc>(context).add(ValidateQr(qrCode: code?? ''));

                            },
                          ),
                      NativeDeviceOrientationReader(
                        useSensor: true, // --> [2]
                        builder: (ctx) {
                          final orientation = NativeDeviceOrientationReader.orientation(ctx);
                          int turns = 0;
                          switch (orientation) {
                            case NativeDeviceOrientation.portraitUp:
                              turns = 0;
                              break;
                            case NativeDeviceOrientation.portraitDown:
                              turns = 2;
                              break;
                            case NativeDeviceOrientation.landscapeLeft:
                              turns = 1;
                              break;
                            case NativeDeviceOrientation.landscapeRight:
                              turns = 3;
                              break;
                            case NativeDeviceOrientation.unknown:
                              turns = 0;
                              break;
                          }
                          // children with rotation
                          return Container();
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
      ),
    );
  }

  void CheckScanner() async {
    bool result = await checkQRPermission(context: context);
    if(result==true){
      setState(() {
        cameraController = MobileScannerController(
          facing: CameraFacing.back,
          torchEnabled: false,
        );
        _showScanner = true;
      });
    }else{
      Navigator.pop(context);
    }
  }

}