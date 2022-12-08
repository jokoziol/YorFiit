import SwiftUI

struct WorkoutSummaryWithoutLocationView: View {

    @State private var workoutSaved: Bool = false

    // MARK: - Workout description
    private let workout: WorkoutItem
    private let workoutName: String
    private let workoutTime: String
    private let workoutSwimLaps: String
    private let workoutCalories: String

    //MARK: -

    init(_ workout: WorkoutItem) {
        self.workout = workout

        self.workoutName = WorkoutType.getName(type: workout.type) ?? "--"
        self.workoutTime = WorkoutTime.getTimeString(timeInSeconds: workout.timeInSeconds)
        self.workoutSwimLaps = WorkoutDistance.getSwimLaps(distanceInMeters: workout.distanceInMeters)
        self.workoutCalories = "cal".localized(workout.calories)
    }

    var body: some View {

        NavigationView {
            VStack {
                List {
                    Text(workoutTime)

                    ForEach(getMaxItems(), id: \.self) {
                        Text($0)
                    }
                }
            }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {

                            if workout.workoutId == nil && !workoutSaved {
                                Button {
                                    persistWorkout()
                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    }
                    .navigationTitle(workoutName)
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        WorkoutInformation.persistTemporaryWorkout(workout, nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
                    }
        }
    }

    private func getMaxItems() -> [String] {

        var workoutList = [String]()

        if workoutSwimLaps != "laps".localized(0.0) && WorkoutDistance.shouldDisplaySwimLaps(workoutType: workout.type) {
            workoutList.append(workoutSwimLaps)
        }

        if workoutCalories != "cal".localized(0.0) {
            workoutList.append(workoutCalories)
        }

        return workoutList
    }

    private func persistWorkout() {
        WorkoutInformation.persistWorkout(workout, nil)

        self.workoutSaved = true

        Vibration.success.vibrate()
    }
}
