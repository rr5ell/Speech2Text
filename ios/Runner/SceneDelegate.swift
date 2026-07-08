import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("[Native Speech] FlutterViewController not ready; speech channel was not registered")
      return
    }

    IOSSpeechRecognitionPlugin.register(with: controller.binaryMessenger)
  }
}
