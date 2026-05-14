import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/id_scan_service.dart';

class IdQrVerifierWidget extends StatefulWidget {
  const IdQrVerifierWidget({super.key});

  @override
  State<IdQrVerifierWidget> createState() => _IdQrVerifierWidgetState();
}

class _IdQrVerifierWidgetState extends State<IdQrVerifierWidget> {
  XFile? _front;
  XFile? _back;
  String _log = '';
  bool _loading = false;

  final _picker = ImagePicker();

  Future<void> _pickFront() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => _front = file);
  }

  Future<void> _pickBack() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => _back = file);
  }

  Future<void> _runVerifyAndLog() async {
    if (_front == null || _back == null) {
      setState(() => _log = 'Pick both front and back images first.');
      return;
    }

    setState(() {
      _loading = true;
      _log = 'Scanning...';
    });

    try {
      final service = IdScanService();

      // Get front OCR name
      final frontResult = await service.extractNameFromIdImage(_front!, idType: 'philsys');
      final frontName = frontResult.extractedName ?? '<none>';
      setState(() => _log = 'Front OCR name: $frontName');

      // Read raw QR payload from back image
      setState(() => _log = 'Reading QR from back image...');
      final rawQr = await service.readQrRaw(_back!);
      final rawDisplay = rawQr ?? '<no-qr-detected>';
      setState(() => _log = '${_log}\nQR raw payload: $rawDisplay');

      // Try parse JSON from QR (many PhilSys QR payloads are JSON)
      String parsedName = '<none parsed>';
      Map<String, dynamic>? parsedJson;
      if (rawQr != null) {
        try {
          final decoded = json.decode(rawQr);
          if (decoded is Map) {
            parsedJson = Map<String, dynamic>.from(decoded);
            // Try to extract fName/mName/lName as in sample payload
            final subject = parsedJson['subject'];
            if (subject is Map) {
              final f = subject['fName'] ?? subject['fName'.toLowerCase()] ?? '';
              final m = subject['mName'] ?? subject['mName'.toLowerCase()] ?? '';
              final l = subject['lName'] ?? subject['lName'.toLowerCase()] ?? '';
              final parts = [f, m, l].where((s) => s != null && s.toString().trim().isNotEmpty).map((s) => s.toString().trim()).toList();
              if (parts.isNotEmpty) parsedName = parts.join(' ');
            } else {
              // Fallback: try common keys
              final f = parsedJson['fName'] ?? parsedJson['f_name'] ?? parsedJson['firstname'];
              final l = parsedJson['lName'] ?? parsedJson['l_name'] ?? parsedJson['lastname'];
              if ((f != null || l != null) && (f?.toString().isNotEmpty == true || l?.toString().isNotEmpty == true)) {
                final parts = <String>[];
                if (f != null) parts.add(f.toString());
                if (l != null) parts.add(l.toString());
                parsedName = parts.join(' ');
              }
            }
          }
        } catch (e) {
          setState(() => _log = '${_log}\nFailed to parse QR as JSON: $e');
        }
      }

      setState(() => _log = '${_log}\nParsed full name from QR: $parsedName');

      // Compare names (use the service's approximate match)
      final matches = (frontName != '<none>' && parsedName != '<none parsed>')
          ? service.namesMatchApproximately(frontName, parsedName)
          : false;

      setState(() => _log = '${_log}\nNames match: $matches');

      if (parsedJson != null) {
        setState(() => _log = '${_log}\n\nParsed JSON (pretty):\n${const JsonEncoder.withIndent('  ').convert(parsedJson)}');
      }
    } catch (e) {
      setState(() => _log = 'Error during verify: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ElevatedButton(onPressed: _pickFront, child: const Text('Pick Front')),
              const SizedBox(width: 8),
              Text(_front?.name ?? 'No front selected'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(onPressed: _pickBack, child: const Text('Pick Back')),
              const SizedBox(width: 8),
              Text(_back?.name ?? 'No back selected'),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton(
                onPressed: _loading ? null : _runVerifyAndLog,
                child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Scan & Verify'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => setState(() {
                  _front = null;
                  _back = null;
                  _log = '';
                }),
                child: const Text('Reset'),
              ),
            ]),
            const SizedBox(height: 12),
            const Text('Log:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.black12,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(_log, style: const TextStyle(fontFamily: 'monospace')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
