import UIKit

extension UIColor {
    func round(to places: Int) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red.round(to: places), green: green.round(to: places),
                       blue: blue.round(to: places), alpha: alpha.round(to: places))
    }
}
