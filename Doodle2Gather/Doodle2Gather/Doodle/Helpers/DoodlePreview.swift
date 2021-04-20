import UIKit
import PencilKit
import DTSharedLibrary

/// Helper image class that uses PencilKit for preview rendering.
class DoodlePreview: UIImageView {

    init<D: DTDoodle>(doodle: D) {
        super.init(image: PKDrawing(from: doodle).image(from: UIScreen.main.bounds, scale: 1))
    }

    init(doodle: DTAdaptedDoodle) {
        super.init(image: PKDrawing(from: doodle).image(from: UIScreen.main.bounds, scale: 1))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
