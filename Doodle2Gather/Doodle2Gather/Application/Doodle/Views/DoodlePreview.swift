import UIKit
import PencilKit
import DTSharedLibrary

/// Helper struct class that uses PencilKit for preview rendering.
struct DoodlePreview {

    let image: UIImage

    init<D: DTDoodle>(of doodle: D) {
        let drawing = PKDrawing(from: doodle)
        guard let strokesFrame = drawing.strokesFrame else {
            image = #imageLiteral(resourceName: "white")
            return
        }
        let previewRect = UIConstants.previewRect(strokesFrame)
        image = drawing.image(from: previewRect, scale: 1)
    }

    init(of doodle: DTAdaptedDoodle) {
        let drawing = PKDrawing(from: doodle)
        guard let strokesFrame = drawing.strokesFrame else {
            image = #imageLiteral(resourceName: "white")
            return
        }
        let previewRect = UIConstants.previewRect(strokesFrame)
        image = drawing.image(from: previewRect, scale: 1)
    }

}
