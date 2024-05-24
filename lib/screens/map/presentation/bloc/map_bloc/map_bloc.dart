import 'dart:typed_data';

import 'package:boldo/models/PositionEntity.dart';
import 'package:boldo/screens/map/map.dart';
import 'package:boldo/utils/MapLauncher.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    on<InitMap>((event, emit) async {
      emit(MapLoading());

      List<Marker> customMarkers = [];

      List<PinMap> _pins = getPins(positions: event.positions);

      MarkerGenerator(_pins, 
      (bitmaps) {
        customMarkers = mapBitmapsToMarkers(
          bitmaps: bitmaps, 
          pins: _pins,
        );
        add(ShowPins(markers: customMarkers));
      }).generate(event.context);


    });
    on<ShowPins>((event, emit){
      emit(MapSuccess(customMarkers: event.markers));
    });
  }

  List<Marker> mapBitmapsToMarkers({
    required List<Uint8List> bitmaps, 
    required List<PinMap> pins,
  }) {

    List<Marker> customMarkers = [];

    bitmaps.asMap().forEach((i, bmp) {

      customMarkers.add(Marker(
        markerId: MarkerId("$i"),
        position: LatLng(pins[i].position.latitude, pins[i].position.longitude),
        icon: BitmapDescriptor.fromBytes(bmp),
        onTap: () => MapsLauncher.launchCoordinates(
          pins[i].position.latitude, 
          pins[i].position.longitude,
          pins[i].position.label,
        )
      ));

    });

    return customMarkers;

  }

  List<PinMap> getPins({required List<PositionEntity> positions}){
    return positions.map((PositionEntity position) => 
    PinMap(
      position: position,
      title: position.title?? 'unknown', 
      subtitle: position.subtitle,
    )).toList();
  }

}
