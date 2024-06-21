import 'package:boldo/constants.dart';
import 'package:boldo/features/doctor_search/presentation/presentation.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Paint a Start with action to set favorite or no the [Doctor]
class DoctorFavoriteIcon extends StatelessWidget {
  /// Paint a Start with action to set favorite or no the [Doctor]
  const DoctorFavoriteIcon({
    required this.doctor,
    this.onSuccessCallback,
    super.key,
  });

  /// The [Doctor] that will change his favorite status
  final Doctor doctor;

  /// Function that will be call if the action is success
  final void Function()? onSuccessCallback;

  @override
  Widget build(BuildContext context) {
    final favoriteActionBloc =
        FavoriteDoctorBlocFactory.getBloc(doctorId: doctor.id ?? '');
    return BlocProvider<FavoriteActionBloc>.value(
      value: favoriteActionBloc,
      child: BlocBuilder<FavoriteActionBloc, FavoriteActionState>(
        builder: (BuildContext context, state) {
          return BlocListener<FavoriteActionBloc, FavoriteActionState>(
            listener: (context, state) {
              if (state is FailedFavoriteAction) {
                emitSnackBar(
                  context: context,
                  text: "No se pudo realizar la acción",
                  status: ActionStatus.Fail,
                );
              }
              if (state is SuccessFavoriteAction) {
                doctor.isFavorite = !doctor.isFavorite;
                onSuccessCallback?.call();
              }
            },
            child: BlocBuilder<FavoriteActionBloc, FavoriteActionState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: state is LoadingFavoriteAction
                      ? () => {}
                      : () {
                          BlocProvider.of<FavoriteActionBloc>(context).add(
                            PutFavoriteStatus(
                              doctor: doctor,
                              favoriteStatus: !doctor.isFavorite,
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/icon/favorite-star.svg',
                      color:
                          doctor.isFavorite ? ConstantsV2.accentRegular : null,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
