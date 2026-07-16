import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  FileStorageService._();

  static final FileStorageService instance = FileStorageService._();

  /// Kullanıcının seçtiği sözleşme dosyasını uygulama klasörüne kopyalar ve
  /// kalıcı yolunu döner.
  Future<String?> pickAndStoreContract() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );
    } on MissingPluginException catch (e) {
      throw StateError(
        'Dosya seçici henüz hazır değil. Uygulamayı tamamen kapatıp tekrar açın. ($e)',
      );
    } on PlatformException catch (e) {
      throw StateError(
        'Dosya seçici kullanılamadı: ${e.message ?? e.code}',
      );
    }
    final pickedPath = result?.files.single.path;
    if (pickedPath == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final contractsDirectory = Directory('${directory.path}/contracts');
    if (!await contractsDirectory.exists()) {
      await contractsDirectory.create(recursive: true);
    }

    final fileName = pickedPath.split(Platform.pathSeparator).last;
    final destination =
        '${contractsDirectory.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    return (await File(pickedPath).copy(destination)).path;
  }
}
