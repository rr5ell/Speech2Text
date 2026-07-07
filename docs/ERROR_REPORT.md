# 错误报告

## [2026-07-01] 错误报告

### 发现的问题
- 问题描述：新增韩语短触发词中包含 `주`、`죽` 等单音节词，可能提高误触发概率。
- 影响范围：韩语识别后处理 `_koreanOkKeywordOutputs` 的 `contains` 匹配逻辑。
- 严重程度：中。
- 问题描述：`test/widget_test.dart` 仍断言旧标题 `Speech_to_Text`，与当前 `AppStrings.appTitle` 的 `Speed_to_Text` 不一致。
- 影响范围：自动化测试。
- 严重程度：低。
- 问题描述：从截图读取韩语词时存在 OCR/人工转写误差，导致部分新增词与用户实际词表不一致。
- 影响范围：韩语热词后处理。
- 严重程度：中。
- 问题描述：Gradle Wrapper 默认从 `services.gradle.org` 下载 `gradle-8.3-all.zip`，在当前网络环境下容易卡住；默认缓存路径也可能落到系统盘用户目录。
- 影响范围：首次打开或构建 Flutter/Android 项目。
- 严重程度：中。
- 问题描述：Android Gradle Plugin `8.1.0` 在 Java 21 环境下触发已知 `JdkImageTransform` 问题，表现为 `ModuleTarget is malformed: platformString missing delimiter: android`。
- 影响范围：Android Debug/Release 构建，尤其是依赖 `path_provider_android` 等插件编译阶段。
- 严重程度：高。
- 问题描述：旧版 `permission_handler_android 10.3.6` 引用 Flutter v1 `PluginRegistry.Registrar`，当前 Flutter SDK 中该接口不可用。
- 影响范围：`:permission_handler_android:compileDebugJavaWithJavac`。
- 严重程度：高。
- 问题描述：Kotlin 增量编译在 C 盘 Pub Cache 与 E 盘项目之间计算相对路径失败，报 `this and base files have different roots`。
- 影响范围：`:record_android:compileDebugKotlin` 等 Kotlin 插件编译任务。
- 严重程度：中。
- 问题描述：iOS 删除第三方语音引擎后改用原生 MethodChannel，但通道注册依赖 `AppDelegate.window?.rootViewController` 和隐式引擎回调；Scene 生命周期下该时机不稳定，Dart 调 `initialize` 时原生端未注册，报 `MissingPluginException(No implementation found for method initialize on channel ios_speech_recognition)`。
- 影响范围：iOS 真机/模拟器启动语音识别。
- 严重程度：高。
- 问题描述：多次启动 iOS 原生识别时，如果旧 `AVAudioEngine` input tap 未正确释放，可能触发重复安装 tap 或音频引擎异常。
- 影响范围：iOS 连续开始/停止语音识别。
- 严重程度：中。

### 解决方案
- 修复方法：将较长的新增触发词放在短词之前，减少被短词抢先命中的风险。
- 修复方法：将 widget 测试断言同步为当前首页标题。
- 修复方法：按用户提供的纯文本词表修正新增韩语触发词。
- 修复方法：当前项目切换到阿里云 Gradle 镜像的 `gradle-8.3-bin.zip`，并将用户级 `GRADLE_USER_HOME` 指向 `E:\Android\.gradle`。
- 修复方法：升级 Android Gradle Plugin 到 `8.2.2`。
- 修复方法：升级 `permission_handler` 到 `^12.0.3`。
- 修复方法：在 `android/gradle.properties` 中设置 `kotlin.incremental=false`。
- 修复方法：新增 `SceneDelegate.swift`，在 `FlutterViewController` 创建完成后用 `controller.binaryMessenger` 注册 `ios_speech_recognition`。
- 修复方法：恢复 `AppDelegate` 的标准 `GeneratedPluginRegistrant.register(with: self)`，移除不稳定的 `window?.rootViewController` 通道注册。
- 修复方法：在 iOS 原生识别开始前调用 `stopListening()` 清理旧任务，并用 `isInputTapInstalled` 防止无状态移除或重复安装 input tap。
- 修复方法：将 `test/widget_test.dart` 的导入从旧包名改为当前 `speech_to_text_ios_native`，并清理 Dart 静态分析告警。
- 验证步骤：运行静态分析、Flutter 测试，并人工检查新增词表顺序。
- 验证步骤：执行 `gradlew --version`，确认 Gradle 8.3 下载并解压到 `E:\Android\.gradle\wrapper\dists`。

### 预防措施
- 后续新增韩语热词时，优先添加完整词组；必须添加单字词时，先评估是否会覆盖其他命令。
- UI 标题或文案变更时，同步更新对应 widget 测试断言。
- 新开 Flutter 项目前确认 IDE 已重启并继承用户级 `GRADLE_USER_HOME`。
