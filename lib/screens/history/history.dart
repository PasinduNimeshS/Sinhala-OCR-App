import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sin_ocr/screens/home/home.dart';

class HistoryPage extends StatelessWidget {
  final List<OcrItem> items;
  final Function(int, String, String) onEditItem; // Now accepts title + text

  const HistoryPage({super.key, required this.items, required this.onEditItem});

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Scan History (${items.length})',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Text(
                  "No history yet",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ),
            )
          else
            ...items.asMap().entries.map((entry) {
              int index = entry.key;
              OcrItem item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    onTap: () => _showFullItem(context, index, item),
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('MMM dd, yyyy – hh:mm a').format(item.date),
                        style: TextStyle(color: secondaryColor, fontSize: 13),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: secondaryColor,
                      size: 18,
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  void _showFullItem(BuildContext context, int index, OcrItem item) {
    final titleController = TextEditingController(text: item.title);
    final textController = TextEditingController(text: item.text);
    bool isEditing = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => Dialog.fullscreen(
                  child: Scaffold(
                    appBar: AppBar(
                      title:
                          isEditing
                              ? TextField(
                                controller: titleController,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              )
                              : Text(
                                titleController.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setDialogState(() => isEditing = !isEditing);
                            if (!isEditing) {
                              // Save when done editing
                              onEditItem(
                                index,
                                titleController.text.trim(),
                                textController.text.trim(),
                              );
                            }
                          },
                          child: Text(
                            isEditing ? "Done" : "Edit",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Expanded(
                            child:
                                isEditing
                                    ? TextField(
                                      controller: textController,
                                      maxLines: null,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.7,
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding: const EdgeInsets.all(
                                          16,
                                        ),
                                      ),
                                    )
                                    : SelectableText(
                                      item.text.isEmpty ? "No text" : item.text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.8,
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: textController.text),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Copied!")),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.share,
                                  color: primaryColor,
                                ),
                                onPressed:
                                    () => Share.share(textController.text),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }
}
