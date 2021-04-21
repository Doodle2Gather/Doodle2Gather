import UIKit

/// Delegate that listens to the changes of a `ColorPicker`.
protocol ColorPickerDelegate: AnyObject {

    /// Informs the delegate that the color selected has changed.
    func colorDidChange(_ color: UIColor)

    /// Informs the delegate that the width selected has changed.
    func widthDidChange(_ width: CGFloat)

    /// Informs the delegate that the opacity selected has changed.
    func opacityDidChange(_ opacity: CGFloat)
}

extension ColorPickerDelegate {

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
