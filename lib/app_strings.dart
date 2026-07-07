// 界面文案：中 / 英 / 日 / 韩四语言 UI 字符串与模型名称。
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

  String get langChinese => '中文';

  String get langEnglish => 'English';

  String get langJapanese => '日本語';

  String get langKorean => '한국어';

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

  String get loadingModel => _t('正在加载模型...', 'Loading model...', 'モデル読み込み中...', '모델 로딩 중...');

  String modelReady(String langName) => _t(
        '模型已就绪 · $langName',
        'Model ready · $langName',
        'モデル準備完了 · $langName',
        '모델 준비 완료 · $langName',
      );

  String needDownload(int sizeMb) => _t(
        '~$sizeMb MB · 需要下载',
        '~$sizeMb MB · Download required',
        '~$sizeMb MB · ダウンロード必要',
        '~$sizeMb MB · 다운로드 필요',
      );

  String get download => _t('下载', 'Download', 'ダウンロード', '다운로드');

  String get prepDownload => _t('准备下载...', 'Preparing download...', 'ダウンロード準備中...', '다운로드 준비 중...');

  String get longPressHint => _t(
        '长按麦克风按钮说话，松开结束',
        'Hold mic button to speak, release to stop',
        'マイクボタンを長押しして話し、離すと終了',
        '마이크 버튼을 길게 눌러 말하고, 놓으면 종료',
      );

  String get downloadModelFirst => _t(
        '请先下载语音模型',
        'Please download the speech model first',
        '先に音声モデルをダウンロードしてください',
        '먼저 음성 모델을 다운로드하세요',
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

  String downloadFailed(Object error) => _t(
        '下载失败: $error',
        'Download failed: $error',
        'ダウンロード失敗: $error',
        '다운로드 실패: $error',
      );

  String modelLoadFailed(Object error) => _t(
        '模型加载失败: $error',
        'Model load failed: $error',
        'モデルの読み込みに失敗: $error',
        '모델 로드 실패: $error',
      );

  String get micPermission => _t(
        '需要麦克风权限才能进行语音识别',
        'Microphone permission is required for speech recognition',
        '音声認識にはマイクの許可が必要です',
        '음성 인식을 위해 마이크 권한이 필요합니다',
      );

  String audioStreamError(Object error) => _t('音频流错误: $error', 'Audio stream error: $error', 'オーディオストリームエラー: $error', '오디오 스트림 오류: $error');

  String recordStartFailed(Object error) => _t('启动录音失败: $error', 'Failed to start recording: $error', '録音開始に失敗: $error', '녹음 시작 실패: $error');

  String get allModelsReady => _t('所有模型已就绪', 'All models ready', 'すべてのモデル準備完了', '모든 모델 준비 완료');

  String get connectingServer => _t('正在连接服务器...', 'Connecting to server...', 'サーバーに接続中...', '서버 연결 중...');

  String get cleaning => _t('正在清理...', 'Cleaning up...', 'クリーンアップ中...', '정리 중...');

  String extractFailed(Object error) => _t('解压失败: $error', 'Extraction failed: $error', '展開失敗: $error', '압축 해제 실패: $error');

  String get downloadVadModel => _t('正在下载 VAD 模型...', 'Downloading VAD model...', 'VAD モデルダウンロード中...', 'VAD 모델 다운로드 중...');

  String downloadVadProgress(String mb) => _t('下载 VAD 模型 $mb MB', 'Downloading VAD model $mb MB', 'VAD モデルダウンロード $mb MB', 'VAD 모델 다운로드 $mb MB');

  String downloadSenseVoiceProgress(String mb, String totalMb) => _t(
        '下载 SenseVoice $mb / $totalMb MB',
        'Downloading SenseVoice $mb / $totalMb MB',
        'SenseVoice ダウンロード $mb / $totalMb MB',
        'SenseVoice 다운로드 $mb / $totalMb MB',
      );

  String downloadSenseVoiceIndeterminate(String mb) => _t(
        '下载 SenseVoice $mb MB...',
        'Downloading SenseVoice $mb MB...',
        'SenseVoice ダウンロード $mb MB...',
        'SenseVoice 다운로드 $mb MB...',
      );

  String get extractingSenseVoice => _t('正在解压 SenseVoice 模型...', 'Extracting SenseVoice model...', 'SenseVoice モデル展開中...', 'SenseVoice 모델 압축 해제 중...');

  String get senseVoiceIncomplete => _t(
        'SenseVoice 模型文件不完整，请重试',
        'SenseVoice model is incomplete, please retry',
        'SenseVoice モデルが不完全です。再試行してください',
        'SenseVoice 모델 파일이 불완전합니다. 다시 시도하세요',
      );

  String get senseVoiceReady => _t('SenseVoice 模型就绪', 'SenseVoice model ready', 'SenseVoice モデル準備完了', 'SenseVoice 모델 준비 완료');

  String downloadModelProgress(String name, String mb, String totalMb) => _t(
        '下载 $name $mb / $totalMb MB',
        'Downloading $name $mb / $totalMb MB',
        '$name ダウンロード $mb / $totalMb MB',
        '$name 다운로드 $mb / $totalMb MB',
      );

  String downloadModelIndeterminate(String name, String mb) => _t(
        '下载 $name $mb MB...',
        'Downloading $name $mb MB...',
        '$name ダウンロード $mb MB...',
        '$name 다운로드 $mb MB...',
      );

  String extractingModel(String name) => _t('正在解压 $name 模型...', 'Extracting $name model...', '$name モデル展開中...', '$name 모델 압축 해제 중...');

  String modelIncomplete(String name) => _t(
        '$name 模型文件不完整，请重试',
        '$name model is incomplete, please retry',
        '$name モデルが不完全です。再試行してください',
        '$name 모델 파일이 불완전합니다. 다시 시도하세요',
      );

  String modelReadyStatus(String name) => _t('$name 模型就绪', '$name model ready', '$name モデル準備完了', '$name 모델 준비 완료');

  String get connectionTimeout => _t(
        '连接超时，请检查网络后重试',
        'Connection timed out, please check your network',
        '接続タイムアウト。ネットワークを確認してください',
        '연결 시간 초과. 네트워크를 확인 후 다시 시도하세요',
      );

  String get downloadTimeout => _t(
        '下载超时，请检查网络后重试',
        'Download timed out, please check your network',
        'ダウンロードタイムアウト。ネットワークを確認してください',
        '다운로드 시간 초과. 네트워크를 확인 후 다시 시도하세요',
      );

  String cannotConnectServer(String message) => _t(
        '无法连接服务器: $message',
        'Cannot connect to server: $message',
        'サーバーに接続できません: $message',
        '서버에 연결할 수 없습니다: $message',
      );

  String get networkRequestFailed => _t('网络请求失败', 'Network request failed', 'ネットワークリクエスト失敗', '네트워크 요청 실패');

  String modelDisplayName(String langCode) {
    return _t('SenseVoice 阿里-量化版', 'SenseVoice Alibaba INT8', 'SenseVoice Alibaba INT8', 'SenseVoice 알리 양자화');
  }

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
