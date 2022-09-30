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
          child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  : specializations != null
                    ? Container(
                      color: Colors.white,
                      height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: specializations!.length > 4 ? 4 : specializations!.length,
                          itemBuilder: _specialization
                      ),
                    )
                    : Container(),
                  Container(
                    height: 44,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // show popup
                          },
                          child: Container(
                            width: 100,
                            color: ConstantsV2.rightBottonNavigaton,
                            child: Center(child: Text('ver todos'))
                          ),
                        )
                      ],
                    ),
                  ),
                  Text('end of horizontal scrollbar')
              ],
            ),
        ),
      ),
    );
  }

  Widget _specialization(BuildContext context, index) {
    return Padding(
      padding: const EdgeInsets.only(top:26.0, bottom: 26, left: 16, right: 16),
      child: Container(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/filter.svg',
              height: 36,
              //color: Colors.black,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      Text('${specializations![index].description != null ? specializations![index].description! : 'Sin descripción'}')
                    ],
                  )
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}
