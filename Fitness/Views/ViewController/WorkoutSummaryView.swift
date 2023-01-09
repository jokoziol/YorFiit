import SwiftUI
import MapKit

struct WorkoutSummaryView: View {

    @State private var workoutSaved: Bool = false
    @State private var workoutSaveInProgress: Bool = false

    private let screenItemWidth: Double

    // MARK: -
    private let workout: WorkoutItem
    private let workoutCoordinates: [CLLocationCoordinate2D]

    // MARK: - Workout description
    private let workoutName: String
    private let workoutTime: String
    private let workoutDistance: String
    private let workoutSwimLaps: String
    private let workoutCalories: String
    private let workoutPace: String
    private let workoutAverageDistance: String

    // MARK: -

    init(_ workout: WorkoutItem, workoutCoordinates: [CLLocationCoordinate2D]) {
        self.workoutCoordinates = workoutCoordinates
        
        var workoutItemLocations: [WorkoutItemLocation] = []
        
        for item in workoutCoordinates{
            workoutItemLocations.append(WorkoutItemLocation(latitude: Double(item.latitude), longitude: Double(item.longitude)))
        }
        
        self.workout = WorkoutItem(workoutId: workout.workoutId,
                                   placeNames: workout.placeNames,
                                   startDate: workout.startDate,
                                   type: workout.type,
                                   timeInSeconds: workout.timeInSeconds,
                                   calories: workout.calories,
                                   distanceInMeters: workout.distanceInMeters,
                                   locations: workoutItemLocations)

        self.workoutName = WorkoutType.getName(type: workout.type) ?? "--"
        self.workoutDistance = WorkoutDistance.getDistanceString(distanceInMeters: workout.distanceInMeters)
        self.workoutSwimLaps = WorkoutDistance.getSwimLaps(distanceInMeters: workout.distanceInMeters)
        self.workoutPace = WorkoutTime.getPace(timeInSeconds: workout.timeInSeconds, distanceInMeters: workout.distanceInMeters) ?? "--"
        self.workoutAverageDistance = WorkoutDistance.getAverageDistanceString(distanceInMeters: workout.distanceInMeters, time: workout.timeInSeconds) ?? "--"
        self.workoutCalories = "cal".localized(workout.calories)
        self.workoutTime = WorkoutTime.getTimeString(timeInSeconds: workout.timeInSeconds)

        self.screenItemWidth = ScreenConfig().calculateWidthForEachItem(3)
    }

    var body: some View {
        NavigationView {
            VStack {

                if self.workout.placeNames != nil {
                    Text(self.workout.placeNames!).frame(width: ScreenConfig.itemCardWidth, height: nil, alignment: .leading).lineLimit(2)
                    Spacer().frame(width: nil, height: ScreenConfig.itemSpacing, alignment: .leading)
                }

                HStack {
                    Text(workoutTime).frame(width: screenItemWidth, height: nil, alignment: .leading).lineLimit(1)
                    Text(workoutPace).frame(width: screenItemWidth, height: nil, alignment: .center).lineLimit(1)
                    Text(workoutDistance).frame(width: screenItemWidth, height: nil, alignment: .trailing).lineLimit(1)
                }
                HStack {
                    Text(workoutCalories).frame(width: screenItemWidth, height: nil, alignment: .leading).lineLimit(1)
                    Text("").frame(width: screenItemWidth, height: nil, alignment: .center)
                    Text(workoutAverageDistance).frame(width: screenItemWidth, height: nil, alignment: .trailing).lineLimit(1)
                }

                MapView(workoutCoordinates)
            }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {

                            //Persist workout
                            if (!workoutSaved && !workoutSaveInProgress) && workout.workoutId == nil {
                                Button {
                                    persistWorkout()
                                } label: {
                                    Image(systemName: "plus")
                                }

                                //Show Progress view (when the workout is saved)
                            } else if (!workoutSaved && workoutSaveInProgress) && workout.workoutId == nil {
                                ProgressView().progressViewStyle(.circular)
                            }
                        }
                    }
                    .navigationTitle(workoutName)
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {

                        if self.workout.workoutId == nil {
                            let group = DispatchGroup()
                            group.enter()

                            DispatchQueue.global().async {
                                WorkoutInformation.persistTemporaryWorkout(workout, workoutCoordinates)
                                group.leave()
                            }

                            group.notify(queue: .main) {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
                                LocationManager.shared.removeAll()
                            }
                        }
                    }
                    .interactiveDismissDisabled(workoutSaveInProgress)
        }
    }

    private func persistWorkout() {
        self.workoutSaveInProgress = true

        let group = DispatchGroup()
        group.enter()

        DispatchQueue.global().async {
            HealthStore.persistWorkout(workout)

            WorkoutInformation.persistWorkout(workout)

            self.workoutSaved = true
            self.workoutSaveInProgress = false

            Vibration.success.vibrate()
            group.leave()
        }

        group.notify(queue: .main) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
        }
    }
}
