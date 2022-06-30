import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'my_studies_event.dart';
part 'my_studies_state.dart';

class MyStudiesBloc extends Bloc<MyStudiesEvent, MyStudiesState> {
  MyStudiesBloc() : super(MyStudiesInitial()) {
    on<MyStudiesEvent>((event, emit) {
       if(event is GetPatientStudiesFromServer) {
        print('GetPatientStudiesFromServer capturado');
        // emit(Loading());
        // var _post;
        // await Task(() =>
        // _patientRepository.getDoctor(id: event.id)!)
        //     .attempt()
        //     .run()
        //     .then((value) {
        //   _post = value;
        // }
        // );
        // var response;
        // if (_post.isLeft()) {
        //   _post.leftMap((l) => response = l.message);
        //   emit(Failed(response: response));

        // }else{
        //   emit(Success());
        // }
      }
    });
  }
}
