import Foundation

class ErrorHandling: ObservableObject {
    static let shared: ErrorHandling = ErrorHandling()

    @Published var showErrorTitle: Bool = false
    @Published var errorTitle: String = ""

    @Published var showErrorTitleAndMessage: Bool = false
    @Published var errorMessage: String = ""

    //MARK: -

    public func showError(_ title: String) {

        DispatchQueue.main.async {
            self.errorTitle = title
            self.showErrorTitle.toggle()
        }
    }

    public func showError(_ title: String, _ message: String) {

        DispatchQueue.main.async {
            self.errorTitle = title
            self.errorMessage = message
            self.showErrorTitleAndMessage.toggle()
        }
    }
}