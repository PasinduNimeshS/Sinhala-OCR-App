import 'package:flutter/material.dart';
import 'package:sin_ocr/services/auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sin_ocr/services/ocr_services.dart'; // Add this import for Tesseract OCR
import 'package:sin_ocr/screens/history/history.dart';
import 'package:sin_ocr/screens/saved/saved.dart';

class OcrItem {
  String title;
  final String text;
  final DateTime date;

  OcrItem({required this.title, required this.text, required this.date});
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthServices _auth = AuthServices();
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService(); // Initialize OCR service
  String extractedText = "Extracted text will appear here...";
  int _selectedIndex = 0;
  File? _selectedImage;
  bool _isLoading = false;

  List<OcrItem> _history = [];
  List<OcrItem> _saved = [];

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color secondaryColor = Color(0xFF757575);

  final List<String> appBarTitles = ['Sinhala OCR', 'History', 'Saved'];

  @override
  void initState() {
    super.initState();
    // Initialize sample data (unchanged)
    final now = DateTime.now();
    _history = [
      // OcrItem(
      //   title: 'Scan #1',
      //   text:
      //       "Sample history text 1 from scan.\n\nThis is extracted Sinhala text.",
      //   date: now.subtract(const Duration(days: 6)),
      // ),
      // OcrItem(
      //   title: 'Scan #2',
      //   text:
      //       "Sample history text 2 from scan.\n\nAnother example of OCR output.",
      //   date: now.subtract(const Duration(days: 2)),
      // ),
      // OcrItem(
      //   title: 'Scan #3',
      //   text: "Sample history text 3 from scan.\n\nFinal history item.",
      //   date: now.subtract(const Duration(days: 0)),
      // ),
    ];
    _saved = [
      // OcrItem(
      //   title: 'Saved #1',
      //   text: "Saved text 1.\n\nImportant Sinhala OCR result to keep.",
      //   date: now.subtract(const Duration(days: 4)),
      // ),
      // OcrItem(
      //   title: 'Saved #2',
      //   text: "Saved text 2.\n\nAnother saved extraction.",
      //   date: now.subtract(const Duration(days: 1)),
      // ),
    ];
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          extractedText = "Image selected. Tap 'Extract Text' to process.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _extractText() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      extractedText = "Processing image...";
    });

    try {
      // Use Tesseract OCR for text extraction (works for both gallery and camera)
      final extracted = await _ocrService.extractText(_selectedImage!.path);

      setState(() {
        _isLoading = false;
        extractedText = extracted;
        // Add to history
        final now = DateTime.now();
        _history.insert(
          0,
          OcrItem(
            title: 'Scan #${_history.length + 1}',
            text: extracted,
            date: now,
          ),
        );
        _selectedImage = null; // Clear image after processing
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        extractedText = "Error processing image: $e";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OCR Error: $e')));
    }
  }

  void _saveExtractedText() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: 'Saved Item');
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Save Text',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: 'Enter title',
                        labelStyle: GoogleFonts.poppins(color: secondaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        errorText:
                            controller.text.isEmpty
                                ? 'Title is required'
                                : null,
                      ),
                      onChanged: (value) {
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: secondaryColor,
                            ),
                            child: Text('Cancel', style: GoogleFonts.poppins()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.text.isNotEmpty &&
                                  extractedText !=
                                      "Extracted text will appear here...") {
                                Navigator.pop(context, controller.text);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Save', style: GoogleFonts.poppins()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    // Handle save logic AFTER dialog closes
    if (result != null &&
        result.isNotEmpty &&
        extractedText != "Extracted text will appear here...") {
      setState(() {
        _saved.insert(
          0,
          OcrItem(title: result, text: extractedText, date: DateTime.now()),
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved successfully')));
      }
    }
  }

  void _updateItemTitle({
    required bool isHistory,
    required int index,
    required String newTitle,
  }) {
    setState(() {
      if (isHistory) {
        _history[index].title = newTitle;
      } else {
        _saved[index].title = newTitle;
      }
    });
  }

  void _deleteSavedItem(int index) {
    setState(() {
      _saved.removeAt(index);
    });
  }

  Future<void> _signOut() async {
    try {
      final success = await _auth.signOut();
      // The Wrapper widget will automatically handle navigation to login screen
      // when the user becomes null due to the StreamProvider
      if (mounted && context.mounted) {
        try {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signed out successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign out failed. Please try again.')),
            );
          }
        } catch (scaffoldError) {
          print('ScaffoldMessenger error: $scaffoldError');
          // Don't show error to user if ScaffoldMessenger fails
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign out failed: $e')),
          );
        } catch (scaffoldError) {
          print('ScaffoldMessenger error: $scaffoldError');
          // Don't show error to user if ScaffoldMessenger fails
        }
      }
    }
  }

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
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 2,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: primaryColor),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryColor,
          unselectedItemColor: secondaryColor,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitles[_selectedIndex]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut, // Use the new method
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeBody(),
            HistoryPage(
              items: _history,
              onEditTitle:
                  (index, newTitle) => _updateItemTitle(
                    isHistory: true,
                    index: index,
                    newTitle: newTitle,
                  ),
            ),
            SavedPage(
              items: _saved,
              onEditTitle:
                  (index, newTitle) => _updateItemTitle(
                    isHistory: false,
                    index: index,
                    newTitle: newTitle,
                  ),
              onDelete: _deleteSavedItem,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.upload_file,
                    label: 'Upload Image',
                    onPressed: _pickImage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Scan Image',
                    onPressed: () => _pickImage(fromCamera: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_selectedImage != null) _buildImagePreview(),
            const SizedBox(height: 16),
            _buildExtractButton(),
            const SizedBox(height: 24),
            _buildExtractedTextCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              height: 220,
              width: double.infinity,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    extractedText = "Extracted text will appear here...";
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractButton() {
    return ElevatedButton.icon(
      icon:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Icon(Icons.text_fields),
      label: Text(_isLoading ? 'Processing...' : 'Extract Text'),
      onPressed: _isLoading ? null : _extractText,
    );
  }

  Widget _buildExtractedTextCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  // Wrap title in Flexible to prevent overflow
                  child: Text(
                    'Extracted Text',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: primaryColor),
                    overflow: TextOverflow.ellipsis, // Handle long titles
                  ),
                ),
                // const SizedBox(width: 5), // Small gap
                Flexible(
                  // Wrap icons Row in Flexible for better wrapping
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Minimize row size
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, color: primaryColor),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: extractedText));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Text copied to clipboard'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: primaryColor),
                        onPressed: () {
                          Share.share(extractedText);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.bookmark_add,
                          color: primaryColor,
                        ),
                        onPressed: _saveExtractedText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: secondaryColor),
            const SizedBox(height: 12),
            Text(extractedText, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
