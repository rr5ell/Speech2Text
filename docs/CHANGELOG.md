# 修改日志

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
