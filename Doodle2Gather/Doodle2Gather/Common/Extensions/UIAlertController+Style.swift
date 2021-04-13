import UIKit

/// Adapted from:
/// https://www.swiftdevcenter.com/
/// change-font-text-color-and-background-color-of-uialertcontroller/
extension UIAlertController {

    /// Sets background color of UIAlertController.
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first,
           let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }

    /// Sets title font and title color of UIAlertController.
    func setTitle(font: UIFont?, color: UIColor?) {
        guard let title = self.title else {
            return
        }
        let attributeString = NSMutableAttributedString(string: title)
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font: titleFont],
                                          range: NSRange(location: 0, length: title.utf8.count))
        }

        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor: titleColor],
                                          range: NSRange(location: 0, length: title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")
    }

    /// Sets message font and message color of UIAlertController.
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else {
            return
        }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font: messageFont],
                                          range: NSRange(location: 0, length: message.utf8.count))
        }

        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor: messageColorColor],
                                          range: NSRange(location: 0, length: message.utf8.count))
        }

        self.setValue(attributeString, forKey: "attributedMessage")
    }

    /// Sets tint color of UIAlertController.
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }

}
