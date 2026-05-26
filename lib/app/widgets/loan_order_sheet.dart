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
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late LoanPrincipalOption _selectedPrincipal;
  late int _selectedTermDays;
  late DateTime _appliedAt;

  HomeController get _controller => Get.find<HomeController>();

  List<int> get _termOptions => _controller.paymentTermOptions;

  @override
  void initState() {
    super.initState();
    _selectedPrincipal = _controller.principalOptions.first;
    _selectedTermDays = _termOptions.first;
    _appliedAt = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

  DateTime get _dueAt => _appliedAt.add(Duration(days: _selectedTermDays));

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text.replaceAll(',', '').trim());
    final success = _controller.submitLoanOrder(
      principal: _selectedPrincipal,
      amount: amount,
      appliedAt: _appliedAt,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Select principal',
                          style: TextStyle(
                            color: colors.darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<LoanPrincipalOption>(
                          value: _selectedPrincipal,
                          items: _controller.principalOptions
                              .map(
                                (principal) => DropdownMenuItem<LoanPrincipalOption>(
                                  value: principal,
                                  child: Text(principal.title),
                                ),
                              )
                              .toList(),
                          onChanged: (principal) {
                            if (principal == null) return;
                            setState(() {
                              _selectedPrincipal = principal;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Loan amount',
                          style: TextStyle(
                            color: colors.darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 0, minHeight: 0),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 8),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    PesoFormatter.buildPesoSymbolSpan(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4B4F57),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            final text = value?.replaceAll(',', '').trim() ?? '';
                            final amount = double.tryParse(text);
                            if (amount == null || amount <= 0) {
                              return 'Enter a valid amount';
                            }
                            if (amount > _controller.availableCreditLimitValue) {
                              return 'Amount must be 25,000 or below';
                            }
                            return null;
                          },
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
                        InkWell(
                          onTap: _pickAppliedDate,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
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
                                    formatLoanDate(_appliedAt),
                                    style: TextStyle(
                                      color: colors.bodyGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Icon(Icons.calendar_month_rounded, color: colors.titleGrey),
                              ],
                            ),
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
                            onPressed: _submit,
                            style: AppThemes.primaryButtonStyle,
                            child: const Text(
                              'Create Loan Order',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}