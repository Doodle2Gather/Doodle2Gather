import PencilKit

/// Adapted from:
/// https://github.com/simonbs/InfiniteCanvas/blob/main/InfiniteCanvas/Source/Canvas/PKDrawing%2BHelpers.swift
extension PKStroke {

    var strokesFrame: CGRect? {
        guard !points.isEmpty else {
            return nil
        }
        var minPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
        var maxPoint = CGPoint(x: 0, y: 0)
        for point in points {
            let location = point.location
            minPoint.x = min(location.x, minPoint.x)
            minPoint.y = min(location.y, minPoint.y)
            maxPoint.x = max(location.x, maxPoint.x)
            maxPoint.y = max(location.y, maxPoint.y)
        }
        return CGRect(x: minPoint.x, y: minPoint.y, width: maxPoint.x - minPoint.x, height: maxPoint.y - minPoint.y)
    }

}
