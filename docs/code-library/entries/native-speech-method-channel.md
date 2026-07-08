# native-speech-method-channel

## Metadata

- status: active
- tech: iOS, Android, Swift, Kotlin, Flutter
- tags: ios, android, speech-recognition, method-channel, scene-delegate
- canonical_code_paths:
  - `E:\StudioProjects\Speech2Text\ios\Runner\SceneDelegate.swift`
  - `E:\StudioProjects\Speech2Text\ios\Runner\IOSSpeechRecognition.swift`
  - `E:\StudioProjects\Speech2Text\android\app\src\main\kotlin\com\vosk\stt\speech_to_text_vosk\MainActivity.kt`
  - `E:\StudioProjects\Speech2Text\lib\home_screen.dart`
- related_docs:
  - `E:\StudioProjects\Speech2Text\docs\code-library\INDEX.md`
- last_updated: 2026-07-08
- author: Codex Agent

## 适用场景

- Flutter App 需要同时接 iOS 和 Android 系统原生语音识别。
- Dart 侧通过 `MethodChannel('native_speech_recognition')` 调用平台能力。
- iOS 不接第三方语音 SDK，使用 Apple Speech Framework。
- Android 不接阿里引擎，使用系统 `android.speech.SpeechRecognizer`。

## 禁止场景

- 不要在 Android 设备没有系统语音服务时假定识别一定可用。
- 不要在 iOS Scene 生命周期下依赖 `AppDelegate.window?.rootViewController` 注册通道。
- 不要把已删除的第三方语音引擎重新接回主链路。

## 核心参数

| 参数名 | 类型 | 默认值 | 说明 | 边界条件 |
| --- | --- | --- | --- | --- |
| channelName | String | `native_speech_recognition` | Dart 和平台原生通信通道名 | iOS、Android、Dart 三端必须一致 |
| language | String | `zh-CN` | 平台识别语言 | iOS 使用 `Locale`，Android 传给 `RecognizerIntent.EXTRA_LANGUAGE` |
| androidLanguageModel | String | `LANGUAGE_MODEL_FREE_FORM` | Android 自由说话模式 | 适合短命令和自然语言 |
| iosBufferSize | AVAudioFrameCount | `1024` | iOS input tap 音频缓冲大小 | 重复安装 tap 前必须先移除旧 tap |

## 复用方式

- Dart 侧固定调用 `initialize`、`startListening`、`stopListening`。
- iOS 在 `SceneDelegate.scene(_:willConnectTo:options:)` 中注册 `IOSSpeechRecognitionPlugin`。
- Android 在 `MainActivity.configureFlutterEngine()` 中注册 MethodChannel。
- 原生侧通过 `onRecognitionPartial` 返回中间结果，通过 `onRecognitionResult` 返回最终结果。
- Flutter 收到最终结果或错误后必须同步结束录音 UI 状态。
- Android/iOS 原生侧在最终结果或错误后清理当前识别会话，下一次识别重新创建会话。
- iOS Speech Framework 可能在 stop 后派发迟到回调，必须用 session id 或 listening flag 丢弃旧会话结果。
- 开始新一轮命令识别时不要清空上次最终结果，只清理 partial 文本。
- 最终识别结果应写入 `HistoryManager`，历史入口不能只保留 UI 按钮。
- partial 文本也要执行热词格式化，但 iOS 只能作为实时预览；不要因为 iOS partial 命中 `ok_` 命令就立即停止监听，避免短词抢先截断完整说话内容。
- Android 和 iOS 的 partial 处理需要分流，Android 不应被 iOS 的连续识别补丁改变原有可用节奏。
- iOS partial 必须有稳定超时兜底，当前为 1.2 秒；超过该时间没有新 partial 时，Flutter 接受当前 partial 并调用 `stopListening`。
- iOS `stopListening()` 必须同时停止 `AVAudioEngine`、结束 recognition request、取消 task，并将 `AVAudioSession` 置为 inactive。
- 结果区需要同时展示已有最终结果和当前 iOS partial，避免历史结果遮挡新一轮未命中的识别文本。
- 热词表以 `feature/korean-hotwords` 中的完整词表为准，合并平台原生识别改动时不得回退成简化词表。
- 中文热词匹配必须先判断测距类 `_chineseDistanceKeywords`，再判断扫描类 `_chineseScanKeywords`，避免同时出现“测距/扫描”时被扫描抢先命中。

## 注意事项

- iOS `Info.plist` 必须包含 `NSSpeechRecognitionUsageDescription` 和 `NSMicrophoneUsageDescription`。
- Android `AndroidManifest.xml` 必须包含 `RECORD_AUDIO`。
- Android 11+ 需要在 `<queries>` 中声明 `android.speech.RecognitionService`。
- Android 系统 `SpeechRecognizer` 是否可用取决于设备系统语音服务，部分设备可能不可用或依赖联网服务。
- 命令识别场景默认一次识别结束即停止录音状态；如需连续听写，应显式实现分轮重启和错误节流。

## 测试与验证

- 测试命令：`flutter analyze --no-pub`
- 测试命令：`flutter test --no-pub`
- Android 编译命令：`flutter build apk --debug`
- iOS 编译验证：在 macOS 上运行 `flutter run -d <ios-device-id>`
- 未覆盖风险：当前 Windows 环境不能本地编译 iOS Swift。

## 给 AI 的指令

优先复用本条目的系统原生语音识别通道。除非哥哥明确要求，否则不要重新引入阿里语音引擎或其他第三方语音 SDK。
