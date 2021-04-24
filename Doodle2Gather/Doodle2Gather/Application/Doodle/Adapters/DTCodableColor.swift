import UIKit

/// Helper struct that allows for `UIColor` to be encoded and decoded.
/// Adapted from https://stackoverflow.com/a/50934846
public struct DTCodableColor: Codable {

    /// RGBA values
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(uiColor: UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }

}
