import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sin_ocr/screens/home/home.dart';

class SavedPage extends StatelessWidget {
  final List<OcrItem> items;
  final Function(int, String) onEditTitle;
  final Function(int) onDelete;

  const SavedPage({
    super.key,
    required this.items,
    required this.onEditTitle,
    required this.onDelete,
  });

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Saved Texts (${items.length})',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              items.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: () => _showFullItem(context, index),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  items[index].title,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: primaryColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(items[index].date),
                                  style: const TextStyle(
                                    color: secondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: secondaryColor,
                                ),
                                onPressed: () {
                                  onDelete(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Item removed from saved'),
                                    ),
                                  );
                                },
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: secondaryColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullItem(BuildContext context, int index) {
    final item = items[index];
    final titleController = TextEditingController(text: item.title);
    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                title: TextField(
                  controller: titleController,
                  style: GoogleFonts.poppins(),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  onChanged: (newTitle) {
                    onEditTitle(index, newTitle);
                  },
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: primaryColor),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          item.text,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: secondaryColor),
                          onPressed: () {
                            onDelete(index);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item removed from saved'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: primaryColor),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: item.text));
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
                            Share.share(item.text);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
