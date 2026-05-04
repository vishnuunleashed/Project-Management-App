import Flutter
import UIKit
import FirebaseCore
import Network
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
    var localNetworkBrowser: NWBrowser?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()

    // Register generated plugins
    GeneratedPluginRegistrant.register(with: self)

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "syncTask_1", frequency: NSNumber(value: 15 * 60))

    // Set up custom MethodChannel for opening iOS Settings
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
          name: "com.infra.interior_design/resourceResolver", // match Dart
          binaryMessenger: controller.binaryMessenger
      )


      channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "openNotificationSettings" {
          if let url = URL(string: UIApplication.openSettingsURLString),
             UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            result(true)
          } else {
            result(false)
          }
        } else if(call.method == "requestLocalNetworkPermission"){
            self.requestLocalNetworkPermission()
            result(true)
            
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    private func requestLocalNetworkPermission() {
        // Trigger Bonjour service browsing to prompt iOS dialog
        let parameters = NWParameters.tcp
        let browser = NWBrowser(for: .bonjour(type: "_http._tcp", domain: nil), using: parameters)

        browser.stateUpdateHandler = { state in
          print("Local network browser state: \(state)")
        }

        browser.start(queue: .main)
        self.localNetworkBrowser = browser
      }
}
