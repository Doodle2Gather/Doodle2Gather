import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let wsController = DTWebSocketController()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup auth provider
        DTAuth.configure()

        // Setup initial view controller
        self.window = UIWindow(frame: UIScreen.main.bounds)

        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")

        // Inject App WS controller
        guard let homeViewController = initialViewController as? HomeViewController else {
            fatalError("Unable to use initial VC as HomeViewController")
        }
        homeViewController.appWSController = wsController

        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

        return true
    }

}
