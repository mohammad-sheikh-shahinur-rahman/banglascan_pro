import 'dart:convert';
import 'package:flutter/services.dart';

class DictionaryService {
  Map<String, String> _dictionary = {};

  Future<void> loadDictionary() async {
    try {
      final String response = await rootBundle.loadString('assets/dictionary/bn_dictionary.json');
      final dynamic data = json.decode(response);
      
      _dictionary.clear();
      
      if (data is List) {
        for (var item in data) {
          if (item is Map && item.containsKey('word') && item.containsKey('definition')) {
            _dictionary[item['word'].toString()] = item['definition'].toString();
          }
        }
      } else if (data is Map) {
        data.forEach((key, value) {
          _dictionary[key.toString()] = value.toString();
        });
      }
    } catch (e) {
      print("Dictionary load error: $e");
    }
  }

  String? getDefinition(String word) {
    // Basic normalization: trim and lowercase if applicable, 
    // though Bangla doesn't have cases.
    return _dictionary[word.trim()];
  }
}
