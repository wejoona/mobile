import Flutter
import UIKit
import DeviceCheck
import CryptoKit
import ImageIO
import LocalAuthentication
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    var attestationKeyId: String?
    var securityChannel: FlutterMethodChannel?
    var attestationChannel: FlutterMethodChannel?
    var biometricsChannel: FlutterMethodChannel?
    var imageAnalysisChannel: FlutterMethodChannel?
    var appIsDarkMode: Bool? = nil
    private var screenCaptureDetectionConfigured = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        setupChannelsWithMessenger(engineBridge.applicationRegistrar.messenger())
    }

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
                SecurityOverlay.shared.show(in: self?.activeWindow(), isDark: self?.appIsDarkMode)
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

        // SECURITY: Biometric enrollment state channel
        biometricsChannel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/biometrics",
            binaryMessenger: messenger
        )

        biometricsChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "getEnrollmentStateHash":
                self?.getBiometricEnrollmentStateHash(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        imageAnalysisChannel = FlutterMethodChannel(
            name: "com.joonapay.usdc_wallet/image_analysis",
            binaryMessenger: messenger
        )

        imageAnalysisChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "detectFaces":
                guard let args = call.arguments as? [String: Any],
                      let path = args["path"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                        message: "Image path is required",
                                        details: nil))
                    return
                }
                self?.detectFaces(path: path, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // SECURITY: Detect screenshots and screen recording
        setupScreenCaptureDetection()
    }

    // MARK: - Image Analysis

    private func detectFaces(path: String, result: @escaping FlutterResult) {
        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                                message: "Image file was not found",
                                details: nil))
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                DispatchQueue.main.async {
                    result(FlutterError(code: "FACE_DETECTION_FAILED",
                                        message: error.localizedDescription,
                                        details: nil))
                }
                return
            }

            let observations = (request.results as? [VNFaceObservation]) ?? []
            DispatchQueue.main.async {
                result([
                    "available": true,
                    "faceCount": observations.count,
                ])
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            guard let faceImage = self.makeFaceDetectionImage(path: path) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "IMAGE_LOAD_FAILED",
                                        message: "Unable to read the selected image",
                                        details: nil))
                }
                return
            }

            do {
                let handler = VNImageRequestHandler(
                    cgImage: faceImage.image,
                    orientation: faceImage.orientation,
                    options: [:]
                )
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "FACE_DETECTION_FAILED",
                                        message: error.localizedDescription,
                                        details: nil))
                }
            }
        }
    }

    private func makeFaceDetectionImage(path: String) -> (image: CGImage, orientation: CGImagePropertyOrientation)? {
        guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else {
            return nil
        }
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let orientation = (properties?[kCGImagePropertyOrientation] as? UInt32)
            .flatMap(CGImagePropertyOrientation.init(rawValue:)) ?? .up

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: false,
            kCGImageSourceThumbnailMaxPixelSize: 1200,
            kCGImageSourceShouldCacheImmediately: false,
        ]

        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return (image, orientation)
    }

    // MARK: - Biometric Enrollment State

    private func getBiometricEnrollmentStateHash(result: FlutterResult) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            result(FlutterError(code: "BIOMETRIC_UNAVAILABLE",
                                message: error?.localizedDescription ?? "Biometrics are not available",
                                details: nil))
            return
        }

        guard let state = context.evaluatedPolicyDomainState else {
            result(FlutterError(code: "BIOMETRIC_STATE_UNAVAILABLE",
                                message: "Unable to read biometric enrollment state",
                                details: nil))
            return
        }

        let digest = SHA256.hash(data: state)
        result("ios:" + Data(digest).base64EncodedString())
    }

    // MARK: - App Lifecycle (UI-related — will move to SceneDelegate)

    override func applicationWillResignActive(_ application: UIApplication) {
        SecurityOverlay.shared.show(in: activeWindow(), isDark: appIsDarkMode)
        super.applicationWillResignActive(application)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        SecurityOverlay.shared.hide()
        super.applicationDidBecomeActive(application)
    }

    func activeWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow } ?? window
        }

        return window
    }

    // MARK: - Screen Capture Detection

    private func setupScreenCaptureDetection() {
        guard !screenCaptureDetectionConfigured else {
            return
        }
        screenCaptureDetectionConfigured = true

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
