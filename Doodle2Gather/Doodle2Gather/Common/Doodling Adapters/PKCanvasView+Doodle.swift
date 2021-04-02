import PencilKit
import DoodlingLibrary

// MARK: - Adapters for Doodling Models

extension PKCanvasView {

    enum Constants {
        static let minZoom: CGFloat = 0.25
        static let maxZoom: CGFloat = 2
        static let currentZoom: CGFloat = 1
    }

    func initialiseDefaultProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        minimumZoomScale = Constants.minZoom
        maximumZoomScale = Constants.maxZoom
        zoomScale = Constants.currentZoom
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        drawingPolicy = .anyInput
    }

    func getStrokes<S>() -> Set<S>? where S: DTStroke {
        Set(drawing.strokes) as? Set<S>
    }

    func getDoodle<D>() -> D? where D: DTDoodle {
        drawing as? D
    }

    func setTool(_ tool: DTTool) {
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

    func setColor(_ color: UIColor) {
        guard let tool = tool as? PKInkingTool else {
            return
        }
        self.tool = PKInkingTool(tool.inkType, color: color, width: tool.width)
    }

    func setWidth(_ width: CGFloat) {
        guard let tool = tool as? PKInkingTool else {
            return
        }
        self.tool = PKInkingTool(tool.inkType, color: tool.color, width: width)
    }

}
