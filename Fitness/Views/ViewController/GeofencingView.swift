import SwiftUI

struct GeofencingView: View {

    @ObservedObject private var store: LocationStore = LocationStore()

    @State private var showProgressIndicator: Bool = false

    var body: some View {
        VStack {

            if self.store.locationList.isEmpty && !showProgressIndicator {

                Text("noSavedLocations".localized()).foregroundColor(.secondary)

            } else if self.showProgressIndicator {

                ProgressView().progressViewStyle(.circular)

            } else {
                List(self.store.locationList, id: \.self) { locationName in

                    Text(locationName.name).swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            locationName.remove()

                            withAnimation(.default) {
                                store.remove(locationName.locationId)
                            }
                        } label: {
                            Label("delete".localized(), systemImage: "trash")
                        }
                    }
                }
            }
        }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {

                        NavigationLink(destination: AddGeofenceLocationView()) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .onAppear {
                    loadLocations()
                }
                .navigationTitle("geofencing".localized()).navigationBarTitleDisplayMode(.inline)
    }

    private func loadLocations() {

        self.showProgressIndicator = true

        let group: DispatchGroup = DispatchGroup()
        group.enter()

        DispatchQueue.global().async {
            store.load()
            group.leave()
        }

        group.notify(queue: .global()) {
            self.showProgressIndicator = false
        }
    }
}