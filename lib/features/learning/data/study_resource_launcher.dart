import 'package:flutter/services.dart';

class StudyResourceLauncher {
  static const _channel = MethodChannel('loopin/study_files');

  Future<void> open(String url) =>
      _channel.invokeMethod<void>('openUrl', <String, Object>{'url': url});
}
