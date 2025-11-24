import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sin_ocr/services/auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sin_ocr/services/ocr_services.dart';
import 'package:sin_ocr/screens/history/history.dart';
import 'package:sin_ocr/screens/saved/saved.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OcrItem {
  String title;
  String text;
  final DateTime date;

  OcrItem({required this.title, required this.text, required this.date});

  Map<String, dynamic> toJson() => {
    'title': title,
    'text': text,
    'date': date.toIso8601String(),
  };

  factory OcrItem.fromJson(Map<String, dynamic> json) => OcrItem(
    title: json['title'] as String,
    text: json['text'] as String,
    date: DateTime.parse(json['date'] as String),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthServices _auth = AuthServices();
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();

  // Default placeholder text - never changes until OCR result
  static const String _defaultPlaceholder =
      "Extracted text will appear here...";
  String extractedText = _defaultPlaceholder;
  bool isEditingText = false;
  final TextEditingController _textController = TextEditingController();

  int _selectedIndex = 0;
  File? _selectedImage;
  bool _isLoading = false;

  String? _selectedOcrType; // null, "printed", or "handwritten"

  List<OcrItem> _history = [];
  List<OcrItem> _saved = [];

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF333333);

  final List<String> appBarTitles = ['Sinhala OCR', 'History', 'Saved'];

  @override
  void initState() {
    super.initState();
    _textController.text = extractedText;
    _loadData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('ocr_history');
    final savedJson = prefs.getString('ocr_saved');

    List<OcrItem> loadedHistory = [];
    List<OcrItem> loadedSaved = [];

    if (historyJson != null) {
      final List<dynamic> list = jsonDecode(historyJson);
      loadedHistory = list.map((e) => OcrItem.fromJson(e)).toList();
      final now = DateTime.now();
      loadedHistory.removeWhere(
        (item) => now.difference(item.date).inHours >= 24,
      );
    }

    if (savedJson != null) {
      final List<dynamic> list = jsonDecode(savedJson);
      loadedSaved = list.map((e) => OcrItem.fromJson(e)).toList();
    }

    if (mounted) {
      setState(() {
        _history = loadedHistory;
        _saved = loadedSaved;
      });
      await _saveData();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'ocr_history',
      jsonEncode(_history.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'ocr_saved',
      jsonEncode(_saved.map((e) => e.toJson()).toList()),
    );
  }

  // RESET FUNCTION - Clears everything
  void _resetAll() {
    setState(() {
      _selectedImage = null;
      _selectedOcrType = null;
      extractedText = _defaultPlaceholder;
      _textController.text = extractedText;
      isEditingText = false;
      _isLoading = false;
    });
  }

  Future<void> _pickAndCropImage({bool fromCamera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 95,
      );

      if (pickedFile == null) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: primaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile != null && mounted) {
        setState(() {
          _selectedImage = File(croppedFile.path);
          _selectedOcrType = null;
          // Do NOT change extractedText here — stays as placeholder
          isEditingText = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _extractText() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }
    if (_selectedOcrType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select document type first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ScanningDialog(),
    );
    setState(() => _isLoading = true);

    try {
      String result;
      if (_selectedOcrType == 'printed') {
        result = await _ocrService.extractText(_selectedImage!.path);
      } else {
        result = await _predictWithSinOcr(_selectedImage!);
      }

      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        _isLoading = false;
        extractedText = result.isEmpty ? 'No text detected.' : result;
        _textController.text = extractedText;
        isEditingText = false;
      });

      final modeName =
          _selectedOcrType == 'printed' ? 'Printed' : 'Handwritten';
      _history.insert(
        0,
        OcrItem(
          title: 'Scan #${_history.length + 1} ($modeName)',
          text: extractedText,
          date: DateTime.now(),
        ),
      );

      await _saveData();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      setState(() {
        _isLoading = false;
        extractedText = "Error: $e";
        _textController.text = extractedText;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OCR Failed: $e')));
    }
  }

  Future<String> _predictWithSinOcr(File imageFile) async {
    const String baseUrl =
        'https://my-fastapi-app-584089990948.us-central1.run.app';
    final uri = Uri.parse('$baseUrl/predict');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send().timeout(const Duration(seconds: 45));
    final resp = await http.Response.fromStream(response);

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      return (json['predicted_sentence'] as String?)?.trim() ??
          'No text returned.';
    } else {
      throw Exception('API Error ${resp.statusCode}');
    }
  }

  void _saveExtractedText() async {
    final titleCtrl = TextEditingController(text: "Saved Scan");
    final textCtrl = TextEditingController(text: extractedText);

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Save Text"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textCtrl,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: "Text (editable)",
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: primaryColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () {
                  extractedText = textCtrl.text;
                  Navigator.pop(context, titleCtrl.text.trim());
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _saved.insert(
          0,
          OcrItem(title: result, text: extractedText, date: DateTime.now()),
        );
      });
      await _saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Saved successfully!"),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  Future<void> _signOut() async => await _auth.signOut();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: textColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            appBarTitles[_selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeBody(),
            HistoryPage(
              items: _history,
              onEditItem: (index, newTitle, newText) {
                setState(() {
                  _history[index].title = newTitle;
                  _history[index].text = newText;
                });
                _saveData();
              },
            ),
            SavedPage(
              items: _saved,
              onEditItem: (index, newTitle, newText) {
                setState(() {
                  _saved[index].title = newTitle;
                  _saved[index].text = newText;
                });
                _saveData();
              },
              onDelete: (index) {
                setState(() => _saved.removeAt(index));
                _saveData();
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upload & Scan Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: const Text(
                    'Upload Image',
                    style: TextStyle(fontSize: 14),
                  ),
                  onPressed: () => _pickAndCropImage(fromCamera: false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: const Text(
                    'Scan Image',
                    style: TextStyle(fontSize: 14),
                  ),
                  onPressed: () => _pickAndCropImage(fromCamera: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Image Preview
          if (_selectedImage != null)
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _selectedImage!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _resetAll,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Document Type Dropdown — Only when image selected
          if (_selectedImage != null) ...[
            const SizedBox(height: 20),
            const Text(
              "Select Document Type",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOcrType,
                    hint: const Text(
                      "Choose type...",
                      style: TextStyle(color: Colors.grey),
                    ),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: primaryColor,
                    ),
                    style: const TextStyle(color: textColor, fontSize: 16),
                    items: const [
                      DropdownMenuItem(
                        value: "printed",
                        child: Text("Printed Text"),
                      ),
                      DropdownMenuItem(
                        value: "handwritten",
                        child: Text("Handwritten Text"),
                      ),
                    ],
                    onChanged:
                        (value) => setState(() => _selectedOcrType = value),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Extract Button
          ElevatedButton.icon(
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                    : const Icon(Icons.text_fields, size: 28),
            label: Text(
              _isLoading ? 'Extracting...' : 'Extract Text',
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selectedOcrType == null
                      ? Colors.grey.shade400
                      : primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onPressed:
                _selectedOcrType == null || _isLoading ? null : _extractText,
          ),

          if (_selectedImage != null && _selectedOcrType == null)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "Please select document type above",
                style: TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 32),

          // Extracted Text Card
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Extracted Text',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 0,
                        children: [
                          if (extractedText != _defaultPlaceholder &&
                              !extractedText.startsWith("Error:") &&
                              !isEditingText)
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                // color: primaryColor,
                                size: 20,
                              ),
                              onPressed:
                                  () => setState(() => isEditingText = true),
                            ),
                          if (isEditingText)
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              onPressed:
                                  () => setState(() {
                                    extractedText = _textController.text.trim();
                                    isEditingText = false;
                                  }),
                            ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: extractedText),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Copied!")),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share, size: 20),
                            onPressed: () => Share.share(extractedText),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.bookmark_add,
                              // color: primaryColor,
                              size: 20,
                            ),
                            onPressed: _saveExtractedText,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Divider(),
                  const SizedBox(height: 10),
                  isEditingText
                      ? TextField(
                        controller: _textController,
                        maxLines: null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          hintText: "Edit text here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      )
                      : SelectableText(
                        extractedText,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color:
                              extractedText == _defaultPlaceholder
                                  ? Colors.grey.shade600
                                  : textColor,
                        ),
                      ),
                  if (extractedText == _defaultPlaceholder)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Upload an image and extract text",
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // RESET BUTTON - Only show after OCR or image upload
          if (_selectedImage != null ||
              extractedText != _defaultPlaceholder) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, color: primaryColor),
              label: const Text(
                "Reset All",
                style: TextStyle(
                  fontSize: 16,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _resetAll,
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ScanningDialog extends StatelessWidget {
  const ScanningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/Scanner.json',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
                repeat: true,
              ),
              SizedBox(height: 30),
              Text(
                'Analyzing...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Please wait while we extract the text',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
            ],
          ),
        ),
      ),
    );
  }
}
