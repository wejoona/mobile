import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func sceneDidBecomeActive(_ scene: UIScene) {
        SecurityOverlay.shared.hide()
        super.sceneDidBecomeActive(scene)
    }

    override func sceneWillResignActive(_ scene: UIScene) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        SecurityOverlay.shared.show(
            in: window,
            isDark: appDelegate?.appIsDarkMode
        )
        super.sceneWillResignActive(scene)
    }
}
