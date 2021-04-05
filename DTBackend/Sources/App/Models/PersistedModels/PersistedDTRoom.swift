import Fluent
import Vapor

final class PersistedDTRoom: Model, Content {
  static let schema = "rooms"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "name")
  var name: String
    
    @Children(for: \.$room)
           var strokes: [PersistedDTStroke]
    
    @Children(for: \.$room)
           var actions: [PersistedDTAction]
  
  init() { }
  
  init(id: UUID? = nil, name: String) {
    self.id = id
    self.name = name
  }

}
