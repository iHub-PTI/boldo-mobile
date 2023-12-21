import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:boldo/app_config.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/files_repository.dart';
import 'package:boldo/network/my_studies_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
part 'new_study_event.dart';
part 'new_study_state.dart';

class NewStudyBloc extends Bloc<NewStudyEvent, NewStudyState> {
  final MyStudesRepository _myStudiesRepository = MyStudesRepository();

  List<MapEntry<File, Either<Failure, AttachmentUrl?>>> files = [];

  Future<List<MapEntry<File, Either<Failure, AttachmentUrl?>>>> addFiles({required List<File> newFiles}) async {

    List<MapEntry<File, Either<Failure, AttachmentUrl?>>> filesWithAttached = [];

    await Future.forEach(newFiles, (file) async {
      Either<Failure, AttachmentUrl?> _var = await Task(() =>
           Future(() {
             if((file.lengthSync()) >
                 (appConfig.FILE_STUDY_LIMIT.getValue.maxSizeBytes?? 10000)){
               throw Failure('Lo sentimos, el archivo supera el límite de ${appConfig.FILE_STUDY_LIMIT.getValue.description}');
             }
                return null;
           })
      )
          .attempt()
          .mapLeftToFailure()
          .run();
      filesWithAttached.add(MapEntry(file, _var));
    });

    if (files.isNotEmpty) {
      files.addAll(filesWithAttached);
    } else {
      files = filesWithAttached;
    }

    return filesWithAttached;
  }

  Future<List<MapEntry<File, Either<Failure, AttachmentUrl?>>>> removeFiles({required List<File> filesToRemove}) async {

    await Future((){

      files.removeWhere((element) => filesToRemove.contains(element.key));

    });

    return files;
  }


  NewStudyBloc() : super(NewStudyInitial()) {
    on<NewStudyEvent>((event, emit) async {
      if (event is SendStudyToServer) {
        emit(Uploading());

        // get files that doesn't has AttachmentUrl because this doesn't yet uploaded
        List<MapEntry<File, Either<Failure, AttachmentUrl?>>> _listOfFilesNotUploaded = event.files.where(
                (element) {

                  AttachmentUrl? _attached;

                  if(element.value.isRight())
                    _attached = element.value.asRight();

                  return element.value.isLeft() || _attached == null;
                }
        ).toList();

        _listOfFilesNotUploaded.removeWhere((element) => ((element.key.lengthSync()) >
            (appConfig.FILE_STUDY_LIMIT.getValue.maxSizeBytes?? 10000)));

        // list of <File, urlUploaded>
        List<MapEntry<File, Either<Failure, MapEntry<File, UploadUrl>>>> _uploadsList = await FilesRepository.uploadFiles(
          files: _listOfFilesNotUploaded.map((mapFile) => MapEntry(mapFile.key, null)).toList(),
        );


        List<MapEntry<File, Either<Failure, AttachmentUrl?>>> _final = [];


        await Future.forEach(event.files, (fileWithAttachment) async {

          //get error or create AttachmentUrl
          if(fileWithAttachment.value.isRight() && fileWithAttachment.value.asRight()!= null ){

            // set Attachment default
            await Task(() {
              return Future(() => fileWithAttachment.value.asRight());
            }).attempt().mapLeftToFailure().run().then((value) =>
                _final.add(MapEntry(fileWithAttachment.key, value))
            );
          }else{

            if(_uploadsList.any((element) => element.key == fileWithAttachment.key)){
              // get the sent file
              MapEntry<File, Either<Failure, MapEntry<File, UploadUrl>>>?
              fileUploaded =_uploadsList.firstWhere(
                    (element) => element.key == fileWithAttachment.key,
              );

              //set the AttachmentUrl to the file, or a Failure
              await Task((){

                // if the file failed
                if(fileUploaded.value.isLeft()){
                  return Future(
                          () => throw fileUploaded.value.asLeft())
                  ;

                } else{ //if the file was uploaded correctly

                  // get the UploadUrl with the file Uploaded
                  MapEntry<File, UploadUrl> fileUploadedSuccess = fileUploaded.value.asRight();

                  //create the AttachmentUrl with contentType
                  return Future(() => AttachmentUrl(
                    url: fileUploadedSuccess.value.location,
                    contentType: p.extension(fileUploaded.key.path).toLowerCase() == '.pdf'
                        ? 'application/pdf'
                        : p.extension(fileUploaded.key.path).toLowerCase() == '.png'
                        ? 'image/png'
                        : 'image/jpeg',
                  ));
                }
              })
                  .attempt()
                  .mapLeftToFailure()
                  .run()
                  .then((value) =>
                  _final.add(MapEntry(fileUploaded.key, value))
              );
            }else{

              _final.add(fileWithAttachment);
            }


          }
        });

        files = _final;

        //check if every file was uploaded
        if(_final.every((element) => element.value.isRight())){
          late Either<Failure, None> _post;
          
          event.diagnosticReport.attachmentUrls = _final.map((e) => e.value.asRight()!).toList();
          
          await Task(() => _myStudiesRepository.sendDiagnosticReport(
              event.diagnosticReport)!)
              .attempt()
              .mapLeftToFailure()
              .run()
              .then((value) {
            _post = value;
          });
          var response;
          if (_post.isLeft()) {
            _post.leftMap((l) => response = l.message);
            emit(FailedUpload(msg: response));
          } else {
            emit(Uploaded());
          }
        }else{
          emit(FailedUploadFiles(files: _final));
        }


      }
    });
  }
}
