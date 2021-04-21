import UIKit

enum UIConstants {

    static let black = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1137254902, alpha: 1)
    static let flamingoRed = #colorLiteral(red: 0.9921568627, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
    static let merlinGrey = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
    static let stackGrey = #colorLiteral(red: 0.5450980392, green: 0.5450980392, blue: 0.5450980392, alpha: 1)
    static let texasYellow = #colorLiteral(red: 0.968627451, green: 1, blue: 0.5529411765, alpha: 1)
    static let white = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    static let minZoom: CGFloat = 0.1
    static let maxZoom: CGFloat = 2
    static let currentZoom: CGFloat = 1

    static let defaultPenWidth: Float = 7
    static let minPenWidth: Float = 3
    static let maxPenWidth: Float = 25
    static let defaultPencilWidth: Float = 5
    static let minPencilWidth: Float = 3
    static let maxPencilWidth: Float = 16
    static let defaultHighlighterWidth: Float = 12
    static let minHighlighterWidth: Float = 8
    static let maxHighlighterWidth: Float = 34

    static let smallOffset: CGFloat = 10
    static let largeOffset: CGFloat = 12

    static let userIconColorCount = 3

    static func previewRect(_ frame: CGRect) -> CGRect {
        CGRect(x: frame.minX - frame.width * 0.05,
               y: frame.minY - frame.height * 0.05,
               width: frame.width * 1.1,
               height: frame.height * 1.1)
    }
}
