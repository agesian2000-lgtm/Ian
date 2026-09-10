import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  List<Expense> expenses = [];
  List<String> expenseTypes = [
    'Food',
    'Transportation',
    'Sports',
    'Utilities',
    'Bills',
    'Shopping',
  ];
  List<MoneySource> moneySources = [
    MoneySource(name: 'GCash', type: 'E-Wallet (GCash/PayMaya)', balance: 5000),
    MoneySource(name: 'BDO Debit', type: 'Debit Card', balance: 25000),
    MoneySource(name: 'BDO Credit', type: 'Credit Card', balance: 50000),
  ];
  Budget budgets = Budget();
  double savings = 45.00;
  TimeFrame currentTimeFrame = TimeFrame.daily;

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    loadData();
  }

  void addExpense(Expense expense) {
    expenses.add(expense);
    
    // Deduct from money source balance
    final sourceIndex = moneySources.indexWhere((s) => s.name == expense.moneySource);
    if (sourceIndex != -1) {
      moneySources[sourceIndex].balance -= expense.amount;
    }
    
    saveData();
    notifyListeners();
  }

  void addMoneySource(MoneySource source) {
    moneySources.add(source);
    saveData();
    notifyListeners();
  }

  void removeMoneySource(String id) {
    moneySources.removeWhere((s) => s.id == id);
    saveData();
    notifyListeners();
  }

  void updateMoneySourceBalance(String id, double newBalance) {
    final index = moneySources.indexWhere((s) => s.id == id);
    if (index != -1) {
      moneySources[index].balance = newBalance;
      saveData();
      notifyListeners();
    }
  }

  void addExpenseType(String type) {
    if (!expenseTypes.contains(type)) {
      expenseTypes.add(type);
      saveData();
      notifyListeners();
    }
  }

  void removeExpenseType(String type) {
    expenseTypes.removeWhere((t) => t == type);
    saveData();
    notifyListeners();
  }

  void updateBudgets(double daily, double weekly, double monthly) {
    budgets = Budget(daily: daily, weekly: weekly, monthly: monthly);
    saveData();
    notifyListeners();
  }

  List<Expense> getFilteredExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (currentTimeFrame) {
      case TimeFrame.daily:
        return expenses.where((e) {
          final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
          return expenseDate == today;
        }).toList();

      case TimeFrame.weekly:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        return expenses.where((e) => e.date.isAfter(weekStart) && e.date.isBefore(weekEnd)).toList();

      case TimeFrame.monthly:
        return expenses.where((e) {
          return e.date.year == now.year && e.date.month == now.month;
        }).toList();
    }
  }

  ({double spent, double budget, double remaining}) getTotals() {
  final filtered = getFilteredExpenses();
  final spent = filtered.fold(0.0, (sum, e) => sum + e.amount);
  
  final budget = switch (currentTimeFrame) {
    TimeFrame.daily => budgets.daily,
    TimeFrame.weekly => budgets.weekly,
    TimeFrame.monthly => budgets.monthly,
  };

  final remaining = (budget - spent).clamp(0.0, budget);
  return (spent: spent, budget: budget, remaining: remaining);
}

  double getTotalBalance() {
    return moneySources.fold(0.0, (sum, s) => sum + s.balance);
  }

  void setTimeFrame(TimeFrame frame) {
    currentTimeFrame = frame;
    notifyListeners();
  }

  void saveData() {
    // Save expenses
    final expensesJson = jsonEncode(expenses.map((e) => e.toMap()).toList());
    _prefs.setString('expenses', expensesJson);

    // Save money sources
    final sourcesJson = jsonEncode(moneySources.map((s) => s.toMap()).toList());
    _prefs.setString('moneySources', sourcesJson);

    // Save budgets
    _prefs.setString('budgets', budgets.toJson());

    // Save expense types
    _prefs.setStringList('expenseTypes', expenseTypes);

    // Save savings
    _prefs.setDouble('savings', savings);
  }

  void loadData() {
    // Load expenses
    final expensesJson = _prefs.getString('expenses');
    if (expensesJson != null) {
      final list = jsonDecode(expensesJson) as List;
      expenses = list.map((e) => Expense.fromMap(e as Map<String, dynamic>)).toList();
    }

    // Load money sources
    final sourcesJson = _prefs.getString('moneySources');
    if (sourcesJson != null) {
      final list = jsonDecode(sourcesJson) as List;
      moneySources = list.map((s) => MoneySource.fromMap(s as Map<String, dynamic>)).toList();
    }

    // Load budgets
    final budgetsJson = _prefs.getString('budgets');
    if (budgetsJson != null) {
      budgets = Budget.fromJson(budgetsJson);
    }

    // Load expense types
    final types = _prefs.getStringList('expenseTypes');
    if (types != null) {
      expenseTypes = types;
    }

    // Load savings
    savings = _prefs.getDouble('savings') ?? 45.00;

    notifyListeners();
  }
}
