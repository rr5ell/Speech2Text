// 主界面：录音交互、Sherpa 识别引擎、结果展示与历史记录。
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'app_locale_scope.dart';
import 'app_strings.dart';
import 'history_manager.dart';
import 'history_record.dart';
import 'model_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const _recognitionLangCodes = ['zh', 'en', 'ja', 'ko'];

const _chineseOkKeywordOutputs = {
  '扫描旗杆': 'ok_扫描旗杆',
  '测距': 'ok_测距',
  '撤距': 'ok_测距',
  '扫描': 'ok_扫描旗杆',
  '旗杆': 'ok_扫描旗杆',
  '测': 'ok_测距',
  '距': 'ok_测距',
  '撤': 'ok_测距',
  '据': 'ok_测距',
  '车具': 'ok_测距',
  '上描': 'ok_扫描旗杆',
  '杆': 'ok_扫描旗杆',
  '个': 'ok_扫描旗杆',
};

const _koreanOkKeywordOutputs = {
  '측정': 'ok_거리측정',
  '거리': 'ok_거리측정',
  '거리측정': 'ok_거리측정',
  '척정': 'ok_거리측정',
  '척점': 'ok_거리측정',
  '측점': 'ok_거리측정',
  '축정': 'ok_거리측정',
  '축점': 'ok_거리측정',
  '걸이': 'ok_거리측정',
  '고리': 'ok_거리측정',
  '측쩡': 'ok_거리측정',
  '즉정': 'ok_거리측정',
  '쯕청': 'ok_거리측정',
  '층정': 'ok_거리측정',
  '저리측정': 'ok_거리측정',
  '거리리측정': 'ok_거리측정',
  '머리측정': 'ok_거리측정',
  '커리': 'ok_거리측정',
  '가을이': 'ok_거리측정',
  '그리': 'ok_거리측정',
  '거측정': 'ok_거리측정',
  '거니': 'ok_거리측정',
  '거위': 'ok_거리측정',
  '리측정': 'ok_거리측정',
  '거디측정': 'ok_거리측정',
  '어디측정': 'ok_거리측정',
  '직장': 'ok_거리측정',
  '머리직접': 'ok_거리측정',
  '정': 'ok_거리측정',
  '머리축': 'ok_거리측정',
  '머리집': 'ok_거리측정',
  '거립직': 'ok_거리측정',
  '직접': 'ok_거리측정',
  '리 첫정': 'ok_거리측정',
  '어리셨정': 'ok_거리측정',
  '머리척종': 'ok_거리측정',
  '머리 체': 'ok_거리측정',
  '저리 책종': 'ok_거리측정',
  '머리 직장 애': 'ok_거리측정',
  '머리 집 더': 'ok_거리측정',
  '우리 집': 'ok_거리측정',
  '허리 직장': 'ok_거리측정',
  '머리 책장': 'ok_거리측정',
  '머리 직접': 'ok_거리측정',
  '허리측': 'ok_거리측정',
  '머리집정': 'ok_거리측정',
  '머리집죠': 'ok_거리측정',
  '머리집장': 'ok_거리측정',
  '머리집자': 'ok_거리측정',
  '머리집다': 'ok_거리측정',
  '머리집 다': 'ok_거리측정',
  '벌리 찍자': 'ok_거리측정',
  '저리 책': 'ok_거리측정',
  '저리 집': 'ok_거리측정',
  '벌리 책': 'ok_거리측정',
  '벌리 직': 'ok_거리측정',
  '벌리 측': 'ok_거리측정',
  '힘 캐 쳐': 'ok_거리측정',
  '머리 집': 'ok_거리측정',
  '머리 죽': 'ok_거리측정',
  '머리직': 'ok_거리측정',
  '머리칠': 'ok_거리측정',
  '아리 책': 'ok_거리측정',
  '벌 직': 'ok_거리측정',
  '머리집덩': 'ok_거리측정',
  '벌릿 직': 'ok_거리측정',
  '죽': 'ok_거리측정',
  '머집': 'ok_거리측정',
  '주': 'ok_거리측정',
  '이 직장': 'ok_거리측정',
  '십 점': 'ok_거리측정',
  '벌리집': 'ok_거리측정',
  '어리집': 'ok_거리측정',
  '저리 집 좀': 'ok_거리측정',
  '괜 괜찮죠': 'ok_핀캐쳐',
  '괜찮죠': 'ok_핀캐쳐',
  '긴케 차': 'ok_핀캐쳐',
  '있 있겠죠': 'ok_핀캐쳐',
  '케청': 'ok_핀캐쳐',
  '링 캐청': 'ok_핀캐쳐',
  '개척': 'ok_핀캐쳐',
  '있죠': 'ok_거리측정',
  '진짜': 'ok_거리측정',
  '집접': 'ok_거리측정',
  '짱': 'ok_거리측정',
  '좀': 'ok_거리측정',
  '집': 'ok_거리측정',
  '머 집': 'ok_거리측정',
  '개': 'ok_거리측정',
  '이렇 이렇게': 'ok_扫描旗杆',
  '그 괜찮쳐': 'ok_扫描旗杆',
  '응 개척': 'ok_扫描旗杆',
  '인 캐죠': 'ok_扫描旗杆',
  '늦겠죠': 'ok_扫描旗杆',
  '힘겼죠': 'ok_扫描旗杆',
  '힘겼쳐': 'ok_扫描旗杆',
  '땡깨쳐': 'ok_扫描旗杆',
  '이렇게쳐': 'ok_扫描旗杆',
  '괜찮쳐': 'ok_扫描旗杆',
  '긴 캐죠': 'ok_扫描旗杆',
  '긴케지': 'ok_扫描旗杆',
  '그겠지': 'ok_扫描旗杆',
  '그 저': 'ok_扫描旗杆',
  '캡죠': 'ok_扫描旗杆',
  '캐죠': 'ok_扫描旗杆',
  '게쳐': 'ok_扫描旗杆',
  '그쳐': 'ok_扫描旗杆',
  '있쳐': 'ok_扫描旗杆',
  '대쳐': 'ok_扫描旗杆',
  '긴케': 'ok_扫描旗杆',
  '인케': 'ok_扫描旗杆',
  '겠죠': 'ok_扫描旗杆',
  '그죠': 'ok_扫描旗杆',
  '죠': 'ok_扫描旗杆',
  '저': 'ok_扫描旗杆',
  '차': 'ok_扫描旗杆',
  '케': 'ok_扫描旗杆',
  '쳐': 'ok_扫描旗杆',
  '그': 'ok_扫描旗杆',
  '핀 캐처': 'ok_핀캐쳐',
  '핀 개처': 'ok_핀캐쳐',
  '핀': 'ok_핀캐쳐',
  '캐처': 'ok_핀캐쳐',
  '핑': 'ok_핀캐쳐',
  '빈': 'ok_핀캐쳐',
  '개처': 'ok_핀캐쳐',
  '캐쳐': 'ok_핀캐쳐',
  '캐차': 'ok_핀캐쳐',
  '캐쩌': 'ok_핀캐쳐',
  '깨쩌': 'ok_핀캐쳐',
  '깨처': 'ok_핀캐쳐',
  '캡쳐': 'ok_핀캐쳐',
  '캡처': 'ok_핀캐쳐',
  '캡챠': 'ok_핀캐쳐',
  '개쳐': 'ok_핀캐쳐',
  '캐저': 'ok_핀캐쳐',
  '캐초': 'ok_핀캐쳐',
  '캐쵸': 'ok_핀캐쳐',
  '흰': 'ok_핀캐쳐',
  '핑캐쳐': 'ok_핀캐쳐',
  '핑크쳐': 'ok_핀캐쳐',
  '팽개쳐': 'ok_핀캐쳐',
  '핀캡쳐': 'ok_핀캐쳐',
  '팬캡쳐': 'ok_핀캐쳐',
  '빈캡쳐': 'ok_핀캐쳐',
  '핑크척': 'ok_핀캐쳐',
  '핑계처': 'ok_핀캐쳐',
  '핑크죠': 'ok_핀캐쳐',
  '핑크': 'ok_핀캐쳐',
  '핀케청': 'ok_핀캐쳐',
  '핀케죠': 'ok_핀캐쳐',
  '핀겠죠': 'ok_핀캐쳐',
  '흰캡쳐': 'ok_핀캐쳐',
  '흰캐쳐': 'ok_핀캐쳐',
  '크죠': 'ok_핀캐쳐',
  '빈캐쳐': 'ok_핀캐쳐',
  '핀케쳐': 'ok_핀캐쳐',
  '흰케쳐': 'ok_핀캐쳐',
  '핑게쳐': 'ok_핀캐쳐',
  '핀캐쳐': 'ok_핀캐쳐',
  '그린캡쳐': 'ok_핀캐쳐',
  '케챱': 'ok_핀캐쳐',
  '빈겠죠': 'ok_핀캐쳐',
  '김캡쳐': 'ok_핀캐쳐',
  '긴캐쳐': 'ok_핀캐쳐',
  '김캐쳐': 'ok_핀캐쳐',
  '빈겟죠': 'ok_핀캐쳐',
  '힌겠죠': 'ok_핀캐쳐',
  '긴 캐쳐': 'ok_핀캐쳐',
  '힘 캡쳐': 'ok_핀캐쳐',
  '힌캡쳐': 'ok_핀캐쳐',
  '는캐쳐': 'ok_핀캐쳐',
  '핑 캐쳐': 'ok_핀캐쳐',
  '핑크차': 'ok_핀캐쳐',
  '케쳐': 'ok_핀캐쳐',
  '핑크처': 'ok_핀캐쳐',
  '케처': 'ok_핀캐쳐',
  '김캐척': 'ok_핀캐쳐',
  '핑캐처': 'ok_핀캐쳐',
  '킨캐쳐': 'ok_핀캐쳐',
  '핑캡처': 'ok_핀캐쳐',
  '긴캐처': 'ok_핀캐쳐',
  '캡척': 'ok_핀캐쳐',
  '캡첩': 'ok_핀캐쳐',
  '케첩': 'ok_핀캐쳐',
  '인처': 'ok_핀캐쳐',
  '힘큐쳐': 'ok_핀캐쳐',
  '이렇쳐': 'ok_핀캐쳐',
  '이괜찮겠죠': 'ok_핀캐쳐',
  '그겠죠': 'ok_핀캐쳐',
  '이렇게저': 'ok_핀캐쳐',
  '켜춰': 'ok_핀캐쳐',
  '카초': 'ok_핀캐쳐',
  '링캡조': 'ok_핀캐쳐',
};

const _englishOkKeywordOutputs = {
  'measure': 'ok_measure',
  'mesure': 'ok_measure',
  'major': 'ok_measure',
  'mell': 'ok_measure',
  'sure': 'ok_measure',
  'me': 'ok_measure',
  'catcher': 'ok_pin catcher',
  'catch': 'ok_pin catcher',
  'cat up': 'ok_pin catcher',
  'catup': 'ok_pin catcher',
  'cater': 'ok_pin catcher',
  'caer': 'ok_pin catcher',
  'pin catcher': 'ok_pin catcher',
  'pink catcher': 'ok_pin catcher',
  'pincatcher': 'ok_pin catcher',
  'pink capture': 'ok_pin catcher',
  'capture': 'ok_pin catcher',
  'pikachu': 'ok_pin catcher',
  'pink': 'ok_pin catcher',
  'pin': 'ok_pin catcher',
  'ink': 'ok_pin catcher',
};

const _japaneseOkKeywordOutputs = {
  '測定': 'ok_測定',
  '特定': 'ok_測定',
  '測': 'ok_測定',
  '定': 'ok_測定',
  'そくてー': 'ok_測定',
  'そってい': 'ok_測定',
  'そってー': 'ok_測定',
  'そてい': 'ok_測定',
  'てー': 'ok_測定',
  '食て': 'ok_測定',
  '食定': 'ok_測定',
  '食って': 'ok_測定',
  'そで': 'ok_測定',
  'そこで': 'ok_測定',
  'こて': 'ok_測定',
  'こやって': 'ok_測定',
  'ピンキャッチャー': 'ok_ピンキャッチャー',
  'ブンキャッチャー': 'ok_ピンキャッチャー',
  'ピンケッチ': 'ok_ピンキャッチャー',
  '貧結': 'ok_ピンキャッチャー',
  '貧血': 'ok_ピンキャッチャー',
  'ピ結': 'ok_ピンキャッチャー',
  'ピ血': 'ok_ピンキャッチャー',
  '金結': 'ok_ピンキャッチャー',
  '金血': 'ok_ピンキャッチャー',
  'ピン': 'ok_ピンキャッチャー',
  'キャッチャー': 'ok_ピンキャッチャー',
  'ピンキャッチャ': 'ok_ピンキャッチャー',
  'ピンキャッチ': 'ok_ピンキャッチャー',
  'ビンキャッチャー': 'ok_ピンキャッチャー',
  'ビン': 'ok_ピンキャッチャー',
  'ヒン': 'ok_ピンキャッチャー',
  'ヒンキャッチャー': 'ok_ピンキャッチャー',
  'ピンチャー': 'ok_ピンキャッチャー',
  'ピンチャンヒン': 'ok_ピンキャッチャー',
  'ピンチャン': 'ok_ピンキャッチャー',
  'ピケチャ': 'ok_ピンキャッチャー',
};

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _modelManager = SherpaModelManager();
  final _historyManager = HistoryManager();
  final _audioRecorder = AudioRecorder();

  String _selectedLangCode = 'zh';
  String _selectedLangName(AppStrings s) => s.recognitionLangName(_selectedLangCode);

  bool _modelsReady = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String _downloadStatusText = '';

  sherpa.VoiceActivityDetector? _vad;
  sherpa.OfflineRecognizer? _recognizer;
  String? _preparedLangCode;
  bool _isPreparing = false;

  bool _isRecording = false;
  int _sessionTextStart = 0;
  String _recognizedText = '';
  String _partialText = '';
  bool _showListeningHint = false;
  String? _error;
  int _segmentCount = 0;

  StreamSubscription<Uint8List>? _audioSub;
  final List<double> _remainingSamples = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _modelManager.setStrings(AppLocaleScope.of(context));
      _checkModels();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioSub?.cancel();
    _audioRecorder.dispose();
    _vad?.free();
    _recognizer?.free();
    super.dispose();
  }

  Future<void> _checkModels() async {
    final ready = await _modelManager.isReadyFor(_selectedLangCode);
    if (mounted) {
      setState(() => _modelsReady = ready);
      if (ready) {
        _prepareEngine();
      } else {
        _downloadModels();
      }
    }
  }

  Future<void> _downloadModels() async {
    if (_isDownloading) return;
    final s = AppLocaleScope.of(context);

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _downloadStatusText = s.prepDownload;
      _error = null;
    });

    try {
      await _modelManager.downloadFor(
        _selectedLangCode,
        (progress, statusText) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
              _downloadStatusText = statusText;
            });
          }
        },
        strings: s,
      );
      if (mounted) {
        setState(() => _modelsReady = true);
      }
      _prepareEngine();
    } catch (e) {
      if (mounted) {
        setState(() => _error = s.downloadFailed(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _freeEngine() {
    _vad?.free();
    _vad = null;
    _recognizer?.free();
    _recognizer = null;
    _preparedLangCode = null;
  }

  bool get _engineMatchesCurrent {
    return _vad != null &&
        _recognizer != null &&
        _preparedLangCode == _selectedLangCode;
  }

  Future<void> _rebuildVad({required bool isKorean}) async {
    _vad?.free();
    _vad = null;

    final vadModelPath = await _modelManager.getVadModelPath();
    debugPrint('[ASR] VAD model: $vadModelPath (korean=$isKorean)');

    final vadConfig = sherpa.VadModelConfig(
      sileroVad: sherpa.SileroVadModelConfig(
        model: vadModelPath,
        minSilenceDuration: isKorean ? 0.5 : 0.25,
        minSpeechDuration: isKorean ? 0.4 : 0.25,
        maxSpeechDuration: 30.0,
        threshold: isKorean ? 0.40 : 0.45,
      ),
      sampleRate: 16000,
      numThreads: 2,
      debug: true,
    );
    _vad = sherpa.VoiceActivityDetector(
      config: vadConfig,
      bufferSizeInSeconds: 60,
    );
  }

  Future<void> _prepareEngine({bool force = false}) async {
    if (!force && _engineMatchesCurrent) return;

    if (mounted) setState(() => _isPreparing = true);

    try {
      sherpa.initBindings();

      final needsVadRebuild = _vad == null ||
          (_selectedLangCode == 'ko') != (_preparedLangCode == 'ko');

      if (needsVadRebuild) {
        await _rebuildVad(isKorean: _selectedLangCode == 'ko');
      }

      _recognizer?.free();
      debugPrint('[SherpaASR] Creating recognizer lang=$_selectedLangCode');

      _recognizer = sherpa.OfflineRecognizer(
        sherpa.OfflineRecognizerConfig(
          model: sherpa.OfflineModelConfig(
            senseVoice: sherpa.OfflineSenseVoiceModelConfig(
              model: await _modelManager.getSenseVoiceModelPath(),
              language: _selectedLangCode,
              useInverseTextNormalization: false,
            ),
            tokens: await _modelManager.getSenseVoiceTokensPath(),
            numThreads: 2,
            debug: true,
          ),
        ),
      );

      _preparedLangCode = _selectedLangCode;
      debugPrint('[SherpaASR] Engine ready lang=$_selectedLangCode');
    } catch (e, st) {
      _freeEngine();
      debugPrint('[ASR] Engine init error: $e\n$st');
      if (mounted) {
        setState(() => _error = AppLocaleScope.of(context).modelLoadFailed(e));
      }
    } finally {
      if (mounted) setState(() => _isPreparing = false);
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    setState(() => _error = null);

    if (!_modelsReady) {
      await _downloadModels();
      if (!_modelsReady) return;
    }

    final permStatus = await Permission.microphone.request();
    if (!permStatus.isGranted) {
      if (mounted) {
        setState(() => _error = AppLocaleScope.of(context).micPermission);
      }
      return;
    }

    try {
      await _prepareEngine();

      if (_vad == null || _recognizer == null) return;

      _vad!.reset();
      _remainingSamples.clear();
      _segmentCount = 0;

      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        autoGain: true,
        noiseSuppress: true,
      );

      final stream = await _audioRecorder.startStream(config);
      debugPrint('[SherpaASR] Audio stream started');

      _audioSub = stream.listen(
        _onAudioData,
        onError: (e) {
          debugPrint('[SherpaASR] Audio stream error: $e');
          if (mounted) {
            setState(() => _error = AppLocaleScope.of(context).audioStreamError(e));
          }
        },
      );

      setState(() {
        _isRecording = true;
        _sessionTextStart = _recognizedText.length;
        _partialText = '';
        _showListeningHint = false;
      });
      _pulseController.repeat(reverse: true);
    } catch (e, st) {
      debugPrint('[ASR] Start recording error: $e\n$st');
      if (mounted) {
        setState(() => _error = AppLocaleScope.of(context).recordStartFailed(e));
      }
    }
  }

  void _onAudioData(Uint8List bytes) {
    if (!_isRecording || _vad == null || _recognizer == null) return;
    if (bytes.isEmpty) return;

    final pcm16 = _bytesToInt16(bytes);
    for (int i = 0; i < pcm16.length; i++) {
      _remainingSamples.add(pcm16[i] / 32768.0);
    }

    const windowSize = 512;
    while (_remainingSamples.length >= windowSize) {
      final chunk = Float32List.fromList(
        _remainingSamples.sublist(0, windowSize),
      );
      _remainingSamples.removeRange(0, windowSize);

      _vad!.acceptWaveform(chunk);

      while (!_vad!.isEmpty()) {
        final segment = _vad!.front();
        _segmentCount++;
        debugPrint('[SherpaASR] Speech segment #$_segmentCount detected, '
            '${segment.samples.length} samples '
            '(${(segment.samples.length / 16000.0).toStringAsFixed(2)}s)');
        _processSegment(segment.samples);
        _vad!.pop();
      }
    }

    if (_vad!.isDetected()) {
      if (mounted && !_showListeningHint) {
        setState(() => _showListeningHint = true);
      }
    } else {
      if (mounted && _showListeningHint) {
        setState(() => _showListeningHint = false);
      }
    }
  }

  Int16List _bytesToInt16(Uint8List bytes) {
    final len = bytes.length - (bytes.length % 2);
    if (len == 0) return Int16List(0);

    if (bytes.offsetInBytes == 0 && bytes.length % 2 == 0) {
      return Int16List.view(bytes.buffer, 0, bytes.length ~/ 2);
    }

    final aligned = Uint8List(len);
    for (int i = 0; i < len; i++) {
      aligned[i] = bytes[i];
    }
    return Int16List.view(aligned.buffer, 0, len ~/ 2);
  }

  String _applyTextFilter(String text) {
    final stripped = text.replaceAll(
      RegExp(r"""[，。！？、；：""'（）《》【】,.!?;:"\u0027()\[\]{}]"""),
      '',
    );
    // Only strip non-Korean chars when Korean is the recognition language,
    // not when the UI language happens to be Korean.
    if (_selectedLangCode == 'ko') {
      final korean = stripped.replaceAll(
        RegExp(r'[^\uAC00-\uD7A3\u1100-\u11FF\u3130-\u318F\uA960-\uA97F\uD7B0-\uD7FF\s]'),
        '',
      );
      return korean.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    }
    return stripped;
  }

  String _formatKeywordRecognitionOutput(String text) {
    if (text.isEmpty) return text;
    if (_selectedLangCode == 'zh') {
      for (final entry in _chineseOkKeywordOutputs.entries) {
        if (text.contains(entry.key)) return entry.value;
      }
    } else if (_selectedLangCode == 'ko') {
      for (final entry in _koreanOkKeywordOutputs.entries) {
        if (text.contains(entry.key)) return entry.value;
      }
    } else if (_selectedLangCode == 'en') {
      final lower = text.toLowerCase();
      for (final entry in _englishOkKeywordOutputs.entries) {
        if (lower.contains(entry.key)) return entry.value;
      }
    } else if (_selectedLangCode == 'ja') {
      for (final entry in _japaneseOkKeywordOutputs.entries) {
        if (text.contains(entry.key)) return entry.value;
      }
    }
    return text;
  }

  void _processSegment(Float32List audioSamples) {
    if (_recognizer == null) return;

    try {
      final stream = _recognizer!.createStream();
      stream.acceptWaveform(samples: audioSamples, sampleRate: 16000);
      _recognizer!.decode(stream);
      final result = _recognizer!.getResult(stream);
      stream.free();

      final text = _formatKeywordRecognitionOutput(
        _applyTextFilter(result.text.trim()),
      );
      debugPrint('[SherpaASR] Result: "$text" lang=${result.lang}');

      if (text.isNotEmpty) {
        if (mounted) {
          setState(() {
            if (_recognizedText.isNotEmpty) _recognizedText += '\n';
            _recognizedText += text;
            _partialText = '';
          });
        }
      }
    } catch (e, st) {
      debugPrint('[SherpaASR] Decode error: $e\n$st');
    }
  }

  Future<void> _stopRecording() async {
    _pulseController.stop();
    _pulseController.reset();

    await _audioSub?.cancel();
    _audioSub = null;

    try {
      await _audioRecorder.stop();
    } catch (_) {}

    if (_vad != null) {
      _vad!.flush();
      while (!_vad!.isEmpty()) {
        final segment = _vad!.front();
        _processSegment(segment.samples);
        _vad!.pop();
      }
    }

    _remainingSamples.clear();

    if (mounted) {
      setState(() {
        _isRecording = false;
        _partialText = '';
        _showListeningHint = false;
      });
    }
    await _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final sessionText = _recognizedText.substring(_sessionTextStart).trim();
    if (sessionText.isEmpty) return;

    await _historyManager.add(
      HistoryRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        languageName: _selectedLangName(AppLocaleScope.of(context)),
        languageFlag: '🗣',
        text: sessionText,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '${time.month}/${time.day} $h:$m';
  }

  void _selectLanguage(String langCode) async {
    if (langCode == _selectedLangCode) return;
    if (_isRecording) await _stopRecording();
    setState(() => _selectedLangCode = langCode);

    final ready = await _modelManager.isReadyFor(langCode);
    if (mounted) {
      setState(() => _modelsReady = ready);
    }
    if (!ready) {
      await _downloadModels();
    } else {
      _prepareEngine(force: true);
    }
  }

  void _copyText() {
    if (_recognizedText.isEmpty) return;
    final s = AppLocaleScope.of(context);
    Clipboard.setData(ClipboardData(text: _recognizedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.copiedToClipboard),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearText() {
    setState(() {
      _recognizedText = '';
      _partialText = '';
      _showListeningHint = false;
    });
  }

  void _onUiLanguageChanged(AppUiLanguage language) {
    _modelManager.setStrings(AppStrings(language));
    AppLocaleScope.changeLanguage(context, language);
  }

  Widget _buildUiLanguageSelector(AppStrings s) {
    const options = [
      (AppUiLanguage.zh, '中文'),
      (AppUiLanguage.en, 'English'),
      (AppUiLanguage.ja, '日本語'),
      (AppUiLanguage.ko, '한국어'),
    ];

    return PopupMenuButton<AppUiLanguage>(
      tooltip: s.uiLanguage,
      onSelected: _onUiLanguageChanged,
      itemBuilder: (context) => options.map((opt) {
        final selected = s.language == opt.$1;
        return PopupMenuItem(
          value: opt.$1,
          child: Row(
            children: [
              if (selected) const Icon(Icons.check, size: 18),
              if (selected) const SizedBox(width: 8),
              Text(opt.$2),
            ],
          ),
        );
      }).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 20),
            const SizedBox(width: 4),
            Text(
              s.uiLanguageLabel,
              style: const TextStyle(fontSize: 13),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final isReady = _modelsReady && !_isDownloading && !_isPreparing;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(s.appTitle),
        actions: [
          _buildUiLanguageSelector(s),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: s.history,
            onPressed: _showHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildLanguageSelector(cs, s),
            _buildModelStatus(cs, s),
            if (_error != null) _buildErrorBanner(cs),
            Expanded(child: _buildResultsArea(cs, s)),
            _buildActionBar(cs, s),
            const SizedBox(height: 96),
          ],
        ),
      ),
      floatingActionButton: _buildRecordFab(cs, isReady, s),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLanguageSelector(ColorScheme cs, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: _recognitionLangCodes.map((code) {
          final selected = _selectedLangCode == code;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Material(
                color: selected
                    ? cs.primaryContainer
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _selectLanguage(code),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      s.recognitionLangName(code),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color: selected
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModelStatus(ColorScheme cs, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _modelsReady
                        ? Icons.check_circle_rounded
                        : Icons.language_rounded,
                    color: _modelsReady ? Colors.green : cs.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _modelManager.modelDisplayName(_selectedLangCode),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _modelsReady
                              ? (_isPreparing
                                  ? s.loadingModel
                                  : s.modelReady(_selectedLangName(s)))
                              : s.needDownload(_modelManager.totalSizeMB(
                                  _selectedLangCode)),
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_modelsReady && !_isDownloading)
                    FilledButton.tonalIcon(
                      onPressed: _downloadModels,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(s.download),
                    ),
                  if (_isPreparing)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              if (_isDownloading) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _downloadProgress,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _downloadStatusText,
                  style:
                      TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: cs.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _error!,
                  style: TextStyle(
                      fontSize: 12, color: cs.onErrorContainer),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _error = null),
                child: Icon(Icons.close,
                    size: 18, color: cs.onErrorContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsArea(ColorScheme cs, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: _recognizedText.isEmpty && _partialText.isEmpty && !_showListeningHint
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic_none_rounded,
                          size: 56, color: cs.outlineVariant),
                      const SizedBox(height: 12),
                      Text(
                        _modelsReady ? s.longPressHint : s.downloadModelFirst,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_recognizedText.isNotEmpty)
                        SelectableText(
                          _recognizedText,
                          style: const TextStyle(
                              fontSize: 16, height: 1.6),
                        ),
                      if (_showListeningHint)
                        Text(
                          s.listening,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: cs.primary.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (_partialText.isNotEmpty)
                        Text(
                          _partialText,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: cs.primary.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildActionBar(ColorScheme cs, AppStrings s) {
    final hasText = _recognizedText.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: hasText ? _copyText : null,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(s.copy),
          ),
          const SizedBox(width: 24),
          TextButton.icon(
            onPressed: hasText ? _clearText : null,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(s.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordFab(ColorScheme cs, bool isReady, AppStrings s) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRecording ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: 72,
            height: 72,
            child: RawGestureDetector(
              gestures: isReady
                  ? <Type, GestureRecognizerFactory>{
                      LongPressGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                              LongPressGestureRecognizer>(
                        () => LongPressGestureRecognizer(
                          duration: const Duration(milliseconds: 150),
                        ),
                        (instance) {
                          instance.onLongPressStart =
                              (_) { _startRecording(); };
                          instance.onLongPressEnd =
                              (_) { _stopRecording(); };
                        },
                      ),
                      TapGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                              TapGestureRecognizer>(
                        () => TapGestureRecognizer(),
                        (instance) {
                          instance.onTap = () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(s.longPressSnack),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          };
                        },
                      ),
                    }
                  : {},
              child: FloatingActionButton(
                onPressed: isReady ? () {} : null,
                shape: const CircleBorder(),
                elevation: _isRecording ? 8 : 4,
                backgroundColor: _isRecording
                    ? cs.error
                    : (isReady ? cs.primary : cs.surfaceContainerHighest),
                foregroundColor: _isRecording
                    ? cs.onError
                    : (isReady ? cs.onPrimary : cs.onSurfaceVariant),
                child: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 32,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showHistory() async {
    final records = await _historyManager.loadAll();
    if (!mounted) return;
    final s = AppLocaleScope.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                builder: (_, scrollController) {
                  return Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.history,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (records.isNotEmpty)
                              TextButton(
                                onPressed: () async {
                                  await _historyManager.clearAll();
                                  records.clear();
                                  setSheetState(() {});
                                },
                                child: Text(s.clearHistory),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: records.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 48,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      s.noHistory,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: records.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, index) {
                                  final record = records[index];
                                  final preview =
                                      record.text.length > 60
                                          ? '${record.text.substring(0, 60)}...'
                                          : record.text;
                                  return ListTile(
                                    leading: Text(
                                      record.languageFlag,
                                      style: const TextStyle(
                                          fontSize: 28),
                                    ),
                                    title: Text(
                                      preview,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${record.languageName} · ${_formatTime(record.createdAt)}',
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _recognizedText =
                                            record.text;
                                        _partialText = '';
                                      });
                                      Navigator.of(ctx).pop();
                                    },
                                    trailing: Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.copy_outlined),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                  text:
                                                      record.text),
                                            );
                                            ScaffoldMessenger.of(
                                                    context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    s.copiedToClipboard),
                                                behavior:
                                                    SnackBarBehavior
                                                        .floating,
                                                duration: const Duration(
                                                    seconds: 2),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons
                                                  .delete_outline),
                                          onPressed: () async {
                                            await _historyManager
                                                .delete(
                                                    record.id);
                                            records
                                                .removeAt(index);
                                            setSheetState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
