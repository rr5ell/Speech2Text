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

## 关键配置

- `ios/Runner/Info.plist` 配置 `NSSpeechRecognitionUsageDescription`。
- `ios/Runner/Info.plist` 配置 `NSMicrophoneUsageDescription`。
- `ios/Runner/Info.plist` 的 `UISceneDelegateClassName` 指向 `$(PRODUCT_MODULE_NAME).SceneDelegate`。

## 最后更新

2026-07-07，Codex Agent。
