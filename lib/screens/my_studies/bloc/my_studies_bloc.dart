import 'package:bloc/bloc.dart';
import 'package:boldo/network/my_studies_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

part 'my_studies_event.dart';
part 'my_studies_state.dart';

class MyStudiesBloc extends Bloc<MyStudiesEvent, MyStudiesState> {
  final MyStudesRepository _myStudiesRepository = MyStudesRepository();
  MyStudiesBloc() : super(MyStudiesInitial()) {
    on<MyStudiesEvent>((event, emit) async {
      if (event is GetPatientStudiesFromServer) {
        print('GetPatientStudiesFromServer capturado');
        emit(Loading());
        var _post;
        await Task(() =>
        _myStudiesRepository.getPatientStudies()!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(msg: response));

        }else{
          emit(Success(nameOfStudies: "Resonancia"));
        }
      }
    });
  }
}
