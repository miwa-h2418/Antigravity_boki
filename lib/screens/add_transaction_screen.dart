import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('カテゴリを選択してください')));
        return;
      }

      final amount = double.parse(_amountController.text);

      await ref
          .read(transactionListProvider.notifier)
          .addTransaction(
            amount,
            _selectedDate,
            _noteController.text.isEmpty ? null : _noteController.text,
            _selectedCategory!,
          );

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('トランザクションの追加')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '金額',
                prefixText: '¥',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '金額を入力してください';
                }
                if (double.tryParse(value) == null) {
                  return '有効な数字を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('日付'),
              subtitle: Text(DateFormat.yMMMEd('ja').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'カテゴリー',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return ListTile(
                    title: const Text('カテゴリーが見つかりませんでした'),
                    trailing: TextButton(
                      onPressed: () {
                        // Seed default categories if empty
                        _seedCategories(ref);
                      },
                      child: const Text('カテゴリーを追加'),
                    ),
                  );
                }
                return Wrap(
                  spacing: 8.0,
                  children: categories.map((category) {
                    return ChoiceChip(
                      label: Text(category.name),
                      avatar: Text(category.icon),
                      selected: _selectedCategory?.id == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                      backgroundColor: Color(category.color).withOpacity(0.2),
                      selectedColor: Color(category.color),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: '備考 (任意)'),
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: _saveTransaction, child: const Text('保存')),
          ],
        ),
      ),
    );
  }

  Future<void> _seedCategories(WidgetRef ref) async {
    final notifier = ref.read(categoryListProvider.notifier);
    await notifier.addCategory(
      '食費',
      '🍔',
      Colors.orange.value,
      CategoryType.expense,
    );
    await notifier.addCategory(
      '交通費',
      '🚃',
      Colors.blue.value,
      CategoryType.expense,
    );
    await notifier.addCategory(
      '給与',
      '💰',
      Colors.green.value,
      CategoryType.income,
    );
    await notifier.addCategory(
      '買い物',
      '🛍️',
      Colors.purple.value,
      CategoryType.expense,
    );
  }
}
