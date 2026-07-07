// 语音识别引擎抽象接口
// 支持切换不同引擎（Sherpa-ONNX、iOS原生等）

import 'dart:typed_data';

import 'sherpa_engine.dart';
import 'ios_native_engine.dart';

/// 语音识别引擎抽象接口
abstract class SpeechRecognitionEngine {
  /// 引擎名称
  String get name;

  /// 初始化引擎
  Future<void> initialize();

  /// 是否已初始化
  bool get isInitialized;

  /// 处理音频数据
  /// 返回识别文本，如果匹配到热词则返回热词指令
  Future<String> processAudio(Float32List samples);

  /// 开始识别会话
  Future<void> startSession();

  /// 结束识别会话
  Future<void> endSession();

  /// 设置当前语言
  void setLanguage(String langCode);

  /// 获取当前语言
  String get currentLanguage;

  /// 释放资源
  void dispose();
}

/// 引擎类型枚举
enum EngineType {
  sherpaOnnx,   // Sherpa-ONNX SenseVoice 模型
  iosNative,    // iOS 原生 Speech Framework
}

/// 引擎工厂 - 创建对应引擎实例
class EngineFactory {
  static SpeechRecognitionEngine createEngine(EngineType type) {
    switch (type) {
      case EngineType.sherpaOnnx:
        return SherpaEngine();
      case EngineType.iosNative:
        return IOSNativeEngine();
    }
  }
}