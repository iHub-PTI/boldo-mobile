part of 'map_bloc.dart';

@immutable
abstract class MapState{}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapFailed extends MapState {
  final response;
  MapFailed({required this.response});
}

class MapSuccess extends MapState {
  final List<Marker> customMarkers;
  final CameraPosition initialCameraPosition;
  MapSuccess({
    required this.customMarkers,
    this.initialCameraPosition = const CameraPosition(
      target: LatLng(
        -25.2954533, 
        -57.6170859,
      ),
      zoom: 14.4746,
    )
  });
}