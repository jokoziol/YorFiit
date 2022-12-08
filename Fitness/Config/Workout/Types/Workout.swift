import Foundation

struct Workout: Decodable, Identifiable {
    let id: Int
    let name: String
    let usesLocation: Bool
    let usesDistance: Bool
    let metValue: Double
    let activityType: UInt
}
