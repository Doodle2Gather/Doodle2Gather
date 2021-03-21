import UIKit

class HomeViewController: UIViewController {
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var roomNameTextField: UITextField!
    @IBOutlet private var loginButton: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        performSegue(withIdentifier: "goToDoodle", sender: self)
    }

    private func attemptLogin() {
        let params = ["username": usernameTextField.text, "password": passwordTextField.text, "roomName": roomNameTextField.text]
        let url = URL(string: "http://d2g.christopher.sg:8080/login")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
        } catch {
            print(error.localizedDescription)
        }

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
          if let error = error {
            print("Error logging in \(error)")
            return
          }

          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            print("Error with the response, unexpected status code: \(String(describing: response))")
            return
          }

          if let data = data,
             let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
            print(loginResponse.roomId)
            }
        })
        task.resume()
    }
}

private struct LoginResponse: Codable {
    var roomId: String
}
