
import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  HiveDatabase._();

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box> openBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return Hive.openBox(boxName);
  }
}
