import 'package:boldo/features/doctor_search/presentation/presentation.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

/// Show a list of doctors in grid mode
class DoctorsGridWidget extends StatelessWidget {
  /// constructor
  DoctorsGridWidget({
    required this.doctors,
    required this.updateFavoriteStatus,
    super.key,
  });

  /// the list of doctors that will be show
  final List<Doctor> doctors;

  /// the callback function on tap favorite icon of a doctor
  final void Function({required Doctor doctor}) updateFavoriteStatus;

  /// key for the list of doctors
  final GlobalKey<AnimatedGridState> griAllDoctorsKey =
      GlobalKey<AnimatedGridState>();

  @override
  Widget build(BuildContext context) {
    return ReorderableBuilder(
      enableDraggable: false,
      children: doctors
          .map(
            (e) => DoctorBoxWidget(
              key: Key(e.id ?? '0'),
              doctor: e,
              onSuccessFavoriteAction: () {
                updateFavoriteStatus(
                  doctor: e,
                );
              },
            ),
          )
          .toList(),
      builder: (children) {
        return GridView.builder(
          key: griAllDoctorsKey,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 5 / 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            return children[index];
          },
        );
      },
    );
  }
}
