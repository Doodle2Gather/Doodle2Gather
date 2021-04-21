import UIKit

protocol LeftPanelsController {

    /// Toggles whether the left panel can be used, i.e. whether editing
    /// can be done.
    func setCanEdit(_ canEdit: Bool)

    /// Shows the stroke editing panel and sets the color to the current
    /// stroke color.
    func strokeDidSelect(color: UIColor)

    /// Hides the stroke editing panel and end the editing of stroke.
    func strokeDidUnselect()

}
