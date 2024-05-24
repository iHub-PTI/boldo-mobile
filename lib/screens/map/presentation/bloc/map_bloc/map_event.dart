part of 'map_bloc.dart';

@immutable
abstract class MapEvent {}

class InitMap extends MapEvent {
  final BuildContext context;
  final List<PositionEntity> positions;
  InitMap({
    required this.context, 
    required this.positions,
  });
}

class ShowPins extends MapEvent {
  final List<Marker> markers;
  ShowPins({required this.markers});
}

