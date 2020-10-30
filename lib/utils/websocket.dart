import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef void OnMessageCallback(String tag, dynamic msg);
typedef void OnCloseCallback(int code, String reason);
typedef void OnOpenCallback();

class SimpleWebSocket {
  String url;
  io.Socket socket;
  String appointmentId;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;
  Logger logger = Logger();
  SimpleWebSocket(this.url, this.appointmentId);

  void connect() async {
    try {
      socket = io.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();

      // Dart client
      socket.on('connect', (_) {
        socket.emit('patient ready', appointmentId);
        onOpen();
      });

      socket.on('find patient', (data) {
        onMessage('find patient', data);
      });

      socket.on('end call', (data) {
        onMessage('end call', data);
      });

      socket.on('call partner', (data) {
        onMessage('call partner', data);
      });
      socket.on('call host', (data) {
        onMessage('call host', data);
      });
      socket.on('offer', (data) {
        onMessage('offer', data);
      });
      socket.on('answer', (data) {
        onMessage('answer', data);
      });
      socket.on('ice-candidate', (data) {
        onMessage('ice-candidate', data);
      });

      socket.on('exception', (e) => print('Exception: $e'));
      socket.on('connect_error', (e) {
        onMessage('connect error', e);
      });

      socket.on('disconnect', (e) {
        print('disconnect');
      });
    } catch (e) {
      logger.e(e);
    }
  }

  void send(event, data) {
    if (socket != null) {
      socket.emit(event, data);
      print('send: $event - $data');
    }
  }

  void close() {
    if (socket != null) {
      send("disconnect", {});
      socket.disconnect();
      socket.clearListeners();
    }
  }
}
