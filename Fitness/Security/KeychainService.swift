import Foundation
import Security

class KeychainService {

    private static let errorTitle: String = "keychainErrorTitle"

    //MARK: -

    public class func persist(service: String, account: String, data: String) {
        do {
            try persistData(service: service, account: account, data: data)
        } catch let error {
            ErrorHandling.shared.showError(errorTitle.localized(), error.localizedDescription)
            return
        }
    }

    private class func update(service: String, account: String, data: String) {
        do {
            try updateData(service: service, account: account, data: data)
        } catch let error {
            ErrorHandling.shared.showError(errorTitle.localized(), error.localizedDescription)
            return
        }
    }

    public class func load(service: String, account: String) -> String? {
        do {
            return try loadData(service: service, account: account)
        } catch let error {

            if error as? KeychainServiceError != KeychainServiceError.failureOnRead {
                ErrorHandling.shared.showError(errorTitle.localized(), error.localizedDescription)
            }

            return nil
        }
    }

    public class func delete(service: String, account: String) {
        removeData(service: service, account: account)
    }

    //MARK: -

    private class func persistData(service: String, account: String, data: String) throws {

        if load(service: service, account: account) != nil {
            update(service: service, account: account, data: data)
            return
        }

        var encryptedData: String?

        do {
            encryptedData = try SecurityUtils.encrypt(textToEncrypt: data)
        } catch {
            return
        }

        guard encryptedData != nil else {
            return
        }

        guard let dataFromString: Data = encryptedData!.data(using: .utf8, allowLossyConversion: false) else {
            return
        }

        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrAccount as String: account,
                                            kSecAttrService as String: service,
                                            kSecValueData as String: dataFromString,
                                            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]


        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)

        guard status == errSecSuccess else {

            switch status {
            case errSecDiskFull: throw KeychainServiceError.diskFull
            case errSecMemoryError: throw KeychainServiceError.memoryError

            default: throw KeychainServiceError.failureOnWrite
            }
        }
    }

    private class func updateData(service: String, account: String, data: String) throws {

        var encryptedData: String?

        do {
            encryptedData = try SecurityUtils.encrypt(textToEncrypt: data)
        } catch {
            return
        }

        guard encryptedData != nil else {
            return
        }

        let dataFromString: Data? = encryptedData!.data(using: .utf8, allowLossyConversion: false)

        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrAccount as String: account,
                                            kSecAttrService as String: service,
                                            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]

        let status: OSStatus = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueData as String: dataFromString] as CFDictionary)

        guard status == errSecSuccess else {
            switch status {
            case errSecDiskFull: throw KeychainServiceError.diskFull
            case errSecMemoryError: throw KeychainServiceError.memoryError

            default: throw KeychainServiceError.failureOnWrite
            }
        }
    }

    private class func loadData(service: String, account: String) throws -> String? {

        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrAccount as String: account,
                                            kSecAttrService as String: service,
                                            kSecMatchLimit as String: kSecMatchLimitOne,
                                            //kSecReturnAttributes as String : true,
                                            kSecReturnData as String: true]

        var dataRefType: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataRefType)

        guard status == errSecSuccess else {
            switch status {
            case errSecAuthFailed: throw KeychainServiceError.authError
                    //case errSecItemNotFound: throw KeychainServiceError.itemNotFound

            default: throw KeychainServiceError.failureOnRead
            }
        }

        var keyChainContent: String?

        if let retrievedData: Data = dataRefType as? Data {
            keyChainContent = String(data: retrievedData, encoding: .utf8)
        }

        do {
            return try SecurityUtils.decrypt(textToDecrypt: keyChainContent)
        } catch {
            return nil
        }
    }

    private class func removeData(service: String, account: String) {

        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrAccount as String: account,
                                            kSecAttrService as String: service]

        guard SecItemDelete(keychainQuery as CFDictionary) == errSecSuccess else {
            return
        }
    }

    //MARK: -

    public class func getAll(targetService: String) -> [String] {

        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: targetService,
                                    kSecMatchLimit as String: kSecMatchLimitAll,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

        var result: AnyObject?
        let lastResult = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        var keyList = [String]()

        if lastResult != noErr {
            return keyList
        }

        for item in (result as? Array<Dictionary<String, Any>>)! {

            if let key = item[kSecAttrAccount as String] as? String,
               let service = item[kSecAttrService as String] as? String {

                if service == targetService {
                    keyList.append(key)
                }
            }
        }

        return keyList
    }

    public class func getUsedSpace() -> Int64 {

        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitAll,
                                    kSecReturnData as String: true,
                                    kSecReturnRef as String: true]

        var result: AnyObject?
        let lastResult = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        var resultInBytes: Int64 = 0

        if lastResult != noErr {
            return resultInBytes
        }

        for item in (result as? Array<Dictionary<String, Any>>)! {

            if let data = item[kSecValueData as String] as? Data {
                resultInBytes += Int64(data.count)
            }
        }

        return resultInBytes
    }

    //MARK: -

    public class func removeAll() {
        let spec: NSDictionary = [kSecClass: kSecClassGenericPassword]
        let status = SecItemDelete(spec)

        guard status == errSecSuccess else {
            return
        }
    }

    public class func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?$%&()#*-+<>"

        if length <= 0 {
            return ""
        }

        return String((0..<length).map { _ in
            letters.randomElement()!
        })
    }
}