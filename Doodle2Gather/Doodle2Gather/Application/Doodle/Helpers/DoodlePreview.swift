import UIKit
import PencilKit
import DTSharedLibrary

/// Helper image class that uses PencilKit for preview rendering.
class DoodlePreview: UIImageView {

    init?<D: DTDoodle>(doodle: D) {
        let drawing = PKDrawing(from: doodle)
        guard let strokesFrame = drawing.strokesFrame else {
            return nil
        }
        let previewRect = UIConstants.previewRect(strokesFrame)
        super.init(image: drawing.image(from: previewRect, scale: 1))
    }

    init?(doodle: DTAdaptedDoodle) {
        let drawing = PKDrawing(from: doodle)
        guard let strokesFrame = drawing.strokesFrame else {
            return nil
        }
        let previewRect = UIConstants.previewRect(strokesFrame)
        super.init(image: drawing.image(from: previewRect, scale: 1))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
