import 'package:boldo/network/passport_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';


part 'passportEvent.dart';
part 'passportState.dart';

class PassportBloc extends Bloc<PassportEvent, PassportState> {
  final PassportRepository _passportRepository = PassportRepository();

  PassportBloc(): super(PassportInitial()) {
    on<PassportEvent>((event, emit) async{
      if (event is GetUserDiseaseList) {
        emit(Loading());
        var _post;
        await Task(() => _passportRepository.getUserDiseaseList()!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          emit(Success());
        }
      }
    });
  }
}
