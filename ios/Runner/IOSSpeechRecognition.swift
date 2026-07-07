// iOS 原生语音识别实现
// 使用 Speech Framework 进行实时语音识别

import Flutter
import Speech
import AVFoundation

class IOSSpeechRecognition: NSObject {
    private var speechRecognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var currentLanguage: String = "zh-CN"
    private var channel: FlutterMethodChannel?

    func initialize(channel: FlutterMethodChannel, language: String, success: @escaping (Bool) -> Void) {
        self.channel = channel
        currentLanguage = language

        // 创建语音识别器
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))

        // 检查授权状态
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                // 请求麦克风权限
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    success(granted)
                }
            case .denied, .restricted, .notDetermined:
                success(false)
            @unknown default:
                success(false)
            }
        }
    }

    func startListening(language: String) {
        currentLanguage = language
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))

        // 配置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // 创建音频引擎
        audioEngine = AVAudioEngine()

        // 创建识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        // 开始识别任务
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let text = result.bestTranscription.formattedString
                self.channel?.invokeMethod("onRecognitionResult", arguments: text)

                if result.isFinal {
                    self.stopListening()
                }
            }

            if let error = error {
                self.channel?.invokeMethod("onError", arguments: error.localizedDescription)
            }
        }

        // 配置音频输入
        let inputNode = audioEngine!.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        // 启动音频引擎
        audioEngine?.prepare()
        try? audioEngine?.start()
    }

    func stopListening() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
    }
}