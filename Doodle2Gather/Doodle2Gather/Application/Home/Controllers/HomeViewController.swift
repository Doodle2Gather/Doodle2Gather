import UIKit

class HomeViewController: UIViewController {

    // Storyboard UI Elements
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var displayNameTextField: UITextField!

    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var formActionSegmentedControl: UISegmentedControl!
    @IBOutlet private var heightConstraint: NSLayoutConstraint!

    @IBOutlet private var emailContainer: UIView!
    @IBOutlet private var passwordContainer: UIView!
    @IBOutlet private var displayNameContainer: UIView!

    // WebSockets
    var appWSController: DTWebSocketController?
    let authWSController = DTAuthWebSocketController()

    // States
    private var loggedIn = false
    private var loadingSpinner: UIAlertController?

    private enum Segment: Int {
        case login
        case register
    }

    let loginButtonText = "Login"
    let registerButtonText = "Register"
    private let darkBlue = #colorLiteral(red: 55.0 / 255.0,
                                         green: 52 / 255.0,
                                         blue: 235.0 / 255.0,
                                         alpha: 1.0)

    let registerSuccessMessage = "Successfully created an account! Please log in!"

    private let credentialsProvider = UserDefaultsCredentialsProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        DTAuth.delegate = self
        loadSavedCredentials()
        updateFormViews()
        emailContainer.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)
        passwordContainer.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)
        displayNameContainer.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)

        // For TextField keyboard avoidance
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        // Register websocket handlers
        guard let appWSController = self.appWSController else {
            fatalError("Unable to get main app WS controller")
        }
        appWSController.registerSubcontroller(self.authWSController)
    }

    deinit {
        // Remove websocket handlers
        appWSController?.removeSubcontroller(self.authWSController)
        NotificationCenter.default.removeObserver(self)
    }

    /// For keyboard avoidance with TextFields
    @objc
    func keyboardNotification(notification: NSNotification) {
      guard let userInfo = notification.userInfo else {
        return
      }

      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let endFrameY = endFrame?.origin.y ?? 0
      let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]
                                        as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

      if endFrameY >= UIScreen.main.bounds.size.height {
        self.view.frame.origin.y = 0.0
      } else {
        self.view.frame.origin.y = -(endFrame?.size.height ?? 0.0) / 1.8
      }

      UIView.animate(
        withDuration: duration,
        delay: TimeInterval(0),
        options: animationCurve,
        animations: { self.view.layoutIfNeeded() },
        completion: nil)
    }

    @objc
    func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status
        view.endEditing(true)
    }

    private func updateFormViews() {
        let segment = Segment(rawValue: formActionSegmentedControl.selectedSegmentIndex)
        switch segment {
        case .login:
            displayNameContainer.isHidden = true
            submitButton.setTitle(loginButtonText, for: .normal)
            heightConstraint.constant = 420
        case .register:
            displayNameContainer.isHidden = false
            submitButton.setTitle(registerButtonText, for: .normal)
            heightConstraint.constant = 500
        default:
            fatalError("Invalid segment")
        }
    }

    private func loadSavedCredentials() {
        guard credentialsProvider.hasSavedCredentials else {
            return
        }
        emailTextField.text = credentialsProvider.savedEmail!
        passwordTextField.text = credentialsProvider.savedPassword!
        DTLogger.info("User credentials loaded and filled from credentials storage")
    }

    private func attemptRegister() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let displayName = displayNameTextField.text else {
            alert(title: "Warning",
                  message: "Please fill in all the fields.",
                  buttonStyle: .default)
            return
        }
        guard !email.isEmpty && !password.isEmpty && !displayName.isEmpty else {
            alert(title: "Warning",
                  message: "Please fill in all the fields.",
                  buttonStyle: .default)
            return
        }
        DTAuth.signUp(email: email,
                      password: password,
                      displayName: displayName)
    }

    private func attemptLogin() {
        if !loggedIn {
            loadingSpinner = createSpinnerView(message: "Logging In...")
        }
        DTAuth.login(email: emailTextField.text!, password: passwordTextField.text!)
    }

    // Inject app WS controller to Gallery VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let galleryVC = segue.destination as? GalleryViewController else {
            fatalError("Unable to pass data to Gallery VC in segue")
        }
        galleryVC.appWSController = self.appWSController
    }

    @IBAction private func onFormActionChanged(_ sender: UISegmentedControl) {
        updateFormViews()
    }

    @IBAction private func onSubmitButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        let segment = Segment(rawValue: formActionSegmentedControl.selectedSegmentIndex)
        switch segment {
        case .login:
            attemptLogin()
        case .register:
            attemptRegister()
        default:
            fatalError("Invalid segment")
        }
    }
}

extension HomeViewController: DTAuthDelegate {

    func displayError(_ error: Error) {
        DispatchQueue.main.async {
            DTLogger.error(error.localizedDescription)
            self.alert(title: AlertConstants.notice,
                       message: AlertConstants.serverError,
                       buttonStyle: .default
            )
        }
    }

    func displayMessage(_ message: String) {
        DispatchQueue.main.async {
            DTLogger.event(message)
            self.alert(title: AlertConstants.notice,
                       message: message,
                       buttonStyle: .default
            )
        }
    }

    func loginDidSucceed() {
        guard let uid = DTAuth.user?.uid,
              let displayName = DTAuth.user?.displayName,
              let email = DTAuth.user?.email else {
            fatalError("Unable to fetch user details")
        }

        DTLogger.event("""
User Logged in
 - Display Name: \(displayName)
 - UID: \(uid)
 - Email: \(email)
""")

        DispatchQueue.main.async {
            self.credentialsProvider.savedEmail = self.emailTextField.text
            self.credentialsProvider.savedPassword = self.passwordTextField.text
        }

        authWSController.sendLoginMessage(userId: uid, displayName: displayName, email: email, successCallback: {
            DTLogger.info { "Login to backend is successful" }
            self.loggedIn = true
            if let spinner = self.loadingSpinner {
                DispatchQueue.main.async {
                    self.removeSpinnerView(spinner)
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: SegueConstants.toGallery, sender: self)
            }
        }) { errorMessage in
            DispatchQueue.main.async {
                if let spinner = self.loadingSpinner {
                    self.removeSpinnerView(spinner)
                }
                DTLogger.error(errorMessage)
                self.alert(title: AlertConstants.notice,
                           message: AlertConstants.serverError,
                           buttonStyle: .default
                )
            }
        }

    }

    func registerDidSucceed() {
        DTLogger.event("Successfully registered")
        displayMessage(registerSuccessMessage)
        DispatchQueue.main.async {
            self.formActionSegmentedControl.selectedSegmentIndex = Segment.login.rawValue
            self.updateFormViews()
        }
    }

}

private struct LoginResponse: Codable {
    var roomId: String
}
