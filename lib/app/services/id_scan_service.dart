import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class IdScanResult {
  const IdScanResult({
    required this.detectedIdType,
    required this.matchesSelectedType,
    this.extractedName,
    this.warningMessage,
  });

  final String? extractedName;
  final String detectedIdType;
  final bool matchesSelectedType;
  final String? warningMessage;
}

class IdScanService {
  static final IdScanService _instance = IdScanService._internal();

  factory IdScanService() {
    return _instance;
  }

  IdScanService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer();

  // All known field-label keywords — used to detect when the next OCR line
  // is another label rather than a value.
  static const _allFieldLabels = [
    'apelyido',
    'last name',
    'lastname',
    'surname',
    'mga pangalan',
    'given names',
    'given name',
    'first name',
    'firstname',
    'gitnang apelyido',
    'middle name',
    'middlename',
    'nationality',
    'address',
    'birth date',
    'date of birth',
    'height',
    'weight',
    'sex',
    'gender',
    'blood type',
    'expiry',
    'expiration',
    'license no',
    'license number',
    'restriction',
    'condition',
  ];

  Future<IdScanResult> extractNameFromIdImage(
    XFile imageFile, {
    String? idType,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final lines = recognizedText.text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        return const IdScanResult(
          detectedIdType: 'unknown',
          matchesSelectedType: false,
          warningMessage: 'No readable text was detected in the image.',
        );
      }

      final normalizedIdType = _normalizeIdType(idType);
      final detectedIdType = _detectDocumentType(lines);

      if (normalizedIdType.contains('national id') || normalizedIdType.contains('philsys')) {
        if (detectedIdType == 'driver_license') {
          return const IdScanResult(
            detectedIdType: 'driver_license',
            matchesSelectedType: false,
            warningMessage: 'This looks like a driver\'s license, not a PhilSys ID.',
          );
        }

        final name = _extractFromPhilSys(lines);
        if (name != null) {
          return IdScanResult(
            extractedName: name,
            detectedIdType: detectedIdType,
            matchesSelectedType: detectedIdType == 'philsys' || detectedIdType == 'unknown',
          );
        }

        return IdScanResult(
          detectedIdType: detectedIdType,
          matchesSelectedType: detectedIdType == 'philsys' || detectedIdType == 'unknown',
          warningMessage: 'The selected PhilSys format was not fully recognized.',
        );
      }

      if (normalizedIdType.contains('driver') || normalizedIdType.contains('license')) {
        if (detectedIdType == 'philsys') {
          return const IdScanResult(
            detectedIdType: 'philsys',
            matchesSelectedType: false,
            warningMessage: 'This looks like a PhilSys ID, not a driver\'s license.',
          );
        }

        final driverName = _extractFromDriversLicense(lines);
        if (driverName != null) {
          return IdScanResult(
            extractedName: driverName,
            detectedIdType: detectedIdType,
            matchesSelectedType: detectedIdType == 'driver_license' || detectedIdType == 'unknown',
          );
        }

        return IdScanResult(
          detectedIdType: detectedIdType,
          matchesSelectedType: detectedIdType == 'driver_license' || detectedIdType == 'unknown',
          warningMessage: 'The selected driver\'s license format was not fully recognized.',
        );
      }

      final genericName = _extractGenericName(lines);
      return IdScanResult(
        extractedName: genericName,
        detectedIdType: detectedIdType,
        matchesSelectedType: detectedIdType == 'unknown' || detectedIdType == _normalizeIdType(idType),
        warningMessage: genericName == null ? 'Could not confidently extract a name from the image.' : null,
      );
    } catch (e) {
      print('Error scanning ID: $e');
      return const IdScanResult(
        detectedIdType: 'unknown',
        matchesSelectedType: false,
        warningMessage: 'An error occurred while scanning the ID.',
      );
    }
  }

  String _normalizeIdType(String? idType) {
    return (idType ?? '').trim().toLowerCase();
  }

  List<String> _uniqueCapturedValues(List<String?> values) {
    final uniqueValues = <String>[];

    for (final value in values) {
      if (value == null) {
        continue;
      }

      final normalized = value.trim();
      if (normalized.isEmpty) {
        continue;
      }

      final exists = uniqueValues.any((entry) => entry.toLowerCase() == normalized.toLowerCase());
      if (!exists) {
        uniqueValues.add(normalized);
      }
    }

    return uniqueValues;
  }

  String? _extractFromPhilSys(List<String> lines) {
    final lastName = _extractNextValueAfterLabel(lines, [
      'apelyido',
      'last name',
    ]);
    final givenNames = _extractNextValueAfterLabel(lines, [
      'mga pangalan',
      'given names',
      'first name',
    ]);
    final middleName = _extractNextValueAfterLabel(lines, [
      'gitnang apelyido',
      'middle name',
    ]);

    final parts = <String>[];
    if (givenNames != null) parts.add(givenNames);
    if (middleName != null && middleName != givenNames) parts.add(middleName);
    if (lastName != null) parts.add(lastName);

    if (parts.isNotEmpty) {
      return _cleanName(parts.join(' '));
    }

    return null;
  }

  String? _extractFromDriversLicense(List<String> lines) {
    // --- Strategy 1: label-based extraction ---
    final firstName = _extractNextValueAfterLabel(lines, [
      'first name',
      'given name',
      'firstname',
    ]);
    final middleName = _extractNextValueAfterLabel(lines, [
      'middle name',
      'middlename',
    ]);
    final lastName = _extractNextValueAfterLabel(lines, [
      'last name',
      'surname',
      'lastname',
    ]);

    // Build in firstname → middlename → lastname order.
    final orderedParts = <String>[];
    if (firstName != null) orderedParts.add(firstName);
    if (middleName != null && middleName != firstName) orderedParts.add(middleName);
    if (lastName != null) orderedParts.add(lastName);

    final capturedValues = _uniqueCapturedValues([
      firstName,
      middleName,
      lastName,
    ]);

    if (capturedValues.length == 1) {
      return _reorderDriverLicenseName(capturedValues.single);
    }

    if (firstName == null && middleName == null && lastName != null) {
      return _reorderDriverLicenseName(lastName);
    }

    // OCR sometimes splits the sample format into:
    //   firstName = surname
    //   middleName = given + middle
    // In that case, move the first captured value to the end.
    if (firstName != null && middleName != null && lastName == null) {
      return _cleanName('$middleName $firstName');
    }

    if (orderedParts.length == 1) {
      return _reorderDriverLicenseName(orderedParts.single);
    }

    if (orderedParts.isNotEmpty) {
      return _cleanName(orderedParts.join(' '));
    }

    // --- Strategy 2: inline label-value on the same line ---
    // e.g. "Last Name: DE LA CRUZ"
    final inlineFirst = _extractValueForLabels(lines, ['first name', 'given name', 'firstname']);
    final inlineMiddle = _extractValueForLabels(lines, ['middle name', 'middlename']);
    final inlineLast = _extractValueForLabels(lines, ['last name', 'surname', 'lastname']);

    final inlineParts = <String>[];
    if (inlineFirst != null) inlineParts.add(inlineFirst);
    if (inlineMiddle != null && inlineMiddle != inlineFirst) inlineParts.add(inlineMiddle);
    if (inlineLast != null) inlineParts.add(inlineLast);

    final uniqueInlineParts = _uniqueCapturedValues(inlineParts);

    if (uniqueInlineParts.length == 1) {
      return _reorderDriverLicenseName(uniqueInlineParts.single);
    }

    if (inlineParts.isNotEmpty) {
      return _cleanName(inlineParts.join(' '));
    }

    // --- Strategy 3: scan for a raw name line before known non-name fields ---
    // Philippine DL typically has the full name on one line in LAST FIRST MIDDLE order.
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_containsAny(line.toLowerCase(), [
        'nationality',
        'address',
        'birth date',
        'date of birth',
        'height',
        'weight',
        'restriction',
        'expiry',
        'license no',
      ])) {
        break;
      }

      if (_looksLikePersonName(line)) {
        return _reorderDriverLicenseName(line);
      }
    }

    final genericName = _extractGenericName(lines);
    if (genericName != null) {
      return _reorderDriverLicenseName(genericName);
    }

    return null;
  }

  /// Philippine DL stores the name as LASTNAME FIRSTNAME [MIDDLENAME].
  /// This reorders it to FIRSTNAME MIDDLENAME LASTNAME.
  ///
  /// Strategy: the last name is always a single "word group" at the beginning.
  /// We identify the boundary by looking for a comma separator, or by treating
  /// the first word as the last name when the total word count is exactly 3.
  /// For compound last names (e.g. DE LA CRUZ) we fall back to moving the
  /// first word only, which matches the most common Philippine DL layout.
  String _reorderDriverLicenseName(String nameLine) {
    // Some DLs use "DE LA CRUZ, JUAN ANDRES" — comma separates last from rest.
    if (nameLine.contains(',')) {
      final parts = nameLine.split(',');
      if (parts.length >= 2) {
        final last = parts[0].trim();
        final rest = parts.sublist(1).join(' ').trim();
        return _cleanName('$rest $last');
      }
    }

    final words = nameLine
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();

    if (words.length < 2) {
      return _cleanName(nameLine);
    }

    // Exactly 3 words → LAST FIRST MIDDLE → FIRST MIDDLE LAST
    if (words.length == 3) {
      return _cleanName('${words[1]} ${words[2]} ${words[0]}');
    }

    // More words: treat only the first word as the last name.
    // DELA FIRST MIDDLE → FIRST MIDDLE DELA
    // This is the safest assumption when we can't detect the last-name boundary.
    final lastName = words.first;
    final remainder = words.sublist(1).join(' ');
    return _cleanName('$remainder $lastName');
  }

  /// Looks for a line that contains one of [labels] AND has the value on the
  /// same line after a separator (e.g. "Last Name: DE LA CRUZ").
  String? _extractValueForLabels(List<String> lines, List<String> labels) {
    for (final rawLine in lines) {
      final line = rawLine.toLowerCase();
      if (!_containsAny(line, labels)) continue;

      final inlineValue = _extractInlineLabelValue(rawLine);
      if (inlineValue != null) return inlineValue;
    }
    return null;
  }

  String? _extractInlineLabelValue(String line) {
    final separators = [':', '-', '–'];
    for (final separator in separators) {
      final index = line.indexOf(separator);
      if (index >= 0 && index < line.length - 1) {
        final value = line.substring(index + 1).trim();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return null;
  }

  String _detectDocumentType(List<String> lines) {
    final text = lines.map((line) => line.toLowerCase()).join(' ');

    if (text.contains('philsys') ||
        text.contains('philippine identification card') ||
        text.contains('pambansang pagkakakilanlan') ||
        text.contains('mga pangalan') ||
        text.contains('gitnang apelyido')) {
      return 'philsys';
    }

    if (text.contains('driver') ||
        text.contains('license') ||
        text.contains('non-professional') ||
        text.contains('professional driver')) {
      return 'driver_license';
    }

    return 'unknown';
  }

  String? _extractGenericName(List<String> lines) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (_containsAny(line.toLowerCase(), ['name', 'full name', 'given name'])) {
        for (int j = i + 1; j < lines.length; j++) {
          final nextLine = lines[j];
          if (nextLine.isNotEmpty && nextLine.length > 2) {
            return _cleanName(nextLine);
          }
        }
      }
    }

    for (final line in lines) {
      if (_looksLikePersonName(line)) {
        return _cleanName(line);
      }
    }

    return null;
  }

  /// Returns the value on the line AFTER a line matching one of [labels].
  /// Uses [_allFieldLabels] to skip over other label lines so we don't
  /// accidentally treat a neighbouring label as a value.
  String? _extractNextValueAfterLabel(List<String> lines, List<String> labels) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      if (!_containsAny(line, labels)) continue;

      for (int j = i + 1; j < lines.length; j++) {
        final nextLine = lines[j].trim();
        if (nextLine.isEmpty) continue;

        // Skip if this line itself is another field label.
        if (_containsAny(nextLine.toLowerCase(), _allFieldLabels)) break;

        return nextLine;
      }
    }
    return null;
  }

  bool _containsAny(String text, List<String> values) {
    final lowerText = text.toLowerCase();
    return values.any(lowerText.contains);
  }

  bool _looksLikePersonName(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length < 3) return false;
    if (_looksLikeDateOrId(trimmed)) return false;
    final letters = trimmed.replaceAll(RegExp('[^A-Za-z]'), '').length;
    return letters >= 3;
  }

  String _cleanName(String name) {
    final cleaned = name
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll(RegExp("[^a-zA-Z\\s\\-\\']"), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    return _collapseRepeatedWordGroups(cleaned);
  }

  String _collapseRepeatedWordGroups(String text) {
    final words = text.split(' ').where((w) => w.trim().isNotEmpty).toList();
    if (words.length < 2) return text;

    for (int size = 1; size <= words.length ~/ 2; size++) {
      if (words.length % size != 0) continue;

      final candidate = words.take(size).toList();
      var matches = true;

      for (int index = 0; index < words.length; index++) {
        if (words[index].toUpperCase() != candidate[index % size].toUpperCase()) {
          matches = false;
          break;
        }
      }

      if (matches && words.length > size) {
        return candidate.join(' ');
      }
    }

    return text;
  }

  bool _looksLikeDateOrId(String text) {
    final numberCount = text.replaceAll(RegExp(r'[^0-9]'), '').length;
    return numberCount > text.length * 0.5;
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}