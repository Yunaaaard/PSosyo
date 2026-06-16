import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p_sosyo/app/data/models/loan_item_record.dart';
import 'package:p_sosyo/app/widgets/scan_success_receipt_card.dart';

class LoanDetailsSheet extends StatelessWidget {
  const LoanDetailsSheet({
    super.key,
    required this.principalTitle,
    required this.referenceId,
    required this.appliedDateTime,
    required this.dueDateTime,
    required this.amountDue,
    required this.items,
    this.rawPayload,
    this.fromName,
  });

  final String principalTitle;
  final String referenceId;
  final String appliedDateTime;
  final String dueDateTime;
  final String amountDue;
  final List<LoanItemRecord> items;
  final String? rawPayload;
  final String? fromName;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'P ', decimalDigits: 2);
    final totalQuantity =
        items.fold<int>(0, (sum, item) => sum + item.quantity);
    final skuCount = items.where((item) => item.sku.trim().isNotEmpty).length;
    final productsTotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final amountDueValue = _parseAmount(amountDue);

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8DAE0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Loan Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2030),
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF6A7080),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          principalTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D2434),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E9FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          referenceId,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B3DF0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Amount Due',
                          value: currency.format(amountDueValue),
                          highlight: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'SKU Count',
                          value: skuCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Total Qty',
                          value: totalQuantity.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Applied', value: appliedDateTime),
                  _InfoRow(label: 'Due', value: dueDateTime),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF232939),
                  ),
                ),
                const Spacer(),
                Text(
                  currency.format(productsTotal),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A5060),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8EAF2)),
                ),
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'No SKU rows found for this loan.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E94A3),
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  headingRowColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                    (_) => const Color(0xFFF5F6FA),
                                  ),
                                  dataRowMinHeight: 44,
                                  dataRowMaxHeight: 52,
                                  columnSpacing: 24,
                                  horizontalMargin: 16,
                                  headingTextStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF444A59),
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('SKU')),
                                    DataColumn(label: Text('Qty')),
                                    DataColumn(label: Text('Unit Price')),
                                    DataColumn(label: Text('Total Price')),
                                  ],
                                  rows: items.map((item) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            item.sku.isEmpty ? '-' : item.sku,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                            Text(item.quantity.toString())),
                                        DataCell(Text(
                                            currency.format(item.unitPrice))),
                                        DataCell(
                                          Text(
                                            currency.format(item.totalPrice),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final String paymentRef = _resolvePaymentReference(rawPayload);

                String qrData;
                if (rawPayload != null && rawPayload!.isNotEmpty) {
                  try {
                    final Map<String, dynamic> base =
                        jsonDecode(rawPayload!) as Map<String, dynamic>;
                    base['payment_reference'] = paymentRef;
                    base['ReferenceID'] = referenceId;
                    qrData = jsonEncode(base);
                  } catch (_) {
                    qrData = rawPayload!;
                  }
                } else {
                  qrData = jsonEncode({
                    'ReferenceID': referenceId,
                    'principalTitle': principalTitle,
                    'amountDue': _parseAmount(amountDue),
                    'dueDate': dueDateTime,
                    'payment_reference': paymentRef,
                  });
                }

                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 24),
                            child: SingleChildScrollView(
                              child: ScanSuccessReceiptCard(
                                qrData: qrData,
                                from: fromName ?? 'JOHN DOE',
                                to: principalTitle,
                                referenceId: referenceId,
                                formattedDateTime: appliedDateTime,
                                amountSent: amountDue,
                                paymentReference: paymentRef,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 12,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              radius: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('View Receipt & QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B3DF0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _parseAmount(String value) {
    return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  }

  static String _resolvePaymentReference(String? rawPayload) {
    if (rawPayload != null && rawPayload.isNotEmpty) {
      try {
        final Map<String, dynamic> parsed =
            jsonDecode(rawPayload) as Map<String, dynamic>;
        final ref = parsed['payment_reference'] ??
            parsed['paymentReference'] ??
            parsed['payment_reference_id'] ??
            parsed['paymentReferenceId'];
        if (ref is String && ref.trim().isNotEmpty) {
          return ref.trim();
        }
      } catch (_) {}
    }
    // Generate in the same format: YYMMDDHHmmss
    final now = DateTime.now();
    return '${now.year.toString().substring(2)}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7A8090),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222836),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFF4EFFF) : const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A8090),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color:
                  highlight ? const Color(0xFF6B3DF0) : const Color(0xFF1F2636),
            ),
          ),
        ],
      ),
    );
  }
}
