import SwiftUI
import LocalAuthentication

@main
struct FitnessApp: App {

    private let errorTitle: String?
    private let errorMessage: String?

    init() {
        if UserInformation.launchedForFirstTime() || UserInformation.resetInProgress() {
            try? SecurityUtils.reset()
            UserInformation.launchedFirstTime()
        }

        if !LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {

            try? SecurityUtils.reset()

            errorTitle = "errorPasscodeNotSetTitle"
            errorMessage = "errorPasscodeNotSetMessage"
            return
        }

        do {
            try SecurityUtils.generateKeys()
        } catch {
            errorTitle = "errorTitle"
            errorMessage = "errorInit"
            return
        }

        errorTitle = nil
        errorMessage = nil
    }

    var body: some Scene {
        WindowGroup {

            if self.errorTitle != nil && self.errorMessage != nil {
                ErrorView(title: self.errorTitle!.localized(), message: self.errorMessage!.localized())
            } else {
                StartView()
            }
        }
    }
}
