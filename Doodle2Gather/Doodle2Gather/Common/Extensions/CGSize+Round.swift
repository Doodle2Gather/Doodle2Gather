import CoreGraphics

extension CGSize {
    func round(to places: Int) -> CGSize {
        CGSize(width: width.round(to: places), height: height.round(to: places))
    }
}
