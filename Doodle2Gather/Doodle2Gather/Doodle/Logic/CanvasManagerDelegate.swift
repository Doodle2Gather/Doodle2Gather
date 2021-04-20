import UIKit
import DTSharedLibrary

protocol CanvasManagerDelegate: AnyObject {

    func canvasZoomScaleDidChange(scale: CGFloat)

    func canvasViewDidChange(type: DTActionType)

    func setCanvasIsEditing(_ isEditing: Bool)

    func strokeDidSelect(color: UIColor)

    func strokeDidUnselect()

}
