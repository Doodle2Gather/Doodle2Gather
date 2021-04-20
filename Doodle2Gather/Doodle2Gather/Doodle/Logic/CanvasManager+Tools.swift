import PencilKit
import DTSharedLibrary

// MARK: - Tool Management

extension CanvasManager {

    var currentActionType: DTActionType {
        switch currentMainTool {
        case .drawing:
            return .add
        case .eraser:
            return .remove
        case .cursor:
            return .modify
        default:
            return .unknown
        }
    }

    func setDrawingTool(_ drawingTool: DrawingTools) {
        augmentors.removeValue(forKey: Constants.detectionKey)
        currentDrawingTool = drawingTool
        switch drawingTool {
        case .pen:
            setTool(.pen)
        case .pencil:
            setTool(.pencil)
        case .highlighter:
            setTool(.highlighter)
        case .magicPen:
            augmentors[Constants.detectionKey] = BestFitShapeDetector()
            setTool(.pen)
        }
    }

    func setShapeTool(_ shapeTool: ShapeTools) {
        currentShapeTool = shapeTool
    }

    func setMainTool(_ mainTool: MainTools) {
        currentMainTool = mainTool
        switch mainTool {
        case .drawing:
            activateDrawingGestureRecognizer()
            setDrawingTool(currentDrawingTool)
        case .eraser:
            activateDrawingGestureRecognizer()
            setTool(.eraser)
        case .cursor:
            activateSelectGestureRecognizer()
        case .shapes:
            activateShapesGestureRecognizer()
        case .text:
            activateTextGestureRecognizer()
        }
    }

    func setTool(_ tool: DTTool) {
        var color = UIColor.black
        var width: CGFloat?

        if let currentTool = canvas.tool as? PKInkingTool {
            color = currentTool.color
            width = currentTool.width
        }

        switch tool {
        case .pen:
            canvas.tool = PKInkingTool(.pen, color: color, width: width)
        case .pencil:
            canvas.tool = PKInkingTool(.pencil, color: color, width: width)
        case .highlighter:
            canvas.tool = PKInkingTool(.marker, color: color, width: width)
        case .eraser:
            canvas.tool = PKEraserTool(.vector)
        case .lasso:
            canvas.tool = PKLassoTool()
        }
    }

    func setColor(_ color: UIColor) {
        guard let tool = canvas.tool as? PKInkingTool else {
            return
        }
        canvas.tool = PKInkingTool(tool.inkType, color: color, width: tool.width)
    }

    func setWidth(_ width: CGFloat) {
        guard let tool = canvas.tool as? PKInkingTool else {
            return
        }
        canvas.tool = PKInkingTool(tool.inkType, color: tool.color, width: width)
    }

    func setIsPressureSensitive(_ isPressureSensitive: Bool) {
        if !isPressureSensitive {
            augmentors[Constants.pressureKey] = WidthAdjustor()
            return
        }
        augmentors.removeValue(forKey: Constants.pressureKey)
    }

}
