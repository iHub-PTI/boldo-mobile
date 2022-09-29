import 'package:boldo/blocs/doctors_available_bloc/doctors_available_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

// PRINCIPAL CLASS
class DoctorsAvailable extends StatefulWidget {
  // flag for trigger the GetDoctorsAvailable event
  final bool callFromHome;
  // if callFromHome is True this parameter can be null
  final List<Doctor>? doctors;
  DoctorsAvailable({required this.callFromHome, this.doctors});
  @override
  _DoctorsAvailableState createState() => _DoctorsAvailableState();
}

// STATE CLASS
class _DoctorsAvailableState extends State<DoctorsAvailable> {
  bool _loading = true;
  List<Doctor> doctors = [];
  @override
  void initState() {
    // trigger event
    BlocProvider.of<DoctorsAvailableBloc>(context).add(GetDoctorsAvailable());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [],
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: SafeArea(
        child: BlocListener<DoctorsAvailableBloc, DoctorsAvailableState>(
          listener: (context, state) {
            if (state is Loading) {
              setState(() {
                _loading = true;
              });
            } else if (state is Success) {
              setState(() {
                _loading = false;
              });
            } else if (state is DoctorsLoaded) {
              setState(() {
                doctors = state.doctors;
              });
            }
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          if (widget.callFromHome) {
                            // in this case we don't need do anything
                            Navigator.pop(context);
                          } else {}
                        },
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 25,
                          color: Constants.extraColor400,
                        ),
                        label: Text(
                          'Médicos disponibles',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // go to filter
                      GestureDetector(
                          onTap: () {},
                          child:
                              SvgPicture.asset('assets/icon/change-filter.svg'))
                    ],
                  ),
                ),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 2 / 3,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20),
                          itemCount: doctors.length,
                          itemBuilder: doctorItem,
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget doctorItem(BuildContext context, index) {
    return Stack(
      children: <Widget>[
        // the first item in stack is the doctor profile photo
        doctors[index].photoUrl != null
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    image: DecorationImage(
                      image: NetworkImage(doctors[index].photoUrl!),
                      fit: BoxFit.cover)),
              )
            : Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: doctors[index].gender == 'female'
                    ? SvgPicture.asset(
                        'assets/images/femaleDoctor.svg',
                        fit: BoxFit.cover,
                      )
                    : SvgPicture.asset(
                        'assets/images/maleDoctor.svg',
                        fit: BoxFit.cover,
                      ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
        // the second item in stack is the column of details
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // name of the doctor
            Row(
              children: [
                // this for jump if there is overflow
                Flexible(
                    child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, bottom: 4),
                      child: Text(
                        '${doctors[index].gender=='female' ? 'Dra.' : 'Dr.'} ${doctors[index].givenName!.split(" ")[0] } ${doctors[index].familyName!.split(" ")[0]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ))
              ],
            ),
            // specializations
            doctors[index].specializations != null
              ? doctors[index].specializations!.length > 0
                ? Container(
                  // 52 is the sum of left and right padding plus the space between columns
                  width: MediaQuery.of(context).size.width/2 - 52,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0, bottom: 8,),
                      child: Row(
                        children: [
                          for (int i = 0;
                            i < doctors[index].specializations!.length;
                            i++)
                            Padding(
                              padding: EdgeInsets.only(
                                  left: i == 0 ? 0 : 3.0, bottom: 8),
                              child: Text(
                                "${doctors[index].specializations![i].description}${doctors[index].specializations!.length > 1 && i == 0 ? "," : ""}",
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(235, 139, 118, 1)
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  ),
                )
                : Container()
              : Container(),

          ],
        ),
      
      ],
    );
  }
}
