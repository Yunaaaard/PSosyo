import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img_pkg;
import 'package:image_picker/image_picker.dart';

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

class IdScanService {
  static final IdScanService _instance = IdScanService._internal();

  factory IdScanService() {
    return _instance;
  }

  IdScanService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer();
  // Use default constructor for compatibility across package versions.
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

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
    'dob',
    'birthday',
    'petsa ng kapanganakan',
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
      final lineVariants = await _readOcrLineVariants(imageFile);
      final lines = _pickBestLines(lineVariants);

      if (lines.isEmpty) {
        return const IdScanResult(
          detectedIdType: 'unknown',
          matchesSelectedType: false,
          warningMessage: 'No readable text was detected in the image.',
        );
      }

      final normalizedIdType = _normalizeIdType(idType);
      final detectedIdType = _detectDocumentType(lines);

      if (normalizedIdType.contains('national id') ||
          normalizedIdType.contains('philsys')) {
        if (detectedIdType == 'driver_license') {
          return const IdScanResult(
            detectedIdType: 'driver_license',
            matchesSelectedType: false,
            warningMessage:
                'This looks like a driver\'s license, not a PhilSys ID.',
          );
        }

        final name = _extractFromPhilSys(lines);
        final birthDate = _extractBirthDateFromPhilSys(lines) ??
            _extractGenericBirthDate(lines);
        final gender =
            _extractGenderFromPhilSys(lines) ?? _extractGenericGender(lines);
        if (name != null || birthDate != null || gender != null) {
          return IdScanResult(
            extractedName: name,
            extractedBirthDate: birthDate,
            extractedGender: gender,
            detectedIdType: detectedIdType,
            matchesSelectedType:
                detectedIdType == 'philsys' || detectedIdType == 'unknown',
          );
        }

        return IdScanResult(
          detectedIdType: detectedIdType,
          matchesSelectedType:
              detectedIdType == 'philsys' || detectedIdType == 'unknown',
          warningMessage:
              'The selected PhilSys format was not fully recognized.',
        );
      }

      if (normalizedIdType.contains('driver') ||
          normalizedIdType.contains('license')) {
        if (detectedIdType == 'philsys') {
          return const IdScanResult(
            detectedIdType: 'philsys',
            matchesSelectedType: false,
            warningMessage:
                'This looks like a PhilSys ID, not a driver\'s license.',
          );
        }

        final driverName = _extractFromDriversLicense(lines);
        final birthDate = _extractBirthDateFromDriversLicense(lines) ??
            _extractGenericBirthDate(lines);
        final gender = _extractGenderFromDriversLicense(lines) ??
            _extractGenericGender(lines);
        if (driverName != null || birthDate != null || gender != null) {
          return IdScanResult(
            extractedName: driverName,
            extractedBirthDate: birthDate,
            extractedGender: gender,
            detectedIdType: detectedIdType,
            matchesSelectedType: detectedIdType == 'driver_license' ||
                detectedIdType == 'unknown',
          );
        }

        return IdScanResult(
          detectedIdType: detectedIdType,
          matchesSelectedType:
              detectedIdType == 'driver_license' || detectedIdType == 'unknown',
          warningMessage:
              'The selected driver\'s license format was not fully recognized.',
        );
      }

      final genericName = _extractGenericName(lines);
      final genericBirthDate = _extractGenericBirthDate(lines);
      final genericGender = _extractGenericGender(lines);
      return IdScanResult(
        extractedName: genericName,
        extractedBirthDate: genericBirthDate,
        extractedGender: genericGender,
        detectedIdType: detectedIdType,
        matchesSelectedType: detectedIdType == 'unknown' ||
            detectedIdType == _normalizeIdType(idType),
        warningMessage: genericName == null
            ? 'Could not confidently extract a name from the image.'
            : null,
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

  /// Convenience wrapper that forces PhilSys parsing rules.
  Future<IdScanResult> extractNameFromPhilSysImage(XFile imageFile) async {
    return await extractNameFromIdImage(imageFile, idType: 'philsys');
  }

  /// Convenience wrapper that forces Driver's License parsing rules.
  Future<IdScanResult> extractNameFromDriversLicenseImage(
      XFile imageFile) async {
    return await extractNameFromIdImage(imageFile, idType: 'driver_license');
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

      final exists = uniqueValues
          .any((entry) => entry.toLowerCase() == normalized.toLowerCase());
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
    if (middleName != null && middleName != firstName)
      orderedParts.add(middleName);
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
    final inlineFirst = _extractValueForLabels(
        lines, ['first name', 'given name', 'firstname']);
    final inlineMiddle =
        _extractValueForLabels(lines, ['middle name', 'middlename']);
    final inlineLast =
        _extractValueForLabels(lines, ['last name', 'surname', 'lastname']);

    final inlineParts = <String>[];
    if (inlineFirst != null) inlineParts.add(inlineFirst);
    if (inlineMiddle != null && inlineMiddle != inlineFirst)
      inlineParts.add(inlineMiddle);
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

  String? _extractBirthDateFromPhilSys(List<String> lines) {
    return _extractBirthDateByLabels(lines, const [
      'date of birth',
      'birth date',
      'dob',
      'petsa ng kapanganakan',
      'kapanganakan',
    ]);
  }

  String? _extractBirthDateFromDriversLicense(List<String> lines) {
    return _extractBirthDateByLabels(lines, const [
      'date of birth',
      'birth date',
      'dob',
      'birthdate',
    ]);
  }

  String? _extractGenderFromPhilSys(List<String> lines) {
    return _extractGenderByLabels(lines, const [
      'sex',
      'gender',
      'kasarian',
    ]);
  }

  String? _extractGenderFromDriversLicense(List<String> lines) {
    return _extractGenderByLabels(lines, const [
      'sex',
      'gender',
    ]);
  }

  String? _extractGenericGender(List<String> lines) {
    final byLabel = _extractGenderByLabels(lines, const [
      'sex',
      'gender',
      'kasarian',
    ]);
    if (byLabel != null) return byLabel;

    for (final line in lines) {
      final gender = _normalizeGenderValue(line);
      if (gender != null) return gender;
    }

    return null;
  }

  String? _extractGenderByLabels(List<String> lines, List<String> labels) {
    final inline = _extractValueForLabels(lines, labels);
    final inlineGender = _normalizeGenderValue(inline);
    if (inlineGender != null) return inlineGender;

    final nextValue = _extractNextValueAfterLabel(lines, labels);
    final nextGender = _normalizeGenderValue(nextValue);
    if (nextGender != null) return nextGender;

    final lineRegex = RegExp(
      r'(?:sex|gender|kasarian)\s*[:\-]?\s*(male|female|m|f)\b',
      caseSensitive: false,
    );

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (!_containsAny(lower, labels)) continue;

      final matched = lineRegex.firstMatch(line);
      if (matched != null) {
        final normalized = _normalizeGenderValue(matched.group(1));
        if (normalized != null) return normalized;
      }

      // Handle compact OCR cases like "... Sex M Date of Birth ...".
      // Extract only the first ~20 characters after the label to avoid picking
      // up letters from dates or other fields further in the line.
      final labelIndex = lower.indexOf(RegExp('sex|gender|kasarian'));
      if (labelIndex >= 0) {
        final endIndex = min(labelIndex + 20, line.length);
        final relevantPart = line.substring(labelIndex, endIndex);
        
        // Look for M or F, but skip if it's part of a word (like "Male", "Female")
        final tokenRegex = RegExp(r'\b([MF])\b(?!ale)', caseSensitive: false);
        final tokenMatch = tokenRegex.firstMatch(relevantPart);
        if (tokenMatch != null) {
          final normalized = _normalizeGenderValue(tokenMatch.group(1));
          if (normalized != null) return normalized;
        }
      }
    }

    return null;
  }

  String? _normalizeGenderValue(String? raw) {
    if (raw == null) return null;
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return null;

    if (value == 'm' || value == 'male') return 'Male';
    if (value == 'f' || value == 'female') return 'Female';

    // OCR may return a full row like "PHL M 2003/04/03".
    final shortToken = RegExp(r'\b([mf])\b', caseSensitive: false)
        .firstMatch(value)
        ?.group(1)
        ?.toLowerCase();
    if (shortToken == 'm') return 'Male';
    if (shortToken == 'f') return 'Female';

    if (RegExp(r'\bmale\b').hasMatch(value)) return 'Male';
    if (RegExp(r'\bfemale\b').hasMatch(value)) return 'Female';

    return null;
  }

  String? _extractGenericBirthDate(List<String> lines) {
    final byLabel = _extractBirthDateByLabels(lines, const [
      'date of birth',
      'birth date',
      'dob',
      'birthdate',
      'birthday',
      'petsa ng kapanganakan',
    ]);
    if (byLabel != null) return byLabel;

    for (final line in lines) {
      final normalized = _normalizeDateString(line);
      if (normalized != null) return normalized;
    }

    return null;
  }

  String? _extractBirthDateByLabels(List<String> lines, List<String> labels) {
    final inline = _extractValueForLabels(lines, labels);
    final inlineDate = _normalizeDateString(inline);
    if (inlineDate != null) return inlineDate;

    final nextValue = _extractNextValueAfterLabel(lines, labels);
    final nextDate = _normalizeDateString(nextValue);
    if (nextDate != null) return nextDate;

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (!_containsAny(lower, labels)) continue;
      final date = _normalizeDateString(line);
      if (date != null) return date;
    }

    return null;
  }

  String? _normalizeDateString(String? raw) {
    if (raw == null) return null;

    final text = raw
        .trim()
        .replaceAll(',', ' ')
        .replaceAll('.', '/')
        .replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) return null;

    final ocrFixedText = _fixOcrDateChars(text);

    final monthRegex = RegExp(
      r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+(\d{1,2})\s+(\d{2,4})',
      caseSensitive: false,
    );
    final monthFirst = monthRegex.firstMatch(ocrFixedText);
    if (monthFirst != null) {
      final month = _monthToNumber(monthFirst.group(1)!);
      final day = int.tryParse(monthFirst.group(2)!);
      final year = _expandYear(int.tryParse(monthFirst.group(3)!));
      final iso = _toIsoDate(year, month, day);
      if (iso != null) return iso;
    }

    final dayMonthWordRegex = RegExp(
      r'(\d{1,2})\s+(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+(\d{2,4})',
      caseSensitive: false,
    );
    final dayMonthWord = dayMonthWordRegex.firstMatch(ocrFixedText);
    if (dayMonthWord != null) {
      final day = int.tryParse(dayMonthWord.group(1)!);
      final month = _monthToNumber(dayMonthWord.group(2)!);
      final year = _expandYear(int.tryParse(dayMonthWord.group(3)!));
      final iso = _toIsoDate(year, month, day);
      if (iso != null) return iso;
    }

    final numericRegex = RegExp(r'(\d{1,4})[\-/](\d{1,2})[\-/](\d{1,4})');
    final numeric = numericRegex.firstMatch(ocrFixedText);
    if (numeric != null) {
      final a = int.tryParse(numeric.group(1)!);
      final b = int.tryParse(numeric.group(2)!);
      final c = int.tryParse(numeric.group(3)!);

      if (a != null && b != null && c != null) {
        if (numeric.group(1)!.length == 4) {
          final iso = _toIsoDate(a, b, c);
          if (iso != null) return iso;
        }

        final year = _expandYear(c);
        if (year != null) {
          if (a > 12 && b <= 12) {
            final iso = _toIsoDate(year, b, a);
            if (iso != null) return iso;
          }

          if (b > 12 && a <= 12) {
            final iso = _toIsoDate(year, a, b);
            if (iso != null) return iso;
          }

          final iso = _toIsoDate(year, a, b);
          if (iso != null) return iso;
        }
      }
    }

    return null;
  }

  String _fixOcrDateChars(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      final prev = i > 0 ? input[i - 1] : '';
      final next = i < input.length - 1 ? input[i + 1] : '';
      final nearDigitOrDate = RegExp(r'[0-9/\-]').hasMatch(prev) ||
          RegExp(r'[0-9/\-]').hasMatch(next);

      if (nearDigitOrDate) {
        if (ch == 'O' || ch == 'o' || ch == 'D') {
          buffer.write('0');
          continue;
        }
        if (ch == 'I' || ch == 'l' || ch == '|' || ch == 'i') {
          buffer.write('1');
          continue;
        }
        if (ch == 'S' || ch == 's') {
          buffer.write('5');
          continue;
        }
        if (ch == 'B') {
          buffer.write('8');
          continue;
        }
      }

      buffer.write(ch);
    }
    return buffer.toString();
  }

  int? _monthToNumber(String monthText) {
    final m = monthText.toLowerCase();
    if (m.startsWith('jan')) return 1;
    if (m.startsWith('feb')) return 2;
    if (m.startsWith('mar')) return 3;
    if (m.startsWith('apr')) return 4;
    if (m == 'may') return 5;
    if (m.startsWith('jun')) return 6;
    if (m.startsWith('jul')) return 7;
    if (m.startsWith('aug')) return 8;
    if (m.startsWith('sep')) return 9;
    if (m.startsWith('oct')) return 10;
    if (m.startsWith('nov')) return 11;
    if (m.startsWith('dec')) return 12;
    return null;
  }

  int? _expandYear(int? year) {
    if (year == null) return null;
    if (year >= 100) return year;
    return year <= 39 ? 2000 + year : 1900 + year;
  }

  String? _toIsoDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) return null;
    if (year < 1900 || year > 2100) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;
    return '${year.toString().padLeft(4, '0')}/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
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

      if (_containsAny(
          line.toLowerCase(), ['name', 'full name', 'given name'])) {
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
    final deDuplicated = _collapseRepeatedWordGroups(cleaned);
    return _normalizeOcrNameErrors(deDuplicated);
  }

  String _normalizeOcrNameErrors(String name) {
    if (name.isEmpty) return name;

    final words = name.split(' ').where((w) => w.trim().isNotEmpty).toList();
    final normalized = words.map((word) {
      final upper = word.toUpperCase();

      // Common OCR confusion on IDs: leading 'Q' is read as 'A'.
      // Example: QUINATADCAN -> AUINATADCAN.
      if (upper.length >= 4 && upper.startsWith('AUI')) {
        return 'Q${word.substring(1)}';
      }

      if (upper.length >= 4 && upper.startsWith('AUE')) {
        return 'Q${word.substring(1)}';
      }

      return word;
    }).toList();

    return normalized.join(' ');
  }

  Future<List<List<String>>> _readOcrLineVariants(XFile imageFile) async {
    final variants = <List<String>>[];

    final original = await _readLinesFromPath(imageFile.path);
    if (original.isNotEmpty) {
      variants.add(original);
    }

    try {
      final bytes = await File(imageFile.path).readAsBytes();
      final decoded = img_pkg.decodeImage(bytes);
      if (decoded != null) {
        final gray = img_pkg.grayscale(decoded);
        final contrasted =
            img_pkg.adjustColor(gray, contrast: 1.35, brightness: 0.03);
        final sharpened = img_pkg.convolution(contrasted, filter: [
          0,
          -1,
          0,
          -1,
          5,
          -1,
          0,
          -1,
          0,
        ]);

        final tmpPath = '${imageFile.path}.ocr_enhanced.jpg';
        await File(tmpPath)
            .writeAsBytes(img_pkg.encodeJpg(sharpened, quality: 92));
        final enhanced = await _readLinesFromPath(tmpPath);
        if (enhanced.isNotEmpty) {
          variants.add(enhanced);
        }
      }
    } catch (e) {
      print('OCR enhancement pass failed: $e');
    }

    return variants;
  }

  Future<List<String>> _readLinesFromPath(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<String> _pickBestLines(List<List<String>> variants) {
    if (variants.isEmpty) return const [];
    if (variants.length == 1) return variants.first;

    List<String> best = variants.first;
    var bestScore = _scoreLines(best);

    for (var i = 1; i < variants.length; i++) {
      final candidate = variants[i];
      final score = _scoreLines(candidate);
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }

    return best;
  }

  int _scoreLines(List<String> lines) {
    if (lines.isEmpty) return -9999;

    var labelHits = 0;
    var totalLen = 0;
    for (final line in lines) {
      totalLen += line.length;
      if (_containsAny(line.toLowerCase(), _allFieldLabels)) {
        labelHits += 1;
      }
    }

    return labelHits * 50 + min(totalLen, 600);
  }

  String _collapseRepeatedWordGroups(String text) {
    final words = text.split(' ').where((w) => w.trim().isNotEmpty).toList();
    if (words.length < 2) return text;

    for (int size = 1; size <= words.length ~/ 2; size++) {
      if (words.length % size != 0) continue;

      final candidate = words.take(size).toList();
      var matches = true;

      for (int index = 0; index < words.length; index++) {
        if (words[index].toUpperCase() !=
            candidate[index % size].toUpperCase()) {
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

  /// Public helper: reads the raw QR payload from [imageFile]. Returns
  /// the raw string or `null` if none found. Useful for UI/debugging.
  Future<String?> readQrRaw(XFile imageFile) async {
    try {
      print('readQrRaw: processing image ${imageFile.path}');
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);
      print('readQrRaw: found ${barcodes.length} barcode(s)');
      if (barcodes.isEmpty) {
        print('readQrRaw: no barcodes on initial pass, trying rotations');
        return await _tryScanWithRotations(imageFile);
      }

      for (final bc in barcodes) {
        print(
            'barcode format=${bc.format}, raw=${bc.rawValue}, display=${bc.displayValue}');
        if (bc.rawValue != null && bc.rawValue!.trim().isNotEmpty)
          return bc.rawValue!.trim();
        if (bc.displayValue != null && bc.displayValue!.trim().isNotEmpty)
          return bc.displayValue!.trim();
      }

      final first = barcodes.first;
      return first.rawValue?.trim() ?? first.displayValue?.trim();
    } catch (e) {
      print('Error reading QR (public): $e');
      return null;
    }
  }

  /// If initial scan failed, attempt rotated images (90/180/270) and retry.
  /// Returns the raw QR string if found, otherwise `null`.
  Future<String?> _tryScanWithRotations(XFile imageFile) async {
    try {
      final bytes = await File(imageFile.path).readAsBytes();
      final original = img_pkg.decodeImage(bytes);
      if (original == null) return null;

      // Try cropping the right half where QR is commonly placed on PhilSys cards
      try {
        final cropX = (original.width * 0.45).toInt();
        final cropW = original.width - cropX;
        final cropped = img_pkg.copyCrop(original,
            x: cropX, y: 0, width: cropW, height: original.height);
        final encodedCrop = img_pkg.encodeJpg(cropped);
        final cropPath = '${imageFile.path}.crop.jpg';
        await File(cropPath).writeAsBytes(encodedCrop);
        print('readQrRaw: trying cropped right-half at $cropPath');
        final inputImageCrop = InputImage.fromFilePath(cropPath);
        final barcodesCrop = await _barcodeScanner.processImage(inputImageCrop);
        print(
            'readQrRaw: cropped scan found ${barcodesCrop.length} barcode(s)');
        if (barcodesCrop.isNotEmpty) {
          for (final bc in barcodesCrop) {
            print(
                'cropped barcode format=${bc.format}, raw=${bc.rawValue}, display=${bc.displayValue}');
            if (bc.rawValue != null && bc.rawValue!.trim().isNotEmpty)
              return bc.rawValue!.trim();
            if (bc.displayValue != null && bc.displayValue!.trim().isNotEmpty)
              return bc.displayValue!.trim();
          }
          final first = barcodesCrop.first;
          return first.rawValue?.trim() ?? first.displayValue?.trim();
        }
      } catch (e) {
        print('Error scanning cropped region: $e');
      }

      for (final angle in [90, 180, 270]) {
        try {
          final rotated = img_pkg.copyRotate(original, angle: angle);
          final encoded = img_pkg.encodeJpg(rotated);
          final tmpPath = '${imageFile.path}.rot$angle.jpg';
          await File(tmpPath).writeAsBytes(encoded);

          print('readQrRaw: trying rotated image $angle° at $tmpPath');
          final inputImage = InputImage.fromFilePath(tmpPath);
          final barcodes = await _barcodeScanner.processImage(inputImage);
          print(
              'readQrRaw: rotated $angle found ${barcodes.length} barcode(s)');
          if (barcodes.isNotEmpty) {
            for (final bc in barcodes) {
              print(
                  'rotated barcode format=${bc.format}, raw=${bc.rawValue}, display=${bc.displayValue}');
              if (bc.rawValue != null && bc.rawValue!.trim().isNotEmpty)
                return bc.rawValue!.trim();
              if (bc.displayValue != null && bc.displayValue!.trim().isNotEmpty)
                return bc.displayValue!.trim();
            }
            final first = barcodes.first;
            return first.rawValue?.trim() ?? first.displayValue?.trim();
          }
        } catch (e) {
          print('Error scanning rotated $angle: $e');
        }
      }
    } catch (e) {
      print('Error in rotation scanning helper: $e');
    }

    return null;
  }

  /// Public wrapper for approximate name matching so other files can use it.
  bool namesMatchApproximately(String a, String b) {
    if (a.trim().isEmpty || b.trim().isEmpty) return false;

    final norm = (String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\s]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final na = norm(a);
    final nb = norm(b);

    final wa = na.split(' ').where((w) => w.length > 1).toSet();
    final wb = nb.split(' ').where((w) => w.length > 1).toSet();
    if (wa.isEmpty || wb.isEmpty) return false;

    final intersection = wa.intersection(wb).length;
    final larger = wa.length > wb.length ? wa.length : wb.length;

    final ratio = intersection / larger;
    return ratio >= 0.6 || na == nb;
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
    await _barcodeScanner.close();
  }

  /// Public helper: extracts name from raw QR content. Handles JSON and
  /// key-value formats commonly found in government ID QR codes.
  String? extractNameFromQrRawContent(String rawQrContent) {
    return _extractNameFromQrContent(rawQrContent);
  }
}

extension _QrHelpers on IdScanService {
  Future<String?> _readQrContentFromImage(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);
      if (barcodes.isEmpty) return null;

      // Prefer the first barcode with a rawValue.
      for (final bc in barcodes) {
        if (bc.rawValue != null && bc.rawValue!.trim().isNotEmpty)
          return bc.rawValue!.trim();
      }

      return barcodes.first.rawValue?.trim();
    } catch (e) {
      print('Error reading QR: $e');
      return null;
    }
  }

  String? _extractNameFromQrContent(String raw) {
    if (raw.trim().isEmpty) return null;

    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        if (decoded['subject'] is Map) {
          final subject = decoded['subject'] as Map;
          final fName = subject['fName'] as String?;
          final mName = subject['mName'] as String?;
          final lName = subject['lName'] as String?;

          if ((fName?.isNotEmpty ?? false) ||
              (mName?.isNotEmpty ?? false) ||
              (lName?.isNotEmpty ?? false)) {
            final parts = <String>[];
            if (fName != null && fName.trim().isNotEmpty)
              parts.add(fName.trim());
            if (mName != null && mName.trim().isNotEmpty)
              parts.add(mName.trim());
            if (lName != null && lName.trim().isNotEmpty)
              parts.add(lName.trim());
            if (parts.isNotEmpty) return _cleanName(parts.join(' '));
          }
        }

        final keys =
            decoded.map((k, v) => MapEntry(k.toString().toLowerCase(), v));

        String? first = keys['firstname'] ??
            keys['first_name'] ??
            keys['givenname'] ??
            keys['given_name'] ??
            keys['given names'] ??
            keys['fname'] ??
            keys['fname'.toLowerCase()];
        String? last = keys['lastname'] ??
            keys['last_name'] ??
            keys['surname'] ??
            keys['family_name'] ??
            keys['lname'];
        String? middle = keys['middlename'] ??
            keys['middle_name'] ??
            keys['middle'] ??
            keys['mname'];
        String? full = keys['name'] ?? keys['full_name'];

        if (full != null && full is String && full.trim().isNotEmpty)
          return _cleanName(full);

        final parts = <String>[];
        if (first is String && first.trim().isNotEmpty) parts.add(first.trim());
        if (middle is String && middle.trim().isNotEmpty)
          parts.add(middle.trim());
        if (last is String && last.trim().isNotEmpty) parts.add(last.trim());

        if (parts.isNotEmpty) return _cleanName(parts.join(' '));
      }
    } catch (_) {}
    final lines = raw
        .split(RegExp(r'\r?\n|;|\|'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final kv = <String, String>{};
    for (final line in lines) {
      final sepIdx = line.indexOf(':');
      if (sepIdx > 0) {
        final k = line.substring(0, sepIdx).trim().toLowerCase();
        final v = line.substring(sepIdx + 1).trim();
        kv[k] = v;
      }
    }

    if (kv.isNotEmpty) {
      final first = kv['first name'] ??
          kv['firstname'] ??
          kv['given name'] ??
          kv['givenname'];
      final last = kv['last name'] ?? kv['lastname'] ?? kv['surname'];
      final middle = kv['middle name'] ?? kv['middlename'];
      final full = kv['name'] ?? kv['full name'];

      if (full != null) return _cleanName(full);
      final parts = <String>[];
      if (first != null) parts.add(first);
      if (middle != null && middle != first) parts.add(middle);
      if (last != null) parts.add(last);
      if (parts.isNotEmpty) return _cleanName(parts.join(' '));
    }

    for (final line in lines) {
      if (_looksLikePersonName(line)) return _cleanName(line);
    }

    if (_looksLikePersonName(raw)) return _cleanName(raw);
    return null;
  }

  bool _namesMatchApproximately(String a, String b) {
    if (a.trim().isEmpty || b.trim().isEmpty) return false;

    final norm = (String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\s]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final na = norm(a);
    final nb = norm(b);

    final wa = na.split(' ').where((w) => w.length > 1).toSet();
    final wb = nb.split(' ').where((w) => w.length > 1).toSet();
    if (wa.isEmpty || wb.isEmpty) return false;

    final intersection = wa.intersection(wb).length;
    final larger = wa.length > wb.length ? wa.length : wb.length;

    final ratio = intersection / larger;
    return ratio >= 0.6 || na == nb;
  }

  bool namesMatchApproximately(String a, String b) =>
      _namesMatchApproximately(a, b);

  Future<IdScanResult> verifyPhilSysFrontWithBackQr({
    required XFile frontImage,
    required XFile backImage,
  }) async {
    try {
      final frontResult =
          await extractNameFromIdImage(frontImage, idType: 'philsys');
      final frontName = frontResult.extractedName;
      if (frontName == null) {
        return IdScanResult(
          detectedIdType: 'philsys',
          matchesSelectedType: false,
          warningMessage: 'Could not extract a name from the front image.',
        );
      }

      final rawQr = await _readQrContentFromImage(backImage);
      if (rawQr == null) {
        return IdScanResult(
          extractedName: frontName,
          detectedIdType: 'philsys_qr',
          matchesSelectedType: false,
          warningMessage: 'No QR code was detected on the back image.',
        );
      }

      final qrName = _extractNameFromQrContent(rawQr);
      final matches =
          qrName != null ? _namesMatchApproximately(frontName, qrName) : false;

      return IdScanResult(
        extractedName: qrName ?? frontName,
        detectedIdType: 'philsys_qr',
        matchesSelectedType: matches,
        warningMessage: matches
            ? null
            : 'The name on the QR did not sufficiently match the front image.',
      );
    } catch (e) {
      print('Error verifying front/back: $e');
      return const IdScanResult(
        detectedIdType: 'philsys_qr',
        matchesSelectedType: false,
        warningMessage: 'An error occurred during verification.',
      );
    }
  }

  /// Variant of [verifyPhilSysFrontWithBackQr] that also logs the QR raw
  /// payload and the parsed full name before returning. Useful for debugging
  /// and manual verification during development.
  Future<IdScanResult> verifyPhilSysFrontWithBackQrAndLog({
    required XFile frontImage,
    required XFile backImage,
  }) async {
    try {
      final frontResult =
          await extractNameFromIdImage(frontImage, idType: 'philsys');
      final frontName = frontResult.extractedName;
      print('Front OCR name: ${frontName ?? "<none>"}');

      final rawQr = await _readQrContentFromImage(backImage);
      print('QR raw payload: ${rawQr ?? "<no-qr-detected>"}');

      final qrName = rawQr != null ? _extractNameFromQrContent(rawQr) : null;
      print('Parsed QR full name: ${qrName ?? "<none>"}');

      final matches = (frontName != null && qrName != null)
          ? _namesMatchApproximately(frontName, qrName)
          : false;
      print('Name match result: $matches');

      return IdScanResult(
        extractedName: qrName ?? frontName,
        detectedIdType: 'philsys_qr',
        matchesSelectedType: matches,
        warningMessage: matches
            ? null
            : 'The name on the QR did not sufficiently match the front image.',
      );
    } catch (e) {
      print('Error verifying front/back (log variant): $e');
      return const IdScanResult(
        detectedIdType: 'philsys_qr',
        matchesSelectedType: false,
        warningMessage: 'An error occurred during verification.',
      );
    }
  }
}
