import SwiftUI
import MapKit
import ActivityKit

struct HomeView: View {

    class HomeObservableObject: ObservableObject {
        @Published var workoutCoordinates = [CLLocationCoordinate2D]()
        @Published var workoutHeartRate: String = "--"
        @Published var workoutSteps: String = "steps".localized(0.0)
    }

    @State private var showChooseWorkout: Bool = false
    @State private var showWorkoutFinished: Bool = false
    @State private var showWorkoutView: Bool = false
    @State private var workoutStarted: Bool = WorkoutInformation.workoutStarted()

    @StateObject private var locationManager: LocationManager = LocationManager()
    @StateObject private var homeObservableObject: HomeObservableObject = HomeObservableObject()

    @State private var workout: WorkoutItem?

    @State private var workoutCoordinates: [CLLocationCoordinate2D]?

    private let startWorkoutPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: NSNotification.Name("startWorkout"))
    private let regionEnteredPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: NSNotification.Name("regionEntered"))
    private let refreshPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: NSNotification.Name("refresh"))
    private let enterForegroundPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)

    private let columns = [GridItem(spacing: 0, alignment: .center), GridItem(spacing: 0, alignment: .center)]

    private let minBatteryLevel: Float = 30.0

    private var workoutTime: String {
        return WorkoutTime.getTimeString(timeInSeconds: WorkoutTime.getDailyTime())
    }
    private var workoutDistance: String {
        return WorkoutDistance.getDistanceString(distanceInMeters: WorkoutDistance.getDailyDistance())
    }

    private var temporaryWorkoutName: String {
        return WorkoutType.getName(type: WorkoutType.getTemporaryWorkoutType()) ?? "--"
    }
    private var temporaryWorkoutItemOne: String {
        return WorkoutTime.getTimeString(timeInSeconds: WorkoutTime.getTemporaryTime())
    }
    private var temporaryWorkoutItemTwo: String {

        let type: String? = WorkoutType.getTemporaryWorkoutType()

        if WorkoutDistance.shouldDisplayDistance(workoutType: type) ||
                   WorkoutDistance.shouldDisplaySwimLaps(workoutType: type) {

            return WorkoutDistance.getAverageDistanceString(distanceInMeters: WorkoutDistance.getTemporaryDistance(), time: WorkoutTime.getTemporaryTime()) ?? "--"
        }

        return "--"
    }
    private var temporaryWorkoutItemThree: String {

        let type: String? = WorkoutType.getTemporaryWorkoutType()
        let timeInSeconds: Int = WorkoutTime.getTemporaryTime()
        let distanceInMeters: Double = WorkoutDistance.getTemporaryDistance()

        if WorkoutDistance.shouldDisplayDistance(workoutType: type) {
            return WorkoutDistance.getDistanceString(distanceInMeters: distanceInMeters)
        }

        if WorkoutDistance.shouldDisplaySwimLaps(workoutType: type) {
            return WorkoutDistance.getSwimLaps(distanceInMeters: distanceInMeters)
        }

        return WorkoutCalories.getCaloriesString(workoutType: type, timeInSeconds: timeInSeconds, distanceInMeters: distanceInMeters) ?? "--"
    }

    var body: some View {
        NavigationView {
            VStack {

                ScrollView {

                    LazyVGrid(columns: self.columns, spacing: 0) {
                        CardGroup(title: "time".localized(), text: workoutTime)
                        CardGroup(title: "stepsTitle".localized(), text: homeObservableObject.workoutSteps)
                        CardGroup(title: "distance".localized(), text: workoutDistance)

                        if SettingsInformation.showHeartRate() {
                            CardGroup(title: "heartRate".localized(), text: homeObservableObject.workoutHeartRate)
                        }
                    }

                    // Last workout view
                    if SettingsInformation.showLastTraining() && WorkoutType.getTemporaryWorkoutType() != nil {
                        MapViewGroup(title: temporaryWorkoutName,
                                itemOneText: temporaryWorkoutItemOne,
                                itemTwoText: temporaryWorkoutItemTwo,
                                itemThreeText: temporaryWorkoutItemThree,
                                workoutCoordinates: homeObservableObject.workoutCoordinates,
                                SettingsInformation.canSaveCoordinates() && WorkoutDistance.shouldDisplayDistance(workoutType: WorkoutType.getTemporaryWorkoutType()))
                    }
                }
            }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {

                            if !workoutStarted {
                                Button {

                                    if UIDevice.current.getBatteryLevel() >= minBatteryLevel {
                                        self.showChooseWorkout.toggle()
                                    } else {
                                        ErrorHandling.shared.showError("batteryTooLowTitle".localized(), "batteryTooLowMessage".localized(minBatteryLevel))
                                    }

                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    }
                    .navigationTitle("home".localized())
                    .sheet(isPresented: $showChooseWorkout, onDismiss: {
                        if WorkoutInformation.workoutStarted() {
                            self.showWorkoutView.toggle()
                        }
                    }, content: {
                        ChooseWorkoutView()
                    })
                    .sheet(isPresented: $showWorkoutFinished) {

                        if (self.workoutCoordinates?.count ?? 0) > 2 {
                            if workout != nil {
                                WorkoutSummaryView(workout!, workoutCoordinates: self.workoutCoordinates!)
                            }
                        } else {
                            if workout != nil {
                                WorkoutSummaryWithoutLocationView(workout!)
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showWorkoutView, onDismiss: {
                        stopWorkout()
                    }, content: {
                        WorkoutView()
                    })
                    .onReceive(startWorkoutPublisher) { _ in
                        self.workoutStarted = true
                        homeObservableObject.workoutCoordinates.removeAll()

                        refreshView()
                        locationManager.startUpdating()
                    }
                    .onReceive(refreshPublisher, perform: { _ in
                        refreshView()
                    })
                    .onReceive(enterForegroundPublisher, perform: { _ in
                        refreshView()
                    })
                    .onAppear {
                        refreshView()

                        if WorkoutInformation.workoutStarted() {
                            showWorkoutView.toggle()
                        }
                    }
        }
    }

    private func refreshView() {
        getStepsFromCurrentDay()
        getBodyWeight()
        getHeartRate()

        if homeObservableObject.workoutCoordinates.isEmpty { //Avoid fetching coordinates every time when the view refreshes
            getSavedCoordinates()
        }
    }

    private func stopWorkout() {
        let (workout, coordinates): (WorkoutItem?, [CLLocationCoordinate2D]?) = WorkoutInformation.stopWorkout()
        locationManager.stopUpdating()

        self.workoutStarted = false
        self.workout = workout
        self.workoutCoordinates = coordinates

        showWorkoutFinished.toggle()
    }

    private func getSavedCoordinates() {

        if !SettingsInformation.showLastTraining() ||
                   WorkoutInformation.workoutStarted() ||
                   !WorkoutDistance.shouldDisplayDistance(workoutType: WorkoutType.getTemporaryWorkoutType()) {

            homeObservableObject.workoutCoordinates.removeAll()
            return
        }

        if let coordinates = workoutCoordinates {
            homeObservableObject.workoutCoordinates = coordinates
            return
        }

        var coordinateList = [CLLocationCoordinate2D]()
        let group: DispatchGroup = DispatchGroup()
        group.enter()

        DispatchQueue.global().async {
            coordinateList = WorkoutLocation.loadCoordinates(id: "")
            group.leave()
        }

        group.notify(queue: .main) {

            if WorkoutInformation.workoutStarted() {
                homeObservableObject.workoutCoordinates.removeAll()
                return
            }

            homeObservableObject.workoutCoordinates = coordinateList
        }
    }

    private func getBodyWeight() {

        if !SettingsInformation.canGetBodyMass() {
            return
        }

        DispatchQueue.main.async {

            HealthStore.getBodyMass { bodyMass in

                if bodyMass > 0.0 {
                    UserInformation.persistWeight(weight: bodyMass)
                }
            }
        }
    }

    private func getHeartRate() {
        if !SettingsInformation.showHeartRate() {
            return
        }

        let group = DispatchGroup()
        group.enter()

        let (startDate, endDate) = Date().getFullDay()
        var heartRate = 0

        DispatchQueue.main.async {
            HealthStore.getHeartRate(startDate: startDate, endDate: endDate) { newHeartRate in
                heartRate = Int(newHeartRate)

                group.leave()
            }
        }

        group.notify(queue: .main) {
            homeObservableObject.workoutHeartRate = (heartRate == 0 ? "--" : "\(heartRate) BPM")
        }
    }

    private func getStepsFromCurrentDay() {

        let startTime: Int = WorkoutTime.getTimerStartTime()
        let startDate: Date = Date(timeIntervalSince1970: TimeInterval(startTime))

        if Calendar.current.isDate(startDate, inSameDayAs: Date()) {

            HealthStore.persistStepsFromCurrentDay {

                DispatchQueue.main.async {
                    homeObservableObject.workoutSteps = WorkoutSteps.getStepsString(steps: WorkoutSteps.getDailySteps())
                }
            }

        } else {
            DispatchQueue.global().async {
                HealthStore.persistAllSteps()
            }
        }
    }
}
