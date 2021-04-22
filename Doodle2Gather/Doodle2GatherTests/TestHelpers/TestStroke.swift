import Doodle2Gather
import DTSharedLibrary
import UIKit

struct TestStroke: DTStroke {

    var color: UIColor
    var tool: DTCodableTool
    var points: [TestPoint]
    var pointsFrame: CGRect?
    var mask: UIBezierPath?
    var transform: CGAffineTransform
    var isSelected = false

    init<S>(from stroke: S) where S: DTStroke {
        self.color = stroke.color
        self.tool = stroke.tool
        self.points = stroke.points.map { TestPoint(from: $0) }
        self.mask = stroke.mask
        self.transform = stroke.transform
    }

    init?(from stroke: DTAdaptedStroke) {
        nil
    }

    init<P>(color: UIColor, tool: DTCodableTool, points: [P],
            transform: CGAffineTransform, mask: UIBezierPath?) where P: DTPoint {
        self.color = color
        self.tool = tool
        self.points = points.map { TestPoint(from: $0) }
        self.transform = transform
        self.mask = mask
    }

    mutating func setIsSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
    }

}
