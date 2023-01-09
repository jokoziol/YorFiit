import SwiftUI
import CoreLocation

struct WorkoutCardItem: View {

    private let defaultWidth = UIScreen.main.bounds.width - 32

    private let workoutItem: WorkoutItem

    private let workoutText: String
    private var workoutDate: String

    @State private var workoutCoordinates = [CLLocationCoordinate2D]()

    @State private var showProgressIndicator = false
    @State private var showWorkoutView = false

    init(_ workoutItem: WorkoutItem) {
        self.workoutItem = workoutItem
        self.workoutDate = ""

        let workoutName = WorkoutType.getName(type: workoutItem.type) ?? "--"

        if workoutItem.distanceInMeters <= 0.0 {
            self.workoutText = workoutName
        } else {
            let workoutDistance = WorkoutDistance.getDistanceString(distanceInMeters: workoutItem.distanceInMeters)
            let swimmingLaps = WorkoutDistance.getSwimLaps(distanceInMeters: workoutItem.distanceInMeters)

            self.workoutText = "\(workoutName)  \u{2022}  \(WorkoutDistance.shouldDisplayDistance(workoutType: workoutItem.type) ? workoutDistance : swimmingLaps)"
        }

        self.workoutDate = workoutItem.startDate.getDateString()
    }

    var body: some View {

        VStack {
            VStack {

                HStack {
                    Text(workoutText)
                            .frame(width: (defaultWidth - 56) * 0.7, height: nil, alignment: .leading)
                            .padding(16.0)

                    if showProgressIndicator {
                        ProgressView()
                                .progressViewStyle(.circular)
                                .frame(width: (defaultWidth - 56) * 0.3, height: nil, alignment: .trailing)
                                .padding(16.0)
                    } else {
                        Text(workoutDate)
                                .frame(width: (defaultWidth - 56) * 0.3, height: nil, alignment: .trailing)
                                .padding(16.0)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                    }
                }
            }
                    .background(Color(UIColor.secondarySystemBackground))
        }
                .cornerRadius(ScreenConfig.cornerRadius).frame(width: ScreenConfig.screenWidth, height: nil, alignment: .center)
                .sheet(isPresented: $showWorkoutView) {

                    if workoutCoordinates.isEmpty {
                        WorkoutSummaryWithoutLocationView(workoutItem)
                    } else {
                        WorkoutSummaryView(workoutItem, workoutCoordinates: workoutCoordinates)
                    }
                }
                .onTapGesture {
                    loadItem()
                }
    }

    private func loadItem() {

        if showProgressIndicator {
            return
        }

        let group = DispatchGroup()
        group.enter()

        self.showProgressIndicator = true
        self.workoutCoordinates.removeAll()

        DispatchQueue.global().async {
            
            for item: WorkoutItemLocation in self.workoutItem.locations ?? []{
                self.workoutCoordinates.append(CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude))
            }

            group.leave()
        }

        group.notify(queue: .main) {
            self.showProgressIndicator = false
            self.showWorkoutView.toggle()
        }
    }
}
