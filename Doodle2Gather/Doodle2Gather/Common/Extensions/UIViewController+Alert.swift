import UIKit

/// Adds alert functionalities to `UIViewController`.
extension UIViewController {

    /// Creates an alert with the given `title`, `message`, `buttonStyle`
    /// and `handler`.
    ///
    /// Buttons, if a `handler` is provided, will default to "Cancel" and "OK",
    /// while if no `handler` is provided, it will default to "OK" only.
    func alert(title: String, message: String, buttonStyle: UIAlertAction.Style,
               handler: ((UIAlertAction) -> Void)? = nil,
               cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let safeHandler = handler {
            alert.addAction(UIAlertAction(title: "OK", style: buttonStyle, handler: safeHandler))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: buttonStyle))
        }

        styleAlert(alert)
        present(alert, animated: true, completion: nil)
    }

    func styleAlert(_ alert: UIAlertController) {
        alert.setBackgroundColor(color: UIConstants.black)
        alert.setTint(color: UIConstants.white)
        alert.setTitle(font: .systemFont(ofSize: 16, weight: .bold), color: UIConstants.white)
        alert.setMessage(font: .systemFont(ofSize: 14), color: UIConstants.white)
    }

}
