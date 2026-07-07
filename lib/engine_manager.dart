// 引擎管理器 - 管理引擎切换和统一调用

import 'dart:typed_data';

import 'speech_engine.dart';
import 'sherpa_engine.dart';
import 'ios_native_engine.dart';

/// 引擎管理器
/// 提供统一的引擎切换和调用接口
class EngineManager {
  SpeechRecognitionEngine? _currentEngine;
  EngineType _currentEngineType = EngineType.sherpaOnnx;

  /// 当前引擎
  SpeechRecognitionEngine? get currentEngine => _currentEngine;

  /// 当前引擎类型
  EngineType get currentEngineType => _currentEngineType;

  /// 切换引擎
  Future<void> switchEngine(EngineType type) async {
    // 释放旧引擎
    if (_currentEngine != null) {
      _currentEngine!.dispose();
    }

    // 创建新引擎
    _currentEngineType = type;
    _currentEngine = EngineFactory.createEngine(type);

    // 初始化新引擎
    await _currentEngine!.initialize();
  }

  /// 初始化当前引擎
  Future<void> initialize() async {
    if (_currentEngine == null) {
      await switchEngine(_currentEngineType);
    }
    await _currentEngine!.initialize();
  }

  /// 设置语言
  void setLanguage(String langCode) {
    if (_currentEngine != null) {
      _currentEngine!.setLanguage(langCode);
    }
  }

  /// 开始识别会话
  Future<void> startSession() async {
    if (_currentEngine != null) {
      await _currentEngine!.startSession();
    }
  }

  /// 结束识别会话
  Future<void> endSession() async {
    if (_currentEngine != null) {
      await _currentEngine!.endSession();
    }
  }

  /// 处理音频（仅 Sherpa 引擎使用）
  Future<String> processAudio(Float32List samples) async {
    if (_currentEngine != null) {
      return await _currentEngine!.processAudio(samples);
    }
    return '';
  }

  /// 是否已初始化
  bool get isInitialized => _currentEngine?.isInitialized ?? false;

  /// 当前引擎名称
  String get engineName => _currentEngine?.name ?? 'None';

  /// 释放资源
  void dispose() {
    if (_currentEngine != null) {
      _currentEngine!.dispose();
      _currentEngine = null;
    }
  }
}