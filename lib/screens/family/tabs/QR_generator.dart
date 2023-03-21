import 'package:boldo/blocs/qr_bloc/qr_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../main.dart';

class QRGenerator extends StatelessWidget {
  const QRGenerator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
          create: (context) => QrBloc()..add(GetQRCode()), // <-- first event,
          child: Stack(
              children: [
                const Background(text: "linkFamily"),
                SafeArea(
                  child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Mi Familia",
                                style: boldoTitleBlackTextStyle.copyWith(
                                    color: ConstantsV2.activeText
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "Boldo te permite designar a una persona de tu "
                                      "confianza para la gestión de tu perfil de salud.",
                                  style: boldoSubTextMediumStyle.copyWith(
                                      color: ConstantsV2.activeText
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20,),
                              Flexible(
                                child: Text(
                                  "Mostrale este código para darle acceso",
                                  style: boldoSubTextMediumStyle.copyWith(
                                      color: ConstantsV2.activeText
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child:BlocBuilder<QrBloc, QrBlocState>(
                            builder: (BuildContext context, state) {
                              if(state is QrObtained){
                                return Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.symmetric(vertical: 80, horizontal: 58),
                                  child: QrImage(
                                    data: state.qrCode.qrCode?? "empty code",
                                    embeddedImage: const AssetImage('assets/images/logo.png'),
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.circle,
                                      color: Colors.black,
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.circle,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }else if(state is Failed){
                                return DataFetchErrorWidget(
                                  retryCallback: () =>
                                    BlocProvider.of<QrBloc>(context).add(
                                        GetQRCode()
                                    )
                                );
                              }else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                                    backgroundColor: Constants.primaryColor600,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ]
                  ),
                )
              ]
          )
        ),
    );
  }
}