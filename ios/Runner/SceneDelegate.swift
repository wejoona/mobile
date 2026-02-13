import Flutter
import UIKit
import DeviceCheck
import CryptoKit

class SceneDelegate: FlutterSceneDelegate {
    private var attestationKeyId: String?
    private var securityOverlayView: UIView?
    private var securityChannel: FlutterMethodChannel?

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        hideSecurityOverlay()
        setupChannelsIfNeeded(scene: scene)
        super.sceneDidBecomeActive(scene)
    }

    override func sceneWillResignActive(_ scene: UIScene) {
        showSecurityOverlay(scene: scene)
        super.sceneWillResignActive(scene)
    }

    override func sceneWillEnterForeground(_ scene: UIScene) {
        super.sceneWillEnterForeground(scene)
    }

    override func sceneDidEnterBackground(_ scene: UIScene) {
        super.sceneDidEnterBackground(scene)
    }

    // MARK: - Channel Setup

    private func setupChannelsIfNeeded(scene: UIScene) {
        guard securityChannel == nil,
              let windowScene = scene as? UIWindowScene,
              let window = windowScene.windows.first,
              let controller = window.rootViewController as? FlutterViewController else {
            return
        }

        // Security channel
        securityChannel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/security",
            binaryMessenger: controller.binaryMessenger
        )

        securityChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "enableSecureMode":
                if let scene = controller.view.window?.windowScene {
                    self?.showSecurityOverlay(scene: scene)
                }
                result(true)
            case "disableSecureMode":
                self?.hideSecurityOverlay()
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Attestation channel
        let attestChannel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/attestation",
            binaryMessenger: controller.binaryMessenger
        )

        attestChannel.setMethodCallHandler { [weak self] (call, result) in
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

        // Screenshot detection
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.securityChannel?.invokeMethod("onScreenshotDetected", arguments: nil)
        }

        // Screen recording detection
        NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if let windowScene = scene as? UIWindowScene {
                let isCaptured = windowScene.screen.isCaptured
                self?.securityChannel?.invokeMethod("onScreenRecordingChanged", arguments: ["isCaptured": isCaptured])
            }
        }
    }

    // MARK: - Security Overlay

    private func showSecurityOverlay(scene: UIScene) {
        guard securityOverlayView == nil,
              let windowScene = scene as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 12/255, alpha: 1.0)

        let logoImageView = UIImageView(image: UIImage(named: "AppIcon"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        logoImageView.center = overlay.center
        overlay.addSubview(logoImageView)

        window.addSubview(overlay)
        securityOverlayView = overlay
    }

    private func hideSecurityOverlay() {
        securityOverlayView?.removeFromSuperview()
        securityOverlayView = nil
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
