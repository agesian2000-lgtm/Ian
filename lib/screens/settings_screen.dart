import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Budget'),
            Tab(text: 'Categories'),
            Tab(text: 'Sources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _BudgetSettingsTab(),
          const _CategorySettingsTab(),
          const _SourceSettingsTab(),
        ],
      ),
    );
  }
}

class _BudgetSettingsTab extends StatefulWidget {
  const _BudgetSettingsTab();

  @override
  State<_BudgetSettingsTab> createState() => _BudgetSettingsTabState();
}

class _BudgetSettingsTabState extends State<_BudgetSettingsTab> {
  late TextEditingController _dailyController;
  late TextEditingController _weeklyController;
  late TextEditingController _monthlyController;
  bool _showSavedMessage = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _dailyController =
        TextEditingController(text: appState.budgets.daily.toString());
    _weeklyController =
        TextEditingController(text: appState.budgets.weekly.toString());
    _monthlyController =
        TextEditingController(text: appState.budgets.monthly.toString());
  }

  @override
  void dispose() {
    _dailyController.dispose();
    _weeklyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _saveBudgets(AppState appState) {
    final daily = double.tryParse(_dailyController.text);
    final weekly = double.tryParse(_weeklyController.text);
    final monthly = double.tryParse(_monthlyController.text);

    if (daily == null || weekly == null || monthly == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    appState.updateBudgets(daily, weekly, monthly);

    setState(() {
      _showSavedMessage = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSavedMessage = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Budget Limits',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _dailyController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Daily Limit',
                        prefixText: '₱ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _weeklyController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Weekly Limit',
                        prefixText: '₱ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _monthlyController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Monthly Limit',
                        prefixText: '₱ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _saveBudgets(appState),
              child: Text(_showSavedMessage ? '✓ Saved!' : 'Save Budgets'),
            ),
          ],
        );
      },
    );
  }
}

class _CategorySettingsTab extends StatefulWidget {
  const _CategorySettingsTab();

  @override
  State<_CategorySettingsTab> createState() => _CategorySettingsTabState();
}

class _CategorySettingsTabState extends State<_CategorySettingsTab> {
  late TextEditingController _newCategoryController;

  @override
  void initState() {
    super.initState();
    _newCategoryController = TextEditingController();
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _addCategory(AppState appState) {
    final category = _newCategoryController.text.trim();
    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    appState.addExpenseType(category);
    _newCategoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Expense Types',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: appState.expenseTypes
                      .map((category) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(category),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    appState.removeExpenseType(category);
                                  },
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add New Category',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newCategoryController,
              decoration: const InputDecoration(
                labelText: 'Category name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _addCategory(appState),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        );
      },
    );
  }
}

class _SourceSettingsTab extends StatefulWidget {
  const _SourceSettingsTab();

  @override
  State<_SourceSettingsTab> createState() => _SourceSettingsTabState();
}

class _SourceSettingsTabState extends State<_SourceSettingsTab> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _addSource(AppState appState) {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text);

    if (name.isEmpty || _selectedType == null || balance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final source = MoneySource(
      name: name,
      type: _selectedType!,
      balance: balance,
    );

    appState.addMoneySource(source);
    _nameController.clear();
    _balanceController.clear();
    setState(() => _selectedType = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Money source added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Money Sources',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: appState.moneySources
                      .map((source) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        source.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(
                                        source.type,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        '₱${source.balance.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: source.balance < 0
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .error
                                                  : Colors.green,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    appState.removeMoneySource(source.id);
                                  },
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add New Source',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Card/Account name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              hint: const Text('Select type'),
              items: SourceType.values
                  .map((type) => DropdownMenuItem(
                        value: type.displayName,
                        child: Text(type.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
                prefixText: '₱ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _addSource(appState),
              icon: const Icon(Icons.add),
              label: const Text('Add Source'),
            ),
          ],
        );
      },
    );
  }
}
