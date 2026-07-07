import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var speechRecognition: IOSSpeechRecognition?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 注册 iOS 原生语音识别 MethodChannel
    let controller = window?.rootViewController as? FlutterViewController
    if let controller = controller {
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
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
