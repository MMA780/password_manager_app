import 'package:hive_flutter/hive_flutter.dart';

part 'password_model.g.dart';

@HiveType(typeId: 0)
class PasswordEntry extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String username;

  @HiveField(2)
  late String password;

  @HiveField(3)
  late String category;

  PasswordEntry({
    required this.title,
    required this.username,
    required this.password,
    this.category = "عمومی", // پیش‌فرض فارسی
  });
}
