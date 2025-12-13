class RejectedFiles {
  final List<RejectedFileItem> driverLicense;
  final List<RejectedFileItem> vehicleRegistration;
  final List<RejectedFileItem> insuranceDocument;
  final List<RejectedFileItem> selfiePhotoId;
  final List<RejectedFileItem> vehicleCheckReport;

  RejectedFiles({
    required this.driverLicense,
    required this.vehicleRegistration,
    required this.insuranceDocument,
    required this.selfiePhotoId,
    required this.vehicleCheckReport,
  });

  factory RejectedFiles.fromJson(Map<String, dynamic> json) {
    return RejectedFiles(
      driverLicense: (json['driver_license'] as List)
          .map((e) => RejectedFileItem.fromJson(e))
          .toList(),
      vehicleRegistration: (json['vehicle_registration'] as List)
          .map((e) => RejectedFileItem.fromJson(e))
          .toList(),
      insuranceDocument: (json['insurance_document'] as List)
          .map((e) => RejectedFileItem.fromJson(e))
          .toList(),
      selfiePhotoId: (json['selfie_photo_id'] as List)
          .map((e) => RejectedFileItem.fromJson(e))
          .toList(),
      vehicleCheckReport: (json['vehicle_check_report'] as List)
          .map((e) => RejectedFileItem.fromJson(e))
          .toList(),
    );
  }

}

class RejectedFileItem {
  final String name;
  final String url;

  RejectedFileItem({
    required this.name,
    required this.url,
  });

  factory RejectedFileItem.fromJson(Map<String, dynamic> json) {
    return RejectedFileItem(
      name: json['name'],
      url: json['url'],
    );
  }
}
