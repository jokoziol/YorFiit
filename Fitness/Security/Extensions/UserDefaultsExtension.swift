import Foundation

extension UserDefaults {

    public func getUsedStorageSize() -> Int64 {

        var size: Int64 = 0

        dictionaryRepresentation().keys.forEach { key in
            size += Int64(string(forKey: key)?.utf8.count ?? 0)
        }

        return size
    }

    //MARK: -

    public func persistEncrypted(_ data: String?, forKey: String) {

        do {
            guard let encryptedText: String = try SecurityUtils.encrypt(textToEncrypt: data) else {
                set(nil, forKey: forKey)
                return
            }

            set(encryptedText, forKey: forKey)
        } catch {
            set(nil, forKey: forKey)
        }
    }

    public func getDecrypted(_ forKey: String) -> String? {
        do {
            return try SecurityUtils.decrypt(textToDecrypt: string(forKey: forKey))
        } catch {
            return nil
        }
    }

    public func persistEncrypted(_ data: Int, forKey: String) {

        do {
            guard let encryptedNumber: String = try SecurityUtils.encrypt(textToEncrypt: "\(data)") else {
                set(nil, forKey: forKey)
                return
            }

            set(encryptedNumber, forKey: forKey)
        } catch {
            set(nil, forKey: forKey)
        }
    }

    public func getDecryptedInteger(_ forKey: String) -> Int {

        do {

            guard let decryptedNumber: String = try SecurityUtils.decrypt(textToDecrypt: string(forKey: forKey)) else {
                return 0
            }

            return Int(decryptedNumber) ?? 0
        } catch {
            return 0
        }
    }

    public func persistEncrypted(_ data: Double, forKey: String) {

        do {

            guard let encryptedDouble: String = try SecurityUtils.encrypt(textToEncrypt: "\(data)") else {

                set(nil, forKey: forKey)
                return
            }

            set(encryptedDouble, forKey: forKey)
        } catch {
            set(nil, forKey: forKey)
        }
    }

    public func getDecryptedDouble(_ forKey: String) -> Double {

        do {
            guard let decryptedDouble: String = try SecurityUtils.decrypt(textToDecrypt: string(forKey: forKey)) else {
                return 0.0
            }

            return Double(decryptedDouble) ?? 0.0
        } catch {
            return 0.0
        }
    }
}