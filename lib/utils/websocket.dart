import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef void OnMessageCallback(String tag, dynamic msg);
typedef void OnCloseCallback(int code, String reason);
typedef void OnOpenCallback();

class SimpleWebSocket {
  String url;
  IO.Socket socket;
  String roomNumber;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;

  SimpleWebSocket(this.url, this.roomNumber);

  connect() async {
    try {
      socket = IO.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();

      // Dart client
      socket.on('connect', (_) {
        print('connected');

        onOpen();
      });
      socket.emit('start call', roomNumber);
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
      socket.on('connect_error', (e) => print('Connect error: $e'));
      socket.on('disconnect', (e) {
        print('disconnect');
      });
      socket.on('fromServer', (_) => print(_));
    } catch (e) {
      print(e);
      // this.onClose(500, e.toString());
    }
  }

  send(event, data) {
    if (socket != null) {
      socket.emit(event, data);
      print('send: $event - $data');
    }
  }

  close() {
    if (socket != null) {
      send("disconnect", {});
      socket.close();
    }
  }
}
