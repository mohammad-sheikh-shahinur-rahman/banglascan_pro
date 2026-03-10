import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class OcrService {
  // Enterprise-grade Text Recognizer. 
  // We use the default constructor because we have already linked the 
  // Bengali (Devanagari) native model in the android build configuration.
  // This allows ML Kit to automatically detect and use the appropriate model.
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extracts and cleans text from image using Google ML Kit with professional formatting.
  Future<String> getOcrText(String imagePath) async {
    try {
      // Create input image from file path
      final inputImage = InputImage.fromFile(File(imagePath));
      
      // Recognition logic
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Log detected block count for performance monitoring
      debugPrint("OCR_LOG: Recognized Blocks -> ${recognizedText.blocks.length}");

      if (recognizedText.text.trim().isEmpty) {
        return "No text detected.\n\nProfessional Advice:\n• Keep the text horizontal and steady\n• Ensure the photo is clear and well-lit\n• Focus strictly on the printed text area";
      }

      // Professional Cleanup: Remove excessive blank lines and ML artifacts
      String cleanedText = recognizedText.text.trim().replaceAll(RegExp(r'\n\s*\n'), '\n');

      return cleanedText;
    } catch (e) {
      debugPrint("OCR_CRITICAL_ERROR: $e");
      return "Extraction failed. Please check your internet connection for first-time model download.";
    }
  }

  /// Proper resource management to avoid memory leaks
  void dispose() {
    _textRecognizer.close();
  }
}
