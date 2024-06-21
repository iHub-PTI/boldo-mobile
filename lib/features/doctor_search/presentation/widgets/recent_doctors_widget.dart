import 'package:boldo/constants.dart';
import 'package:boldo/features/doctor_search/presentation/presentation.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DoctorsRecentWidget extends StatefulWidget {
  const DoctorsRecentWidget({
    required this.doctors,
    required this.updateFavoriteStatus,
    super.key,
  });

  /// The [Doctor] that will change his favorite status
  final List<Doctor> doctors;

  /// Function that will be call if the action is success
  final void Function({required Doctor doctor}) updateFavoriteStatus;

  @override
  State<DoctorsRecentWidget> createState() => _DoctorsRecentWidgetState();
}

class _DoctorsRecentWidgetState extends State<DoctorsRecentWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    getRecentDoctors();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    return BlocBuilder<RecentDoctorsBloc, RecentDoctorsState>(
      builder: (context, state) {
        if (state is LoadingRecentDoctors) {
          return loadingStatus();
        } else if (state is FailedRecentDoctors) {
          return DataFetchErrorWidget(
            retryCallback: () {
              getRecentDoctors();
            },
          );
        } else {
          return widget.doctors.isNotEmpty
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ConstantsV2.grayLightest,
                          boxShadow: [
                            shadowRegular,
                          ],
                        ),
                        height: 250,
                        child: GridView.builder(
                          physics: const ScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            childAspectRatio: 4 / 3.2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: widget.doctors.length,
                          itemBuilder: (context, index) {
                            return DoctorBoxWidget(
                              doctor: widget.doctors[index],
                              onSuccessFavoriteAction: () {
                                widget.updateFavoriteStatus(
                                  doctor: widget.doctors[index],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : _emptyRecentDoctors();
        }
      },
    );
  }

  void getRecentDoctors() {
    BlocProvider.of<RecentDoctorsBloc>(context).add(
      GetRecentDoctors(
        organizations: Provider.of<DoctorFilterProvider>(context, listen: false)
            .getOrganizationsApplied,
        specializations:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getSpecializationsApplied,
        virtualAppointment:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getLastVirtualAppointmentApplied,
        inPersonAppointment:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getLastInPersonAppointmentApplied,
        names: Provider.of<DoctorFilterProvider>(context, listen: false)
            .getNamesApplied,
      ),
    );
  }

  Widget _emptyRecentDoctors() {
    return Container(
      color: ConstantsV2.grayLightest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 39),
        child: Column(
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/icon/empty_recentDoctors.svg',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                const Text(
                  'No hay consultas recientes',
                  style: TextStyle(
                    color: ConstantsV2.activeText,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'El listado aparecerá aquí una vez que hayas consultado',
                  style: bodyMediumRegular.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
