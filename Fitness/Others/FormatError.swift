import Foundation

enum FormatError: Error {
    case badFormat
}

extension FormatError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .badFormat: return "errorBadFormat".localized()
        }
    }
}