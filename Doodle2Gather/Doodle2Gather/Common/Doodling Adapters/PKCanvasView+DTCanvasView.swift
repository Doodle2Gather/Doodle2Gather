import PencilKit
import DoodlingLibrary

extension PKCanvasView: DTCanvasView {

    public func registerDelegate(_ delegate: DTCanvasViewDelegate) -> DTCanvasViewDelegate {
        let wrapperDelegate = WrapperPKCanvasViewDelegate(delegate: delegate)
        self.delegate = wrapperDelegate
        return wrapperDelegate
    }

    public func loadDoodle<D>(_ doodle: D) where D: DTDoodle {
        self.drawing = PKDrawing(from: doodle)
        self.alwaysBounceVertical = true
        // TODO: Remove this line once a DT version of drawing policy is added.
        self.drawingPolicy = .anyInput
    }

    public func getStrokes<S>() -> Set<S>? where S: DTStroke {
        Set(drawing.strokes) as? Set<S>
    }

    public func getDoodle<D>() -> D? where D: DTDoodle {
        drawing as? D
    }

    public func setTool(_ tool: DTTool) {
        var color = UIColor.black
        var width: CGFloat?
        if let currentTool = self.tool as? PKInkingTool {
            color = currentTool.color
            width = currentTool.width
        }

        switch tool {
        case .pen:
            self.tool = PKInkingTool(.pen, color: color, width: width)
        case .pencil:
            self.tool = PKInkingTool(.pencil, color: color, width: width)
        case .marker:
            self.tool = PKInkingTool(.marker, color: color, width: width)
        case .eraser:
            self.tool = PKEraserTool(.bitmap)
        }
    }

    public func setColor(_ color: UIColor) {
        guard let tool = tool as? PKInkingTool else {
            return
        }
        self.tool = PKInkingTool(tool.inkType, color: color, width: tool.width)
    }

    public func setWidth(_ width: CGFloat) {
        guard let tool = tool as? PKInkingTool else {
            return
        }
        self.tool = PKInkingTool(tool.inkType, color: tool.color, width: width)
    }

}

class WrapperPKCanvasViewDelegate: NSObject, PKCanvasViewDelegate, DTCanvasViewDelegate {

    private weak var actualDelegate: DTCanvasViewDelegate?

    init(delegate: DTCanvasViewDelegate) {
        self.actualDelegate = delegate
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        actualDelegate?.canvasViewDoodleDidChange(canvasView)
    }

    func canvasViewDoodleDidChange(_ canvasView: DTCanvasView) {
        actualDelegate?.canvasViewDoodleDidChange(canvasView)
    }

}
