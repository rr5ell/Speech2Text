// iOS 原生 Speech Framework 引擎实现
// 通过 MethodChannel 调用 iOS 原生语音识别

import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'speech_engine.dart';

/// iOS 原生 Speech Framework 引擎实现
class IOSNativeEngine implements SpeechRecognitionEngine {
  @override
  String get name => 'iOS Native Speech';

  static const MethodChannel _channel = MethodChannel('ios_speech_recognition');
  bool _initialized = false;
  String _langCode = 'zh-CN';
  bool _isListening = false;

  @override
  bool get isInitialized => _initialized;

  @override
  String get currentLanguage => _langCode;

  @override
  void setLanguage(String langCode) {
    // iOS 语言代码映射
    _langCode = _mapLanguageCode(langCode);
  }

  /// 将项目语言代码映射到 iOS 语言代码
  String _mapLanguageCode(String langCode) {
    switch (langCode) {
      case 'zh':
        return 'zh-CN';  // 简体中文
      case 'en':
        return 'en-US';  // 美式英语
      case 'ja':
        return 'ja-JP';  // 日语
      case 'ko':
        return 'ko-KR';  // 韩语
      default:
        return 'zh-CN';
    }
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 调用 iOS 原生初始化
      final result = await _channel.invokeMethod('initialize', {
        'language': _langCode,
      });
      _initialized = result == true;
    } catch (e) {
      print('IOSNativeEngine initialization failed: $e');
      _initialized = false;
    }
  }

  @override
  Future<void> startSession() async {
    if (!_initialized) return;

    try {
      await _channel.invokeMethod('startListening', {
        'language': _langCode,
      });
      _isListening = true;
    } catch (e) {
      print('IOSNativeEngine startSession failed: $e');
    }
  }

  @override
  Future<void> endSession() async {
    if (!_initialized) return;

    try {
      await _channel.invokeMethod('stopListening');
      _isListening = false;
    } catch (e) {
      print('IOSNativeEngine endSession failed: $e');
    }
  }

  @override
  Future<String> processAudio(Float32List samples) async {
    // iOS 原生引擎是实时回调模式，不通过 processAudio 获取结果
    // 这里返回空字符串，实际结果通过回调获取
    return '';
  }

  /// 设置识别结果回调
  void setResultCallback(Function(String text) onResult) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onRecognitionResult') {
        final text = call.arguments as String;
        onResult(text);
      }
    });
  }

  /// 设置错误回调
  void setErrorCallback(Function(String error) onError) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onError') {
        final error = call.arguments as String;
        onError(error);
      }
    });
  }

  @override
  void dispose() {
    endSession();
    _initialized = false;
    _channel.setMethodCallHandler(null);
  }
}