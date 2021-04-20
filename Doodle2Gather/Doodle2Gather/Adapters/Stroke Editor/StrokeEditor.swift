import UIKit

protocol StrokeEditor {
    func setToolAndGetProperties(_ tool: DrawingTools) -> (width: CGFloat, color: UIColor)

    func enterEditStrokeMode(color: UIColor)

    func exitEditStrokeMode()
}
