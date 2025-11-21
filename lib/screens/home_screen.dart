import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/category.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('簿記アプリ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/stats'),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('まだ取引はありません'));
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final category = transaction.category.value;
              final isExpense = category?.type == CategoryType.expense;
              final color = isExpense ? Colors.red : Colors.green;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: category != null
                      ? Color(category.color)
                      : Colors.grey,
                  child: Text(category?.icon ?? '?'),
                ),
                title: Text(category?.name ?? '未分類'),
                subtitle: Text(
                  DateFormat.yMMMEd('ja').format(transaction.date),
                ),
                trailing: Text(
                  '${isExpense ? '-' : '+'}${NumberFormat.simpleCurrency(locale: 'ja').format(transaction.amount)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                onLongPress: () {
                  // TODO: Show delete confirmation
                  ref
                      .read(transactionListProvider.notifier)
                      .deleteTransaction(transaction.id);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
