import 'dart:convert';

class LoanQrPayloadService {
  const LoanQrPayloadService();

  bool looksLikeImportableLoanPayload(Map<String, dynamic> payload) {
    final referenceId = findString(
      payload,
      ['referenceId', 'reference_id', 'ReferenceID', 'loanId', 'loan_id', 'id'],
    );
    final principalTitle =
        findString(payload, ['principalTitle', 'principal_title', 'title']);
    final dueDate = findDate(payload, ['dueDate', 'due_date']);
    final amountDue =
        findAmount(payload, ['amountDue', 'amount_due', 'amount', 'totalAmount', 'total_amount']);
    final products = payload['products'];

    return referenceId != null &&
        principalTitle != null &&
        dueDate != null &&
        (amountDue != null || products is List);
  }

  String? extractReferenceIdFromPayload(
    String rawPayload,
    Map<String, dynamic>? decodedPayload,
  ) {
    final fromJson = decodedPayload == null
        ? null
        : findString(
            decodedPayload,
            ['referenceId', 'reference_id', 'ReferenceID', 'loanId', 'loan_id', 'id'],
          );
    if (fromJson != null) {
      return fromJson;
    }

    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      for (final key in <String>[
        'referenceId',
        'reference_id',
        'ReferenceID',
        'loanId',
        'loan_id',
        'id'
      ]) {
        final value = uri.queryParameters[key];
        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      final lastSegment =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (lastSegment.trim().isNotEmpty) {
        return lastSegment.trim();
      }
    }

    return trimmed;
  }

  Map<String, dynamic>? decodeQrPayload(String rawPayload) {
    try {
      final decoded = jsonDecode(_normalizeJsonPayload(rawPayload));
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      final extracted = _extractJsonObject(rawPayload);
      if (extracted == null) {
        return null;
      }

      try {
        final decoded = jsonDecode(_normalizeJsonPayload(extracted));
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final loose = _extractLooseLoanPayload(rawPayload);
    if (loose.isNotEmpty) {
      return loose;
    }
    return null;
  }

  String? findString(Map<String, dynamic> payload, List<String> keys) {
    final value = _findValue(payload, keys);
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  double? findAmount(Map<String, dynamic> payload, List<String> keys) {
    final value = _findValue(payload, keys);
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    final cleaned =
        value.toString().replaceAll(',', '').replaceAll('₱', '').trim();
    return double.tryParse(cleaned);
  }

  DateTime? findDate(Map<String, dynamic> payload, List<String> keys) {
    final value = _findValue(payload, keys);
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    final direct = DateTime.tryParse(raw);
    if (direct != null) {
      return direct;
    }

    final normalized = raw.replaceAll(RegExp(r'\s+\|\s+.*$'), '');
    return DateTime.tryParse(normalized);
  }

  String? _extractJsonObject(String rawPayload) {
    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final fenceStripped = trimmed
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();

    if (fenceStripped.startsWith('{') && fenceStripped.endsWith('}')) {
      return fenceStripped;
    }

    final startIndex = fenceStripped.indexOf('{');
    if (startIndex == -1) {
      return null;
    }

    var depth = 0;
    for (var index = startIndex; index < fenceStripped.length; index++) {
      final char = fenceStripped[index];
      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) {
          return fenceStripped.substring(startIndex, index + 1);
        }
      }
    }

    return null;
  }

  String _normalizeJsonPayload(String rawPayload) {
    return rawPayload.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
  }

  Map<String, dynamic> _extractLooseLoanPayload(String rawPayload) {
    final normalized = rawPayload.replaceAll('\r', '');
    final payload = <String, dynamic>{};

    String? matchString(String pattern) {
      final match =
          RegExp(pattern, multiLine: true, dotAll: true).firstMatch(normalized);
      if (match == null) {
        return null;
      }

      return match.group(1)?.trim();
    }

    payload['referenceId'] = matchString(
      r'"(?:referenceId|reference_id|ReferenceID|loanId|loan_id)"\s*:\s*"([^"]+)"',
    );
    payload['principalTitle'] =
        matchString(r'"principalTitle"\s*:\s*"([^"]+)"');
    payload['amountDue'] = matchString(r'"amountDue"\s*:\s*([^,}\n]+)');
    payload['appliedDate'] = matchString(r'"appliedDate"\s*:\s*"([^"]+)"');
    payload['dueDate'] = matchString(r'"dueDate"\s*:\s*"([^"]+)"');

    payload.removeWhere(
      (key, value) => value == null || value.toString().trim().isEmpty,
    );
    return payload;
  }

  dynamic _findValue(Map<String, dynamic> payload, List<String> keys) {
    final normalizedKeys = keys.map((key) => key.toLowerCase()).toSet();

    dynamic search(dynamic value) {
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        for (final entry in map.entries) {
          final key = entry.key.toString().toLowerCase();
          if (normalizedKeys.contains(key)) {
            return entry.value;
          }
        }

        for (final entry in map.entries) {
          final nested = search(entry.value);
          if (nested != null) {
            return nested;
          }
        }
      } else if (value is List) {
        for (final item in value) {
          final nested = search(item);
          if (nested != null) {
            return nested;
          }
        }
      }
      return null;
    }

    return search(payload);
  }
}
