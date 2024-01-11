import 'package:socket_io_client/socket_io_client.dart' as io;

class CallSocket {

  late String urlSocketServer;

  late io.Socket _socket;

  late String _room;

  late String _token;

  CallSocket({
    required String urlSocketServer,
    required room,
    required token,
  }){
    _room = room;
    _token = token;

    // create socket connection
    _socket = io.io(
      urlSocketServer,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .build(),
    );

    _socket.onConnect((_) => {
      emit(
        event: CallSignalsEmit.InWaitingRoom,
      ),
      emit(
        event: CallSignalsEmit.PatientReadyToConnect,
      ),
    });

    connect();
  }

  void connect(){
    _socket.connect();

  }

  void onConnect({Function? callback}){
    _socket.onConnect((data) {
      callback?.call();
    });
  }

  void emit ({required CallSignalsEmit event, Map<String, dynamic>? data}){
    _socket.emit(event.message,
      {
        ...?data,
        ...{"room": _room, "token": _token}
      },
    );
    print(event.message);
  }

  void on({required CallSignalsListen event, Function(dynamic data)? callback}){
    _socket.on(event.message, (data){
      callback?.call(data);
    });
  }

  void dispose() {
    _socket.dispose();
  }

  void clearListeners() {
    _socket.clearListeners();
  }

  void off({required CallSignalsListen event}){
    _socket.off(event.message);
  }

}

enum CallSignalsEmit {
  /// Signal to inform to the Doctor that the patient is in the waiting room
  InWaitingRoom(
    message: 'patient ready',
  ),
  /// Signal to inform to the Doctor in the call that the patient is ready to negotiate
  PatientReadyToConnect(
    message: 'ready!',
  ),
  IceCandidate(
    message: 'ice candidate',
  ),
  SDPOffer(
    message: 'sdp offer',
  ),
  /// Signal to inform to the Doctor in the call that the patient is
  /// successfully connected to Coturn server
  Connected(
    message: 'patient in call',
  ),
  /// Signal to inform to the Doctor in the call that the patient is
  /// leaving the call
  Disconnect(
    message: 'end call',
  );

  const CallSignalsEmit({
    required this.message,
  });
  final String message;

}


enum CallSignalsListen {
  FindPatient(
    message: 'find patient',
  ),
  DoctorReady(
    message: 'ready?',
  ),
  IceCandidate(
    message: 'ice candidate',
  ),
  SDPOffer(
    message: 'sdp offer',
  ),
  Disconnect(
    message: 'end call',
  );

  const CallSignalsListen({
    required this.message,
  });
  final String message;


}