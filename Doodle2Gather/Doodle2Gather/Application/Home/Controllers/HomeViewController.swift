import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction private func onLoginTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToDoodle", sender: self)
    }

}
