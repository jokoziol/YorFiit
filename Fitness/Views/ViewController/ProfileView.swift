import SwiftUI
import CoreLocation

struct ProfileView: View {

    private let defaultWidth: CGFloat = UIScreen.main.bounds.width - 16
    private let refreshPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: NSNotification.Name("refreshProfile"))

    @StateObject private var workoutStore: WorkoutStore = WorkoutStore()

    @State private var workoutCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()

    @State private var workoutId: String = ""

    @State private var username: String = UserInformation.getUsername()
    @State private var weight: String = UserInformation.getFormattedWeight()
    @State private var height: String = UserInformation.getFormattedHeight()

    @State private var showSettingsView: Bool = false
    @State private var showProgressIndicator: Bool = false

    var body: some View {

        NavigationView {
            VStack {
                VStack {

                    Text(username)
                            .frame(width: defaultWidth, height: nil, alignment: .leading)
                            .lineLimit(1)

                    Spacer()

                    HStack {
                        Text(weight).frame(width: ((defaultWidth - 8) / 2), height: nil, alignment: .leading).lineLimit(1)
                        Text(height).frame(width: ((defaultWidth - 8) / 2), height: nil, alignment: .trailing).lineLimit(1)
                    }

                    List {
                        ForEach(workoutStore.workoutItems) { item in

                            WorkoutCardItem(item).swipeActions(edge: .trailing, allowsFullSwipe: true) {

                                        Button(role: .destructive) {
                                            removeWorkout(item)

                                            withAnimation(.default) {
                                                workoutStore.remove(item.workoutId ?? "")
                                            }

                                        } label: {
                                            Label("delete".localized(), systemImage: "trash")
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
                        }
                    }
                            .allowsHitTesting(!showProgressIndicator)
                            .listStyle(PlainListStyle())
                }
                        .blur(radius: showProgressIndicator ? 3.25 : 0.0)
            }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {

                            if showProgressIndicator {
                                ProgressView().progressViewStyle(.circular)
                            } else {
                                Button {
                                    self.showSettingsView.toggle()
                                } label: {
                                    Image(systemName: "gear")
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showSettingsView) {
                        SettingsView()
                    }
                    .navigationTitle("profile".localized()).navigationBarTitleDisplayMode(.inline)
                    .onReceive(refreshPublisher, perform: { _ in

                        self.username = UserInformation.getUsername()
                        self.weight = UserInformation.getFormattedWeight()
                        self.height = UserInformation.getFormattedHeight()
                    })
                    .onAppear {
                        self.username = UserInformation.getUsername()
                        self.weight = UserInformation.getFormattedWeight()
                        self.height = UserInformation.getFormattedHeight()

                        DispatchQueue.main.async {
                            workoutStore.load()
                        }
                    }
        }
    }

    private func removeWorkout(_ workoutItem: WorkoutItem) {

        if showProgressIndicator {
            return
        }

        let group = DispatchGroup()
        group.enter()

        self.showProgressIndicator = true

        DispatchQueue.global().async {

            WorkoutInformation.deleteWorkout(id: workoutItem.workoutId ?? "")

            group.leave()
        }

        group.notify(queue: .main) {
            self.showProgressIndicator = false
        }
    }
}
