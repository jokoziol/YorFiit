import SwiftUI

struct ChooseWorkoutView: View {

    @Environment(\.dismiss) private var dismiss

    private let workoutList: [WorkoutSection] = WorkoutConfig.shared.workoutSections

    var body: some View {

        NavigationView {
            VStack {
                List {
                    ForEach(workoutList) { sectionItem in

                        Section {

                            ForEach(sectionItem.workouts) { workout in
                                Button(workout.name.localized()) {
                                    startWorkout(workoutId: workout.name)
                                }
                                        .foregroundColor(.primary)
                            }

                        } header: {
                            Text(sectionItem.name.localized())
                        }
                    }
                }
            }
                    .navigationTitle("chooseWorkout".localized())
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        HealthStore.requestPermission()
                    }
        }
    }

    private func startWorkout(workoutId: String) {

        WorkoutInformation.startWorkout(workoutType: workoutId)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "startWorkout"), object: nil)

        if #available(iOS 16.1, *) {
            LiveActivityHelper.startWorkoutActivity(WorkoutType.getName(type: workoutId) ?? "--")
        }

        dismiss()
    }
}