import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/category.dart';
import 'isar_provider.dart';

part 'category_provider.g.dart';

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() async {
    final isar = await ref.watch(isarProvider.future);
    return isar.categorys.where().findAll();
  }

  Future<void> addCategory(
    String name,
    String icon,
    int color,
    CategoryType type,
  ) async {
    final isar = await ref.read(isarProvider.future);
    final category = Category()
      ..name = name
      ..icon = icon
      ..color = color
      ..type = type;

    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(int id) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.categorys.delete(id);
    });
    ref.invalidateSelf();
  }
}
