# ios-native-speech-method-channel

## Metadata

- status: active
- tech: iOS, Swift, Flutter
- tags: ios, speech-recognition, method-channel, scene-delegate
- canonical_code_paths:
  - `E:\StudioProjects\Speech2Text\ios\Runner\SceneDelegate.swift`
  - `E:\StudioProjects\Speech2Text\ios\Runner\IOSSpeechRecognition.swift`
  - `E:\StudioProjects\Speech2Text\lib\home_screen.dart`
- related_docs:
  - `E:\StudioProjects\Speech2Text\docs\code-library\INDEX.md`
- last_updated: 2026-07-07
- author: Codex Agent

## 适用场景

- Flutter iOS App 使用 Scene 生命周期。
- Dart 侧通过 `MethodChannel('ios_speech_recognition')` 调用 iOS 原生 Speech Framework。
- 需要解决 `MissingPluginException(No implementation found for method initialize on channel ios_speech_recognition)`。

## 禁止场景

- 不要在 Android、Web、Windows 平台复用该 Swift 实现。
- 不要在 iOS Scene 生命周期下依赖 `AppDelegate.window?.rootViewController` 注册通道。

## 核心参数

| 参数名 | 类型 | 默认值 | 说明 | 边界条件 |
| --- | --- | --- | --- | --- |
| channelName | String | `ios_speech_recognition` | Dart 和 iOS 原生通信通道名 | 两端必须完全一致 |
| language | String | `zh-CN` | iOS `Locale` 识别语言 | 必须是 `SFSpeechRecognizer` 支持的 locale |
| bufferSize | AVAudioFrameCount | `1024` | `inputNode.installTap` 音频缓冲大小 | 重复安装 tap 前必须先移除旧 tap |

## 复用方式

- 在 `SceneDelegate.scene(_:willConnectTo:options:)` 中获取 `FlutterViewController`。
- 使用 `controller.binaryMessenger` 注册 `IOSSpeechRecognitionPlugin`。
- Dart 侧固定调用 `initialize`、`startListening`、`stopListening`。

## 注意事项

- `Info.plist` 必须包含 `NSSpeechRecognitionUsageDescription` 和 `NSMicrophoneUsageDescription`。
- 开始识别前先清理旧 `AVAudioEngine`、`SFSpeechRecognitionTask` 和 input tap。
- 原生回调 Flutter MethodChannel 时回到主线程，避免 UI 状态更新时机不一致。

## 测试与验证

- 测试命令：`flutter analyze`
- iOS 编译验证：在 macOS 上运行 `flutter run -d <ios-device-id>`
- 已覆盖边界：Scene 生命周期 MethodChannel 注册、重复开始识别前清理旧音频任务。
- 未覆盖风险：当前 Windows 环境不能本地编译 iOS Swift。

## 给 AI 的指令

优先复用本条目的 SceneDelegate 注册方式。除非哥哥明确要求重构，否则不要退回到 `AppDelegate.window?.rootViewController` 注册 MethodChannel。
