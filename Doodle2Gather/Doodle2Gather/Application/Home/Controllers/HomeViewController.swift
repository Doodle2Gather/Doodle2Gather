import UIKit

class HomeViewController: UIViewController {
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var roomNameTextField: UITextField!
    @IBOutlet private var loginButton: UIStackView!
    @IBOutlet private var errorMessageLabel: UILabel!

    enum ErrorMessages {
        static let incorrectCredentials = "Incorrect credentials"
        static let unableToFetchResponse = "Unable to fetch response. Is your internet connection working?"

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        errorMessageLabel.text = ""
        usernameTextField.text = UIDevice.current.name
        passwordTextField.text = "goodpassword"
        roomNameTextField.text = "devRoom"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDoodle" {
            guard let vc = segue.destination as? DoodleViewController else {
                fatalError("Unable to get DoodleViewController")
            }
            vc.username = usernameTextField.text
            vc.roomName = roomNameTextField.text
        }
    }

    @IBAction private func onLoginTapped(_ sender: UIButton) {
        attemptLogin()
    }

    private func attemptLogin() {
        let params = ["username": usernameTextField.text,
                      "password": passwordTextField.text,
                      "roomName": roomNameTextField.text]
        let url = URL(string: "http://d2g.christopher.sg:8080/login")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
        } catch {
            DispatchQueue.main.async {
                self.errorMessageLabel.text = error.localizedDescription
            }
        }

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessageLabel.text = error.localizedDescription
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.errorMessageLabel.text = ErrorMessages.incorrectCredentials
                }
                return
            }

            guard let data = data,
                  (try? JSONDecoder().decode(LoginResponse.self, from: data)) != nil else {
                DispatchQueue.main.async {
                    self.errorMessageLabel.text = ErrorMessages.unableToFetchResponse
                }
                return
            }

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToDoodle", sender: self)
            }
        })
        task.resume()
    }
}

private struct LoginResponse: Codable {
    var roomId: String
}
