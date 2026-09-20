import 'package:flutter/services.dart';

class ImportedStudyFile {
  const ImportedStudyFile({required this.name, required this.content});
  final String name;
  final String content;
}

class StudyFileImporter {
  static const _channel = MethodChannel('loopin/study_files');

  Future<ImportedStudyFile?> pickTextNote() async {
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'pickTextNote',
    );
    if (result == null) return null;
    final name = result['name'] as String?;
    final content = result['content'] as String?;
    if (name == null || content == null || content.trim().isEmpty) return null;
    return ImportedStudyFile(name: name, content: content);
  }
}
