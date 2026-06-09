class IdScanResult {
  const IdScanResult({
    required this.detectedIdType,
    required this.matchesSelectedType,
    this.extractedName,
    this.extractedBirthDate,
    this.extractedGender,
    this.extractedFirstName,
    this.extractedMiddleName,
    this.extractedLastName,
    this.warningMessage,
  });

  final String? extractedName;
  final String? extractedBirthDate;
  final String? extractedGender;
  final String? extractedFirstName;
  final String? extractedMiddleName;
  final String? extractedLastName;
  final String detectedIdType;
  final bool matchesSelectedType;
  final String? warningMessage;
}

