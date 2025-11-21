import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/category.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('統計')),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('まだ取引はありません'));
          }

          // Calculate totals by category
          final categoryTotals = <String, double>{};
          final categoryColors = <String, int>{};
          final categoryIcons = <String, String>{};

          for (var transaction in transactions) {
            final category = transaction.category.value;
            if (category != null && category.type == CategoryType.expense) {
              categoryTotals[category.name] =
                  (categoryTotals[category.name] ?? 0) + transaction.amount;
              categoryColors[category.name] = category.color;
              categoryIcons[category.name] = category.icon;
            }
          }

          if (categoryTotals.isEmpty) {
            return const Center(child: Text('まだ費用はありません'));
          }

          final totalExpense = categoryTotals.values.reduce((a, b) => a + b);

          return Column(
            children: [
              const SizedBox(height: 24),
              Text(
                '合計費用: ${NumberFormat.simpleCurrency(locale: 'ja').format(totalExpense)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: categoryTotals.entries.map((entry) {
                      final percentage = (entry.value / totalExpense) * 100;
                      return PieChartSectionData(
                        color: Color(
                          categoryColors[entry.key] ?? Colors.grey.value,
                        ),
                        value: entry.value,
                        title:
                            '${percentage.toStringAsFixed(1)}%\n${categoryIcons[entry.key]}',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: categoryTotals.entries.map((entry) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(
                          categoryColors[entry.key] ?? Colors.grey.value,
                        ),
                        child: Text(categoryIcons[entry.key] ?? '?'),
                      ),
                      title: Text(entry.key),
                      trailing: Text(
                        NumberFormat.simpleCurrency(
                          locale: 'ja',
                        ).format(entry.value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
