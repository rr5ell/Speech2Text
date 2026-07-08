// iOS 原生语音识别实现
// 使用 Speech Framework 进行实时语音识别

import Flutter
import Speech
import AVFoundation

final class IOSSpeechRecognitionPlugin {
    private static let channelName = "native_speech_recognition"
    private static var channel: FlutterMethodChannel?
    private static var speechRecognition: IOSSpeechRecognition?

    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        let speechRecognition = IOSSpeechRecognition()

        self.channel = channel
        self.speechRecognition = speechRecognition

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "initialize":
                let args = call.arguments as? [String: Any]
                let language = args?["language"] as? String ?? "zh-CN"
                speechRecognition.initialize(channel: channel, language: language) { success in
                    result(success)
                }

            case "startListening":
                let args = call.arguments as? [String: Any]
                let language = args?["language"] as? String ?? "zh-CN"
                speechRecognition.startListening(language: language)
                result(nil)

            case "stopListening":
                speechRecognition.stopListening()
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        print("[iOS Speech] MethodChannel '\(channelName)' registered")
    }
}

class IOSSpeechRecognition: NSObject {
    private var speechRecognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var currentLanguage: String = "zh-CN"
    private var channel: FlutterMethodChannel?
    private var isInputTapInstalled = false
    private var activeSessionId = 0
    private var isListening = false

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
                    DispatchQueue.main.async {
                        success(granted)
                    }
                }
            case .denied, .restricted, .notDetermined:
                DispatchQueue.main.async {
                    success(false)
                }
            @unknown default:
                DispatchQueue.main.async {
                    success(false)
                }
            }
        }
    }

    func startListening(language: String) {
        stopListening()
        activeSessionId += 1
        let sessionId = activeSessionId
        isListening = true

        currentLanguage = language
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            isListening = false
            channel?.invokeMethod("onError", arguments: "当前语言的 iOS 语音识别不可用: \(language)")
            return
        }

        // 配置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            isListening = false
            channel?.invokeMethod("onError", arguments: "配置音频会话失败: \(error.localizedDescription)")
            return
        }

        // 创建音频引擎
        audioEngine = AVAudioEngine()

        // 创建识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        // 开始识别任务
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            guard self.isListening && sessionId == self.activeSessionId else {
                return
            }

            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    guard self.isListening && sessionId == self.activeSessionId else {
                        return
                    }
                    let method = result.isFinal ? "onRecognitionResult" : "onRecognitionPartial"
                    self.channel?.invokeMethod(method, arguments: text)
                }

                if result.isFinal {
                    DispatchQueue.main.async {
                        self.stopListening()
                    }
                }
            }

            if let error = error {
                DispatchQueue.main.async {
                    guard self.isListening && sessionId == self.activeSessionId else {
                        return
                    }
                    self.channel?.invokeMethod("onError", arguments: error.localizedDescription)
                    self.stopListening()
                }
            }
        }

        // 配置音频输入
        guard let audioEngine = audioEngine else { return }
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        isInputTapInstalled = true

        // 启动音频引擎
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            isListening = false
            channel?.invokeMethod("onError", arguments: "启动音频引擎失败: \(error.localizedDescription)")
            stopListening()
        }
    }

    func stopListening() {
        isListening = false
        activeSessionId += 1
        if isInputTapInstalled {
            audioEngine?.inputNode.removeTap(onBus: 0)
            isInputTapInstalled = false
        }
        audioEngine?.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("[iOS Speech] Failed to deactivate audio session: \(error.localizedDescription)")
        }

        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
    }
}
