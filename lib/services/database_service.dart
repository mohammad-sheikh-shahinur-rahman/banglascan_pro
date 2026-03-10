
import 'package:banglascan_pro/models/scan_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  static const String _boxName = 'scans';

  Box<Scan> _getBox() {
    return Hive.box<Scan>(_boxName);
  }

  Future<void> saveScan(Scan scan) async {
    try {
      final box = _getBox();
      await box.add(scan);
    } catch (e) {
      debugPrint('DB_ERROR: $e');
    }
  }

  /// Professional Update Feature: Updates an existing scan's text
  Future<void> updateScanText(Scan scan, String newText) async {
    try {
      final updatedScan = Scan(
        imagePath: scan.imagePath,
        ocrText: newText,
        timestamp: scan.timestamp,
      );
      // Replace the old object with the new one at the same key
      await scan.delete(); // Remove old
      await _getBox().add(updatedScan); // Add updated (it will appear at the top in history)
    } catch (e) {
      debugPrint('DB_UPDATE_ERROR: $e');
    }
  }

  List<Scan> getAllScans() {
    return _getBox().values.toList().cast<Scan>().reversed.toList();
  }

  Future<void> deleteScan(dynamic key) async {
    await _getBox().delete(key);
  }

  ValueListenable<Box<Scan>> getScansListenable() {
    return _getBox().listenable();
  }

  Future<void> clearAllHistory() async {
    await _getBox().clear();
  }
}
