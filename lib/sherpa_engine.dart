// Sherpa-ONNX SenseVoice 引擎实现

import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'speech_engine.dart';
import 'model_manager.dart';

/// Sherpa-ONNX SenseVoice 引擎实现
class SherpaEngine implements SpeechRecognitionEngine {
  @override
  String get name => 'Sherpa-ONNX SenseVoice';

  sherpa.OfflineRecognizer? _recognizer;
  sherpa.OfflineStream? _stream;
  bool _initialized = false;
  String _langCode = 'zh';
  final _modelManager = SherpaModelManager();

  @override
  bool get isInitialized => _initialized;

  @override
  String get currentLanguage => _langCode;

  @override
  void setLanguage(String langCode) {
    _langCode = langCode;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      sherpa.initBindings();

      // 创建识别器
      _recognizer = sherpa.OfflineRecognizer(
        sherpa.OfflineRecognizerConfig(
          model: sherpa.OfflineModelConfig(
            senseVoice: sherpa.OfflineSenseVoiceModelConfig(
              model: await _modelManager.getSenseVoiceModelPath(),
              language: _langCode,
              useInverseTextNormalization: false,
            ),
            tokens: await _modelManager.getSenseVoiceTokensPath(),
            numThreads: 2,
            debug: true,
          ),
        ),
      );
      _initialized = true;
    } catch (e) {
      print('SherpaEngine initialization failed: $e');
      _initialized = false;
    }
  }

  @override
  Future<void> startSession() async {
    if (!_initialized || _recognizer == null) return;
    _stream = _recognizer!.createStream();
  }

  @override
  Future<void> endSession() async {
    if (_stream != null) {
      _stream!.free();
      _stream = null;
    }
  }

  @override
  Future<String> processAudio(Float32List samples) async {
    if (!_initialized || _stream == null) return '';

    // 输入音频数据
    _stream!.acceptWaveform(samples: samples, sampleRate: 16000);

    // 解码
    _recognizer!.decode(_stream!);

    // 获取结果
    final result = _recognizer!.getResult(_stream!);
    return result.text.trim();
  }

  @override
  void dispose() {
    endSession();
    if (_recognizer != null) {
      _recognizer!.free();
      _recognizer = null;
    }
    _initialized = false;
  }
}