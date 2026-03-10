
import 'dart:io';
import 'package:banglascan_pro/models/scan_model.dart';
import 'package:banglascan_pro/services/database_service.dart';
import 'package:banglascan_pro/services/dictionary_service.dart';
import 'package:banglascan_pro/services/ocr_service.dart';
import 'package:banglascan_pro/services/pdf_service.dart';
import 'package:banglascan_pro/services/tts_service.dart';
import 'package:banglascan_pro/widgets/tappable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final OcrService _ocrService = OcrService();
  final DatabaseService _dbService = DatabaseService();
  final PdfService _pdfService = PdfService();
  final TtsService _ttsService = TtsService();
  final DictionaryService _dictionaryService = DictionaryService();

  late TextEditingController _textController;
  bool _isLoading = true;
  bool _isEditing = false;
  Scan? _currentScan;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _initServices();
  }

  void _initServices() async {
    _ttsService.initTts();
    await _dictionaryService.loadDictionary();
    _processAndInitialSave();
  }

  @override
  void dispose() {
    _ttsService.stop();
    _textController.dispose();
    super.dispose();
  }

  void _processAndInitialSave() async {
    final ocrText = await _ocrService.getOcrText(widget.imagePath);

    _currentScan = Scan(
      imagePath: widget.imagePath,
      ocrText: ocrText,
      timestamp: DateTime.now(),
    );
    await _dbService.saveScan(_currentScan!);

    if (mounted) {
      setState(() {
        _textController.text = ocrText;
        _isLoading = false;
      });
    }
  }

  void _saveEdits() async {
    if (_currentScan != null) {
      await _dbService.updateScanText(_currentScan!, _textController.text);
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved to history'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _shareText() {
    Share.share(_textController.text);
    HapticFeedback.lightImpact();
  }

  void _toggleTts() {
    HapticFeedback.selectionClick();
    if (_ttsService.ttsState == TtsState.playing) {
      _ttsService.stop();
    } else {
      _ttsService.speak(_textController.text);
    }
    setState(() {});
  }

  void _showDefinition(String word) {
    HapticFeedback.selectionClick();
    final cleanWord = word.replaceAll(RegExp(r'[^\u0980-\u09FFa-zA-Z]'), '');
    final definition = _dictionaryService.getDefinition(cleanWord);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cleanWord, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.teal),
                    onPressed: () => _ttsService.speak(cleanWord),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(definition ?? 'No definition found for "$cleanWord".', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              if (definition == null)
                OutlinedButton.icon(
                  onPressed: () { /* Online search logic could go here */ },
                  icon: const Icon(Icons.search),
                  label: const Text('Search Online'),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('Scan Result'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle_rounded : Icons.edit_note_rounded),
            onPressed: () {
              setState(() {
                if (_isEditing) _saveEdits();
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: _isLoading ? null : () => _pdfService.generateAndPrintPdf(widget.imagePath, _textController.text),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _isLoading ? null : _shareText,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isEditing
                      ? TextField(
                          controller: _textController,
                          maxLines: null,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Edit Extracted Text',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Extracted Content:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 10),
                              TappableText(text: _textController.text, onWordTap: _showDefinition),
                            ],
                          ),
                        ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _toggleTts,
              backgroundColor: Colors.teal,
              icon: Icon(_ttsService.ttsState == TtsState.playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
              label: Text(_ttsService.ttsState == TtsState.playing ? 'Stop Reading' : 'Listen Text'),
            ),
    );
  }
}
