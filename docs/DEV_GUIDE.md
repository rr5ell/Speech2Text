# 离线语音识别与热词增强实现指南

## 概述

本文档介绍如何使用 Sherpa-ONNX SenseVoice 模型实现离线语音识别，并通过热词机制显著提高特定功能指令的识别准确率。

---

## 一、语音识别引擎实现

### 1.1 技术选型

**推荐方案**：Sherpa-ONNX + SenseVoice 模型

优势：
- 完全离线运行，无需网络
- 支持多语言（中文、英语、日语、韩语）
- 实时流式识别
- 模型体积小、速度快

### 1.2 模型下载

SenseVoice 多语言模型（推荐使用 int8 量化版本）：

```
https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2
```

**模型版本说明**：

| 版本 | 大小 | 说明 |
|------|------|------|
| int8 量化版 | **~155MB** | 推荐，体积小、速度快，精度几乎无损 |
| fp16 版本 | ~300MB | 半精度，速度稍慢 |
| fp32 版本 | ~600MB | 全精度，体积最大 |

解压后包含：
- `model.int8.onnx` - 模型文件（int8量化）
- `tokens.txt` - 词表文件

### 1.3 初始化识别器

**Flutter 实现**：

```dart
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

// 创建配置（SenseVoice 模型）
final config = sherpa.OfflineRecognizerConfig(
  featConfig: sherpa.FeatureConfig(
    sampleRate: 16000,
    featureDim: 80,
  ),
  modelConfig: sherpa.OfflineModelConfig(
    transducer: sherpa.OfflineTransducerModelConfig(
      encoder: '',
      decoder: '',
      joiner: '',
    ),
    paraformer: sherpa.OfflineParaformerModelConfig(
      model: '$modelPath/model.int8.onnx',  // int8量化模型
    ),
    tokens: '$modelPath/tokens.txt',
    numThreads: 4,          // 根据设备CPU调整
    provider: 'cpu',        // iOS可用 'coreml'
    modelType: 'sensevoice',
  ),
  decodingMethod: 'greedy_search',
);

// 创建识别器
final recognizer = sherpa.createOfflineRecognizer(config: config);
```

**关键参数**：
- `numThreads`: 识别线程数，影响识别速度
- `provider`: 推理后端，iOS 推荐 `coreml`，Android/Linux/Mac 用 `cpu`
- `model.int8.onnx`: int8 量化模型文件（约155MB）

### 1.4 音频录制配置

**必须满足**：
- 采样率：16000 Hz（与模型匹配）
- 声道：单声道（mono）
- 格式：Float32 或 WAV

```dart
import 'package:record/record.dart';

final config = RecordConfig(
  encoder: AudioEncoder.wav,
  sampleRate: 16000,    // 必须是16kHz
  numChannels: 1,       // 单声道
);

await audioRecorder.start(config);
```

### 1.5 实时识别流程

```dart
// 处理音频数据
void processAudio(Float32List samples) {
  // 1. 创建音频流
  final stream = recognizer.createStream();
  
  // 2. 输入音频
  stream.acceptWaveform(
    samples: samples,
    sampleRate: 16000,
  );
  
  // 3. 解码
  recognizer.decode(stream);
  
  // 4. 获取结果
  final result = recognizer.getResult(stream);
  final text = result.text;
  
  // 5. 销毁流（必须！避免内存泄漏）
  stream.destroy();
  
  // 6. 处理识别文本
  handleRecognitionResult(text);
}
```

---

## 二、热词机制 - 提高识别成功率的核心

### 2.1 为什么需要热词？

**问题**：语音识别在实际场景中存在多种干扰因素：

1. **发音偏差**
   - 用户说"测距"，可能被识别为："撤距"、"车具"、"这具"
   
2. **口音差异**
   - 不同地区用户发音不同
   
3. **同音词干扰**
   - "旗杆" → 可能识别为："气缸"、"七杠"、"乞缸"
   
4. **连读、吞音**
   - "扫描旗杆" → 可能识别为："扫旗杆"、"上描"、"扫"

**解决方案**：建立热词映射表，覆盖所有可能的识别变体。

### 2.2 热词映射表设计

**结构**：`Map<String, String>`

```dart
// Key: 可能被识别出的文本（包含所有变体）
// Value: 功能指令标识

const distanceKeywords = {
  // 标准发音
  '测距': 'ok_distance',
  
  // 发音偏差变体
  '撤距': 'ok_distance',    // "测"→"撤"
  '车具': 'ok_distance',    // 连读偏差
  '特去': 'ok_distance',    // 口音偏差
  '这具': 'ok_distance',
  
  // 单字/简化
  '测': 'ok_distance',
  '距': 'ok_distance',
  '撤': 'ok_distance',
  '据': 'ok_distance',
};
```

### 2.3 如何收集热词变体？

**方法一：测试收集**

1. 找不同用户反复说出目标词汇
2. 记录所有被识别出的文本
3. 添加到热词表

**方法二：分析发音相似词**

- 找出同音词：`旗杆` → `气缸`、`七杠`
- 找出近音词：`测距` → `撤距`、`车具`
- 找出简化/连读：`扫描旗杆` → `扫旗杆`、`上描`

**方法三：用户反馈收集**

- 上线后收集误识别案例
- 定期更新热词表

> **详细热词列表请参考**: [热词配置文档](HOTWORDS.md)

### 2.4 热词匹配实现

```dart
String matchKeyword(String recognizedText) {
  // 遍历热词表
  for (final entry in keywordMap.entries) {
    // 检查识别文本是否包含热词
    if (recognizedText.contains(entry.key)) {
      return entry.value;  // 返回功能指令
    }
  }
  
  // 未匹配，返回原始文本
  return recognizedText;
}
```

**使用示例**：

```dart
// 用户说的是"测距"，但识别为"撤距"
final text = "撤距";
final result = matchKeyword(text);
// result = "ok_distance"  ✓ 成功匹配！
```

### 2.5 多语言热词管理

如果支持多种语言，每种语言单独维护热词表：

```dart
// 中文
const chineseKeywords = {
  '扫描旗杆': 'ok_scan',
  '测距': 'ok_distance',
  ...
};

// 韩语
const koreanKeywords = {
  '거리측정': 'ok_distance',
  '핀캐쳐': 'ok_pin_catcher',
  ...
};

// 英语
const englishKeywords = {
  'measure': 'ok_distance',
  'catcher': 'ok_pin_catcher',
  ...
};

// 根据当前语言选择热词表
Map<String, String> getKeywordMap(String langCode) {
  switch (langCode) {
    case 'zh': return chineseKeywords;
    case 'ko': return koreanKeywords;
    case 'en': return englishKeywords;
    default: return {};
  }
}
```

---

## 三、完整识别流程

### 3.1 流程图

```
用户说话 → 麦克风录音 → 音频流(16kHz) → Sherpa识别器 → 识别文本
    ↓
热词匹配 → 功能指令 → 触发功能
```

### 3.2 代码实现

```dart
class SpeechRecognizer {
  sherpa.Recognizer? _recognizer;
  Map<String, String> _keywords = {};
  
  // 初始化
  Future<void> init(String modelPath, String langCode) async {
    // 1. 创建识别器
    final config = sherpa.SenseVoiceConfig(...);
    _recognizer = sherpa.createRecognizer(config: config);
    
    // 2. 加载热词表
    _keywords = getKeywordMap(langCode);
  }
  
  // 处理音频
  void processAudio(Float32List samples) {
    final stream = _recognizer!.createStream();
    stream.acceptWaveform(samples: samples, sampleRate: 16000);
    _recognizer!.decode(stream);
    
    final text = _recognizer!.getResult(stream).text;
    stream.destroy();
    
    // 热词匹配
    final matched = _matchKeyword(text);
    
    // 触发功能
    if (matched.startsWith('ok_')) {
      onKeywordDetected?.call(matched);
    }
  }
  
  // 热词匹配
  String _matchKeyword(String text) {
    for (final entry in _keywords.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }
    return text;
  }
  
  // 回调
  Function(String keyword)? onKeywordDetected;
}
```

### 3.3 功能触发

```dart
// 使用示例
final recognizer = SpeechRecognizer();
recognizer.onKeywordDetected = (keyword) {
  switch (keyword) {
    case 'ok_distance':
      startDistanceMeasurement();
      break;
    case 'ok_scan':
      startScanning();
      break;
    case 'ok_pin_catcher':
      startPinCatcher();
      break;
  }
};
```

---

## 四、提高识别成功率的技巧

### 4.1 热词覆盖度

**原则**：覆盖越广，识别率越高

- 每个核心功能至少准备 10-20 个变体
- 包含单字、词组、连读、口音变体
- 定期根据用户反馈更新

### 4.2 热词优先级

当多个功能的热词有重叠时，设置优先级：

```dart
String matchKeyword(String text) {
  // 优先级1：扫描
  for (final entry in scanKeywords.entries) {
    if (text.contains(entry.key)) return entry.value;
  }
  
  // 优先级2：测距
  for (final entry in distanceKeywords.entries) {
    if (text.contains(entry.key)) return entry.value;
  }
  
  // 优先级3：其他
  ...
}
```

### 4.3 模型参数优化

```dart
// 调整线程数（根据设备性能）
numThreads: 2,  // 低端设备
numThreads: 4,  // 中端设备
numThreads: 8,  // 高端设备

// 启用格式化（提高数字、日期识别）
useInverseTextNormalization: true,
```

### 4.4 录音环境优化

- 使用降噪算法（如果可能）
- 避免在嘈杂环境使用
- 麦克风距离适中（5-15cm）

---

## 五、常见问题

### Q1: 为什么说"测距"总是识别成"撤距"？

**原因**：语音模型在某些发音上存在偏差

**解决**：把"撤距"加入热词表，映射到 `ok_distance`

### Q2: 热词太多会影响性能吗？

**影响**：热词匹配是简单的字符串查找，性能影响极小

**建议**：放心添加，不影响实时性

### Q3: 如何判断需要添加哪些变体？

**方法**：
1. 实际测试，记录识别结果
2. 分析发音相似词
3. 查看用户反馈日志

### Q4: 识别结果不稳定怎么办？

**方案**：
1. 添加更多变体覆盖
2. 使用多次确认（如要求用户重复）
3. 结合上下文判断

---

## 六、依赖资源

### Flutter 插件

```yaml
dependencies:
  sherpa_onnx: ^1.13.0    # 语音识别引擎
  record: ^6.1.2          # 音频录制
  path_provider: ^2.1.0   # 文件路径
```

### 模型下载

- [SenseVoice 多语言模型 (int8)](https://github.com/k2-fsa/sherpa-onnx/releases)
- 模型大小：约 **155MB**（int8量化版本）

### 参考文档

- [Sherpa-ONNX 官方文档](https://k2-fsa.github.io/sherpa/onnx/)
- [SenseVoice 介绍](https://github.com/modelscope/SenseVoice)

---

## 七、快速开始 Checklist

1. ✓ 下载 SenseVoice 模型
2. ✓ 安装 `sherpa_onnx` 和 `record` 插件
3. ✓ 配置录音（16kHz 单声道）
4. ✓ 初始化识别器
5. ✓ 定义功能热词表
6. ✓ 实现音频处理循环
7. ✓ 实现热词匹配逻辑
8. ✓ 测试识别准确率
9. ✓ 收集变体、更新热词表

---

**文档版本**: v1.0  
**适用场景**: 离线语音识别 + 功能指令识别  
**更新日期**: 2026-07-07