import Foundation

enum KeyError: Error {

    case creationFailed
    case deletionPrivateKeyFailed
    case deletionPublicKeyFailed
    case resetFailed
    case encryptionFailed
    case decryptionFailed

}

extension KeyError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .creationFailed: return "errorCreationFailed".localized()
        case .deletionPrivateKeyFailed: return "errorDeletionPrivateFailed".localized()
        case .deletionPublicKeyFailed: return "errorDeletionPublicFailed".localized()
        case .resetFailed: return "errorResetFailed".localized()
        case .encryptionFailed: return "errorEncryptionFailed".localized()
        case .decryptionFailed: return "errorDecryptionFailed".localized()
        }
    }
}