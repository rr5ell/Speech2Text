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
