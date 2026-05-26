import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/modules/home_screen/models/loan_order.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

class LoanOrderSheet extends StatefulWidget {
  const LoanOrderSheet({super.key});

  @override
  State<LoanOrderSheet> createState() => _LoanOrderSheetState();
}

class _LoanOrderSheetState extends State<LoanOrderSheet> {
  late int _selectedTermDays;
  late DateTime _appliedAt;
  late final List<double> _allocations;

  HomeController get _controller => Get.find<HomeController>();

  List<int> get _termOptions => _controller.paymentTermOptions;

  @override
  void initState() {
    super.initState();
    _selectedTermDays = _termOptions.first;
    final now = DateTime.now();
    _appliedAt = DateTime(now.year, now.month, now.day);
    _allocations = List<double>.filled(_controller.principalOptions.length, 0);
  }

  Future<void> _pickAppliedDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _appliedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _appliedAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _appliedAt.hour,
        _appliedAt.minute,
      );
    });
  }

  DateTime get _dueAt {
    final now = DateTime.now();
    final applied = DateTime(now.year, now.month, now.day);
    return applied.add(Duration(days: _selectedTermDays));
  }

  double get _totalPercent =>
      _allocations.fold<double>(0, (sum, value) => sum + value);

  double get _availableCredit => _controller.availableCreditLimitValue;

  void _onAllocationChanged(int index, double value) {
    final otherTotal = _totalPercent - _allocations[index];
    final maxForThis = (100 - otherTotal).clamp(0, 100).toDouble();
    final clamped = value > maxForThis ? maxForThis : value;

    setState(() {
      _allocations[index] = clamped.roundToDouble();
    });
  }

  String _amountForPercent(double percent) {
    final amount = _availableCredit * (percent / 100);
    return formatAmount(amount);
  }

  void _submit() {
    if (_totalPercent <= 0.001) {
      Get.snackbar(
        'Invalid allocation',
        'Select at least one brand allocation greater than 0%.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final allocations = <LoanPrincipalOption, double>{};
    for (var index = 0; index < _controller.principalOptions.length; index++) {
      final percent = _allocations[index];
      if (percent > 0) {
        allocations[_controller.principalOptions[index]] = percent;
      }
    }

    final now = DateTime.now();
    final appliedAt = DateTime(now.year, now.month, now.day);
    final success = _controller.submitLoanOrdersByAllocation(
      allocations: allocations,
      appliedAt: appliedAt,
      termDays: _selectedTermDays,
    );

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;
    final dueDateText = formatLoanDate(_dueAt);
    final totalPercent = _totalPercent;
    final allocatedAmount = _availableCredit * (totalPercent / 100);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6D8DE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close_rounded,
                        color: colors.titleGrey,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'New Loan Order',
                      style: TextStyle(
                        color: colors.darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Brand allocation',
                        style: TextStyle(
                          color: colors.darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD8DBE2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total allocation',
                                  style: TextStyle(
                                    color: Color(0xFF6C7180),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${totalPercent.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: (totalPercent - 100).abs() < 0.001
                                        ? const Color(0xFF1EA35B)
                                        : const Color(0xFFEA4335),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Allocated amount',
                                  style: TextStyle(
                                    color: Color(0xFF9B9FA9),
                                  ),
                                ),
                                PesoFormatter.buildPesoText(
                                  amount: formatAmount(allocatedAmount),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4B4F57),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (var index = 0;
                                index < _controller.principalOptions.length;
                                index++) ...[
                              Builder(builder: (context) {
                                final option = _controller.principalOptions[index];
                                final enabled = !_controller.loanOrders
                                    .any((lo) => lo.title == option.title && lo.remainingAmount > 0);
                                return _BrandAllocationSlider(
                                  option: option,
                                  percentage: _allocations[index],
                                  computedAmount: _amountForPercent(_allocations[index]),
                                  onChanged: enabled
                                      ? (value) => _onAllocationChanged(index, value)
                                      : null,
                                  enabled: enabled,
                                );
                              }),
                              if (index != _controller.principalOptions.length - 1)
                                const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                        Text(
                          'Payment schedule',
                          style: TextStyle(
                            color: colors.darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: _selectedTermDays,
                          items: _termOptions
                              .map(
                                (days) => DropdownMenuItem<int>(
                                  value: days,
                                  child: Text('$days days'),
                                ),
                              )
                              .toList(),
                          onChanged: (days) {
                            if (days == null) return;
                            setState(() {
                              _selectedTermDays = days;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Applied date',
                          style: TextStyle(
                            color: colors.darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD8DBE2)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formatLoanDate(DateTime.now()),
                                  style: TextStyle(
                                    color: colors.bodyGrey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Due date',
                          style: TextStyle(
                            color: colors.darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7FA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            dueDateText,
                            style: TextStyle(
                              color: colors.bodyGrey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                          onPressed: totalPercent > 0.001 ? _submit : null,
                            style: AppThemes.primaryButtonStyle,
                            child: const Text(
                              'Create Loan Orders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandAllocationSlider extends StatelessWidget {
  const _BrandAllocationSlider({
    required this.option,
    required this.percentage,
    required this.computedAmount,
    required this.onChanged,
    this.enabled = true,
  });

  final LoanPrincipalOption option;
  final double percentage;
  final String computedAmount;
  final ValueChanged<double>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final displayAmount = enabled ? computedAmount : '—';
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(option.logoAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  option.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3038),
                  ),
                ),
              ),
              if (enabled)
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B3DF0),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E7EA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Blocked',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C7180),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          Slider(
            value: percentage,
            onChanged: onChanged,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: const Color(0xFF6B3DF0),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Amount: $displayAmount',
              style: const TextStyle(
                color: Color(0xFF6C7180),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}