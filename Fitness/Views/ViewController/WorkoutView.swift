import SwiftUI
import CoreMotion

struct WorkoutView: View {

    @Environment(\.dismiss) private var dismiss

    private let timer = Timer.publish(every: 1.0, tolerance: 0.5, on: .main, in: .common).autoconnect()

    private let displayDistance: Bool

    private let workoutType: Int
    private let startDate: Date

    private let screenPadding: Double
    private let headerItemWidth: Double

    private let regionEnteredPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: NSNotification.Name("regionEntered"))

    @State private var timeString: String = ""
    @State private var firstSecondaryHeaderString: String = ""
    @State private var secondSecondaryHeaderString: String = ""
    @State private var thirdSecondaryHeaderString: String = ""
    @State private var caloriesString: String = ""

    init() {

        guard let workout = WorkoutInformation.workout else {
            fatalError("WorkoutHelper cannot be nil")
        }

        workoutType = workout.type
        startDate = workout.startDate

        displayDistance = WorkoutDistance.shouldDisplayDistance(workoutType: workoutType)
        let itemsPerRow = displayDistance ? 2 : 1

        screenPadding = ScreenConfig.mediumSpacing
        headerItemWidth = ScreenConfig().calculateWidthForEachItem(containerWidth: (ScreenConfig.screenWidth - screenPadding), itemsPerRow)
    }

    var body: some View {
        VStack {

            GeometryReader { proxy in
                VStack {
                    Text(timeString).font(.system(size: proxy.size.width * 0.2).bold())

                    Spacer().frame(height: ScreenConfig.largeSpacing)

                    HStack {
                        if displayDistance {
                            Text(firstSecondaryHeaderString).frame(width: headerItemWidth, alignment: .center).font(.title)
                        }
                        Text(caloriesString).frame(width: headerItemWidth, alignment: .center).font(.title)
                    }

                    Spacer().frame(height: ScreenConfig.smallSpacing)

                    if displayDistance {
                        HStack {
                            Text(secondSecondaryHeaderString).frame(width: headerItemWidth, alignment: .center).font(.title)
                            Text(thirdSecondaryHeaderString).frame(width: headerItemWidth, alignment: .center).font(.title)
                        }
                    }

                    Spacer()
                }
            }

            Button(role: .destructive, action: {
                stopWorkout()
            }, label: {
                Text("stopWorkout".localized())
            })
        }
                .padding(screenPadding)
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

        let distance: Double = workout.distance ?? 0.0
        let timeDifference: Int = Int(Date().timeIntervalSince(startDate))

        let hours: String = String(format: "%.02d", locale: .current, timeDifference.hours)
        let minutes: String = String(format: "%.02d", locale: .current, timeDifference.minutes)
        let seconds: String = String(format: "%.02d", locale: .current, timeDifference.seconds)

        if WorkoutDistance.shouldDisplayDistance(workoutType: workoutType) {
            firstSecondaryHeaderString = WorkoutDistance.getDistanceString(distanceInMeters: distance)
            secondSecondaryHeaderString = WorkoutDistance.getAverageDistanceString(distanceInMeters: distance, time: timeDifference) ?? "--"
            thirdSecondaryHeaderString = WorkoutTime.getPace(timeInSeconds: timeDifference, distanceInMeters: distance) ?? "--"
        }

        let calories: String? = WorkoutCalories.getCaloriesString(workoutType: workoutType, timeInSeconds: timeDifference, distanceInMeters: distance)
        timeString = "\(hours):\(minutes):\(seconds)"
        caloriesString = calories ?? "--"

        if #available(iOS 16.1, *) {
            LiveActivityHelper.updateWorkoutActivity(distanceString: firstSecondaryHeaderString, paceString: thirdSecondaryHeaderString, caloriesString: calories)
        }
    }

    private func stopWorkout() {
        if #available(iOS 16.1, *) {
            LiveActivityHelper.stopWorkoutActivity()
        }

        dismiss()
    }
}