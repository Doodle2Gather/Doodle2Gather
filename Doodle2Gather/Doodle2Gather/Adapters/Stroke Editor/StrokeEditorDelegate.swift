import UIKit

protocol StrokeEditorDelegate: AnyObject {
    func colorDidChange(_ color: UIColor)
    func widthDidChange(_ width: CGFloat)
    func opacityDidChange(_ opacity: CGFloat)
}

extension StrokeEditorDelegate {
    func colorDidChange(_ color: UIColor) {
        // Do nothing
    }

    func widthDidChange(_ width: CGFloat) {
        // Do nothing
    }

    func opacityDidChange(_ opacity: CGFloat) {
        // Do nothing
    }
}
