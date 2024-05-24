import 'dart:async';

import 'package:boldo/models/PositionEntity.dart';
import 'package:boldo/screens/map/presentation/bloc/bloc.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {

  final List<PositionEntity>? positions;
  final String? label;

  const MapScreen({
    super.key,
    this.positions,
    this.label,
  });

  @override
  State<MapScreen> createState() => MapSampleState();
}

class MapSampleState extends State<MapScreen> {

  @override
  void initState(){

    super.initState();
    
  }

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          BlocProvider<MapBloc>(
            create: (BuildContext context) => MapBloc()..add(InitMap(
              context: context,
              positions:  widget.positions?? [],
            )),
            child: BlocBuilder<MapBloc, MapState>(
              builder: (context, status){

                if(status is MapSuccess){
                  return Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: status.initialCameraPosition,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        padding: const EdgeInsets.all(16),
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController controller) async {
                          _controller.complete(controller);
                        },
                        markers: status.customMarkers.toSet(),
                      ),
                      SafeArea(
                        minimum: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(widget.label ?? ''),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.close_rounded),
                                      SizedBox(width: 4,),
                                      Text('Cerrar mapa'),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }else{
                  return loadingStatus();
                }
              

              },
            ),
          ),
        ],
      ),
    );
  }

}