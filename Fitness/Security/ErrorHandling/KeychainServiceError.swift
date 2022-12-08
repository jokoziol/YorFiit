import Foundation

enum KeychainServiceError: Error {

    case failureOnRead
    case failureOnWrite
    case authError
    case memoryError
    case diskFull
    case itemNotFound

}

extension KeychainServiceError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .failureOnRead: return "errorKeychainFailureRead".localized()
        case .failureOnWrite: return "errorKeychainFailureWrite".localized()
        case .authError: return "errorKeychainAuth".localized()
        case .memoryError: return "errorKeychainMemory".localized()
        case .diskFull: return "errorKeychainDiskFull".localized()
        case .itemNotFound: return "errorKeychainItemNotFound".localized()
        }
    }
}