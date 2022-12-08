import SwiftUI

struct SettingsView: View {

    private let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0"

    var body: some View {

        NavigationView {
            VStack {
                List {

                    Section {
                        NavigationLink(destination: UserSettingsView()) {
                            Text("userSettings".localized())
                        }
                        NavigationLink(destination: AdvancedSettingsView()) {
                            Text("advancedSettings".localized())
                        }
                    } header: {
                        Text("user".localized())
                    }

                    Section {
                        NavigationLink(destination: StorageView()) {
                            Text("storage".localized())
                        }
                        NavigationLink(destination: GeofencingView()) {
                            Text("geofencing".localized())
                        }
                    } header: {
                        Text("other".localized())
                    }

                    Section {
                        Link(destination: URL(string: "https://github.com/jokoziol/YorFiit")!) {
                            Text("openSourceProject".localized())
                        }
                    } header: {
                        Text("GitHub")
                    }
                }

                Text("version".localized(appVersion))
            }
                    .navigationTitle("settings".localized())
                    .navigationBarTitleDisplayMode(.inline)
        }
    }
}
