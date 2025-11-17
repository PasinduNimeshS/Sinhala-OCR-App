// lib/services/ocr_service.dart
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';

class OcrService {
  Future<String> extractText(String imagePath) async {
    try {
      // Configure OCR for English + Sinhala using Tesseract engine
      // - language: 'eng+sin' (requires eng.traineddata and sin.traineddata in assets/tessdata/)
      // - engine: Tesseract for reliable multi-language support (Apple Vision may not handle Sinhala well)
      // - options: Use raw Tesseract config keys for OEM (LSTM_ONLY) and PSM (SINGLE_BLOCK)
      final config = OCRConfig(
        language: 'eng+sin',
        engine: OCREngine.tesseract,
        options: {
          'tessedit_ocr_engine_mode': '1',  // LSTM_ONLY (neural net mode for better accuracy)
          'tessedit_pageseg_mode': '6',     // SINGLE_BLOCK (uniform text block; adjust to '3' for fully automatic if needed)
        },
      );

      final String text = await TesseractOcr.extractText(
        imagePath,
        config: config,
      );

      // Handle empty text case
      if (text.isEmpty) {
        return 'No text detected.';
      }

      return text;
    } catch (e) {
      // Improved error handling
      throw Exception('OCR processing failed. Error: ${e.toString()}');
    }
  }
}
