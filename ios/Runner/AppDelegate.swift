import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var speechRecognition: IOSSpeechRecognition?
  private var methodChannelRegistered = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 尝试在 application 中注册（可能 window 还没创建）
    if let controller = window?.rootViewController as? FlutterViewController {
      setupSpeechRecognition(controller)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // FlutterImplicitEngineDelegate 的回调方法
  // 在 Flutter 引擎初始化完成后调用，这是注册插件和 MethodChannel 的正确时机
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // 注册所有 Flutter 插件
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // 尝试再次获取 FlutterViewController 并注册 MethodChannel
    if let controller = window?.rootViewController as? FlutterViewController {
      setupSpeechRecognition(controller)
    }
  }

  private func setupSpeechRecognition(_ controller: FlutterViewController) {
    // 避免重复注册
    if methodChannelRegistered {
      return
    }

    let channel = FlutterMethodChannel(name: "ios_speech_recognition",
                                        binaryMessenger: controller.binaryMessenger)

    speechRecognition = IOSSpeechRecognition()

    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "initialize":
        let args = call.arguments as? [String: Any]
        let language = args?["language"] as? String ?? "zh-CN"
        self?.speechRecognition?.initialize(channel: channel, language: language) { success in
          result(success)
        }

      case "startListening":
        let args = call.arguments as? [String: Any]
        let language = args?["language"] as? String ?? "zh-CN"
        self?.speechRecognition?.startListening(language: language)
        result(nil)

      case "stopListening":
        self?.speechRecognition?.stopListening()
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    methodChannelRegistered = true
    print("[AppDelegate] MethodChannel 'ios_speech_recognition' registered successfully")
  }
}
