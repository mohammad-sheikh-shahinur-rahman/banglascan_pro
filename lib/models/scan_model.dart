
import 'package:hive/hive.dart';

part 'scan_model.g.dart';

@HiveType(typeId: 0)
class Scan extends HiveObject {
  @HiveField(0)
  final String imagePath;

  @HiveField(1)
  final String ocrText;

  @HiveField(2)
  final DateTime timestamp;

  Scan({
    required this.imagePath,
    required this.ocrText,
    required this.timestamp,
  });
}
