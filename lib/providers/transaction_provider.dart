import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import 'isar_provider.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final isar = await ref.watch(isarProvider.future);
    return isar.transactions.where().sortByDateDesc().findAll();
  }

  Future<void> addTransaction(
    double amount,
    DateTime date,
    String? note,
    Category category,
  ) async {
    final isar = await ref.read(isarProvider.future);
    final transaction = Transaction()
      ..amount = amount
      ..date = date
      ..note = note;

    transaction.category.value = category;

    await isar.writeTxn(() async {
      await isar.transactions.put(transaction);
      await transaction.category.save();
    });
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(int id) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.transactions.delete(id);
    });
    ref.invalidateSelf();
  }
}
