
import 'dart:io';
import 'package:banglascan_pro/models/scan_model.dart';
import 'package:banglascan_pro/services/database_service.dart';
import 'package:banglascan_pro/services/dictionary_service.dart';
import 'package:banglascan_pro/services/pdf_service.dart';
import 'package:banglascan_pro/services/tts_service.dart';
import 'package:banglascan_pro/widgets/tappable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryDetailScreen extends StatefulWidget {
  final Scan scan;

  const HistoryDetailScreen({Key? key, required this.scan}) : super(key: key);

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final PdfService _pdfService = PdfService();
  final TtsService _ttsService = TtsService();
  final DictionaryService _dictionaryService = DictionaryService();
  final DatabaseService _dbService = DatabaseService();

  late TextEditingController _textController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.scan.ocrText);
    _initServices();
  }

  void _initServices() async {
    _ttsService.initTts();
    await _dictionaryService.loadDictionary();
  }

  @override
  void dispose() {
    _ttsService.stop();
    _textController.dispose();
    super.dispose();
  }

  void _saveEdits() async {
    if (_textController.text != widget.scan.ocrText) {
      await _dbService.updateScanText(widget.scan, _textController.text);
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved'), behavior: SnackBarBehavior.floating),
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

  void _searchOnline(String word) async {
    final Uri url = Uri.parse('https://www.google.com/search?q=$word+meaning');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  void _showDefinition(String word) {
    HapticFeedback.selectionClick();
    final cleanWord = word.replaceAll(RegExp(r'[^\u0980-\u09FFa-zA-Z]'), '');
    final definition = _dictionaryService.getDefinition(cleanWord);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cleanWord, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.teal, size: 30),
                      onPressed: () => _ttsService.speak(cleanWord),
                    ),
                  ],
                ),
                const Divider(thickness: 1.5),
                const SizedBox(height: 15),
                Text(
                  definition ?? 'No local definition found for "$cleanWord".',
                  style: const TextStyle(fontSize: 18, height: 1.4),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _searchOnline(cleanWord),
                    icon: const Icon(Icons.public_rounded),
                    label: const Text('Search Online Meaning'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM, yyyy • hh:mm a').format(widget.scan.timestamp);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('Scan Details'),
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
            icon: const Icon(Icons.print_rounded),
            onPressed: () => _pdfService.generateAndPrintPdf(widget.scan.imagePath, _textController.text),
          ),
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: _shareText),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Hero(tag: widget.scan.imagePath, child: Image.file(File(widget.scan.imagePath), fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(dateStr, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _isEditing
                ? TextField(
                    controller: _textController,
                    maxLines: null,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Edit Scan Content',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXTRACTED TEXT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        TappableText(text: _textController.text, onWordTap: _showDefinition),
                      ],
                    ),
                  ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleTts,
        backgroundColor: Colors.teal,
        icon: Icon(_ttsService.ttsState == TtsState.playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
        label: Text(_ttsService.ttsState == TtsState.playing ? 'Stop Reading' : 'Listen Text'),
      ),
    );
  }
}
