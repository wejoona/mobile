import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        guard let controller = window?.rootViewController as? FlutterViewController,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        appDelegate.setupChannelsWithMessenger(controller.binaryMessenger)
    }

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
