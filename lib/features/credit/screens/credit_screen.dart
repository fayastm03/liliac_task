import 'package:flutter/material.dart';

import '../models/credit_model.dart';
import '../repositories/credit_repository.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  static const Color teal = Color(0xFF00877F);
  static const Color textColor = Color(0xFF333333);
  static const Color mutedColor = Color(0xFF888888);
  static const Color borderColor = Color(0xFFDDDDDD);

  final CreditRepository _repository = CreditRepository();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<String> _creditTypes = const [
    'Subscriptions',
    'Utilities',
    'Shopping',
    'Food',
    'Entertainment',
    'Other',
  ];

  List<CreditModel> _credits = [];

  String _selectedCreditType = 'Subscriptions';
  String _selectedPlan = 'Monthly';
  DateTime _selectedDate = DateTime.now();

  int? _editingId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCredits() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.getCredits();

      if (!mounted) return;

      setState(() {
        _credits = result;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Error loading credits: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load saved credits.';
      });
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: teal,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });
  }

  Future<void> _saveCredit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final recipient = _recipientController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || !amount.isFinite || amount <= 0) return;

    final wasEditing = _editingId != null;

    setState(() {
      _isSaving = true;
    });

    try {
      final credit = CreditModel(
        id: _editingId,
        creditType: _selectedCreditType,
        recipient: recipient,
        amount: amount,
        dueDate: _selectedDate,
        planType: _selectedPlan,
        createdAt: DateTime.now(),
      );

      if (wasEditing) {
        final updated = await _repository.updateCredit(credit);

        if (!updated) {
          throw StateError('The credit record could not be found.');
        }
      } else {
        await _repository.insertCredit(credit);
      }

      if (!mounted) return;

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasEditing
                ? 'Credit updated successfully'
                : 'Credit saved successfully',
          ),
          backgroundColor: teal,
        ),
      );

      await _loadCredits();
    } catch (error, stackTrace) {
      debugPrint('Error saving credit: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save credit. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _startEditing(CreditModel credit) {
    setState(() {
      _editingId = credit.id;
      _selectedCreditType = _creditTypes.contains(credit.creditType)
          ? credit.creditType
          : 'Other';
      _selectedPlan = credit.planType;
      _selectedDate = credit.dueDate;
      _recipientController.text = credit.recipient;
      _amountController.text = credit.amount.toStringAsFixed(2);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit the details and tap Update.')),
    );
  }

  Future<void> _deleteCredit(CreditModel credit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete credit?'),
          content: Text('Delete "${credit.recipient}" from your saved list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || credit.id == null || !mounted) return;

    try {
      final deleted = await _repository.deleteCredit(credit.id!);

      if (!mounted) return;

      if (!deleted) {
        throw StateError('The credit record could not be found.');
      }

      if (_editingId == credit.id) {
        _clearForm();
      }

      await _loadCredits();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credit deleted successfully')),
      );
    } catch (error) {
      debugPrint('Error deleting credit: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete this credit.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _recipientController.clear();
    _amountController.clear();

    setState(() {
      _editingId = null;
      _selectedCreditType = 'Subscriptions';
      _selectedPlan = 'Monthly';
      _selectedDate = DateTime.now();
    });

    _formKey.currentState?.reset();
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final digits = parts.first;
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 &&
          (remaining == 3 || (remaining > 3 && (remaining - 3) % 2 == 0))) {
        buffer.write(',');
      }
    }

    return '₹ ${buffer.toString()}.${parts[1]}';
  }

  String _dueLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    final difference = due.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 0) return 'Overdue';

    return 'Due On ${_formatShortDate(date)}';
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF666666),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 14),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: teal, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Color(0xFF888888),
        size: 21,
      ),
      style: const TextStyle(color: Color(0xFF555555), fontSize: 13),
      decoration: _fieldDecoration(hint: ''),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(9),
      child: InputDecorator(
        decoration: _fieldDecoration(
          hint: '',
          suffixIcon: const Icon(
            Icons.calendar_month,
            color: Color(0xFF888888),
            size: 19,
          ),
        ),
        child: Text(
          _formatDate(_selectedDate),
          style: const TextStyle(color: Color(0xFF555555), fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSavedCredit(CreditModel credit) {
    final dueLabel = _dueLabel(credit.dueDate);
    final dueIsUrgent = dueLabel == 'Today' || dueLabel == 'Overdue';

    return InkWell(
      onTap: () => _startEditing(credit),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    credit.recipient,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: dueIsUrgent ? 'Due ' : 'Due On '),
                        TextSpan(
                          text: dueIsUrgent
                              ? dueLabel
                              : _formatShortDate(credit.dueDate),
                          style: TextStyle(
                            color: dueIsUrgent ? Colors.redAccent : mutedColor,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(color: mutedColor, fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    credit.creditType,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  credit.planType,
                  style: const TextStyle(color: mutedColor, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatAmount(credit.amount),
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    icon: const Icon(Icons.more_horiz, color: mutedColor),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _startEditing(credit);
                      } else if (value == 'delete') {
                        _deleteCredit(credit);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: teal)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              TextButton(onPressed: _loadCredits, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_credits.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFFBBBBBB),
                size: 36,
              ),
              SizedBox(height: 8),
              Text(
                'No saved lists yet',
                style: TextStyle(color: mutedColor, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Add your first credit using the form above.',
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: _credits.map(_buildSavedCredit).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Compact header. The existing bottom navigation remains external.

          Container(
            width: double.infinity,
            height: 120,
            color: teal,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Text(
                      'Credit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      tooltip: 'Back to Dashboard',
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.maybePop(context);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: teal,
              onRefresh: _loadCredits,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 125),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Credit Type'),
                      _buildDropdown(
                        value: _selectedCreditType,
                        items: _creditTypes,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCreditType = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 13),

                      _sectionLabel('To'),
                      TextFormField(
                        controller: _recipientController,
                        style: const TextStyle(fontSize: 13, color: textColor),
                        decoration: _fieldDecoration(hint: 'Enter recipient'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a recipient';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 13),

                      _sectionLabel('Amount'),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(fontSize: 13, color: textColor),
                        decoration: _fieldDecoration(hint: 'Enter amount'),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');

                          if (amount == null ||
                              !amount.isFinite ||
                              amount <= 0) {
                            return 'Enter an amount greater than zero';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 13),

                      _sectionLabel('Date'),
                      _buildDateField(),

                      const SizedBox(height: 13),

                      _sectionLabel('Plan Type'),
                      _buildDropdown(
                        value: _selectedPlan,
                        items: const ['Monthly', 'One-Time'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPlan = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveCredit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: teal.withOpacity(0.6),
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 21,
                                  width: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _editingId == null ? 'Save' : 'Update',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      if (_editingId != null)
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: _clearForm,
                            child: const Text(
                              'Cancel editing',
                              style: TextStyle(color: teal),
                            ),
                          ),
                        ),

                      const SizedBox(height: 19),

                      const Text(
                        'Your Saved Lists',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      _buildSavedList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
