import UIKit

extension UIColor {

    func lighten() -> UIColor {
        var alpha: CGFloat = 1
        self.getWhite(nil, alpha: &alpha)
        return self.withAlphaComponent(alpha * 0.5)
    }

    func darken() -> UIColor {
        var alpha: CGFloat = 1
        self.getWhite(nil, alpha: &alpha)
        return self.withAlphaComponent(max(1, alpha * 2))
    }

}
