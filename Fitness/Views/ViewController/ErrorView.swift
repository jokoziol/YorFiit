import SwiftUI

struct ErrorView: View {

    private let title: String
    private let message: String

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    var body: some View {

        VStack {

            Spacer().frame(height: 24.0)

            Text(self.title).font(.largeTitle.bold()).multilineTextAlignment(.center)

            Spacer().frame(height: 16.0)

            Text(self.message).font(.body).multilineTextAlignment(.center)

            Spacer()
        }
    }
}