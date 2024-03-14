import 'package:boldo/blocs/passport_bloc/passportBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:qr_flutter/qr_flutter.dart';
import '../../widgets/background.dart';

class UserQrDetail extends StatefulWidget {
  const UserQrDetail({Key? key}) : super(key: key);

  @override
  State<UserQrDetail> createState() => _UserQrDetailState();
}

class _UserQrDetailState extends State<UserQrDetail> {
  bool _isloading = false;
  //_failedConectionCounter is used to check if user is trying consecutive way the same failed connection,
  //if the failed persist in the third intent send user to login page again, feel free to improve this
  int _failedConectionCounter = 0;
  @override
  void initState() {
    BlocProvider.of<PassportBloc>(context).add(GetUserQrCode());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? qrUrlCode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            const Background(text: "linkFamily"),
            Column(
              children: [
                Expanded(
                  child: BlocListener<PassportBloc, PassportState>(listener: (context, state) {
                  if (state is QrUrlLoaded) {
                    setState(() {
                      qrUrlCode = state.url;
                    });
                  } else if (state is Failed || state is Success) {
                    if (state is Failed) {
                      _failedConectionCounter++;
                    } else {
                      _failedConectionCounter = 0;
                    }
                    setState(() {
                      _isloading = false;
                    });
                  } else if (state is Loading) {
                    setState(() {
                      _isloading = true;
                    });
                  }
                      }, child: BlocBuilder<PassportBloc, PassportState>(builder: (context, state) {
                  if (state is Failed) {
                    return Align(
                        alignment: Alignment.center,
                        child: DataFetchErrorWidget(
                          retryCallback: () async {
                            if (_failedConectionCounter >= 3) {
                              await storage.deleteAll();
                              await prefs.clear();
                              _failedConectionCounter = 0;
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HeroScreenV2(),
                                  ),
                                  (route) => false);
                            } else {
                              BlocProvider.of<PassportBloc>(context)
                                  .add(GetUserDiseaseList());
                            }
                          },
                        ));
                  }
                
                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0, right: 15),
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.close,
                              )),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 250,
                          width: 250,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                side: BorderSide(width: 3, color: Constants.accordionbg)),
                            child: qrUrlCode != null
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: QrImage(
                                      data: qrUrlCode!,
                                      version: QrVersions.auto,
                                      // size: 250.0,
                                    ),
                                  )
                                : loadingStatus(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              // SvgPicture.asset(
                              //   'assets/icon/config.svg',
                              // ),
                              Spacer(),
                              GestureDetector(
                                onTap: (() {
                                  BlocProvider.of<PassportBloc>(context)
                                      .add(GetUserVaccinationPdfPressed(pdfFromHome: false));
                                }),
                                child: SvgPicture.asset(
                                  'assets/decorations/download.svg',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isloading)
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.white.withOpacity(0.3),
                                child: LoadingHelper()))
                    ],
                  );
                      })),
                    ),
              ],
            ),
            
              ], ));
  }
}
