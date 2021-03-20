import PencilKit

extension PKStroke: DTStroke {

    var color: UIColor {
        get {
            ink.color
        }
        set {
            ink.color = newValue
        }
    }

    init<S>(from stroke: S) where S: DTStroke {
        self.init(ink: .init(.pen), path: .init())
    }
}
