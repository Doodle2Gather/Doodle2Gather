import CoreGraphics

extension CGPoint {
    func round(to places: Int) -> CGPoint {
        CGPoint(x: x.round(to: places), y: y.round(to: places))
    }
}
