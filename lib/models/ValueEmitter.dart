import 'dart:async';

class ValueEmitter<T> {

  ValueEmitter({required T value}){
    updateValue(value);
  }

  StreamController<T> _controller = StreamController<T>.broadcast();

  void listenValue(Function(T) function) => _controller.stream.listen(function);

  void updateValue(T value){
    _currentValue = value;
    _controller.sink.add(value);
  }


  late T _currentValue;

  T get getValue => _currentValue;

}