import UIKit

protocol LeftPanelsControllerDelegate: AnyObject {

    /// Informs the delegate to set this as a new main tool.
    func setMainTool(_ mainTool: MainTools)

    /// Informs the delegate to set this as a new drawing tool.
    func setDrawingTool(_ drawingTool: DrawingTools)

    /// Informs the delegate to set this as a new shape tool.
    func setShapeTool(_ shapeTool: ShapeTools)

    /// Informs the delegate to set this as a new select tool.
    func setSelectTool(_ selectTool: SelectTools)

    /// Informs the delegate to set this as the new width of the strokes.
    func setWidth(_ width: CGFloat)

    /// Informs the delegate to set this as the new color of the strokes.
    func setColor(_ color: UIColor)

    /// Informs the delegate to set whether the magic pen is pressure
    /// sensitive.
    func setIsPressureSensitive(_ isPressureSensitive: Bool)

}
