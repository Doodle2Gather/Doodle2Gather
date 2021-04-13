import UIKit

class HomeViewController: UIViewController {

    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var displayNameTextField: UITextField!

    @IBOutlet private var actionMessageLabel: UILabel!
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var formActionSegmentedControl: UISegmentedControl!
    @IBOutlet private var heightConstraint: NSLayoutConstraint!

    @IBOutlet private var emailContainer: UIView!
    @IBOutlet private var passwordContainer: UIView!
    @IBOutlet private var displayNameContainer: UIView!

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

    @IBAction private func onFormActionChanged(_ sender: UISegmentedControl) {
        updateFormViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DTAuth.delegate = self
        loadSavedCredentials()
        actionMessageLabel.text = ""
        updateFormViews()
        emailContainer.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)
        passwordContainer.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)
        displayNameContainer.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)

        // For TextField keyboard avoidance
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    deinit {
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

    private func loadSavedCredentials() {
        guard credentialsProvider.hasSavedCredentials else {
            return
        }
        emailTextField.text = credentialsProvider.savedEmail!
        passwordTextField.text = credentialsProvider.savedPassword!
        DTLogger.info("User credentials loaded and filled from credentials storage")
    }

    private func attemptRegister() {
        DTAuth.signUp(email: emailTextField.text!,
                      password: passwordTextField.text!,
                      displayName: displayNameTextField.text!)
    }

    private func attemptLogin() {
        DTAuth.login(email: emailTextField.text!, password: passwordTextField.text!)
    }
}

extension HomeViewController: DTAuthDelegate {

    func displayError(_ error: Error) {
        DispatchQueue.main.async {
            DTLogger.error(error.localizedDescription)
            self.actionMessageLabel.textColor = .systemRed
            self.actionMessageLabel.text = error.localizedDescription
        }
    }

    func displayMessage(_ message: String) {
        DispatchQueue.main.async {
            self.actionMessageLabel.textColor = self.darkBlue
            self.actionMessageLabel.text = message
        }
    }

    func loginDidSucceed() {
        DTLogger.event("""
User Logged in
 - Display Name: \(DTAuth.user?.displayName ?? "Not found")
 - UID: \(DTAuth.user?.uid ?? "Not found")
 - Email: \(DTAuth.user?.email ?? "Not found")
""")

        DispatchQueue.main.async {
            self.credentialsProvider.savedEmail = self.emailTextField.text
            self.credentialsProvider.savedPassword = self.passwordTextField.text
        }

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: SegueConstants.toGallery, sender: self)
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
