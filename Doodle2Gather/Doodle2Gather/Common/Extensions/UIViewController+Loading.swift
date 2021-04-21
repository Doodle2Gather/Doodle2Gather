import UIKit

/// Adds loading spinner functionalities to `UIViewController`.
extension UIViewController {

    /// Creates a loading spinner on top of the current view controller.
    /// Returns the new spinner view created.
    func createSpinnerView(message: String) -> UIAlertController {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        styleSpinner(activityIndicator)

        alert.view.addSubview(activityIndicator)
        alert.view.heightAnchor.constraint(equalToConstant: 95).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor,
                                                   constant: 0).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor,
                                                  constant: -20).isActive = true

        styleAlert(alert)
        present(alert, animated: true)

        return alert
    }

    /// Removes the spinner view.
    func removeSpinnerView(_ view: UIAlertController) {
        view.dismiss(animated: true, completion: nil)
    }

    private func styleSpinner(_ activityIndicator: UIActivityIndicatorView) {
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
}
