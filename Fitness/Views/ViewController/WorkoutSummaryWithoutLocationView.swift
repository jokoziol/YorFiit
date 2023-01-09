import SwiftUI

struct WorkoutSummaryWithoutLocationView: View {

    @State private var workoutSaved: Bool = false

    private let columns: [GridItem]

    // MARK: - Workout description
    private let workout: WorkoutItem
    private let workoutName: String
    private let workoutTime: String
    private let workoutSwimLaps: String
    private let workoutCalories: String
    //MARK: -

    init(_ workout: WorkoutItem) {
        self.workout = workout

        self.workoutName = WorkoutType.getName(type: workout.type ?? nil) ?? "--"
        self.workoutTime = WorkoutTime.getTimeString(timeInSeconds: workout.timeInSeconds)
        self.workoutSwimLaps = WorkoutDistance.getSwimLaps(distanceInMeters: workout.distanceInMeters)
        self.workoutCalories = "cal".localized(workout.calories)
        
        self.columns = self.workoutSwimLaps == "laps".localized(0.0) ? [GridItem(alignment: .center)] : [GridItem(alignment: .center), GridItem(alignment: .center)]
    }

    var body: some View {

        NavigationView {

            VStack {
                GeometryReader { proxy in
                    VStack {
                        Text(self.workoutTime).font(.system(size: proxy.size.width * 0.1).bold())

                        LazyVGrid(columns: self.columns) {
                            ForEach(getMaxItems(), id: \.self) {
                                Text($0).font(.system(size: proxy.size.width * 0.05))
                            }
                        }
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
                        if self.workout.workoutId == nil {
                            WorkoutInformation.persistTemporaryWorkout(workout, nil)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
                        }
                    }
                    .padding(ScreenConfig.mediumSpacing)
        }
    }

    private func getMaxItems() -> [String] {

        var workoutList = [String]()
        workoutList.append(workoutCalories)

        if workoutSwimLaps != "laps".localized(0.0) && WorkoutDistance.shouldDisplaySwimLaps(workoutType: workout.type) {
            workoutList.append(workoutSwimLaps)
        }

        return workoutList
    }

    private func persistWorkout() {
        WorkoutInformation.persistWorkout(workout)

        self.workoutSaved = true

        Vibration.success.vibrate()
    }
}
