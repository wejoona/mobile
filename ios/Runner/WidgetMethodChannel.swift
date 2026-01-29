import Flutter
import UIKit
import WidgetKit

/// Method channel for widget communication
class WidgetMethodChannel {
    private let channel: FlutterMethodChannel

    init(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/widget",
            binaryMessenger: binaryMessenger
        )

        setupMethodHandler()
    }

    private func setupMethodHandler() {
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "updateWidget":
                self?.updateWidget()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func updateWidget() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
