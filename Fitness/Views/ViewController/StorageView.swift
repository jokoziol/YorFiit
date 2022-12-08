import SwiftUI

struct StorageView: View {

    @State private var showProgressIndicator: Bool = false

    @State private var storageSize: String = "loadStorageSize".localized()

    var body: some View {

        VStack {

            Spacer()

            Text(storageSize)

            Spacer().frame(height: 16.0)

            Button(role: .destructive) {
                resetUserData()
            } label: {
                Text("reset".localized())
            }

            Spacer()
        }
                .navigationTitle("storage".localized())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if showProgressIndicator {
                            ProgressView().progressViewStyle(.circular)
                        }
                    }
                }
                .frame(width: ScreenConfig.cardWidth)
                .onAppear {
                    getStorageSize()
                }
                .interactiveDismissDisabled(showProgressIndicator)
    }

    private func resetUserData() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        showProgressIndicator = true

        DispatchQueue.global().async {

            do {
                try SecurityUtils.reset()
            } catch {
                Vibration.error.vibrate()
                ErrorHandling.shared.showError("errorTitle".localized())
                return
            }

            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            showProgressIndicator = false

            do {
                try SecurityUtils.generateKeys()
                UserInformation.launchedFirstTime()
            } catch {
                Vibration.error.vibrate()
                ErrorHandling.shared.showError("errorTitle".localized())
                return
            }

            restartApplication()
        }
    }

    private func restartApplication() {

        let window = UIApplication.shared.connectedScenes
                .filter {
                    $0.activationState == .foregroundActive
                }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)

        if window == nil {
            return
        }

        guard let rootView = window!.rootViewController else {
            return
        }

        let navigationController = UIHostingController(rootView: StartView())
        navigationController.view.frame = rootView.view.frame
        navigationController.view.layoutIfNeeded()

        Vibration.success.vibrate()

        UIView.transition(with: window!, duration: 0.2, options: .transitionCrossDissolve) {
            window!.rootViewController = navigationController
        }
    }

    private func getStorageSize() {

        DispatchQueue.global().async {
            let savedDataSizeInBytes = KeychainService.getUsedSpace() + UserDefaults.standard.getUsedStorageSize()
            let formattedSize = ByteCountFormatter.string(fromByteCount: savedDataSizeInBytes, countStyle: .memory)
            let formattedFreeSize = ByteCountFormatter.string(fromByteCount: UIDevice.current.getFreeDiskSpace(), countStyle: .memory)

            storageSize = "usedMemory".localized(formattedSize, formattedFreeSize)
        }
    }
}
