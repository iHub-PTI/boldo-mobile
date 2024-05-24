import 'package:boldo/blocs/qr_bloc/qr_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/background.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator extends StatelessWidget {
  const QRGenerator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthQr = 244;

    return Scaffold(
      body: BlocProvider(
        create: (context) => QrBloc()..add(GetQRCode()), // <-- first event,
        child: Stack(
          children: [
            const Background(text: "linkFamily"),
            SafeArea(
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BackButtonLabel(
                              iconType: BackIcon.backArrow,
                              iconColor: BackIcon.backClose.iconColor,
                              labelText: 'Mi Familia',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 26.0,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Boldo te permite designar a una persona de tu "
                              "confianza para la gestión de tu perfil de salud.",
                              style: boldoSubTextMediumStyle.copyWith(
                                color: ConstantsV2.activeText,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Mostrale este código para darle acceso.",
                              style: boldoSubTextMediumStyle.copyWith(
                                color: ConstantsV2.activeText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: BlocBuilder<QrBloc, QrBlocState>(
                      builder: (BuildContext context, state) {
                        if (state is QrObtained) {
                          return Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            child: QrImage(
                              data: state.qrCode.qrCode ?? "empty code",
                              embeddedImage:
                                  const AssetImage('assets/images/logo.png'),
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.circle,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.circle,
                                color: Colors.black,
                              ),
                              size: widthQr *
                                  (MediaQuery.of(context).size.width / 360),
                            ),
                          );
                        } else if (state is Failed) {
                          return DataFetchErrorWidget(
                            retryCallback: () =>
                                BlocProvider.of<QrBloc>(context)
                                    .add(GetQRCode()),
                          );
                        } else {
                          return loadingStatus();
                        }
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      bottom: 24,
                      right: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Row(
                            children: [
                              Text(
                                'Cancelar',
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.cancel_rounded,
                                size: 20,
                                color: ConstantsV2.orange,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
