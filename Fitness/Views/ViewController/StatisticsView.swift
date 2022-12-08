import SwiftUI

struct StatisticsView: View {

    private let defaultWidth: CGFloat = UIScreen.main.bounds.width - 8
    private let viewItems: [String] = ["week".localized(),
                                       "month".localized(),
                                       "months".localized(3),
                                       "months".localized(6)]

    @State private var selectedItem: Int = 0

    @State private var showBestWorkout: Bool = SettingsInformation.showBestWorkout()
    @State private var showWorkouts: Bool = SettingsInformation.showWorkout()

    @State private var showProgressIndicator: Bool = false

    @State private var timeText: String = ""
    @State private var stepsText: String = ""
    @State private var distanceText: String = ""

    @State private var bestWorkout: WorkoutItem?
    @State private var workouts = [WorkoutItem]()

    var body: some View {

        NavigationView {
            VStack {
                ScrollView {
                    Picker("", selection: $selectedItem) {
                        ForEach(0..<viewItems.count, id: \.self) {
                            Text(viewItems[$0])
                        }
                    }
                            .pickerStyle(.segmented).frame(width: defaultWidth, height: nil, alignment: .center)

                    CardGroup(title: "time".localized(), text: timeText)
                    CardGroup(title: "stepsTitle".localized(), text: stepsText)
                    CardGroup(title: "distance".localized(), text: distanceText)

                    if showBestWorkout, let workout = bestWorkout {
                        Spacer().frame(width: nil, height: 24.0, alignment: .leading)

                        Text("bestWorkout".localized())
                                .font(Font.title2.bold())
                                .frame(width: ScreenConfig.titleWidth, height: nil, alignment: .leading)

                        WorkoutCardItem(workout)
                    }

                    if showWorkouts && !workouts.isEmpty {

                        Spacer().frame(width: nil, height: 24.0, alignment: .leading)

                        Text("workoutList".localized())
                                .font(Font.title2.bold())
                                .frame(width: ScreenConfig.titleWidth, height: nil, alignment: .leading)

                        ForEach(workouts, id: \.self) {
                            WorkoutCardItem($0)
                        }
                    }
                }
            }
                    .navigationTitle("statistics".localized())
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            if showProgressIndicator {
                                ProgressView().progressViewStyle(.circular)
                            }
                        }
                    }
                    .onChange(of: selectedItem) { newValue in
                        switch newValue {
                        case 0: loadWeeklyStatistics()
                        case 1: loadMonthlyStatistics()
                        case 2: loadThreeMonthStatistics()
                        case 3: loadSixMonthStatistics()

                        default: return
                        }
                    }
                    .onAppear {
                        refreshView()
                    }
        }
    }

    private func refreshView() {
        self.showBestWorkout = SettingsInformation.showBestWorkout()
        self.showWorkouts = SettingsInformation.showWorkout()

        switch selectedItem {
        case 0: loadWeeklyStatistics()
        case 1: loadMonthlyStatistics()
        case 2: loadThreeMonthStatistics()
        case 3: loadSixMonthStatistics()

        default: return
        }
    }

    private func loadStatistics(timeInSeconds: Int, steps: Double, distanceInMeters: Double) {
        self.timeText = WorkoutTime.getTimeString(timeInSeconds: timeInSeconds)
        self.stepsText = WorkoutSteps.getStepsString(steps: steps)
        self.distanceText = WorkoutDistance.getDistanceString(distanceInMeters: distanceInMeters)
    }

    private func loadWeeklyStatistics() {
        loadStatistics(timeInSeconds: WorkoutTime.getWeeklyTime(),
                steps: WorkoutSteps.getWeeklySteps(),
                distanceInMeters: WorkoutDistance.getWeeklyDistance())

        getAllWorkouts(-1, true)
    }

    private func loadMonthlyStatistics() {
        loadStatistics(timeInSeconds: WorkoutTime.getMonthlyTime(1),
                steps: WorkoutSteps.getMonthlySteps(1),
                distanceInMeters: WorkoutDistance.getMonthlyDistance(1))

        getAllWorkouts(1, false)
    }

    private func loadThreeMonthStatistics() {
        loadStatistics(timeInSeconds: WorkoutTime.getMonthlyTime(3),
                steps: WorkoutSteps.getMonthlySteps(3),
                distanceInMeters: WorkoutDistance.getMonthlyDistance(3))

        getAllWorkouts(3, false)
    }

    private func loadSixMonthStatistics() {
        loadStatistics(timeInSeconds: WorkoutTime.getMonthlyTime(6),
                steps: WorkoutSteps.getMonthlySteps(6),
                distanceInMeters: WorkoutDistance.getMonthlyDistance(6))

        getAllWorkouts(6, false)
    }

    private func getAllWorkouts(_ from: Int, _ day: Bool) {

        showProgressIndicator = true

        workouts.removeAll()
        bestWorkout = nil

        let targetTimeInterval: TimeInterval

        if day {
            targetTimeInterval = Date().getDaysFromWeek().first?.timeIntervalSince1970 ?? 0.0
        } else {
            targetTimeInterval = Date().getDaysFromMonth(from).first?.timeIntervalSince1970 ?? 0.0
        }

        let group = DispatchGroup()
        group.enter()

        DispatchQueue.main.async {

            let workoutStore = WorkoutStore()
            workoutStore.load()

            for item in workoutStore.workoutItems {

                let timeInterval = item.startDate.timeIntervalSince1970

                if timeInterval > targetTimeInterval {
                    workouts.append(item)

                    //Best time or best distance
                    if item.distanceInMeters > (bestWorkout?.distanceInMeters ?? 0.0) || item.timeInSeconds > (bestWorkout?.timeInSeconds ?? 0) {
                        bestWorkout = item
                    }
                }
            }

            if bestWorkout != nil {
                workouts.removeAll {
                    $0 == bestWorkout
                }
            }

            group.leave()
        }

        group.notify(queue: .main) {
            showProgressIndicator = false
        }
    }
}