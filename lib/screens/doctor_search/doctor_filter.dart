import 'package:boldo/blocs/doctors_available_bloc/doctors_available_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorFilter extends StatefulWidget {
  DoctorFilter();
  @override
  _DoctorFilterState createState() => _DoctorFilterState();
}

class _DoctorFilterState extends State<DoctorFilter> {
  bool _loading = true;
  List<Doctor>? doctors;
  List<Specializations>? specializations;
  @override
  void initState() {
    BlocProvider.of<DoctorsAvailableBloc>(context).add(GetSpecializations());
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
            } else if (state is FilterLoaded) {
              setState(() {
                doctors = state.doctors;
              });
            } else if (state is SpecializationsLoaded) {
              setState(() {
                specializations = state.specializations;
              });
            }
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // button to go to back
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 25,
                          color: Constants.extraColor400,
                        ),
                        label: Text(
                          'Búsqueda de médicos',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                _loading
                  // loading 
                  ? const Center(child: CircularProgressIndicator()) 
                  // list of specializations
                  : Card()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
