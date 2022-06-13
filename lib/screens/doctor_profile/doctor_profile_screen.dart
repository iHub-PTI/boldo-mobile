import 'package:boldo/utils/expandable_card/expandable_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/Doctor.dart';
import '../../constants.dart';
import '../../utils/helpers.dart';

class DoctorProfileScreen extends StatefulWidget{
  const DoctorProfileScreen({Key? key, required this.doctor}) : super(key: key);
  final Doctor doctor;

  @override
  State<StatefulWidget> createState() =>
    _DoctorProfileScreenState();

}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  
  List<NextAvailability> availabilities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ExpandableCardPage(
          page: Background(
            doctor: widget.doctor,
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: Container(
                height: MediaQuery.of(context).size.height - 130,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.75,
                                child: Card(
                                  elevation: 0.0,
                                  color: ConstantsV2.lightGrey.withOpacity(0.80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                      color: ConstantsV2.lightGrey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${getDoctorPrefix(widget.doctor.gender!)}",
                                              style: boldoHeadingTextStyle.copyWith(color: ConstantsV2.orange),
                                            ),
                                            Flexible(
                                              child: Text(
                                                "${widget.doctor.givenName?.split(" ")[0]} ${widget.doctor.familyName?.split(" ")[0]}",
                                                style: boldoHeadingTextStyle.copyWith(color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (widget.doctor.specializations != null)
                                          Align(
                                            alignment: Alignment.center,
                                            child: SingleChildScrollView(
                                              scrollDirection:
                                              Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  for (var specialization
                                                  in widget.doctor.specializations!)
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 4),
                                                      child: Text(
                                                        "${specialization.description}",
                                                        style: boldoSubTextMediumStyle.copyWith(
                                                            color: ConstantsV2.activeText),
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
                              ),
                              Card(
                                elevation: 0.0,
                                color: ConstantsV2.lightGrey,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: Align(
                                      widthFactor: 1.0,
                                      heightFactor: 1.0,
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: SvgPicture.asset(
                                            'assets/icon/close_black.svg',
                                            height: 17,)
                                      ),)
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(),
                          Row(
                            children: [
                              Card(
                                elevation: 0.0,
                                color: ConstantsV2.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: ConstantsV2.lightGrey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Text("18:00")
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 0.0,
                                color: ConstantsV2.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: ConstantsV2.lightGrey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Text("18:30")
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 0.0,
                                color: ConstantsV2.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: ConstantsV2.lightGrey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Text("19:00")
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                ),
              ),
            ),
          ),
          expandableCard: ExpandableCard(
            handleColor: ConstantsV2.orange,
            backgroundColor: Colors.white.withOpacity(0.85),
            maxHeight: MediaQuery.of(context).size.height-120,
            minHeight: MediaQuery.of(context).size.height*0.2,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.doctor.biography != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Biografía",
                          style: boldoSubTextMediumStyle.copyWith(color: Colors.black),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(widget.doctor.biography??'',
                            style: boldoCorpMediumBlackTextStyle.copyWith(
                                color: ConstantsV2.inactiveText)),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Background extends StatelessWidget {
  final Widget child;
  final Doctor doctor;
  const Background({
    Key? key,
    required this.child,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: doctor.photoUrl == null
                ? SvgPicture.asset(
              doctor.gender == "female"
                  ? 'assets/images/femaleDoctor.svg'
                  : 'assets/images/maleDoctor.svg',
              fit: BoxFit.cover,)
                : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: doctor.photoUrl?? '',
              progressIndicatorBuilder:
                  (context, url, downloadProgress) =>
                  Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
                      backgroundColor:
                      Constants.primaryColor600,
                    ),
                  ),
              errorWidget: (context, url, error) =>
              const Icon(Icons.error),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
