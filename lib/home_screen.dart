// 主界面：iOS 原生语音识别、热词匹配、结果展示。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_locale_scope.dart';
import 'app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const _recognitionLangCodes = ['zh', 'en', 'ja', 'ko'];

// 中文扫描热词（扫描旗杆功能）
const _chineseScanKeywords = {
  '扫描旗杆': 'ok_扫描旗杆',
  '扫描': 'ok_扫描旗杆',
  '旗杆': 'ok_扫描旗杆',
  '上描': 'ok_扫描旗杆',
  '杆': 'ok_扫描旗杆',
  '个': 'ok_扫描旗杆',
  '扫旗杆': 'ok_扫描旗杆',
  '旗': 'ok_扫描旗杆',
  '扫': 'ok_扫描旗杆',
  '七杠': 'ok_扫描旗杆',
  '气缸': 'ok_扫描旗杆',
  '缸': 'ok_扫描旗杆',
  '怎么': 'ok_扫描旗杆',
  '怎': 'ok_扫描旗杆',
  '乞': 'ok_扫描旗杆',
  '什了气缸': 'ok_扫描旗杆',
  '什么提缸': 'ok_扫描旗杆',
  '怎么提高': 'ok_扫描旗杆',
  '怎么提丐': 'ok_扫描旗杆',
  '怎么七杠': 'ok_扫描旗杆',
  '早么提纲': 'ok_扫描旗杆',
  '帮要提纲': 'ok_扫描旗杆',
  '找没旗缸': 'ok_扫描旗杆',
  '怎么提纲': 'ok_扫描旗杆',
  '项目要提纲': 'ok_扫描旗杆',
  '怎了提纲': 'ok_扫描旗杆',
  '怎龙旗丐': 'ok_扫描旗杆',
  '提纲': 'ok_扫描旗杆',
  '车最提高': 'ok_扫描旗杆',
};

// 中文测距热词（距离测量功能）
const _chineseDistanceKeywords = {
  '测距': 'ok_测距',
  '撤距': 'ok_测距',
  '测': 'ok_测距',
  '距': 'ok_测距',
  '撤': 'ok_测距',
  '据': 'ok_测距',
  '车具': 'ok_测距',
  '特去': 'ok_测距',
  '这具': 'ok_测距',
  '体纲': 'ok_测距',
  '此举提刚': 'ok_测距',
};

// 韩语测距热词（거리측정功能）
const _koreanDistanceKeywords = {
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
  '허리': 'ok_거리측정',
  '머리집정': 'ok_거리측정',
  '머리집죠': 'ok_거리측정',
  '머리집장': 'ok_거리측정',
  '머리집자': 'ok_거리측정',
  '머리집다': 'ok_거리측정',
  '머리집 다': 'ok_거리측정',
  '벌리 찍자': 'ok_거리측정',
  '자': 'ok_거리측정',
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
  '있죠': 'ok_거리측정',
  '진짜': 'ok_거리측정',
  '짜': 'ok_거리측정',
  '집접': 'ok_거리측정',
  '짱': 'ok_거리측정',
  '좀': 'ok_거리측정',
  '집': 'ok_거리측정',
  '머 집': 'ok_거리측정',
  '개': 'ok_거리측정',
};

// 韩语Pin Catcher热词（핀캐쳐功能）
const _koreanPinCatcherKeywords = {
  '괜 괜찮죠': 'ok_핀캐쳐',
  '괜찮죠': 'ok_핀캐쳐',
  '긴케 차': 'ok_핀캐쳐',
  '있 있겠죠': 'ok_핀캐쳐',
  '케청': 'ok_핀캐쳐',
  '링 캐청': 'ok_핀캐쳐',
  '개척': 'ok_핀캐쳐',
  '이렇 이렇게': 'ok_핀캐쳐',
  '그 괜찮쳐': 'ok_핀캐쳐',
  '응 개척': 'ok_핀캐쳐',
  '인 캐죠': 'ok_핀캐쳐',
  '늦겠죠': 'ok_핀캐쳐',
  '힘겼죠': 'ok_핀캐쳐',
  '힘겼쳐': 'ok_핀캐쳐',
  '땡깨쳐': 'ok_핀캐쳐',
  '이렇게쳐': 'ok_핀캐쳐',
  '괜찮쳐': 'ok_핀캐쳐',
  '긴 캐죠': 'ok_핀캐쳐',
  '긴케지': 'ok_핀캐쳐',
  '그겠지': 'ok_핀캐쳐',
  '그 저': 'ok_핀캐쳐',
  '캡죠': 'ok_핀캐쳐',
  '캐죠': 'ok_핀캐쳐',
  '게쳐': 'ok_핀캐쳐',
  '그쳐': 'ok_핀캐쳐',
  '있쳐': 'ok_핀캐쳐',
  '대쳐': 'ok_핀캐쳐',
  '긴케': 'ok_핀캐쳐',
  '인케': 'ok_핀캐쳐',
  '겠죠': 'ok_핀캐쳐',
  '그죠': 'ok_핀캐쳐',
  '죠': 'ok_핀캐쳐',
  '저': 'ok_핀캐쳐',
  '차': 'ok_핀캐쳐',
  '케': 'ok_핀캐쳐',
  '쳐': 'ok_핀캐쳐',
  '그': 'ok_핀캐쳐',
  '핀 캐처': 'ok_핀캐쳐',
  '핀 개처': 'ok_핀캐쳐',
  '핀': 'ok_핀캐쳐',
  '캐처': 'ok_핀캐쳐',
  '처': 'ok_핀캐쳐',
  '핑': 'ok_핀캐쳐',
  '빈': 'ok_핀캐쳐',
  '개처': 'ok_핀캐쳐',
  '캐쳐': 'ok_핀캐쳐',
  '캐차': 'ok_핀캐쳐',
  '캐쩌': 'ok_핀캐쳐',
  '깨쩌': 'ok_핀캐쳐',
  '깨처': 'ok_핀캐쳐',
};

// 英语测距热词（measure功能）
const _englishDistanceKeywords = {
  'measure': 'ok_measure',
  'mesure': 'ok_measure',
  'major': 'ok_measure',
  'mell': 'ok_measure',
  'sure': 'ok_measure',
  'me': 'ok_measure',
  'press': 'ok_measure',
  'should': 'ok_measure',
  'sual': 'ok_measure',
};

// 英语Pin Catcher热词（pin catcher功能）
const _englishPinCatcherKeywords = {
  'catcher': 'ok_pin catcher',
  'catch': 'ok_pin catcher',
  'cat up': 'ok_pin catcher',
  'catup': 'ok_pin catcher',
  'cater': 'ok_pin catcher',
  'caer': 'ok_pin catcher',
  'cer': 'ok_pin catcher',
  'enger': 'ok_pin catcher',
  'pin catcher': 'ok_pin catcher',
  'pink catcher': 'ok_pin catcher',
  'pincatcher': 'ok_pin catcher',
  'pink capture': 'ok_pin catcher',
  'capture': 'ok_pin catcher',
  'pikachu': 'ok_pin catcher',
  'pink': 'ok_pin catcher',
  'pin': 'ok_pin catcher',
  'ink': 'ok_pin catcher',
  'in': 'ok_pin catcher',
  'control': 'ok_pin catcher',
  'inay so': 'ok_pin catcher',
};

// 日语测距热词（測定功能）
const _japaneseDistanceKeywords = {
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
};

// 日语Pin Catcher热词（ピンキャッチャー功能）
const _japanesePinCatcherKeywords = {
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
};

class _HomeScreenState extends State<HomeScreen> {
  static const _channel = MethodChannel('native_speech_recognition');

  String _selectedLangCode = 'zh';
  String _recognizedText = '';
  String _partialText = '';
  bool _isRecording = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
  }

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onRecognitionResult') {
        final text = call.arguments as String;
        final formatted = _formatKeyword(text);
        debugPrint('[Native Speech] Result: "$text" → "$formatted"');
        if (mounted) {
          setState(() {
            if (_recognizedText.isNotEmpty) _recognizedText += '\n';
            _recognizedText += formatted;
            _partialText = '';
          });
        }
      } else if (call.method == 'onRecognitionPartial') {
        final text = call.arguments as String;
        debugPrint('[Native Speech] Partial: "$text"');
        if (mounted) {
          setState(() => _partialText = text);
        }
      } else if (call.method == 'onError') {
        final error = call.arguments as String;
        debugPrint('[Native Speech] Error: $error');
        if (mounted) {
          setState(() => _error = error);
        }
      }
    });
  }

  String _formatKeyword(String text) {
    if (text.isEmpty) return text;

    String? matched;
    if (_selectedLangCode == 'zh') {
      for (final entry in _chineseScanKeywords.entries) {
        if (text.contains(entry.key)) {
          matched = entry.value;
          break;
        }
      }
      if (matched == null) {
        for (final entry in _chineseDistanceKeywords.entries) {
          if (text.contains(entry.key)) {
            matched = entry.value;
            break;
          }
        }
      }
    } else if (_selectedLangCode == 'ko') {
      for (final entry in _koreanDistanceKeywords.entries) {
        if (text.contains(entry.key)) {
          matched = entry.value;
          break;
        }
      }
      if (matched == null) {
        for (final entry in _koreanPinCatcherKeywords.entries) {
          if (text.contains(entry.key)) {
            matched = entry.value;
            break;
          }
        }
      }
    } else if (_selectedLangCode == 'en') {
      final lower = text.toLowerCase();
      for (final entry in _englishDistanceKeywords.entries) {
        if (lower.contains(entry.key)) {
          matched = entry.value;
          break;
        }
      }
      if (matched == null) {
        for (final entry in _englishPinCatcherKeywords.entries) {
          if (lower.contains(entry.key)) {
            matched = entry.value;
            break;
          }
        }
      }
    } else if (_selectedLangCode == 'ja') {
      for (final entry in _japaneseDistanceKeywords.entries) {
        if (text.contains(entry.key)) {
          matched = entry.value;
          break;
        }
      }
      if (matched == null) {
        for (final entry in _japanesePinCatcherKeywords.entries) {
          if (text.contains(entry.key)) {
            matched = entry.value;
            break;
          }
        }
      }
    }

    return matched != null ? '$text → $matched' : text;
  }

  String _getNativeLanguageCode(String langCode) {
    switch (langCode) {
      case 'zh': return 'zh-CN';
      case 'en': return 'en-US';
      case 'ja': return 'ja-JP';
      case 'ko': return 'ko-KR';
      default: return 'zh-CN';
    }
  }

  Future<void> _startRecording() async {
    setState(() => _error = null);

    final permStatus = await Permission.microphone.request();
    if (!permStatus.isGranted) {
      setState(() => _error = AppLocaleScope.of(context).micPermission);
      return;
    }

    try {
      final nativeLang = _getNativeLanguageCode(_selectedLangCode);
      final initialized = await _channel.invokeMethod<bool>(
        'initialize',
        {'language': nativeLang},
      );
      if (initialized != true) {
        setState(() => _error = '当前设备不支持系统语音识别');
        return;
      }
      await _channel.invokeMethod('startListening', {'language': nativeLang});

      setState(() {
        _isRecording = true;
        _recognizedText = '';
        _partialText = '';
      });

      debugPrint('[Native Speech] Started listening with language: $nativeLang');
    } catch (e) {
      debugPrint('[Native Speech] Start error: $e');
      setState(() => _error = '启动语音识别失败: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _channel.invokeMethod('stopListening');
      setState(() => _isRecording = false);
      debugPrint('[Native Speech] Stopped listening');
    } catch (e) {
      debugPrint('[Native Speech] Stop error: $e');
    }
  }

  void _selectLanguage(String code) {
    if (code == _selectedLangCode) return;
    setState(() => _selectedLangCode = code);
  }

  void _showHistory() {
    // TODO: Show history dialog
  }

  void _copyText() {
    if (_recognizedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _recognizedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocaleScope.of(context).copied)),
    );
  }

  void _clearText() {
    setState(() => _recognizedText = '');
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(s.appTitle),
        actions: [
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
            _buildStatusCard(cs, s),
            if (_error != null) _buildErrorBanner(cs),
            Expanded(child: _buildResultsArea(cs, s)),
            _buildActionBar(cs, s),
            const SizedBox(height: 96),
          ],
        ),
      ),
      floatingActionButton: _buildRecordFab(cs, s),
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
                color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
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
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
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

  Widget _buildStatusCard(ColorScheme cs, AppStrings s) {
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
          child: Row(
            children: [
              Icon(
                Icons.mic,
                color: cs.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '系统原生语音识别',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _isRecording ? '正在聆听...' : '点击麦克风开始识别',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_error!, style: TextStyle(color: cs.onErrorContainer)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea(ColorScheme cs, AppStrings s) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Text(
          _recognizedText.isEmpty && _partialText.isEmpty
              ? s.tapMicHint
              : _recognizedText,
          style: TextStyle(
            fontSize: 16,
            color: _recognizedText.isEmpty ? cs.onSurfaceVariant : cs.onSurface,
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
          if (hasText)
            TextButton.icon(
              onPressed: _copyText,
              icon: const Icon(Icons.copy, size: 18),
              label: Text(s.copy),
            ),
          if (hasText) const SizedBox(width: 16),
          if (hasText)
            TextButton.icon(
              onPressed: _clearText,
              icon: const Icon(Icons.clear, size: 18),
              label: Text(s.clear),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordFab(ColorScheme cs, AppStrings s) {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording ? cs.error : cs.primary,
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? cs.error : cs.primary).withAlpha(100),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: _isRecording ? cs.onError : cs.onPrimary,
          size: 32,
        ),
      ),
    );
  }
}
