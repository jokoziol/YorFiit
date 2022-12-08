import Foundation

struct WorkoutSection: Decodable, Identifiable {
    let id = UUID()
    let name: String
    let workouts: [Workout]
}
