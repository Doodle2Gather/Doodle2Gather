import Foundation

extension Double {

    func truncate(places: Int) -> Double {
        Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }

}
