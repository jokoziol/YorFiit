import Foundation

class WorkoutConfig {

    public static let shared = WorkoutConfig()

    public let workouts: [Workout]
    public let workoutSections: [WorkoutSection]

    private init() {

        guard let path = Bundle.main.path(forResource: "workoutConfig", ofType: "json") else {
            fatalError("Config file could not be located")
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let result = try JSONDecoder().decode(ResponseData.self, from: data)

            var workouts = [Workout]()
            for item in result.workoutSections {

                for i in item.workouts {
                    workouts.append(i)

                    //Validate
                    if i.name.localized() == i.name {
                        fatalError("The workout name " + i.name + " was not localized")
                    }

                    if i.metValue <= 0.0 {
                        fatalError("Invalid MET value for " + i.name)
                    }
                }

                //Validate
                if item.name.localized() == item.name {
                    fatalError("The workout section name " + item.name + " was not localized")
                }

                if item.workouts.isEmpty {
                    fatalError("Workout sections cannot be empty")
                }
            }

            self.workouts = workouts
            self.workoutSections = result.workoutSections

        } catch {
            fatalError()
        }
    }
}

fileprivate struct ResponseData: Decodable {
    var workoutSections: [WorkoutSection]
}