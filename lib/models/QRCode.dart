class QRCode {

  String? qrCode;

  QRCode({
    this.qrCode,
  });

  QRCode.fromJson(Map<String, dynamic> json) {
    qrCode = json['qrCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['qrCode'] = qrCode;
    return data;
  }
}