import UIKit

/// Extracted security overlay — used by AppDelegate now, SceneDelegate later.
/// Shows a branded blur overlay when the app enters background to hide sensitive content.
class SecurityOverlay {
    static let shared = SecurityOverlay()
    private var overlayView: UIView?

    private init() {}

    func show(in window: UIWindow?, isDark: Bool?) {
        guard overlayView == nil, let window = window else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let darkMode: Bool
        if let synced = isDark {
            darkMode = synced
        } else {
            // Read from Keychain (FlutterSecureStorage)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "app_theme_mode",
                kSecAttrService as String: "flutter_secure_storage_service",
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecSuccess,
               let data = item as? Data,
               let value = String(data: data, encoding: .utf8) {
                darkMode = (value == "dark")
            } else {
                darkMode = window.rootViewController?.traitCollection.userInterfaceStyle == .dark
            }
        }

        // Theme-aware background
        let bgColor = darkMode
            ? UIColor(red: 10/255, green: 10/255, blue: 12/255, alpha: 1.0)
            : UIColor(red: 250/255, green: 250/255, blue: 248/255, alpha: 1.0)
        overlay.backgroundColor = bgColor

        // Blur
        let blurStyle: UIBlurEffect.Style = darkMode ? .dark : .light
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        blurView.frame = overlay.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.addSubview(blurView)

        // App logo
        let logoImageView = UIImageView(image: UIImage(named: "AppIcon"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        logoImageView.center = CGPoint(x: overlay.center.x, y: overlay.center.y - 30)
        logoImageView.layer.cornerRadius = 22
        logoImageView.clipsToBounds = true
        overlay.addSubview(logoImageView)

        // "Korido" label
        let label = UILabel()
        label.text = "Korido"
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = darkMode ? .white : UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        label.textAlignment = .center
        label.sizeToFit()
        label.center = CGPoint(x: overlay.center.x, y: logoImageView.frame.maxY + 24)
        overlay.addSubview(label)

        window.addSubview(overlay)
        overlayView = overlay
    }

    func hide() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
}
