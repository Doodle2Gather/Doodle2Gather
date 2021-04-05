import Foundation

public struct DTStrokeIndexPair: Codable {
    public let stroke: Data
    public let index: Int
    
    public init(_ stroke: Data, _ index: Int) {
        self.stroke = stroke
        self.index = index
    }
}

extension DTStrokeIndexPair: Hashable {}
