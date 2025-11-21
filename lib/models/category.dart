import 'package:isar/isar.dart';

part 'category.g.dart';

enum CategoryType { income, expense }

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late String icon; // Store as string (e.g., codePoint or asset path)

  late int color; // Store as int (ARGB)

  @Enumerated(EnumType.name)
  late CategoryType type;
}
