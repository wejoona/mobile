import Flutter
import UIKit
import DeviceCheck
import CryptoKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var attestationKeyId: String?
    private var securityOverlayView: UIView?
    private var securityChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // SECURITY: Set up App Attest method channel
        setupAttestationChannel()

        // SECURITY: Set up security method channel
        setupSecurityChannel()

        // SECURITY: Detect screenshots and screen recording
        setupScreenCaptureDetection()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // SECURITY: Hide app content when entering background
    override func applicationWillResignActive(_ application: UIApplication) {
        showSecurityOverlay()
        super.applicationWillResignActive(application)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        hideSecurityOverlay()
        super.applicationDidBecomeActive(application)
    }

    private func setupSecurityChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }

        securityChannel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/security",
            binaryMessenger: controller.binaryMessenger
        )

        securityChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "enableSecureMode":
                self?.showSecurityOverlay()
                result(true)
            case "disableSecureMode":
                self?.hideSecurityOverlay()
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func setupScreenCaptureDetection() {
        // SECURITY: Detect screenshot capture
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Notify Flutter that a screenshot was taken
            self?.securityChannel?.invokeMethod("onScreenshotDetected", arguments: nil)
        }

        // SECURITY: Detect screen recording (iOS 11+)
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

    private func showSecurityOverlay() {
        guard securityOverlayView == nil, let window = self.window else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor(red: 26/255, green: 26/255, blue: 31/255, alpha: 1.0) // AppColors.obsidian

        // Add app logo or blur effect
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

    private func setupAttestationChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }

        let channel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/attestation",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
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
    }

    private func requestAppAttest(nonce: String, result: @escaping FlutterResult) {
        // Check iOS version first
        guard #available(iOS 14.0, *) else {
            result(FlutterError(code: "NOT_SUPPORTED",
                               message: "App Attest requires iOS 14.0 or newer",
                               details: nil))
            return
        }

        // Check if App Attest is supported
        guard DCAppAttestService.shared.isSupported else {
            result(FlutterError(code: "NOT_SUPPORTED",
                               message: "App Attest is not supported on this device",
                               details: nil))
            return
        }

        let service = DCAppAttestService.shared

        // Generate a new key if we don't have one
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
        // Create hash of the nonce for attestation
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

            // Return attestation and key ID
            // The attestation should be sent to your backend for verification
            let response: [String: Any] = [
                "attestation": attestation.base64EncodedString(),
                "keyId": keyId
            ]

            result(response)
        }
    }
}
