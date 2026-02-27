import Flutter
import UIKit
import DeviceCheck
import CryptoKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    var attestationKeyId: String?
    var securityChannel: FlutterMethodChannel?
    var attestationChannel: FlutterMethodChannel?
    var appIsDarkMode: Bool? = nil

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Set up method channels using the Flutter view controller
        setupChannels()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - UIScene migration prep
    // When FlutterImplicitEngineDelegate becomes available, uncomment:
    // func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    //     GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    //     setupChannelsWithMessenger(engineBridge.applicationRegistrar.messenger())
    // }

    // MARK: - Channel Setup

    /// Set up method channels - extracted to allow reuse with future scene-based setup
    func setupChannels() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }
        setupChannelsWithMessenger(controller.binaryMessenger)
    }

    /// Core channel setup using a messenger (works with both AppDelegate and scene-based lifecycle)
    func setupChannelsWithMessenger(_ messenger: FlutterBinaryMessenger) {
        // SECURITY: Security method channel
        securityChannel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/security",
            binaryMessenger: messenger
        )

        securityChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "enableSecureMode":
                SecurityOverlay.shared.show(in: self?.window, isDark: self?.appIsDarkMode)
                result(true)
            case "disableSecureMode":
                SecurityOverlay.shared.hide()
                result(true)
            case "setThemeMode":
                if let isDark = call.arguments as? Bool {
                    self?.appIsDarkMode = isDark
                }
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // SECURITY: App Attest method channel
        attestationChannel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/attestation",
            binaryMessenger: messenger
        )

        attestationChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "requestAppAttest":
                guard let args = call.arguments as? [String: Any],
                      let nonce = args["nonce"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                       message: "Nonce is required",
                                       details: nil))
                    return
                }
                self?.requestAppAttest(nonce: nonce, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // SECURITY: Detect screenshots and screen recording
        setupScreenCaptureDetection()
    }

    // MARK: - App Lifecycle (UI-related — will move to SceneDelegate)

    override func applicationWillResignActive(_ application: UIApplication) {
        SecurityOverlay.shared.show(in: self.window, isDark: appIsDarkMode)
        super.applicationWillResignActive(application)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        SecurityOverlay.shared.hide()
        super.applicationDidBecomeActive(application)
    }

    // MARK: - Screen Capture Detection

    private func setupScreenCaptureDetection() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.securityChannel?.invokeMethod("onScreenshotDetected", arguments: nil)
        }

        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(
                forName: UIScreen.capturedDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                let isCaptured = UIScreen.main.isCaptured
                self?.securityChannel?.invokeMethod("onScreenRecordingChanged", arguments: ["isCaptured": isCaptured])
            }
        }
    }

    // MARK: - App Attest

    private func requestAppAttest(nonce: String, result: @escaping FlutterResult) {
        guard #available(iOS 14.0, *) else {
            result(FlutterError(code: "NOT_SUPPORTED",
                               message: "App Attest requires iOS 14.0 or newer",
                               details: nil))
            return
        }

        guard DCAppAttestService.shared.isSupported else {
            result(FlutterError(code: "NOT_SUPPORTED",
                               message: "App Attest is not supported on this device",
                               details: nil))
            return
        }

        let service = DCAppAttestService.shared

        if attestationKeyId == nil {
            service.generateKey { [weak self] keyId, error in
                if let error = error {
                    result(FlutterError(code: "KEY_GENERATION_ERROR",
                                       message: error.localizedDescription,
                                       details: nil))
                    return
                }

                guard let keyId = keyId else {
                    result(FlutterError(code: "KEY_GENERATION_ERROR",
                                       message: "Failed to generate key",
                                       details: nil))
                    return
                }

                self?.attestationKeyId = keyId
                if #available(iOS 14.0, *) {
                    self?.performAttestation(keyId: keyId, nonce: nonce, result: result)
                }
            }
        } else {
            performAttestation(keyId: attestationKeyId!, nonce: nonce, result: result)
        }
    }

    @available(iOS 14.0, *)
    private func performAttestation(keyId: String, nonce: String, result: @escaping FlutterResult) {
        guard let nonceData = nonce.data(using: .utf8) else {
            result(FlutterError(code: "INVALID_NONCE",
                               message: "Failed to encode nonce",
                               details: nil))
            return
        }

        let hash = Data(SHA256.hash(data: nonceData))

        DCAppAttestService.shared.attestKey(keyId, clientDataHash: hash) { attestation, error in
            if let error = error {
                result(FlutterError(code: "ATTESTATION_ERROR",
                                   message: error.localizedDescription,
                                   details: nil))
                return
            }

            guard let attestation = attestation else {
                result(FlutterError(code: "ATTESTATION_ERROR",
                                   message: "No attestation received",
                                   details: nil))
                return
            }

            let response: [String: Any] = [
                "attestation": attestation.base64EncodedString(),
                "keyId": keyId
            ]

            result(response)
        }
    }
}
