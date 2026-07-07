// 主界面：iOS 原生语音识别、热词匹配、结果展示。
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_locale_scope.dart';
import 'app_strings.dart';
import 'history_manager.dart';
import 'history_record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const _recognitionLangCodes = ['zh', 'en', 'ja', 'ko'];

// 中文扫描热词
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
};

// 中文测距热词
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
};

// 韩语测距热词
const _koreanDistanceKeywords = {
  '측정': 'ok_거리측정',
  '거리': 'ok_거리측정',
  '거리측정': 'ok_거리측정',
  '척정': 'ok_거리측정',
};

// 韩语 Pin Catcher 热词
const _koreanPinCatcherKeywords = {
  '핀캐쳐': 'ok_핀캐쳐',
  '핀': 'ok_핀캐쳐',
  '캐쳐': 'ok_핀캐쳐',
  '핑': 'ok_핀캐쳐',
  '빈': 'ok_핀캐쳐',
};

// 英语测距热词
const _englishDistanceKeywords = {
  'measure': 'ok_measure',
  'mesure': 'ok_measure',
  'me': 'ok_measure',
};

// 英语 Pin Catcher 热词
const _englishPinCatcherKeywords = {
  'catcher': 'ok_pin catcher',
  'catch': 'ok_pin catcher',
  'pin': 'ok_pin catcher',
};

// 日语测距热词
const _japaneseDistanceKeywords = {
  '測定': 'ok_測定',
  '測': 'ok_測定',
  '定': 'ok_測定',
};

// 日语 Pin Catcher 热词
const _japanesePinCatcherKeywords = {
  'ピンキャッチャー': 'ok_ピンキャッチャー',
  'ピン': 'ok_ピンキャッチャー',
};

class _HomeScreenState extends State<HomeScreen> {
  final _historyManager = HistoryManager();
  static const _channel = MethodChannel('ios_speech_recognition');

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
        debugPrint('[iOS Speech] Result: "$text" → "$formatted"');
        if (mounted) {
          setState(() {
            if (_recognizedText.isNotEmpty) _recognizedText += '\n';
            _recognizedText += formatted;
            _partialText = '';
          });
        }
      } else if (call.method == 'onError') {
        final error = call.arguments as String;
        debugPrint('[iOS Speech] Error: $error');
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

  String _getiOSLanguageCode(String langCode) {
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
      final iosLang = _getiOSLanguageCode(_selectedLangCode);
      await _channel.invokeMethod('initialize', {'language': iosLang});
      await _channel.invokeMethod('startListening', {'language': iosLang});

      setState(() {
        _isRecording = true;
        _recognizedText = '';
        _partialText = '';
      });

      debugPrint('[iOS Speech] Started listening with language: $iosLang');
    } catch (e) {
      debugPrint('[iOS Speech] Start error: $e');
      setState(() => _error = '启动语音识别失败: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _channel.invokeMethod('stopListening');
      setState(() => _isRecording = false);
      debugPrint('[iOS Speech] Stopped listening');
    } catch (e) {
      debugPrint('[iOS Speech] Stop error: $e');
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
                    Text(
                      'iOS 原生语音识别',
                      style: const TextStyle(
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