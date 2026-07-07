# Speech2Text 复用规则

## iOS 语音识别通道

- 优先复用 `ios/Runner/SceneDelegate.swift` 和 `ios/Runner/IOSSpeechRecognition.swift` 的 MethodChannel 注册方式。
- 不要把通道注册绑定到 `AppDelegate.window?.rootViewController`，Scene 生命周期下该对象可能为空。
- 不要在 Dart 侧重复创建不同 channel name；固定使用 `ios_speech_recognition`。
- 不要在一次识别未结束时重复安装 `AVAudioEngine.inputNode` tap。
- 修改识别语言映射时同步检查 `lib/home_screen.dart` 的 `_getiOSLanguageCode()`。

## 禁止事项

- 不要把已删除的第三方语音引擎逻辑重新接回主识别链路。
- 不要在没有 Info.plist 权限声明的情况下调用 iOS Speech 或麦克风能力。
- 不要忽略 `MissingPluginException`；它表示原生 MethodChannel 没有完成注册。

## 最后更新

2026-07-07，Codex Agent。
