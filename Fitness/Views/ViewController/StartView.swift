import SwiftUI

struct StartView: View {

    @StateObject private var errorHandling: ErrorHandling = ErrorHandling.shared

    var body: some View {

        VStack {
            TabView {
                HomeView().tabItem {
                    Label("home".localized(), systemImage: "house.fill")
                }
                StatisticsView().tabItem {
                    Label("statistics".localized(), systemImage: "chart.xyaxis.line")
                }
                ProfileView().tabItem {
                    Label("profile".localized(), systemImage: "person.fill")
                }
            }
        }
                .alert(errorHandling.errorTitle, isPresented: self.$errorHandling.showErrorTitle) {

                }
                .alert(errorHandling.errorTitle, isPresented: self.$errorHandling.showErrorTitleAndMessage) {

                } message: {
                    Text(errorHandling.errorMessage)
                }
    }
}