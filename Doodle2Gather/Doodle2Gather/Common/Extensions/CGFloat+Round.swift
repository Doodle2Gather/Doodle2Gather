import CoreGraphics

extension CGFloat {
    func round(to places: Int) -> CGFloat {
        CGFloat(Double(self).round(to: places))
    }
}
