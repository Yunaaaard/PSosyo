class IdScanResult {
  const IdScanResult({
    required this.detectedIdType,
    required this.matchesSelectedType,
    this.extractedName,
    this.extractedBirthDate,
    this.extractedGender,
    this.warningMessage,
  });

  final String? extractedName;
  final String? extractedBirthDate;
  final String? extractedGender;
  final String detectedIdType;
  final bool matchesSelectedType;
  final String? warningMessage;
}
