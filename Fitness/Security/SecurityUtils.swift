import Foundation

class SecurityUtils {

    class func generateKeys() throws {

        if existKeys() {
            return
        }

        do {
            try generateECCKey()
        } catch {
            throw KeyError.creationFailed
        }
    }

    //MARK: -

    private class func generateECCKey() throws {

        let access: SecAccessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .privateKeyUsage,
                nil)!

        let attributes: NSDictionary = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                                        kSecAttrKeySizeInBits: 256,
                                        kSecAttrTokenID: kSecAttrTokenIDSecureEnclave,
                                        kSecPrivateKeyAttrs: [
                                            kSecAttrIsPermanent: true,
                                            kSecAttrApplicationTag: "com.github.jokoziol.fitness.key".data(using: .utf8)!,
                                            kSecAttrAccessControl: access
                                        ]]

        var error: Unmanaged<CFError>?
        guard let _ = SecKeyCreateRandomKey(attributes, &error) else {
            throw error!.takeRetainedValue() as Error
        }
    }

    private class func getPrivateKey() -> SecKey? {

        let attributes: [String: Any] = [kSecClass as String: kSecClassKey,
                                         kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                                         kSecAttrApplicationTag as String: "com.github.jokoziol.fitness.key".data(using: .utf8)!,
                                         kSecReturnRef as String: true]

        var reference: AnyObject?

        guard SecItemCopyMatching(attributes as CFDictionary, &reference) == errSecSuccess else {
            return nil
        }

        return (reference as! SecKey)
    }

    public class func deletePrivateKey() throws {

        let privateKeyAttributes: [String: Any] = [kSecClass as String: kSecClassKey,
                                                   kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                                                   kSecAttrApplicationTag as String: "com.github.jokoziol.fitness.key".data(using: .utf8)!,
                                                   kSecReturnRef as String: true]

        guard SecItemDelete(privateKeyAttributes as CFDictionary) == errSecSuccess else {
            throw KeyError.deletionPrivateKeyFailed
        }
    }

    private class func getPublicKey() -> SecKey? {

        guard let privateKey: SecKey = getPrivateKey() else {
            return nil
        }

        return SecKeyCopyPublicKey(privateKey)
    }

    //MARK: -

    public class func encrypt(textToEncrypt: String?) throws -> String? {
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM

        guard let publicKey: SecKey = getPublicKey() else {
            throw KeyError.encryptionFailed
        }

        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            return nil
        }

        guard textToEncrypt != nil else {
            return nil
        }

        guard let textToEncryptData: Data = textToEncrypt?.data(using: .utf8) else {
            return nil
        }

        var error: Unmanaged<CFError>?
        guard let cipherText: CFData = SecKeyCreateEncryptedData(publicKey,
                algorithm,
                textToEncryptData as CFData,
                &error)
        else {
            throw error!.takeRetainedValue() as Error
        }

        return (cipherText as Data).base64EncodedString()
    }

    public class func decrypt(textToDecrypt: String?) throws -> String? {
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM

        guard let privateKey: SecKey = getPrivateKey() else {
            throw KeyError.decryptionFailed
        }

        guard textToDecrypt != nil else {
            return nil
        }

        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            return nil
        }

        guard let textToDecryptData: Data = Data.init(base64Encoded: textToDecrypt!) else {
            return nil
        }

        var error: Unmanaged<CFError>?
        guard let clearText: CFData = SecKeyCreateDecryptedData(privateKey,
                algorithm,
                textToDecryptData as CFData,
                &error)
        else {
            throw error!.takeRetainedValue() as Error
        }

        guard let returnString: String = String(data: (clearText as Data), encoding: .utf8) else {
            return nil
        }

        return returnString
    }

    //MARK: -

    public class func reset() throws {

        UserInformation.resetInProgress(true)

        let defaults: UserDefaults = UserDefaults.standard

        defaults.dictionaryRepresentation().keys.forEach { key in
            defaults.removeObject(forKey: key)
        }

        KeychainService.removeAll()

        do {
            try deletePrivateKey()
        } catch {
            UserInformation.resetInProgress(false)
            throw KeyError.resetFailed
        }

        UserInformation.resetInProgress(false)
    }

    private class func existKeys() -> Bool {
        return getPublicKey() != nil
    }
}