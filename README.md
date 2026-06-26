# Speech to Text

基于 Flutter 的**离线语音转文字**应用，使用 [Sherpa-ONNX](https://github.com/k2-fsa/sherpa-onnx) **SenseVoice INT8** 模型，支持中文、英文、日语、韩语识别。

> 更详细的架构说明见 [项目概述.md](./项目概述.md)

## 功能特性

- 完全离线识别，无需云端 API，保护隐私
- 识别语言：中文 / English / 日本語 / 한국어（按所选语言加载 SenseVoice）
- 界面语言：中 / 英 / 日 / 韩四语切换
- 首次启动按需下载模型（约 157 MB），安装包体积小
- Silero VAD 语音分段，支持长按说话、分段出字
- 领域热词后处理：识别结果匹配触发词后输出标准化指令（如 `ok_测距`）
- 识别历史本地保存，支持复制、清除与单条删除

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter（Dart SDK ^3.5.0） |
| 识别引擎 | `sherpa_onnx` + SenseVoice INT8 |
| 语音检测 | Silero VAD |
| 录音 | `record`（16 kHz PCM 流式） |
| 模型下载 | `dio` + `archive` |
| 权限 | `permission_handler` |

## 环境要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install)（Dart ^3.5.0）
- Android 开发：Android SDK 35、JDK 17、minSdk 24
- Release 构建仅包含 **arm64-v8a** 架构
- 首次下载模型需要网络连接

## 快速开始

```bash
# 克隆项目
git clone <repository-url>
cd Speech_to_Text_flutter

# 安装依赖
flutter pub get

# 连接设备或启动模拟器后运行
flutter run
```

## 构建 Release APK

```bash
flutter build apk --release
```

产物路径：`build/app/outputs/flutter-apk/app-release.apk`

## 使用说明

1. **首次启动**：应用检测本地模型，缺失时自动从 GitHub Releases 下载 SenseVoice 与 VAD 模型。
2. **切换界面语言**：点击 AppBar 右上角语言按钮（中 / EN / 日本語 / 한국어）。
3. **选择识别语言**：在顶部语言栏选择本次识别使用的语言。
4. **开始录音**：模型就绪后，**长按**麦克风按钮（约 150 ms）开始识别，**松手**结束；短按会提示需长按。
5. **查看历史**：点击历史图标，可查看、复制、删除或清空记录。

## 项目结构

```
lib/
├── main.dart              # 应用入口、主题、HTTP 超时
├── home_screen.dart       # 主界面、录音、识别引擎、热词匹配
├── model_manager.dart     # 模型下载与管理
├── app_strings.dart       # 四语言 UI 文案
├── app_locale_scope.dart  # UI 语言上下文
├── history_manager.dart   # 历史记录持久化
├── history_record.dart    # 历史记录模型
└── language.dart          # 语言枚举（备用）
```

## 权限说明

| 权限 | 用途 |
|------|------|
| `RECORD_AUDIO` | 麦克风录音 |
| `INTERNET` | 首次下载 ASR 模型 |

## 本地数据

| 路径 | 说明 |
|------|------|
| `{应用文档目录}/sherpa_models/` | SenseVoice 与 VAD 模型文件 |
| `{应用文档目录}/history.json` | 识别历史（最多 100 条） |

## 平台支持

| 平台 | 状态 |
|------|------|
| Android | 主要支持（minSdk 24，arm64-v8a） |
| Windows | 目录已包含，当前以 Android 为主 |

## 相关文档

| 文档 | 说明 |
|------|------|
| [项目概述.md](./项目概述.md) | 架构、模块与识别流程 |
| [关于VAD.md](./关于VAD.md) | VAD 原理与参数 |
| [热词增加.md](./热词增加.md) | 热词触发词表与扩展方法 |
| [关于是否可以商用&怎么用.md](./关于是否可以商用&怎么用.md) | 商用许可与上架建议 |
| [知识点.md](./知识点.md) | Sherpa-ONNX 概念说明 |
| [手机压力测试.md](./手机压力测试.md) | 设备内存与模型上限实测 |

## 相关链接

- [Sherpa-ONNX](https://github.com/k2-fsa/sherpa-onnx)
- [SenseVoice 模型](https://github.com/k2-fsa/sherpa-onnx/releases/tag/asr-models)

## License

未指定开源协议，使用前请自行确认。
