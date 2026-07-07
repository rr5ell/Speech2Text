# Speech2Text 代码资产索引

本目录记录当前分支中可复用、可交接的稳定实现。

## 项目信息

| 字段 | 内容 |
| --- | --- |
| project_id | `speech2text` |
| 项目根目录 | `E:\StudioProjects\Speech2Text` |
| 当前分支 | `feature/ios-native-only` |
| 应用类型 | Flutter + iOS 原生语音识别 |

## 可复用能力

| reuse_id | 能力 | 标签 | canonical code path | 说明 | 状态 |
| --- | --- | --- | --- | --- | --- |
| ios-native-speech-method-channel | iOS Speech Framework 原生识别通道 | ios, swift, flutter, method-channel, speech-recognition | `ios/Runner/SceneDelegate.swift`; `ios/Runner/IOSSpeechRecognition.swift`; `lib/home_screen.dart` | 在 Scene 生命周期中获取 `FlutterViewController` 并注册 `ios_speech_recognition`，Dart 侧通过 MethodChannel 调用 `initialize`、`startListening`、`stopListening`。 | active |

## 复用约束

- iOS 使用 Scene 生命周期时，不要依赖 `AppDelegate.window?.rootViewController` 注册 MethodChannel。
- `ios_speech_recognition` 必须在 `SceneDelegate.scene(_:willConnectTo:options:)` 中基于当前 `FlutterViewController.binaryMessenger` 注册。
- `NSSpeechRecognitionUsageDescription` 和 `NSMicrophoneUsageDescription` 必须存在于 `ios/Runner/Info.plist`。
- 开始新识别前要先停止旧的 `AVAudioEngine`、`SFSpeechRecognitionTask` 和 input tap，避免重复安装 tap。

## 验证命令

```powershell
flutter analyze
```

iOS 编译和真机运行需要在 macOS/Xcode 环境执行。

## 最后更新

2026-07-07，Codex Agent。
