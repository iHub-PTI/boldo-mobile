import 'package:boldo/blocs/logout_bloc/userLogoutBloc.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/organizations/memberships_screen.dart';
import 'package:boldo/screens/privacy_policy/privacy_policy.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/screens/terms_of_services/terms_of_services.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:boldo/constants.dart';

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
      image: 'assets/icon/family.svg',
      title: 'Editar perfil',
      route: '/familyScreen',
    ),
    const ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Mi cuenta',
      route: '/familyScreen',
    ),
    const ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Mi familia',
      route: '/familyScreen',
    ),
  ];

  final List<ItemMenu> settingsItems = [
    const ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Notificaciones',
      route: '/familyScreen',
    ),
    const ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Seguridad',
      route: '/familyScreen',
    ),
  ];

  final List<ItemMenu> appItems = [
    const ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Centro de ayuda',
      route: '/familyScreen',
    ),
  ];

  final List<ItemMenu> items = [
    const ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Mi Familia',
      route: '/familyScreen',
    ),
    ItemMenu(
      image: 'assets/icon/credit-card.svg',
      title: 'Mis Centros Asistenciales',
      page: Organizations(),
    ),
    const ItemMenu(
      image: 'assets/icon/shield-check.svg',
      title: 'Políticas de privacidad',
      page: PrivacyPolicy(),
    ),
    const ItemMenu(
      image: 'assets/icon/document-text.svg',
      title: 'Términos de servicio',
      page: TermsOfServices(),
    ),
    const ItemMenu(
      image: 'assets/icon/share.svg',
      title: 'Compartir',
      page: null,
    ),
    // const ItemMenu(
    //   image: 'assets/icon/adjustments.svg',
    //   title: 'Configuraciones',
    //   page: null,
    // ),
  ];

  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          body: Stack(children: [
            //const Background(text: "menu"),
            Container(
              width: double.infinity,
              height: 122,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    // radius: MediaQuery.of(context).size.width / 180,
                    colors: <Color>[
                      ConstantsV2.patientAppBarColor300,
                      ConstantsV2.patientAppBarColor200,
                      ConstantsV2.patientAppBarColor100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
            ),
            SafeArea(
              child: Container(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Center(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/profileScreen');
                      },
                      child: ImageViewTypeForm(
                        height: 100,
                        width: 100,
                        border: true,
                        url: patient.photoUrl,
                        gender: patient.gender,
                        borderWidth: 3,
                      ),
                    )),
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
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMenuSection(
                                      context, 'Cuenta', accountItems),
                                  _buildMenuSection(context, 'Configuraciones',
                                      settingsItems),
                                  _buildMenuSection(
                                    context,
                                    'Aplicación',
                                    appItems,
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: items.length,
                                      padding: const EdgeInsets.all(16),
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: _buildItem,
                                      physics: const ClampingScrollPhysics(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      BlocProvider.of<UserLogoutBloc>(context)
                                          .add(GetUserLogout(context: context));
                                    },
                                    icon: SvgPicture.asset(
                                      "assets/icon/power-settings-new.svg",
                                      color: ConstantsV2.yellow,
                                    ),
                                    label: Text(
                                      "Cerrar Sesión",
                                      style: boldoSubTextStyle.copyWith(
                                        color: ConstantsV2.grayDark,
                                      ),
                                    ),
                                  ),
                                ),
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
                      ));
                } else {
                  return Container();
                }
              },
            )
          ]),
        ));
  }

  Widget _buildMenuSection(
      BuildContext context, String sectionTitle, List<ItemMenu> sectionItems) {
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
                  return Divider(); // Divider between items
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

  Widget _buildItem(BuildContext context, int index) {
    return items[index];
  }

  Widget _buildItemList(BuildContext context, int index, List<ItemMenu> items) {
    return items[index];
  }
}
