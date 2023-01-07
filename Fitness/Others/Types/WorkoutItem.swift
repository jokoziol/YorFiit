import Foundation

struct WorkoutItem: Identifiable, Hashable {
    let id = UUID()
    let workoutId: String?
    let placeNames: String?
    let startDate: Date
    let type: String?
    let timeInSeconds: Int
    let calories: Double
    let distanceInMeters: Double
}