## [2026-07-07] 自动提交

- aa4d663 - docs: 更新文档 (2026-07-07 10:51:34 +0800)
- 作者: Claude Agent

## [2026-07-07] 自动提交

- 6a62e5b - docs: 更新文档 (2026-07-07 10:48:05 +0800)
- 作者: Claude Agent

## [2026-07-07] 自动提交

- f4e60d1 - docs: 更新文档 (2026-07-07 10:47:45 +0800)
- 作者: Claude Agent

## [2026-07-07] 自动提交

- d130fe9 - docs: 更新文档 (2026-07-07 10:42:57 +0800)
- 作者: Claude Agent

## [2026-07-07] 自动提交

- 17f088f - docs: 更新文档 (2026-07-07 10:42:49 +0800)
- 作者: Claude Agent

## [2026-07-07] 自动提交

- 3df1f81 - docs: 更新文档 (2026-07-07 10:42:21 +0800)
- 作者: Claude Agent

## [2026-07-07] 自动提交

- f07e10d - docs: 更新文档 (2026-07-07 10:27:45 +0800)
- 作者: Claude Agent

## [2026-07-07] 自动提交

- 8fdb014 - docs: 更新文档 (2026-07-07 10:19:29 +0800)
- 作者: Claude Agent

# 修改日志

## [2026-07-08] Codex Agent

### Fixed
- 修复蒲公英上传脚本：APK 的 `buildType` 改为 `android`，COS 上传使用 `curl --form-string` 传递签名字段，避免分号被解析导致上传失败。
- 调整中文、韩语、日语热词变体：补充中文扫描短词，修正韩语 `개` 归类到 pin catcher，补充韩语/日语常见误识别词，并移除一条英文误触发词。
- 修复 iOS 只依赖 `SFSpeechRecognizer` final 结果才关闭麦克风的问题，partial 文本稳定 1.2 秒后会自动保存并停止本轮监听。
- 修复 iOS `stopListening()` 只停止 `AVAudioEngine` 但未释放 `AVAudioSession` 的问题，停止时会将音频会话置为 inactive。
- 修复 iOS partial 热词命中后立即停止监听导致只能识别一个短词的问题；iOS partial 现在只作为实时预览，最终结果或手动停止时再保存。
- 修复 iOS 已有历史结果时新的 partial 文本被结果区隐藏的问题，未命中热词的中间文本也会显示并在停止时保留。
- 修复 partial 识别文本已经命中热词时仍只原样显示的问题，现在如“测”会实时预览为 `测 → ok_测距`。
- 修复中文识别文本同时包含“测距”和“扫描”时，扫描热词先命中导致无法输出 `ok_测距` 的问题。
- 修复 iOS 调用 stop 后仍可能收到 Speech Framework 迟到 partial 回调，导致 UI 显示停止后继续变化的问题。
- 从 `feature/korean-hotwords` 恢复完整热词表，避免 iOS/Android 原生识别分支误用简化热词。
- 恢复历史记录入口，识别最终结果会写入本地历史，历史按钮可弹出列表并支持恢复、复制、删除、清空。
- 修复点击麦克风开始新一轮识别时清空上次最终结果的问题。
- 将识别结果区改为固定占位布局，避免识别命中后内容或操作按钮变化导致文本框尺寸变化。
- 修复原生语音识别命中、错误或无有效结果后，Flutter UI 仍显示录音中的问题。
- 固定结果操作区高度，避免识别命中后“复制/清除”按钮出现导致结果文本框尺寸变化。
- 修复 partial 识别结果存在时结果区域显示空白的问题。
- Android/iOS 原生识别在最终结果或错误后主动清理当前识别会话，避免后续无法重新识别。

## [2026-07-08] Codex Agent

### Added
- 新增 Android 系统原生 `SpeechRecognizer` 语音识别实现，通过 `native_speech_recognition` MethodChannel 与 Flutter 通信。
- Android 原生识别支持 `initialize`、`startListening`、`stopListening`，并通过 `onRecognitionPartial` / `onRecognitionResult` 回传中间和最终识别文本。
- Android Manifest 增加 `android.speech.RecognitionService` 查询声明，兼容 Android 11+ 包可见性限制。

### Changed
- 将 Flutter/iOS 通道名从 `ios_speech_recognition` 调整为平台中性的 `native_speech_recognition`。
- 首页文案从 `iOS 原生语音识别` 调整为 `系统原生语音识别`。
- 更新项目代码资产库，登记 iOS/Android 系统原生语音识别共用通道。

## [2026-07-07] Codex Agent

### Fixed
- 修复 iOS Scene 生命周期下 `ios_speech_recognition` MethodChannel 未稳定注册，导致 Dart 调用 `initialize` 抛出 `MissingPluginException` 的问题。
- 新增 `SceneDelegate.swift`，在 `FlutterViewController` 创建后注册 iOS 原生语音识别通道。
- 将 iOS 语音识别通道封装为 `IOSSpeechRecognitionPlugin`，并增加音频 input tap 的重复安装防护。
- 修正 widget test 的包名引用，并清理 `home_screen.dart` 中阻塞静态分析的无用 import/字段。

## [2026-07-01 09:41:47 +08:00] Codex Agent

### Changed
- 新增韩语 pin catcher/扫描类触发词，统一输出 `ok_핀캐쳐`。
- 新增韩语测距类触发词，统一输出 `ok_거리측정`。
- 同步更新 `docs/热词增加.md` 中的韩语热词说明。
- 修复 widget 测试中与当前 App 标题不一致的旧断言。
- 按用户提供的文本修正韩语热词 OCR 误读项。

## [2026-07-01 10:38:40 +08:00] Codex Agent

### Changed
- 将当前 Android Gradle Wrapper 下载源从 `services.gradle.org` 切换为阿里云 Gradle 镜像。
- 将当前项目 Gradle 发行包从 `gradle-8.3-all.zip` 改为更小的 `gradle-8.3-bin.zip`。
- 设置用户级 `GRADLE_USER_HOME=E:\Android\.gradle`，使 Gradle Wrapper 缓存落到 E 盘。

## [2026-07-01] Codex Agent

### Fixed
- 将 Android Gradle Plugin 从 `8.1.0` 升级到 `8.2.2`，规避 Java 21 下 `JdkImageTransform` / `jlink.exe` 构建失败。
- 升级 `permission_handler` 到 `^12.0.3`，修复旧版 Android 插件引用 Flutter v1 `Registrar` 导致的编译失败。
- 关闭 Kotlin 增量编译，规避 Pub Cache 与项目跨盘时 Kotlin 编译器 `different roots` 异常。
