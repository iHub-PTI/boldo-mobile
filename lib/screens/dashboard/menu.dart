import 'package:boldo/app_config.dart';
import 'package:boldo/blocs/logout_bloc/userLogoutBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/my_account/my_account_screen.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../main.dart';

class MenuScreen extends StatefulWidget {
  final bool setLoggedOut;

  MenuScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<ItemMenu> accountItems = [
    const ItemMenu(
      image: 'assets/icon/person-outline.svg',
      title: 'Editar perfil',
      route: '/profileScreen',
    ),
    const ItemMenu(
      image: 'assets/icon/identification.svg',
      title: 'Mi cuenta',
      page: MyAccount(),
    ),
    const ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Mi familia',
      route: '/familyScreen',
    ),
  ];

  final List<ItemMenu> settingsItems = [
    const ItemMenu(
      image: 'assets/icon/bell.svg',
      title: 'Notificaciones',
      route: null,
    ),
    const ItemMenu(
      image: 'assets/icon/security.svg',
      title: 'Seguridad',
      route: null,
    ),
  ];

  final List<ItemMenu> appItems = [
    const ItemMenu(
      image: 'assets/icon/help-outline.svg',
      title: 'Centro de ayuda',
      route: null,
    ),
    ItemMenu(
      image: 'assets/icon/share.svg',
      title: 'Compartir',
      page: null,
      showRightIcon: false,
      onTap: (context) => _shareApp(context: context),
    ),
  ];

  FlutterAppAuth appAuth = const FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gradientHeight = screenHeight * 0.18;
    final double picturePadding = (screenHeight * 0.15) / 2;
    return BlocListener<UserLogoutBloc, UserLogoutState>(
      listener: (context, state) {
        if (state is UserLogoutFailed) {
          emitSnackBar(
            context: context,
            text: state.response,
            status: ActionStatus.Fail,
          );
        }
      },
      child: Scaffold(
        floatingActionButton: BackButtonLabel(
          iconType: BackIcon.backClose,
          iconColor: ConstantsV2.lightest,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: Stack(
          children: [
            //const Background(text: "menu"),
            Container(
              width: double.infinity,
              height: gradientHeight,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: screenWidth / 49,
                  colors: <Color>[
                    ConstantsV2.patientAppBarColor100,
                    ConstantsV2.patientAppBarColor200,
                    ConstantsV2.patientAppBarColor300,
                  ],
                  center: Alignment(1, screenWidth / 27.5),
                  stops: [0.8, 0.85, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: picturePadding,
                    ),
                    Center(
                      child: ImageViewTypeForm(
                        height: 100,
                        width: 100,
                        border: true,
                        url: patient.photoUrl,
                        gender: patient.gender,
                        borderWidth: 3,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "${patient.givenName ?? ''} ${patient.familyName ?? ''}",
                      style: boldoMenuUserName,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMenuSection(
                                    context,
                                    'Cuenta',
                                    accountItems,
                                  ),
                                  _buildMenuSection(
                                    context,
                                    'Configuraciones',
                                    settingsItems,
                                  ),
                                  _buildMenuSection(
                                    context,
                                    'Aplicación',
                                    appItems,
                                  ),
                                  const Divider(height: 0.3),
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        BlocProvider.of<UserLogoutBloc>(context)
                                            .add(
                                          GetUserLogout(
                                            context: context,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/power-settings-new.svg',
                                            color: ConstantsV2.activeText,
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            'Cerrar sesión',
                                            style: boldoTitleBlackTextStyle
                                                .copyWith(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<UserLogoutBloc, UserLogoutState>(
              builder: (context, state) {
                if (state is UserLogoutLoading) {
                  return Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/loading.gif',
                      height: 60,
                      width: 60,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String sectionTitle,
    List<ItemMenu> sectionItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(
            sectionTitle,
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          color: Colors.white,
          child: Container(
            alignment: Alignment.topLeft,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sectionItems.length * 2 - 1,
              padding: const EdgeInsets.symmetric(vertical: 4),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                if (index.isOdd) {
                  return const Divider(); // Divider between items
                }

                return _buildItemList(context, (index ~/ 2), sectionItems);
              },
              physics: const ClampingScrollPhysics(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemList(BuildContext context, int index, List<ItemMenu> items) {
    return items[index];
  }
}

Future<void> _shareApp({required BuildContext context}) async {
  final box = context.findRenderObject() as RenderBox?;
  final url = appConfig.DEFAULT_APP_URL_DOWNLOAD;
  Share.share(
    'Estoy usando Boldo, el ecosistema de productos digitales de salud del Paraguay. \n Descargalo gratis en: \n$url',
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  );
  return null;
}
