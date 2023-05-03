import 'package:boldo/models/UserVaccinate.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../main.dart';

class VaccinateCard extends StatefulWidget {
  final UserVaccinate? userVaccinate;
  // this contains the scheme status
  final bool? completeVaccineRecord;
  const VaccinateCard({Key? key, required this.userVaccinate, required this.completeVaccineRecord})
      : super(key: key);

  @override
  State<VaccinateCard> createState() => _VaccinateCardState();
}

class _VaccinateCardState extends State<VaccinateCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: vaccineNoEmpty(),
    );
  }

  Column vaccineNoEmpty() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('vacunas contra ', style: boldoSubTextStyle),
            const SizedBox(
              width: 5,
            ),
            Text(
              widget.userVaccinate!.diseaseCode,
              style: boldoHeadingTextStyle,
            )
          ],
        ),
        const SizedBox(height: 5),
        widget.completeVaccineRecord!
            ? Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icon/check.svg'),
                    const SizedBox(width: 5),
                    const Text(
                      'Esquema completo',
                      style: TextStyle(color: Color.fromRGBO(40, 187, 143, 1)),
                    ),
                  ],
                ),
              )
            : Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icon/check.svg',
                      color: Colors.yellow,
                    ),
                    const SizedBox(width: 5),
                    const Text('Esquema incompleto'),
                  ],
                ),
              ),
        const SizedBox(height: 5),
        Container(
          height: MediaQuery.of(context).size.width >
                  MediaQuery.of(context).size.height
              ? 80
              // all options are relative to list container minus title size
              : (MediaQuery.of(context).size.height < 1200)
                  ? (MediaQuery.of(context).size.height < 800)
                      ? (MediaQuery.of(context).size.height * 0.415) - 95
                      : (MediaQuery.of(context).size.height * 0.35) - 95
                  : (MediaQuery.of(context).size.height * 0.4) - 95,
          child: Scrollbar(
            isAlwaysShown: true,
            child: ListView.builder(
                dragStartBehavior: DragStartBehavior.down,
                reverse: false,
                itemCount: widget.userVaccinate!.vaccineApplicationList!.length,
                itemBuilder: (BuildContext context, int index) {
                  final disease =
                      widget.userVaccinate!.vaccineApplicationList![index];
                  return VacinnateDetail(
                      title: disease.dose!.contains('°')
                          ? disease.dose!
                          : disease.dose!.contains('1')
                              ? '1° Dosis'
                              : disease.dose!.contains('2')
                                  ? '2° Dosis'
                                  : (disease.dose!),
                      detail: disease.vaccineName,
                      date: DateFormat('dd MMMM yyyy')
                          .format(disease.vaccineApplicationDate));
                }),
          ),
        ),
      ],
    );
  }
}

class VacinnateDetail extends StatelessWidget {
  final String? title;
  final String? detail;
  final String? date;
  const VacinnateDetail({
    Key? key,
    this.title = '',
    this.detail = '',
    this.date = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        color: Constants.otherColor800,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title!, style: boldoSubTextStyle.copyWith(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                detail!,
                maxLines: 2,
                style: boldoSubTextStyle.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                date!,
                style: const TextStyle(
                    color: Color(0xff707882),
                    fontSize: 10,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
        ),
      ),
    );
  }
}
