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
            alert.addAction(UIAlertAction(title: AlertConstants.ok, style: buttonStyle, handler: safeHandler))
            alert.addAction(UIAlertAction(title: AlertConstants.cancel, style: .cancel, handler: cancelHandler))
        } else {
            alert.addAction(UIAlertAction(title: AlertConstants.ok, style: buttonStyle))
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

    /// Creates an action with the given `message`, `actions`
    /// and `origin`.
    func actionSheet(message: String?, actions: [UIAlertAction], origin: CGPoint, source: UIView) {
        let actionSheet = ActionSheetAlertController(title: nil, message: message,
                                                     preferredStyle: .actionSheet)
        actions.forEach { actionSheet.addAction($0) }

        actionSheet.popoverPresentationController?.sourceRect = CGRect(
            origin: origin,
            size: CGSize()
        )
        actionSheet.popoverPresentationController?.sourceView = source

        styleActionSheet(actionSheet)
        present(actionSheet, animated: true, completion: nil)
    }

    func styleActionSheet(_ actionSheet: UIAlertController) {
        actionSheet.popoverPresentationController?.backgroundColor = UIConstants.black
        actionSheet.setTint(color: UIConstants.white)
    }

}
