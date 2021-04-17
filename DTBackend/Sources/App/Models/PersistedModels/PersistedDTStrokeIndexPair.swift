import Fluent
import Vapor
import DTSharedLibrary

final class PersistedDTStrokeIndexPair: Model, Content {
    static let schema = "pairs"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "stroke_data")
    var stroke: Data

    @Field(key: "index")
    var index: Int

    init() { }

    init(stroke: Data, index: Int, id: UUID? = nil) {
        self.stroke = stroke
        self.index = index
        self.id = id
    }
}
