import CoreGraphics

enum DoodleConstants {
    // Point properties
    static let defaultForce: CGFloat = 0
    static let defaultSize = CGSize(width: 6, height: 6)
    static let defaultOpacity: CGFloat = 1
    static let defaultAzimuth: CGFloat = -1.5
    static let defaultAltitude = CGFloat.pi / 2

    // Stroke properties
    static let defaultTransform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)

    // PencilKit constants
    static let colorAccuracy = 4
    static let accuracy = 1
}

enum DrawingTools: Int {
    case pen
    case pencil
    case highlighter
    case magicPen
}

enum MainTools: Int {
    case drawing
    case eraser
    case shapes
    case cursor
}

enum ShapeTools: Int {
    case circle
    case square
    case triangle
    case star
}

enum SelectTools: Int {
    case all
    case user
}
