import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        initializeWindow(windowScene);
    }

    private func initializeWindow(_ windowScene: UIWindowScene) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = PhotosViewController()
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
    }
}
