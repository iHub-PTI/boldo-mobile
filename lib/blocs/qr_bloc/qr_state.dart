part of 'qr_bloc.dart';

@immutable
abstract class QrBlocState{}

class QrInitialState extends QrBlocState {}

class Loading extends QrBlocState {}

class Failed extends QrBlocState {
  final response;
  Failed({required this.response});
}

class Success extends QrBlocState {}

class QrObtained extends QrBlocState {
  final QRCode qrCode;
  QrObtained({required this.qrCode});
}

class QrDecoded extends QrBlocState {}