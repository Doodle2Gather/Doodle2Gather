import CoreGraphics

extension CGPoint {

    func truncate(places: Int) -> CGPoint {
        CGPoint(x: x.truncate(places: places), y: y.truncate(places: places))
    }

}
