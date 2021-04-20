import CoreGraphics

extension CGPoint {

    func distanceTo(_ otherPoint: CGPoint) -> CGFloat {
        sqrt(pow(x - otherPoint.x, 2) + pow(y - otherPoint.y, 2))
    }

    func isCloseTo(_ otherPoint: CGPoint, within: CGFloat) -> Bool {
        pow(x - otherPoint.x, 2) + pow(y - otherPoint.y, 2) <= pow(within, 2)
    }

}
