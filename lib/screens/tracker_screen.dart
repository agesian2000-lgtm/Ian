import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import 'add_expense_dialog.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final totals = appState.getTotals();
        final totalBalance = appState.getTotalBalance();
        final expenses = appState.getFilteredExpenses();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Expense Tracker'),
              floating: true,
              snap: true,
              expandedHeight: 340,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Frame Selector
                        SegmentedButton<TimeFrame>(
                          segments: const [
                            ButtonSegment(
                              value: TimeFrame.daily,
                              label: Text('Daily'),
                            ),
                            ButtonSegment(
                              value: TimeFrame.weekly,
                              label: Text('Weekly'),
                            ),
                            ButtonSegment(
                              value: TimeFrame.monthly,
                              label: Text('Monthly'),
                            ),
                          ],
                          selected: {appState.currentTimeFrame},
                          onSelectionChanged: (selected) {
                            appState.setTimeFrame(selected.first);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Budget Card
                        _BudgetCard(totals: totals),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Balances
                    _BalanceOverview(
                      totalBalance: totalBalance,
                      sources: appState.moneySources,
                    ),
                    const SizedBox(height: 24),

                    // Add Expense Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AddExpenseDialog(),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Expense'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Expenses List
                    Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.list,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No expenses recorded',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: expenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final expense =
                              expenses[expenses.length - 1 - index];
                          return _ExpenseCard(expense: expense);
                        },
                      ),
                    const SizedBox(height: 24),

                    // Savings Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Savings',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rolled over from monthly',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Text(
                              '₱${appState.savings.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final ({double spent, double budget, double remaining}) totals;

  const _BudgetCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    final percentage = (totals.spent / totals.budget).clamp(0.0, 1.0);
    final isOverBudget = totals.spent > totals.budget;
    final isWarning =
        totals.remaining < totals.budget * 0.2 && !isOverBudget;

    Color barColor;
    if (isOverBudget) {
      barColor = Theme.of(context).colorScheme.error;
    } else if (isWarning) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.green;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Limit',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '₱${totals.budget.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '₱${totals.spent.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '₱${totals.remaining.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
            if (isOverBudget)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Over budget by ₱${(totals.spent - totals.budget).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else if (isWarning)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Only ₱${totals.remaining.toStringAsFixed(2)} remaining',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BalanceOverview extends StatelessWidget {
  final double totalBalance;
  final List<MoneySource> sources;

  const _BalanceOverview({
    required this.totalBalance,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Balances',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Across All',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${totalBalance.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...sources.map((source) {
          final isNegative = source.balance < 0;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        source.type,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    '₱${source.balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isNegative
                              ? Theme.of(context).colorScheme.error
                              : Colors.green,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;

  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expense.category,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '-₱${expense.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(expense.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(expense.paymentMethod),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                Chip(
                  label: Text(expense.moneySource),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
            if (expense.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                expense.notes,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
