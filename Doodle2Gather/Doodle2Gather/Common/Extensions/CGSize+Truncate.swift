import CoreGraphics

extension CGSize {

    func truncate(places: Int) -> CGSize {
        CGSize(width: width.truncate(places: places), height: height.truncate(places: places))
    }

}
