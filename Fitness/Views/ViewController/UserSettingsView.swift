import SwiftUI

struct UserSettingsView: View {

    @State private var username: String = ""

    var body: some View {
        VStack {

            Form {
                TextField("settingsUsername".localized(), text: $username).keyboardType(.default).onChange(of: username) { newValue in
                    UserInformation.persistUsername(username: newValue)
                }

                if !SettingsInformation.canGetBodyMass() {
                    BodyMeasurementTextView("settingsWeight".localized(), UserInformation.getFormattedWeight(), .weight) {
                        UserInformation.persistWeight(weight: $0)
                    }
                }

                BodyMeasurementTextView("settingsHeight".localized(), UserInformation.getFormattedHeightFromMeters(UserInformation.getHeight()), .height) {
                    UserInformation.persistHeight(height: $0)
                }
            }
        }
                .frame(width: ScreenConfig.screenWidth, height: nil, alignment: .center)
                .onDisappear {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshProfile"), object: nil)
                }
                .onAppear {
                    username = UserInformation.getUsername()
                }
    }
}