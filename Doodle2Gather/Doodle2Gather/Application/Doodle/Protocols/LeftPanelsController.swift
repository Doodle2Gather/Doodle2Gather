import UIKit

protocol LeftPanelsController {

    func setCanEdit(_ canEdit: Bool)

    func strokeDidSelect(color: UIColor)

    func strokeDidUnselect()

}
