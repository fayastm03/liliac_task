import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.transaction});

  final TransactionModel? transaction;

  bool get isEditing => transaction != null;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'expense';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  static const Color _teal = Color(0xFF307F7A);
  static const Color _fieldBorder = Color(0xFFD9D9D9);
  static const Color _secondaryText = Color(0xFF656565);

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _type = transaction.type;
      _selectedDate = transaction.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || !amount.isFinite || amount <= 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<TransactionProvider>();
    final existingTransaction = widget.transaction;

    // Preserve the existing category because the field is hidden in this UI.
    final transaction = TransactionModel(
      id: existingTransaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      category: existingTransaction?.category ?? 'General',
      date: _selectedDate,
      description: existingTransaction?.description,
      type: _type,
    );

    try {
      final success = existingTransaction == null
          ? await provider.addTransaction(transaction)
          : await provider.updateTransaction(transaction);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Transaction updated successfully'
                  : 'Transaction saved successfully',
            ),
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Unable to save the transaction.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );

      debugPrint('Save transaction failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: _teal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 110,
          title: Text(
            isEditing ? 'Edit Transaction' : 'Transaction',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.055),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TRANSACTION TYPE'),
                            DropdownButtonFormField<String>(
                              initialValue: _type,
                              isExpanded: true,
                              decoration: _fieldDecoration(),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'expense',
                                  child: Text('Expense'),
                                ),
                                DropdownMenuItem(
                                  value: 'income',
                                  child: Text('Income'),
                                ),
                              ],
                              onChanged: _isSaving
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        setState(() {
                                          _type = value;
                                        });
                                      }
                                    },
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('NAME'),
                            TextFormField(
                              controller: _titleController,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: _fieldDecoration(
                                hintText: 'Enter transaction name',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildLabel('AMOUNT'),
                            TextFormField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _fieldDecoration(
                                prefixText: '₹ ',
                                prefixStyle: const TextStyle(
                                  color: _teal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                suffixIcon: TextButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () {
                                          _amountController.clear();
                                        },
                                  style: TextButton.styleFrom(
                                    foregroundColor: _teal,
                                  ),
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide(
                                    color: _teal,
                                    width: 1.3,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                final amount = double.tryParse(text);

                                if (text.isEmpty) {
                                  return 'Please enter an amount';
                                }

                                if (amount == null ||
                                    !amount.isFinite ||
                                    amount <= 0) {
                                  return 'Enter a valid positive amount';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildLabel('DATE'),
                            InkWell(
                              onTap: _isSaving ? null : _selectDate,
                              borderRadius: BorderRadius.circular(8),
                              child: InputDecorator(
                                decoration: _fieldDecoration(
                                  suffixIcon: const Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                child: Text(
                                  MaterialLocalizations.of(context)
                                      .formatMediumDate(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        disabledBackgroundColor: _teal.withValues(alpha: 0.6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    String? hintText,
    String? prefixText,
    TextStyle? prefixStyle,
    Widget? suffixIcon,
    InputBorder? focusedBorder,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: prefixStyle,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: _secondaryText, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder:
          focusedBorder ??
          const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: _teal, width: 1.2),
          ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: _secondaryText,
          letterSpacing: 0.7,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
