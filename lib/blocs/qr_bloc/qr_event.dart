part of 'qr_bloc.dart';

@immutable
abstract class QrBlocEvent {}

class ValidateQr extends QrBlocEvent {
  final String qrCode;
  ValidateQr({required this.qrCode});
}

class GetQRCode extends QrBlocEvent {}
