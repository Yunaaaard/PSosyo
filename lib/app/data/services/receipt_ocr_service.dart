import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:p_sosyo/app/data/models/receipt_ocr_result.dart';

class ReceiptOcrService {
  ReceiptOcrService() : _recognizer = TextRecognizer();

  final TextRecognizer _recognizer;

  Future<ReceiptOcrResult> readReceiptOcr(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final recognizedText = await _recognizer.processImage(inputImage);
    return extractReceiptOcrResult(recognizedText.text);
  }

  ReceiptOcrResult extractReceiptOcrResult(String rawText) {
    final lines = _splitReceiptLines(rawText);
    final reference = _extractReceiptReference(lines);
    final phoneNumber = _extractReceiptPhoneNumber(lines);
    final amount = _extractReceiptAmount(lines);

    return ReceiptOcrResult(
      referenceNumber: reference,
      phoneNumber: phoneNumber,
      amount: amount,
    );
  }

  void close() {
    _recognizer.close();
  }

  String? _extractReceiptReference(List<String> lines) {
    for (var index = 0; index < lines.length; index++) {
      final current = lines[index];
      if (!_isReferenceLabel(current)) {
        continue;
      }

      final sameLine = _stripLabelPrefix(current, _referenceLabelPatterns);
      final nextLine = index + 1 < lines.length ? lines[index + 1] : '';
      final candidate = sameLine.isNotEmpty ? sameLine : nextLine;
      final digits = _extractReferenceDigits(candidate);
      if (digits.length >= 10) {
        return _formatReferenceDigits(digits);
      }
    }

    return null;
  }

  double? _extractReceiptAmount(List<String> lines) {
    for (var index = 0; index < lines.length; index++) {
      final current = lines[index];
      if (!_isAmountLabel(current)) {
        continue;
      }

      final sameLine = _stripLabelPrefix(current, _amountLabelPatterns);
      final sameLineAmount = _extractAmountFromText(sameLine);
      if (sameLineAmount != null) {
        return sameLineAmount;
      }

      if (index + 1 < lines.length) {
        final nextLine = lines[index + 1];
        if (_isLikelyAmountLine(nextLine)) {
          final nextAmount = _extractAmountFromText(nextLine);
          if (nextAmount != null) {
            return nextAmount;
          }
        }
      }

      if (index + 2 < lines.length) {
        final skipLine = lines[index + 2];
        if (_isLikelyAmountLine(skipLine)) {
          final skipAmount = _extractAmountFromText(skipLine);
          if (skipAmount != null) {
            return skipAmount;
          }
        }
      }
    }

    final fallbackValues = <double>[];
    for (var index = 0; index < lines.length; index++) {
      final current = lines[index];
      if (!_isLikelyAmountLine(current)) {
        continue;
      }

      final parsed = _extractAmountFromText(current);
      if (parsed != null) {
        fallbackValues.add(parsed);
      }

      if (index + 1 < lines.length && _isLikelyAmountLine(lines[index + 1])) {
        final nextParsed = _extractAmountFromText(lines[index + 1]);
        if (nextParsed != null) {
          fallbackValues.add(nextParsed);
        }
      }
    }

    if (fallbackValues.isEmpty) {
      return null;
    }

    fallbackValues.sort((a, b) => b.compareTo(a));
    return fallbackValues.first;
  }

  String? _extractReceiptPhoneNumber(List<String> lines) {
    for (final line in lines) {
      final phone = _extractPlus63PhoneNumber(line);
      if (phone != null) {
        return phone;
      }
    }

    return null;
  }

  String? _extractPlus63PhoneNumber(String text) {
    final normalized = _normalizeOcrWhitespace(text);
    if (normalized.isEmpty) {
      return null;
    }

    final match = RegExp(
            r'(?:\+63|63)[\s\-()]*(9\d{2})[\s\-()]*?(\d{3})[\s\-()]*?(\d{4})')
        .firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final prefix = match.group(1);
    final middle = match.group(2);
    final last = match.group(3);
    if (prefix == null || middle == null || last == null) {
      return null;
    }

    return '+63 $prefix $middle $last';
  }

  double? _extractAmountFromText(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final hasMoneyMarker = normalized.contains('₱') ||
        normalized.toLowerCase().contains('php') ||
        normalized.toLowerCase().contains('p ');
    final hasDecimalOrGrouping =
        normalized.contains('.') || normalized.contains(',');

    if (!hasMoneyMarker && !hasDecimalOrGrouping) {
      return null;
    }

    final amountRegex = RegExp(
      r'(?:₱|php|p)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2})?)|([0-9]+\.[0-9]{2})',
      caseSensitive: false,
    );
    final match = amountRegex.firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final value = match.group(1) ?? match.group(2) ?? '';
    final cleaned = value.replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }

  bool _isReferenceLabel(String value) {
    final normalized = value.toLowerCase();
    return _referenceLabelPatterns.any((pattern) => pattern.hasMatch(normalized));
  }

  bool _isAmountLabel(String value) {
    final normalized = value.toLowerCase();
    return _amountLabelPatterns.any((pattern) => pattern.hasMatch(normalized));
  }

  bool _isLikelyAmountSectionLine(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('amount') ||
        normalized.contains('sent') ||
        normalized.contains('php') ||
        normalized.contains('₱');
  }

  String _formatReferenceDigits(String digits) {
    final cleaned = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) {
      return digits;
    }

    if (cleaned.length == 13) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    }

    final buffer = StringBuffer();
    for (var index = 0; index < cleaned.length; index++) {
      buffer.write(cleaned[index]);
      if ((index + 1) % 4 == 0 && index != cleaned.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  List<String> _splitReceiptLines(String rawText) {
    return rawText
        .replaceAll('\r', '\n')
        .split(RegExp(r'\n+'))
        .map((line) => _normalizeOcrWhitespace(line))
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String _extractReferenceDigits(String text) {
    final normalized = _normalizeOcrWhitespace(text);
    if (normalized.isEmpty) {
      return '';
    }

    final match = RegExp(r'^[0-9][0-9\s-]*').firstMatch(normalized);
    if (match != null) {
      return match.group(0)?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    }

    final looseMatch = RegExp(r'(\d[\d\s-]{7,}\d)').firstMatch(normalized);
    if (looseMatch != null) {
      return looseMatch.group(1)?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    }

    return '';
  }

  final List<RegExp> _referenceLabelPatterns = [
    RegExp(r'\bref\s*no\.?\b', caseSensitive: false),
    RegExp(r'\breference\s*no\.?\b', caseSensitive: false),
  ];

  final List<RegExp> _amountLabelPatterns = [
    RegExp(r'\btotal\s*amount\s*sent\b', caseSensitive: false),
  ];

  String _normalizeOcrWhitespace(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _isLikelyAmountLine(String value) {
    final normalized = value.toLowerCase();
    return _isLikelyAmountSectionLine(normalized) ||
        RegExp(r'\b[0-9]{1,3}(?:,[0-9]{3})*\.[0-9]{2}\b')
            .hasMatch(normalized) ||
        normalized.contains('₱');
  }

  String _stripLabelPrefix(String value, List<RegExp> patterns) {
    var output = value.trim();
    for (final pattern in patterns) {
      output = output.replaceFirst(pattern, '').trim();
    }
    output = output.replaceFirst(RegExp(r'^[:\-\s]+'), '').trim();
    return output;
  }
}
