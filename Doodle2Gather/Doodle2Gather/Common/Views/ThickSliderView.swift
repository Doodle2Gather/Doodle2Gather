import UIKit

class ThickSliderView: UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = 20
        return rect
    }

}
