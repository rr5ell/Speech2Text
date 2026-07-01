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

### 解决方案
- 修复方法：将较长的新增触发词放在短词之前，减少被短词抢先命中的风险。
- 修复方法：将 widget 测试断言同步为当前首页标题。
- 修复方法：按用户提供的纯文本词表修正新增韩语触发词。
- 修复方法：当前项目切换到阿里云 Gradle 镜像的 `gradle-8.3-bin.zip`，并将用户级 `GRADLE_USER_HOME` 指向 `E:\Android\.gradle`。
- 验证步骤：运行静态分析、Flutter 测试，并人工检查新增词表顺序。
- 验证步骤：执行 `gradlew --version`，确认 Gradle 8.3 下载并解压到 `E:\Android\.gradle\wrapper\dists`。

### 预防措施
- 后续新增韩语热词时，优先添加完整词组；必须添加单字词时，先评估是否会覆盖其他命令。
- UI 标题或文案变更时，同步更新对应 widget 测试断言。
- 新开 Flutter 项目前确认 IDE 已重启并继承用户级 `GRADLE_USER_HOME`。
