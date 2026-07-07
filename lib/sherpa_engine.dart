// Sherpa-ONNX SenseVoice 引擎实现

import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:path_provider/path_provider.dart';

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
  String? _modelPath;
  String? _tokensPath;

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
      // 获取模型路径
      final modelManager = SherpaModelManager();
      _modelPath = await modelManager.getSenseVoiceModelPath();
      _tokensPath = await modelManager.getSenseVoiceTokensPath();

      // 创建识别器配置
      final config = sherpa.OfflineRecognizerConfig(
        featConfig: sherpa.FeatureConfig(
          sampleRate: 16000,
          featureDim: 80,
        ),
        modelConfig: sherpa.OfflineModelConfig(
          transducer: sherpa.OfflineTransducerModelConfig(
            encoder: '',
            decoder: '',
            joiner: '',
          ),
          paraformer: sherpa.OfflineParaformerModelConfig(
            model: _modelPath!,
          ),
          tokens: _tokensPath!,
          numThreads: 4,
          provider: 'cpu',
          modelType: 'sensevoice',
        ),
        decodingMethod: 'greedy_search',
      );

      _recognizer = sherpa.createOfflineRecognizer(config: config);
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
      _stream!.destroy();
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
      _recognizer!.destroy();
      _recognizer = null;
    }
    _initialized = false;
  }
}