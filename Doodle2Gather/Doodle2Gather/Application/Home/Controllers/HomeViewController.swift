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
    }

    @IBAction private func onSubmitButtonTapped(_ sender: UIButton) {
        attemptLogin()
    }

    private func attemptLogin() {
        DTAuth.signUp(email: emailTextField.text!, password: passwordTextField.text!, displayName: emailTextField.text!)
//        let params = ["username": usernameTextField.text,
//                      "password": passwordTextField.text,
//                      "roomName": roomNameTextField.text]
//        let url = URL(string: ApiEndpoints.Login)!
//        var request = URLRequest(url: url)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.httpMethod = "POST"
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        } catch {
//            DispatchQueue.main.async {
//                self.errorMessageLabel.text = error.localizedDescription
//            }
//        }
//
//        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.errorMessageLabel.text = error.localizedDescription
//                }
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                DispatchQueue.main.async {
//                    self.errorMessageLabel.text = ErrorMessages.incorrectCredentials
//                }
//                return
//            }
//
//            guard let data = data,
//                  (try? JSONDecoder().decode(LoginResponse.self, from: data)) != nil else {
//                DispatchQueue.main.async {
//                    self.errorMessageLabel.text = ErrorMessages.unableToFetchResponse
//                }
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "goToDoodle", sender: self)
//            }
//        })
//        task.resume()
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
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToDoodle", sender: self)
        }
    }

}

private struct LoginResponse: Codable {
    var roomId: String
}
