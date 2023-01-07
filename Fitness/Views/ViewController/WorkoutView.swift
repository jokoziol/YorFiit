import SwiftUI
import CoreMotion

struct WorkoutView: View {

    @Environment(\.dismiss) private var dismiss

    private let timer = Timer.publish(every: 1.0, tolerance: 0.5, on: .main, in: .common).autoconnect()

    private let columns: [GridItem]

    private let displayDistance: Bool

    private let workoutType: String
    private let startDate: Date

    private let regionEnteredPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: NSNotification.Name("regionEntered"))

    @State private var workoutPaused = false

    @State private var timeString: String = ""
    @State private var firstSecondaryHeaderString: String = ""
    @State private var secondSecondaryHeaderString: String = ""
    @State private var thirdSecondaryHeaderString: String = ""
    @State private var caloriesString: String = ""

    init() {

        guard let workout = WorkoutInformation.workout else {
            fatalError("WorkoutHelper cannot be nil")
        }

        self.workoutType = workout.type
        self.startDate = workout.startDate

        self.displayDistance = WorkoutDistance.shouldDisplayDistance(workoutType: workoutType) || WorkoutDistance.shouldDisplaySwimLaps(workoutType: workoutType)

        self.columns = self.displayDistance ? [GridItem(alignment: .center), GridItem(alignment: .center)] : [GridItem(alignment: .center)]
    }

    var body: some View {
        VStack {

            GeometryReader { proxy in
                VStack {
                    Text(timeString).font(.system(size: proxy.size.width * 0.2).bold())

                    Spacer().frame(height: ScreenConfig.largeSpacing)

                    LazyVGrid(columns: self.columns) {

                        if displayDistance {
                            Text(firstSecondaryHeaderString).font(.title)
                        }
                        Text(caloriesString).font(.title)

                        if displayDistance {
                            Text(secondSecondaryHeaderString).font(.title)
                            Text(thirdSecondaryHeaderString).font(.title)
                        }
                    }

                    Spacer()
                }
            }

            HStack {
                Button(action: {
                    pauseWorkout()
                }, label: {

                    if self.workoutPaused {
                        Text("resumeWorkout".localized()).foregroundColor(.orange)
                    } else {
                        Text("pauseWorkout".localized()).foregroundColor(.orange)
                    }
                })

                Spacer()

                Button(role: .destructive, action: {
                    stopWorkout()
                }, label: {
                    Text("stopWorkout".localized())
                })
            }
        }
                .padding(ScreenConfig.mediumSpacing)
                .onReceive(timer) { _ in
                    updateUI()
                }
                .onReceive(regionEnteredPublisher) { _ in
                    stopWorkout()
                }
                .navigationBarBackButtonHidden(true)
    }

    private func updateUI() {

        guard let workout = WorkoutInformation.workout else {
            return
        }

        if workout.pausedWorkout {
            return
        }

        let distance: Double = workout.distance ?? 0.0
        let timeDifference: Int = Int(Date().timeIntervalSince(startDate)) - workout.pausedWorkoutTime

        let hours: String = String(format: "%.02d", locale: .current, timeDifference.hours)
        let minutes: String = String(format: "%.02d", locale: .current, timeDifference.minutes)
        let seconds: String = String(format: "%.02d", locale: .current, timeDifference.seconds)

        if self.displayDistance {
            firstSecondaryHeaderString = WorkoutDistance.getDistanceString(distanceInMeters: distance)
            secondSecondaryHeaderString = WorkoutDistance.getAverageDistanceString(distanceInMeters: distance, time: timeDifference) ?? "--"
            thirdSecondaryHeaderString = WorkoutTime.getPace(timeInSeconds: timeDifference, distanceInMeters: distance) ?? "--"
        }

        let calories: String? = WorkoutCalories.getCaloriesString(workoutType: workoutType, timeInSeconds: timeDifference, distanceInMeters: distance)
        timeString = "\(hours):\(minutes):\(seconds)"
        caloriesString = calories ?? "--"

        if #available(iOS 16.1, *) {
            LiveActivityHelper.updateWorkoutActivity(timeString: timeString, distanceString: firstSecondaryHeaderString, paceString: thirdSecondaryHeaderString, caloriesString: calories)
        }
    }

    private func pauseWorkout() {
        guard let workout = WorkoutInformation.workout else {
            return
        }

        workout.pausedWorkout = !workout.pausedWorkout
        self.workoutPaused = workout.pausedWorkout

        if workout.pausedWorkout {
            workout.pausedWorkoutDate = Date()

            return
        }

        workout.pausedWorkoutTime += Int(workout.pausedWorkoutDate?.timeIntervalSinceNow ?? 0) * (-1)
        workout.pausedWorkoutDate = nil
    }

    private func stopWorkout() {
        if #available(iOS 16.1, *) {
            LiveActivityHelper.stopWorkoutActivity()
        }

        if self.workoutPaused, let workout = WorkoutInformation.workout {
            workout.pausedWorkoutTime += Int(workout.pausedWorkoutDate?.timeIntervalSinceNow ?? 0) * (-1)
            workout.pausedWorkoutDate = nil
        }

        dismiss()
    }
}