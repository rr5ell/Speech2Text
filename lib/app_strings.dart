// 界面文案：中 / 英 / 日 / 韩四语言 UI 字符串。
enum AppUiLanguage { zh, en, ja, ko }

class AppStrings {
  AppStrings(this.language);

  final AppUiLanguage language;

  String _t(String zh, String en, String ja, String ko) {
    switch (language) {
      case AppUiLanguage.zh:
        return zh;
      case AppUiLanguage.en:
        return en;
      case AppUiLanguage.ja:
        return ja;
      case AppUiLanguage.ko:
        return ko;
    }
  }

  bool get isZh => language == AppUiLanguage.zh;

  String get appTitle => 'Speed_to_Text';

  String get history => _t('历史记录', 'History', '履歴', '기록');

  String get uiLanguage => _t('界面语言', 'Language', '言語', '앱 언어');

  String get nativeSpeechTitle => _t(
        '系统原生语音识别',
        'System Speech Recognition',
        'システム音声認識',
        '시스템 음성 인식',
      );

  String get idleMicHint => _t(
        '点击麦克风开始识别',
        'Tap the mic to start',
        'マイクをタップして開始',
        '마이크를 눌러 시작',
      );

  String get unsupportedSpeech => _t(
        '当前设备不支持系统语音识别',
        'System speech recognition is not available on this device',
        'この端末ではシステム音声認識を利用できません',
        '현재 기기에서 시스템 음성 인식을 사용할 수 없습니다',
      );

  String startSpeechFailed(Object error) => _t(
        '启动语音识别失败: $error',
        'Failed to start speech recognition: $error',
        '音声認識の開始に失敗しました: $error',
        '음성 인식 시작 실패: $error',
      );

  String get langChinese => '中文';

  String get langEnglish => 'English';

  String get langJapanese => '日本語';

  String get langKorean => '한국어';

  String uiLanguageName(AppUiLanguage language) {
    switch (language) {
      case AppUiLanguage.zh:
        return langChinese;
      case AppUiLanguage.en:
        return langEnglish;
      case AppUiLanguage.ja:
        return langJapanese;
      case AppUiLanguage.ko:
        return langKorean;
    }
  }

  String recognitionLangName(String code) {
    switch (code) {
      case 'zh':
        return langChinese;
      case 'en':
        return langEnglish;
      case 'ja':
        return langJapanese;
      case 'ko':
        return langKorean;
      default:
        return code;
    }
  }

  String get longPressHint => _t(
        '长按麦克风按钮说话，松开结束',
        'Hold mic button to speak, release to stop',
        'マイクボタンを長押しして話し、離すと終了',
        '마이크 버튼을 길게 눌러 말하고, 놓으면 종료',
      );

  String get copy => _t('复制', 'Copy', 'コピー', '복사');

  String get clear => _t('清除', 'Clear', 'クリア', '지우기');

  String get copied => _t('已复制', 'Copied', 'コピーしました', '복사됨');

  String get tapMicHint => _t(
        '点击麦克风按钮开始语音识别',
        'Tap mic button to start speech recognition',
        'マイクボタンをタップして開始',
        '마이크 버튼을 눌러 시작',
      );

  String get longPressSnack => _t(
        '长按按钮说话，松开结束',
        'Hold to speak, release to stop',
        '長押しで話し、離すと終了',
        '버튼을 길게 눌러 말하고, 놓으면 종료',
      );

  String get copiedToClipboard => _t('已复制到剪贴板', 'Copied to clipboard', 'クリップボードにコピーしました', '클립보드에 복사됨');

  String get noHistory => _t('暂无历史记录', 'No history', '履歴なし', '기록 없음');

  String get clearHistory => _t('清空', 'Clear all', 'すべて削除', '전체 삭제');

  String get listening => _t('正在聆听...', 'Listening...', '聞いています...', '듣는 중...');

  String get micPermission => _t(
        '需要麦克风权限才能进行语音识别',
        'Microphone permission is required for speech recognition',
        '音声認識にはマイクの許可が必要です',
        '음성 인식을 위해 마이크 권한이 필요합니다',
      );

  String get uiLanguageLabel {
    switch (language) {
      case AppUiLanguage.zh:
        return '中文';
      case AppUiLanguage.en:
        return 'EN';
      case AppUiLanguage.ja:
        return '日本語';
      case AppUiLanguage.ko:
        return '한국어';
    }
  }
}
