import UIKit

class HomeViewController: UIViewController {

    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var displayNameTextField: UITextField!
    @IBOutlet private var errorMessageLabel: UILabel!
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var formActionSegmentedControl: UISegmentedControl!

    private enum Segment: Int {
        case login
        case register
    }

    private func updateFormViews() {
        let segment = Segment(rawValue: formActionSegmentedControl.selectedSegmentIndex)
        switch segment {
        case .login:
            displayNameTextField.isHidden = true
            submitButton.setTitle("LOGIN", for: .normal)
            submitButton.backgroundColor = .systemIndigo
        case .register:
            displayNameTextField.isHidden = false
            submitButton.setTitle("REGISTER", for: .normal)
            submitButton.backgroundColor = .systemTeal
        default:
            fatalError("Invalid segment")
        }
    }

    @IBAction private func onFormActionChanged(_ sender: UISegmentedControl) {
        updateFormViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DTAuth.delegate = self
        errorMessageLabel.text = ""
        updateFormViews()
        submitButton.layer.cornerRadius = 20
        submitButton.clipsToBounds = true

        // For TextField keyboard avoidance
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    deinit {
      NotificationCenter.default.removeObserver(self)
    }

    /**
     For TextField keyboard avoidance
     */
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

    @IBAction private func onSubmitButtonTapped(_ sender: UIButton) {
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

    private func attemptRegister() {
        DTAuth.signUp(email: emailTextField.text!, password: passwordTextField.text!, displayName: emailTextField.text!)
    }

    private func attemptLogin() {
        DTAuth.login(email: emailTextField.text!, password: passwordTextField.text!)
    }
}

extension HomeViewController: DTAuthDelegate {
    func displayError(_ error: Error) {
        DispatchQueue.main.async {
            DTLogger.error(error.localizedDescription)
            self.errorMessageLabel.text = error.localizedDescription
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
            self.performSegue(withIdentifier: "goToDoodle", sender: self)
        }
    }

}

private struct LoginResponse: Codable {
    var roomId: String
}
