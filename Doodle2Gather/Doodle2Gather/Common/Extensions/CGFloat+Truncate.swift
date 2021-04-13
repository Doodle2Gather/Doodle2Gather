import CoreGraphics

extension CGFloat {

    func truncate(places: Int) -> CGFloat {
        CGFloat(floor(pow(10.0, Double(places)) * Double(self)) / pow(10.0, Double(places)))
    }

}
