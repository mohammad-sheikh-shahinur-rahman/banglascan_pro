
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class TranslationService {
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  
  /// Identifies the language of the source text
  Future<String> identifyLanguage(String text) async {
    try {
      final String languageCode = await _languageIdentifier.identifyLanguage(text);
      return languageCode;
    } catch (e) {
      return "und"; // Undetermined
    }
  }

  /// Translates text between English and Bengali
  Future<String> translateText(String text, bool toBengali) async {
    final sourceLanguage = toBengali ? TranslateLanguage.english : TranslateLanguage.bengali;
    final targetLanguage = toBengali ? TranslateLanguage.bengali : TranslateLanguage.english;

    final OnDeviceTranslator translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    try {
      final String translation = await translator.translateText(text);
      await translator.close();
      return translation;
    } catch (e) {
      await translator.close();
      return "Translation Error: Ensure language models are downloaded.";
    }
  }

  void dispose() {
    _languageIdentifier.close();
  }
}
