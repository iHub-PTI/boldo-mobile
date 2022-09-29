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
      children: [
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
          )
      ],
    );
  }
}
