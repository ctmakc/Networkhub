import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:networkhub/core/error/app_exception.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Recognizes text from the given image file path
  Future<String> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final recognizedText = await _recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw OcrException(message: 'Failed to recognize text: $e');
    }
  }

  /// Returns structured text blocks with their positions
  Future<RecognizedText> recognizeTextDetailed(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      return await _recognizer.processImage(inputImage);
    } catch (e) {
      throw OcrException(message: 'Failed to recognize text: $e');
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
