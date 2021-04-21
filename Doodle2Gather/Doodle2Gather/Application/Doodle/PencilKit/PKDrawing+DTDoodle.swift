import PencilKit
import DTSharedLibrary

/// Adapts `PKDrawing` to work with implementations used in Doodle2Gather.
extension PKDrawing: DTDoodle {

    public var dtStrokes: [PKStroke] {
        get {
            strokes
        }
        set {
            strokes = newValue
        }
    }

    public init<D>(from doodle: D) where D: DTDoodle {
        self.init(strokes: doodle.dtStrokes.map { PKStroke(from: $0) })
    }

    public init(from doodle: DTAdaptedDoodle) {
        self.init(strokes: doodle.strokes.filter({ !$0.isDeleted }).compactMap { PKStroke(from: $0) })
    }

    public mutating func removeStrokes<S>(_ removedStrokes: [S]) where S: DTStroke {
        let removed = Set(removedStrokes)
        dtStrokes = dtStrokes.filter({ stroke in
            guard let stroke = stroke as? S else {
                fatalError("Failed to convert PKStroke to DTStroke")
            }
            return !removed.contains(stroke)
        })
    }

    public mutating func removeStroke<S>(_ removedStroke: S) where S: DTStroke {
        dtStrokes = dtStrokes.filter({ stroke in
            guard let stroke = stroke as? S else {
                fatalError("Failed to convert PKStroke to DTStroke")
            }
            return !(stroke == removedStroke)
        })
    }

    public mutating func addStrokes<S>(_ addedStrokes: [S]) where S: DTStroke {
        dtStrokes.append(contentsOf: (addedStrokes.map { PKStroke(from: $0) }))
    }

    public mutating func addStroke<S>(_ addedStroke: S) where S: DTStroke {
        dtStrokes.append(PKStroke(from: addedStroke))
    }

}

// MARK: - Strokes Frame

/// Adapted from:
/// https://github.com/simonbs/InfiniteCanvas/blob/main/InfiniteCanvas/Source/Canvas/PKDrawing%2BHelpers.swift
extension PKDrawing {

    public var strokesFrame: CGRect? {
        guard !strokes.isEmpty else {
            return nil
        }
        var minPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
        var maxPoint = CGPoint(x: 0, y: 0)
        for stroke in strokes {
            let renderBounds = stroke.renderBounds
            if renderBounds.minX < minPoint.x {
                minPoint.x = floor(renderBounds.minX)
            }
            if renderBounds.minY < minPoint.y {
                minPoint.y = floor(renderBounds.minY)
            }
            if renderBounds.maxX > maxPoint.x {
                maxPoint.x = ceil(renderBounds.maxX)
            }
            if renderBounds.maxY > maxPoint.y {
                maxPoint.y = ceil(renderBounds.maxY)
            }
        }
        return CGRect(x: minPoint.x, y: minPoint.y, width: maxPoint.x - minPoint.x, height: maxPoint.y - minPoint.y)
    }

}
