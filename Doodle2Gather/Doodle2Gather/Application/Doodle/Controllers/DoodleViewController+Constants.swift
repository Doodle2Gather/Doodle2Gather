extension DoodleViewController {

    enum DrawingTools: Int {
        case pen
        case pencil
        case highlighter
        case magicPen
    }

    enum MainTools: Int {
        case drawingTool
        case eraserTool
        case textTool
        case shapesTool
        case cursorTool
    }

    enum Constants {
        static let defaultPenWidth: Float = 5
        static let minPenWidth: Float = 0.9
        static let maxPenWidth: Float = 25
        static let defaultPencilWidth: Float = 5
        static let minPencilWidth: Float = 3
        static let maxPencilWidth: Float = 16
        static let defaultHighlighterWidth: Float = 12
        static let minHighlighterWidth: Float = 8
        static let maxHighlighterWidth: Float = 34
    }

}
