import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({Key? key}) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  String? _selectedMoneySource;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addExpense(AppState appState) {
    final amount = double.tryParse(_amountController.text);

    if (amount == null ||
        amount <= 0 ||
        _selectedCategory == null ||
        _selectedPaymentMethod == null ||
        _selectedMoneySource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final expense = Expense(
      date: DateTime.now(),
      amount: amount,
      category: _selectedCategory!,
      paymentMethod: _selectedPaymentMethod!,
      moneySource: _selectedMoneySource!,
      notes: _notesController.text,
    );

    appState.addExpense(expense);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Expense',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  // Amount
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₱ ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text('Select category'),
                    items: appState.expenseTypes
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment Method
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    hint: const Text('Select payment method'),
                    items: PaymentMethod.values
                        .map((method) => DropdownMenuItem(
                              value: method.displayName,
                              child: Text(method.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedPaymentMethod = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Money Source
                  DropdownButtonFormField<String>(
                    value: _selectedMoneySource,
                    hint: const Text('Select money source'),
                    items: appState.moneySources
                        .map((source) => DropdownMenuItem(
                              value: source.name,
                              child: Text(source.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedMoneySource = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Money Source',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add notes...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _addExpense(appState),
                        child: const Text('Add Expense'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
