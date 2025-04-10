import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/book_data.dart';

class FileService {
  static Future<BookData?> pickEpubFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      return BookData(
        filePath: filePath,
        title: fileName,
        lastRead: DateTime.now(),
      );
    }
    return null;
  }
}
