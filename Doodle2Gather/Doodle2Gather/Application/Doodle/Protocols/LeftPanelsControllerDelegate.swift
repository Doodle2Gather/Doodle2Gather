import UIKit

protocol LeftPanelsControllerDelegate: AnyObject {

    func setMainTool(_ mainTool: MainTools)

    func setDrawingTool(_ drawingTool: DrawingTools)

    func setShapeTool(_ shapeTool: ShapeTools)

    func setSelectTool(_ selectTool: SelectTools)

    func setWidth(_ width: CGFloat)

    func setColor(_ color: UIColor)

    func setIsPressureSensitive(_ isPressureSensitive: Bool)

}
