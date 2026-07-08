# Speech2Text 技术栈

## 当前分支

`feature/ios-native-only`

## Flutter 依赖

| 依赖 | 用途 |
| --- | --- |
| `permission_handler` | Dart 侧麦克风权限申请 |
| `path_provider` | 本地路径能力 |
| `path` | 路径处理 |

## iOS 原生能力

| 框架 | 用途 |
| --- | --- |
| `Speech` | `SFSpeechRecognizer` 实时语音识别 |
| `AVFoundation` | `AVAudioEngine` 麦克风采集 |
| `Flutter` | `FlutterMethodChannel` 与 Dart 通信 |

## Android 原生能力

| 框架 | 用途 |
| --- | --- |
| `android.speech.SpeechRecognizer` | Android 系统语音识别 |
| `RecognizerIntent` | 配置识别语言、自由说话模式、部分结果 |
| `MethodChannel` | 与 Dart 通信 |

## 关键配置

- `ios/Runner/Info.plist` 配置 `NSSpeechRecognitionUsageDescription`。
- `ios/Runner/Info.plist` 配置 `NSMicrophoneUsageDescription`。
- `ios/Runner/Info.plist` 的 `UISceneDelegateClassName` 指向 `$(PRODUCT_MODULE_NAME).SceneDelegate`。
- `android/app/src/main/AndroidManifest.xml` 配置 `RECORD_AUDIO`。
- Android 11+ 需要在 `<queries>` 中声明 `android.speech.RecognitionService`，否则系统语音服务查询可能不可见。

## 最后更新

2026-07-07，Codex Agent。
