import 'package:boldo/constants.dart';
import 'package:dio/dio.dart';

final Map<String,String> errorsTranslate = {
  "QR code does not exist":"El código QR no existe",
  "Invalid QR code":"El código QR no es válido",
  "Expired QR code":"El código QR ya expiró",
  "The dependent and the caretaker are the same": "El familiar no puede ser el mismo que el principal",
  "Relationship of dependence with the patient is already exists": "El familiar ya se encuentra asignado",
  "timeslot is not available for booking": "El turno ya no está disponible",
  "'start' has to be at least 5 minutes in the future": "El agendamiento debe ser antes de los 5 minutos que empiece",
  "The front of the IdCardParaguay card could not be validated": "Error al validar la parte frontal",
  "Invalid name": "No se visualiza el nombre",
  "Invalid last name": "No se visualiza el apellido",
  "Invalid sex" : "No se visualiza el sexo",
  "Invalid birthDate" : "No se visualiza la fecha de nacimiento",
  "The back of the IdCardParaguay card could not be validated": "Error al validar la parte posterior",
  "Invalid IC": "Error al validar la parte posterior",
  "Invalid Document number": "Error al validar la parte posterior",
  "Invalid nationality": "Error al validar la parte posterior",
  "Face could not be validated": "No coincide la Selfie",
};

/// Decode a message revived by
String translateBackendMessage(Response? response){
  try {
    if (errorsTranslate.containsKey(response?.data['messages'].join())) {
      String result = errorsTranslate[response?.data['messages']
          .first] ?? genericError;
      return result;
    }
    return genericError;
  }catch (exception){
    try{
      String result = errorsTranslate[response?.data['message']] ?? genericError;
      return result;
    }catch (exception){
      try{
        String result = errorsTranslate[response?.data] ?? genericError;
        return result;
      }catch (exception){
        return genericError;
      }
    }
  }
}